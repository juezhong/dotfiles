# ============================================================
# Brew Upgrade Toolkit for zsh
# 特性：
# 1. 显式打印所有文件系统操作（mkdir / mktemp / append / rm / mv / cp 等）
# 2. Ctrl+C 中断时删除本次临时日志，不写 history
# 3. 未安装包直接跳过
# 4. 自动识别 formula / cask
# 5. 按月归档日志
# 6. 提供 history 查询与统计
# 7. 必须显式指定包名，不支持无参数升级全部
# ============================================================

# -----------------------------
# 输出统一前缀
# -----------------------------
_brewup_log_info() {
    echo "[INFO] $*"
}

_brewup_log_fs() {
    echo "[FS] $*" >&2
}

_brewup_log_warn() {
    echo "[WARN] $*" >&2
}

_brewup_log_err() {
    echo "[ERR] $*" >&2
}

# -----------------------------
# 文件系统辅助函数（显式输出）
# -----------------------------
_brewup_mkdir() {
    local dir="$1"
    _brewup_log_fs "mkdir -p $dir"
    command mkdir -p "$dir"
}

_brewup_rm() {
    local target_path="$1"
    _brewup_log_fs "rm -f $target_path"
    command rm -f "$target_path"
}

_brewup_mv() {
    local src="$1"
    local dst="$2"
    _brewup_log_fs "mv $src -> $dst"
    command mv "$src" "$dst"
}

_brewup_cp() {
    local src="$1"
    local dst="$2"
    _brewup_log_fs "cp $src -> $dst"
    command cp "$src" "$dst"
}

_brewup_append_file() {
    local src="$1"
    local dst="$2"
    _brewup_log_fs "append $src >> $dst"
    command cat "$src" >> "$dst"
}

_brewup_mktemp() {
    local template="$1"
    local tmp
    tmp="$(command mktemp "$template")"
    _brewup_log_fs "mktemp -> $tmp"
    echo "$tmp"
}

_brewup_write_file() {
    local dst="$1"
    shift
    _brewup_log_fs "write -> $dst"
    printf "%s" "$*" > "$dst"
}

_brewup_append_text_line() {
    local dst="$1"
    local line="$2"
    _brewup_log_fs "append line -> $dst"
    printf "%s\n" "$line" >> "$dst"
}

_brewup_append_clean_transcript() {
    local src="$1"
    local dst="$2"

    [[ -f "$src" ]] || return 1

    _brewup_log_fs "append cleaned transcript $src >> $dst"

    ruby -e '
        s = File.binread(ARGV[0]).force_encoding("UTF-8")
        s.gsub!(/\r\n/, "\n")
        s.gsub!(/\e\][^\a]*(?:\a|\e\\)/, "")
        s.gsub!(/\e\[[0-9;]*G/, "\r")
        s.gsub!(/\e\[[0-9;]*K/, "\u0000")
        s.gsub!(/\e\[[0-9;?]*[ -\/]*[@-~]/, "")

        out = []
        line = +""
        cursor = 0
        rewriting = false

        s.each_char do |ch|
          case ch
          when "\r"
            cursor = 0
            rewriting = true
          when "\n"
            line = line[0, cursor] if rewriting && cursor < line.length
            out << line.rstrip
            line = +""
            cursor = 0
            rewriting = false
          when "\b"
            if cursor > 0
              line.slice!(cursor - 1)
              cursor -= 1
            end
          when "\u0000"
            line = line[0, cursor]
          else
            next if ch.ord < 32 || ch.ord == 127

            if cursor >= line.length
              line << (" " * (cursor - line.length)) << ch
            else
              line[cursor] = ch
            end

            cursor += 1
          end
        end

        out << line.rstrip unless line.empty?

        blank = false
        out.each do |entry|
          if entry.empty?
            next if blank
            puts
            blank = true
          else
            puts entry
            blank = false
          end
        end
    ' "$src" >> "$dst"
}

_brewup_user_declined_in_log() {
    local log_file="$1"

    [[ -f "$log_file" ]] || return 1

    sed -E $'s/\x1B\\[[0-9;]*[[:alpha:]]//g' "$log_file" 2>/dev/null | awk '
        /Do you want to proceed with the installation\?/ { asked=1 }
        NF {
            line=$0
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            last=line
        }
        END {
            last=tolower(last)
            exit !(asked && (last=="n" || last=="no"))
        }
    '
}

# -----------------------------
# 内部函数：基础目录
# -----------------------------
_brewup_base_dir() {
    echo "$HOME/Desktop/logs/upgrades"
}

# -----------------------------
# 内部函数：history 文件路径
# -----------------------------
_brewup_history_file() {
    echo "$(_brewup_base_dir)/history.tsv"
}

# -----------------------------
# 内部函数：批次 ID
# -----------------------------
_brewup_batch_id() {
    printf "batch-%s-%d-%04d\n" "$(date '+%Y%m%d%H%M%S')" "$$" "$RANDOM"
}

# -----------------------------
# 内部函数：按月目录
# -----------------------------
_brewup_month_dir() {
    echo "$(_brewup_base_dir)/$(date '+%Y-%m')"
}

# -----------------------------
# 初始化目录和 history 表头
# -----------------------------
_brewup_init_env() {
    local base_dir="$(_brewup_base_dir)"
    local month_dir="$(_brewup_month_dir)"
    local history_file="$(_brewup_history_file)"

    _brewup_mkdir "$base_dir"
    _brewup_mkdir "$month_dir"

    if [[ ! -f "$history_file" ]]; then
        _brewup_log_info "history 文件不存在，初始化表头"
        _brewup_write_file "$history_file" $'timestamp\tbatch_id\tpackage\ttype\ttrigger\ttriggered_by\tbefore\tafter\tresult\tmacos\tbrew\tlog_file\tfail_reason\n'
    fi
}

# -----------------------------
# 判断包类型
# 返回：
#   formula / cask / unknown
# -----------------------------
_brewup_detect_type() {
    local pkg="$1"

    if brew list --formula "$pkg" >/dev/null 2>&1; then
        echo "formula"
        return 0
    fi

    if brew list --cask "$pkg" >/dev/null 2>&1; then
        echo "cask"
        return 0
    fi

    echo "unknown"
    return 1
}

# -----------------------------
# 判断是否已安装
# -----------------------------
_brewup_is_installed() {
    local pkg="$1"
    local pkg_type
    pkg_type="$(_brewup_detect_type "$pkg")"
    [[ "$pkg_type" != "unknown" ]]
}

# -----------------------------
# 获取版本
# -----------------------------
_brewup_get_version() {
    local pkg="$1"
    local pkg_type="$2"
    local ver=""
    local opt_target=""

    if [[ "$pkg_type" == "cask" ]]; then
        ver="$(brew list --cask --versions "$pkg" 2>/dev/null | awk '{print $2}')"
    else
        opt_target="$(command readlink "/opt/homebrew/opt/$pkg" 2>/dev/null)"
        if [[ -n "$opt_target" ]]; then
            ver="${opt_target:t}"
        fi

        if [[ -z "$ver" ]]; then
            ver="$(
                brew info --json=v2 "$pkg" 2>/dev/null | \
                awk -F '"' '/"linked_keg":/ { if ($4 != "") { print $4; exit } }'
            )"
        fi

        if [[ -z "$ver" ]]; then
            ver="$(brew list --versions "$pkg" 2>/dev/null | awk '{print $NF}')"
        fi
    fi

    [[ -n "$ver" ]] && echo "$ver" || echo "unknown"
}

# -----------------------------
# 追加 history
# -----------------------------
_brewup_append_history() {
    local history_file="$(_brewup_history_file)"

    local timestamp="$1"
    local batch_id="$2"
    local pkg="$3"
    local pkg_type="$4"
    local trigger="$5"
    local triggered_by="$6"
    local before_version="$7"
    local after_version="$8"
    local result="$9"
    local macos_version="${10}"
    local brew_version="${11}"
    local log_file="${12}"
    local fail_reason="${13}"

    local safe_batch_id safe_trigger safe_triggered_by
    local safe_fail_reason safe_log_file safe_brew_version line
    safe_batch_id="${batch_id//$'\t'/ }"
    safe_trigger="${trigger//$'\t'/ }"
    safe_triggered_by="${triggered_by//$'\t'/ }"
    safe_fail_reason="${fail_reason//$'\t'/ }"
    safe_fail_reason="${safe_fail_reason//$'\n'/ }"
    safe_log_file="${log_file//$'\t'/ }"
    safe_brew_version="${brew_version//$'\t'/ }"

    line="$(printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" \
        "$timestamp" \
        "$safe_batch_id" \
        "$pkg" \
        "$pkg_type" \
        "$safe_trigger" \
        "$safe_triggered_by" \
        "$before_version" \
        "$after_version" \
        "$result" \
        "$macos_version" \
        "$safe_brew_version" \
        "$safe_log_file" \
        "$safe_fail_reason")"

    _brewup_log_fs "append history -> $history_file"
    printf "%s\n" "$line" >> "$history_file"
}

# -----------------------------
# 批量记录 formula 当前版本
# -----------------------------
_brewup_append_formula_versions() {
    local dst="$1"
    shift
    (( $# > 0 )) || return 0
    (( $+commands[brew] )) || return 1
    (( $+commands[jq] )) || return 1

    command brew info --json=v2 "$@" 2>/dev/null | command jq -r '
        .formulae[]? | [.name, ((.installed | length) > 0), (.linked_keg // "")] | @tsv
    ' | while IFS=$'\t' read -r pkg installed_flag linked_keg; do
        local current_version=""
        local opt_target=""

        if [[ "$installed_flag" != "true" ]]; then
            current_version="-"
        else
            opt_target="$(command readlink "/opt/homebrew/opt/$pkg" 2>/dev/null)"
            if [[ -n "$opt_target" ]]; then
                current_version="${opt_target:t}"
            elif [[ -n "$linked_keg" ]]; then
                current_version="$linked_keg"
            else
                current_version="$(brew list --versions "$pkg" 2>/dev/null | awk '{print $NF}')"
            fi

            [[ -n "$current_version" ]] || current_version="unknown"
        fi

        printf "formula\t%s\t%s\n" "$pkg" "$current_version"
    done >> "$dst"
}

# -----------------------------
# 批量记录 cask 当前版本
# -----------------------------
_brewup_append_cask_versions() {
    local dst="$1"
    shift
    (( $# > 0 )) || return 0
    (( $+commands[brew] )) || return 1
    (( $+commands[jq] )) || return 1

    command brew info --json=v2 --cask "$@" 2>/dev/null | command jq -r '
        .casks[]? |
        [
            .token,
            (
                if .installed == null then "-"
                elif (.installed | type) == "array" then (.installed | join(","))
                else (.installed | tostring)
                end
            )
        ] | @tsv
    ' | awk -F '\t' 'BEGIN { OFS="\t" } { print "cask", $1, ($2 == "" ? "-" : $2) }' >> "$dst"
}

# -----------------------------
# 构建候选包图：
# - 直接升级包
# - 已安装 dependents
# - 它们递归声明的依赖
# -----------------------------
_brewup_collect_candidate_graph() {
    local nodes_file="$1"
    local edges_file="$2"
    local dependents_file="$3"
    local pkg="$4"
    local pkg_type="$5"
    local dependent=""
    local dependent_type=""

    (( $+commands[brew] )) || return 1
    (( $+commands[jq] )) || return 1

    : > "$nodes_file"
    : > "$edges_file"
    : > "$dependents_file"

    local -a formula_queue cask_queue next_formula_queue next_cask_queue dependents
    local -a formula_roots cask_roots
    local parent="" child="" child_type=""
    local max_depth=2
    local current_depth=0
    typeset -A seen_formula seen_cask

    if [[ "$pkg_type" == "formula" ]]; then
        seen_formula[$pkg]=1
        formula_queue+=("$pkg")
        formula_roots+=("$pkg")
        printf "formula\t%s\n" "$pkg" >> "$nodes_file"

        dependents=("${(@f)$(command brew uses --installed "$pkg" 2>/dev/null)}")
        for dependent in "${dependents[@]}"; do
            [[ -n "$dependent" ]] || continue
            dependent_type="$(_brewup_detect_type "$dependent")"
            [[ "$dependent_type" == "unknown" ]] && continue

            printf "%s\t%s\n" "$dependent_type" "$dependent" >> "$dependents_file"

            if [[ "$dependent_type" == "formula" && -z "${seen_formula[$dependent]}" ]]; then
                seen_formula[$dependent]=1
                formula_queue+=("$dependent")
                formula_roots+=("$dependent")
                printf "formula\t%s\n" "$dependent" >> "$nodes_file"
            elif [[ "$dependent_type" == "cask" && -z "${seen_cask[$dependent]}" ]]; then
                seen_cask[$dependent]=1
                cask_queue+=("$dependent")
                cask_roots+=("$dependent")
                printf "cask\t%s\n" "$dependent" >> "$nodes_file"
            fi
        done
    else
        seen_cask[$pkg]=1
        cask_queue+=("$pkg")
        cask_roots+=("$pkg")
        printf "cask\t%s\n" "$pkg" >> "$nodes_file"
    fi

    formula_roots=("${(@u)formula_roots}")
    cask_roots=("${(@u)cask_roots}")

    for parent in "${formula_roots[@]}"; do
        while IFS= read -r child; do
            [[ -n "$child" ]] || continue
            printf "formula\t%s\n" "$child" >> "$nodes_file"
        done < <(command brew deps "$parent" 2>/dev/null)
    done

    while (( (${#formula_queue[@]} > 0 || ${#cask_queue[@]} > 0) && current_depth < max_depth )); do
        if (( ${#formula_queue[@]} > 0 )); then
            next_formula_queue=()

            while IFS=$'\t' read -r parent child child_type; do
                [[ -n "$parent" && -n "$child" ]] || continue
                printf "%s\t%s\n" "$parent" "$child" >> "$edges_file"

                if [[ "$child_type" == "formula" && -z "${seen_formula[$child]}" ]]; then
                    seen_formula[$child]=1
                    next_formula_queue+=("$child")
                    printf "formula\t%s\n" "$child" >> "$nodes_file"
                fi
            done < <(
                command brew info --json=v2 "${formula_queue[@]}" 2>/dev/null | command jq -r '
                    .formulae[]? |
                    .name as $parent |
                    .dependencies[]? |
                    [$parent, ., "formula"] | @tsv
                '
            )
        else
            next_formula_queue=()
        fi

        if (( ${#cask_queue[@]} > 0 )); then
            next_cask_queue=()

            while IFS=$'\t' read -r parent child child_type; do
                [[ -n "$parent" && -n "$child" && -n "$child_type" ]] || continue
                printf "%s\t%s\n" "$parent" "$child" >> "$edges_file"

                if [[ "$child_type" == "formula" && -z "${seen_formula[$child]}" ]]; then
                    seen_formula[$child]=1
                    next_formula_queue+=("$child")
                    printf "formula\t%s\n" "$child" >> "$nodes_file"
                elif [[ "$child_type" == "cask" && -z "${seen_cask[$child]}" ]]; then
                    seen_cask[$child]=1
                    next_cask_queue+=("$child")
                    printf "cask\t%s\n" "$child" >> "$nodes_file"
                fi
            done < <(
                command brew info --json=v2 --cask "${cask_queue[@]}" 2>/dev/null | command jq -r '
                    .casks[]? |
                    .token as $parent |
                    (
                        ((.depends_on.formula // [])[]? | [$parent, ., "formula"]),
                        ((.depends_on.cask // [])[]? | [$parent, ., "cask"])
                    ) | @tsv
                '
            )
        else
            next_cask_queue=()
        fi

        formula_queue=("${(@u)next_formula_queue}")
        cask_queue=("${(@u)next_cask_queue}")
        (( current_depth++ ))
    done

    command sort -u "$nodes_file" -o "$nodes_file"
    command sort -u "$edges_file" -o "$edges_file"
    command sort -u "$dependents_file" -o "$dependents_file"
}

# -----------------------------
# 根据候选包图记录版本快照
# -----------------------------
_brewup_write_version_snapshot() {
    local snapshot_file="$1"
    local nodes_file="$2"
    local pkg_type=""
    local pkg=""
    local -a formula_pkgs cask_pkgs

    [[ -f "$nodes_file" ]] || return 1

    : > "$snapshot_file"

    while IFS=$'\t' read -r pkg_type pkg; do
        [[ -n "$pkg" ]] || continue
        if [[ "$pkg_type" == "formula" ]]; then
            formula_pkgs+=("$pkg")
        elif [[ "$pkg_type" == "cask" ]]; then
            cask_pkgs+=("$pkg")
        fi
    done < "$nodes_file"

    formula_pkgs=("${(@u)formula_pkgs}")
    cask_pkgs=("${(@u)cask_pkgs}")

    _brewup_append_formula_versions "$snapshot_file" "${formula_pkgs[@]}" || return 1
    _brewup_append_cask_versions "$snapshot_file" "${cask_pkgs[@]}" || return 1
}

# -----------------------------
# 从快照中读取指定包版本
# -----------------------------
_brewup_snapshot_get_version() {
    local snapshot_file="$1"
    local pkg="$2"

    [[ -f "$snapshot_file" ]] || {
        echo "unknown"
        return 1
    }

    awk -F '\t' -v p="$pkg" '$2 == p { print $3; exit }' "$snapshot_file"
}

# -----------------------------
# 从本次 transcript 提取实际依赖归属
# -----------------------------
_brewup_collect_transcript_dependency_edges() {
    local transcript_file="$1"

    [[ -f "$transcript_file" ]] || return 0

    sed -nE 's/^==> Installing ([^[:space:]]+) dependency: (.+)$/\1\t\2/p' "$transcript_file" | \
        command sort -u
}

# -----------------------------
# 根据前后快照和包图记录 related history
# -----------------------------
_brewup_append_related_history() {
    local before_snapshot_file="$1"
    local after_snapshot_file="$2"
    local edges_file="$3"
    local dependents_file="$4"
    local direct_pkg="$5"
    local timestamp="$6"
    local batch_id="$7"
    local macos_version="$8"
    local brew_version="$9"
    local final_log_file="${10}"
    local transcript_file="${11}"

    [[ -f "$before_snapshot_file" && -f "$after_snapshot_file" ]] || return 0

    local pkg_type=""
    local pkg=""
    local before_version=""
    local after_version=""
    local parent=""
    local triggered_by=""
    local trigger=""
    local root=""
    local root_type=""
    local maybe_parent=""
    local -a root_candidates direct_changed_parents fallback_changed_roots
    local -a changed_formula_targets
    typeset -A snapshot_type before_map after_map dependent_map changed_map parent_map root_formula_closure runtime_parent_map transcript_parent_map

    while IFS=$'\t' read -r pkg_type pkg before_version; do
        [[ -n "$pkg" ]] || continue
        snapshot_type[$pkg]="$pkg_type"
        before_map[$pkg]="$before_version"
    done < "$before_snapshot_file"

    while IFS=$'\t' read -r pkg_type pkg after_version; do
        [[ -n "$pkg" ]] || continue
        after_map[$pkg]="$after_version"
        if [[ "$pkg" != "$direct_pkg" && "$after_version" != "${before_map[$pkg]}" ]]; then
            changed_map[$pkg]=1
        fi
    done < "$after_snapshot_file"

    while IFS=$'\t' read -r pkg_type pkg; do
        [[ -n "$pkg" ]] || continue
        dependent_map[$pkg]=1
        if [[ -n "${changed_map[$pkg]}" ]]; then
            root_candidates+=("$pkg")
        fi
    done < "$dependents_file"

    while IFS=$'\t' read -r pkg_type pkg after_version; do
        [[ "$pkg_type" == "formula" ]] || continue
        [[ "$pkg" == "$direct_pkg" && "${snapshot_type[$direct_pkg]}" != "formula" ]] && continue
        if [[ "$pkg" == "$direct_pkg" || -n "${changed_map[$pkg]}" ]]; then
            changed_formula_targets+=("$pkg")
        fi
    done < "$after_snapshot_file"

    changed_formula_targets=("${(@u)changed_formula_targets}")

    if [[ -f "$transcript_file" ]]; then
        while IFS=$'\t' read -r parent pkg; do
            [[ -n "$parent" && -n "$pkg" ]] || continue
            if [[ -n "${transcript_parent_map[$pkg]}" ]]; then
                transcript_parent_map[$pkg]+=$'\n'"$parent"
            else
                transcript_parent_map[$pkg]="$parent"
            fi
        done < <(_brewup_collect_transcript_dependency_edges "$transcript_file")
    fi

    if (( ${#changed_formula_targets[@]} > 0 )); then
        while IFS=$'\t' read -r parent pkg; do
            [[ -n "$parent" && -n "$pkg" ]] || continue
            if [[ -n "${runtime_parent_map[$pkg]}" ]]; then
                runtime_parent_map[$pkg]+=$'\n'"$parent"
            else
                runtime_parent_map[$pkg]="$parent"
            fi
        done < <(
            command brew info --json=v2 "${changed_formula_targets[@]}" 2>/dev/null | command jq -r '
                .formulae[]? |
                .name as $parent |
                .installed[-1].runtime_dependencies[]?.full_name |
                [$parent, .] | @tsv
            '
        )
    fi

    if [[ "${snapshot_type[$direct_pkg]}" == "formula" || "${snapshot_type[$direct_pkg]}" == "cask" ]]; then
        root_candidates+=("$direct_pkg")
    fi

    root_candidates=("${(@u)root_candidates}")

    for root in "${root_candidates[@]}"; do
        root_type="${snapshot_type[$root]}"
        if [[ "$root_type" == "formula" ]]; then
            while IFS= read -r pkg; do
                [[ -n "$pkg" ]] || continue
                root_formula_closure[$root:$pkg]=1
            done < <(command brew deps "$root" 2>/dev/null)
        fi
    done

    while IFS=$'\t' read -r parent pkg; do
        [[ -n "$parent" && -n "$pkg" ]] || continue
        if [[ -n "${parent_map[$pkg]}" ]]; then
            parent_map[$pkg]+=$'\n'"$parent"
        else
            parent_map[$pkg]="$parent"
        fi
    done < "$edges_file"

    while IFS=$'\t' read -r pkg_type pkg before_version; do
        [[ -n "$pkg" ]] || continue
        [[ "$pkg" == "$direct_pkg" ]] && continue

        after_version="${after_map[$pkg]}"
        [[ -n "$after_version" ]] || continue
        [[ "$after_version" == "$before_version" ]] && continue

        if [[ -n "${dependent_map[$pkg]}" ]]; then
            trigger="dependent"
            triggered_by="$direct_pkg"
        else
            trigger="dependency"
            triggered_by=""
            direct_changed_parents=()

            if [[ -n "${transcript_parent_map[$pkg]}" ]]; then
                for maybe_parent in ${(f)transcript_parent_map[$pkg]}; do
                    if [[ "$maybe_parent" == "$direct_pkg" || -n "${changed_map[$maybe_parent]}" ]]; then
                        direct_changed_parents+=("$maybe_parent")
                    fi
                done
            elif [[ -n "${runtime_parent_map[$pkg]}" ]]; then
                direct_changed_parents=("${(@f)runtime_parent_map[$pkg]}")
            elif [[ -n "${parent_map[$pkg]}" ]]; then
                for maybe_parent in ${(f)parent_map[$pkg]}; do
                    if [[ "$maybe_parent" == "$direct_pkg" || -n "${changed_map[$maybe_parent]}" ]]; then
                        direct_changed_parents+=("$maybe_parent")
                    fi
                done
            fi

            direct_changed_parents=("${(@ou)direct_changed_parents}")

            if (( ${#direct_changed_parents[@]} > 0 )); then
                triggered_by="${(j:,:)direct_changed_parents}"
            fi

            if [[ -z "$triggered_by" ]]; then
                fallback_changed_roots=()
                for root in "${root_candidates[@]}"; do
                    [[ "$root" == "$pkg" ]] && continue
                    if [[ -n "${root_formula_closure[$root:$pkg]}" ]]; then
                        fallback_changed_roots+=("$root")
                    fi
                done
                fallback_changed_roots=("${(@ou)fallback_changed_roots}")
                if (( ${#fallback_changed_roots[@]} > 0 )); then
                    triggered_by="${(j:,:)fallback_changed_roots}"
                fi
            fi

            if [[ -z "$triggered_by" && -n "${parent_map[$pkg]}" ]]; then
                parent="${${(f)parent_map[$pkg]}[1]}"
                [[ -n "$parent" ]] && triggered_by="$parent"
            fi

            [[ -n "$triggered_by" ]] || triggered_by="$direct_pkg"
        fi

        _brewup_append_history \
            "$timestamp" \
            "$batch_id" \
            "$pkg" \
            "${snapshot_type[$pkg]}" \
            "$trigger" \
            "$triggered_by" \
            "$before_version" \
            "$after_version" \
            "SUCCESS" \
            "${macos_version:-unknown}" \
            "${brew_version:-unknown}" \
            "$final_log_file" \
            "-"
    done < "$before_snapshot_file"
}

# -----------------------------
# 历史记录展示时翻译触发方式
# -----------------------------
_brewup_render_history() {
    local history_file="$1"

    awk -F '\t' '
        BEGIN { OFS = "\t" }
        NR == 1 { print; next }
        {
            if ($5 == "direct") $5 = "主动升级"
            else if ($5 == "dependency") $5 = "依赖连带升级"
            else if ($5 == "dependent") $5 = "依赖方连带升级"
            print
        }
    ' "$history_file"
}

# -----------------------------
# 单包升级
# -----------------------------
_brewup_one() {
    local batch_id="$1"
    local pkg="$2"

    _brewup_init_env

    if [[ -z "$pkg" ]]; then
        _brewup_log_err "包名不能为空"
        return 1
    fi

    if ! _brewup_is_installed "$pkg"; then
        _brewup_log_warn "包未安装，跳过: $pkg"
        return 2
    fi

    local base_dir month_dir history_file
    base_dir="$(_brewup_base_dir)"
    month_dir="$(_brewup_month_dir)"
    history_file="$(_brewup_history_file)"

    local pkg_type
    pkg_type="$(_brewup_detect_type "$pkg")"

    local start_time end_time
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"
    end_time=""

    local macos_version kernel_version arch_info brew_version
    macos_version="$(sw_vers -productVersion 2>/dev/null)"
    kernel_version="$(uname -sr 2>/dev/null)"
    arch_info="$(uname -m 2>/dev/null)"
    brew_version="$(brew --version 2>/dev/null | head -n1)"

    local before_version after_version
    before_version="unknown"
    after_version="unknown"

    local final_log_file tmp_log_file raw_output_file
    local candidate_nodes_file="" candidate_edges_file="" candidate_dependents_file=""
    local before_snapshot_file="" after_snapshot_file=""
    local relation_tracking_available=1
    final_log_file="$month_dir/${pkg}.log"
    tmp_log_file="$month_dir/.${pkg}.log.tmp.$$"
    raw_output_file="$(_brewup_mktemp "/tmp/brewup.${pkg}.XXXXXX")"
    candidate_nodes_file="$(_brewup_mktemp "/tmp/brewup.nodes.${pkg}.XXXXXX")"
    candidate_edges_file="$(_brewup_mktemp "/tmp/brewup.edges.${pkg}.XXXXXX")"
    candidate_dependents_file="$(_brewup_mktemp "/tmp/brewup.dependents.${pkg}.XXXXXX")"
    before_snapshot_file="$(_brewup_mktemp "/tmp/brewup.before.${pkg}.XXXXXX")"
    after_snapshot_file="$(_brewup_mktemp "/tmp/brewup.after.${pkg}.XXXXXX")"

    local interrupted=0
    local user_cancelled=0
    local trap_installed=0
    local result="FAILED"
    local fail_reason="-"

    _brewup_cleanup_interrupt() {
        interrupted=1
        echo
        _brewup_log_warn "检测到 Ctrl+C，已中断升级并清理本次日志: $pkg"
        _brewup_rm "$tmp_log_file"
        _brewup_rm "$raw_output_file"
        _brewup_rm "$candidate_nodes_file"
        _brewup_rm "$candidate_edges_file"
        _brewup_rm "$candidate_dependents_file"
        _brewup_rm "$before_snapshot_file"
        _brewup_rm "$after_snapshot_file"
        trap - INT
        return 130
    }

    trap _brewup_cleanup_interrupt INT
    trap_installed=1

    if ! _brewup_collect_candidate_graph \
        "$candidate_nodes_file" \
        "$candidate_edges_file" \
        "$candidate_dependents_file" \
        "$pkg" \
        "$pkg_type"; then
        relation_tracking_available=0
        _brewup_log_warn "无法构建候选包图，将只记录直接升级包"
        _brewup_write_file "$candidate_nodes_file" "$(printf "%s\t%s\n" "$pkg_type" "$pkg")"
        _brewup_write_file "$candidate_edges_file" ""
        _brewup_write_file "$candidate_dependents_file" ""
    fi

    if ! _brewup_write_version_snapshot "$before_snapshot_file" "$candidate_nodes_file"; then
        relation_tracking_available=0
        _brewup_log_warn "无法生成升级前快照，将只记录直接升级包"
        before_version="$(_brewup_get_version "$pkg" "$pkg_type")"
        _brewup_write_file "$candidate_nodes_file" "$(printf "%s\t%s\n" "$pkg_type" "$pkg")"
        _brewup_write_file "$candidate_edges_file" ""
        _brewup_write_file "$candidate_dependents_file" ""
        _brewup_write_file "$before_snapshot_file" "$(printf "%s\t%s\t%s\n" "$pkg_type" "$pkg" "$before_version")"
    fi

    before_version="$(_brewup_snapshot_get_version "$before_snapshot_file" "$pkg")"
    [[ -n "$before_version" ]] || before_version="$(_brewup_get_version "$pkg" "$pkg_type")"

    {
        echo "============================================================"
        echo "Package      : $pkg"
        echo "Package Type : $pkg_type"
        echo "Start Time   : $start_time"
        echo "Log File     : $final_log_file"
        echo "============================================================"
        echo
        echo "System Information"
        echo "------------------------------------------------------------"
        echo "macOS Version: ${macos_version:-unknown}"
        echo "Kernel       : ${kernel_version:-unknown}"
        echo "Architecture : ${arch_info:-unknown}"
        echo "Homebrew     : ${brew_version:-unknown}"
        echo
        echo "Package Version"
        echo "------------------------------------------------------------"
        echo "Before       : ${before_version:-unknown}"
        echo
        echo "Upgrade Log"
        echo "------------------------------------------------------------"
    } 2>&1 | tee -a "$tmp_log_file"

    if [[ "$pkg_type" == "cask" ]]; then
        _brewup_log_info "执行命令: brew upgrade --cask $pkg"
        script -q "$raw_output_file" brew upgrade --cask "$pkg"
        if [[ "$?" -eq 0 ]]; then
            result="SUCCESS"
        else
            result="FAILED"
        fi
    else
        _brewup_log_info "执行命令: brew upgrade $pkg"
        script -q "$raw_output_file" brew upgrade "$pkg"
        if [[ "$?" -eq 0 ]]; then
            result="SUCCESS"
        else
            result="FAILED"
        fi
    fi

    if [[ "$interrupted" -eq 1 ]]; then
        return 130
    fi

    if [[ "$result" == "FAILED" ]] && {
        grep -qiE 'cancelled|canceled' "$tmp_log_file" "$raw_output_file" 2>/dev/null ||
        _brewup_user_declined_in_log "$tmp_log_file" ||
        _brewup_user_declined_in_log "$raw_output_file"
    }; then
        user_cancelled=1
    fi

    if [[ "$user_cancelled" -eq 1 ]]; then
        _brewup_log_warn "用户取消升级，已删除本次日志且不写入 history: $pkg"
        _brewup_rm "$tmp_log_file"
        _brewup_rm "$raw_output_file"
        _brewup_rm "$candidate_nodes_file"
        _brewup_rm "$candidate_edges_file"
        _brewup_rm "$candidate_dependents_file"
        _brewup_rm "$before_snapshot_file"
        _brewup_rm "$after_snapshot_file"

        if [[ "$trap_installed" -eq 1 ]]; then
            trap - INT
        fi

        return 3
    fi

    _brewup_append_clean_transcript "$raw_output_file" "$tmp_log_file"

    if [[ "$result" == "SUCCESS" ]]; then
        if _brewup_write_version_snapshot "$after_snapshot_file" "$candidate_nodes_file"; then
            after_version="$(_brewup_snapshot_get_version "$after_snapshot_file" "$pkg")"
        else
            relation_tracking_available=0
            _brewup_log_warn "无法生成升级后快照，将跳过关联升级记录"
        fi
    fi

    [[ -n "$after_version" && "$after_version" != "unknown" ]] || after_version="$(_brewup_get_version "$pkg" "$pkg_type")"

    if [[ "$result" == "FAILED" ]]; then
        fail_reason="$(
            tail -n 30 "$raw_output_file" 2>/dev/null | \
            sed '/^[[:space:]]*$/d' | \
            grep -E 'Error|error|Failed|failed|No such|invalid|denied|mismatch|already|not installed|No available formula|No available cask' | \
            tail -n 5 | \
            tr '\n' '|' | \
            sed 's/|$//'
        )"
        [[ -z "$fail_reason" ]] && fail_reason="see log for details"
    else
        fail_reason="-"
    fi

    end_time="$(date '+%Y-%m-%d %H:%M:%S')"

    {
        echo
        echo "Upgrade Result"
        echo "------------------------------------------------------------"
        echo "Result       : $result"
        echo "After        : ${after_version:-unknown}"
        echo "Fail Reason  : $fail_reason"
        echo
        echo "End Time     : $end_time"
        echo "============================================================"
        echo
    } 2>&1 | tee -a "$tmp_log_file"

    _brewup_append_file "$tmp_log_file" "$final_log_file"

    _brewup_append_history \
        "$start_time" \
        "$batch_id" \
        "$pkg" \
        "$pkg_type" \
        "direct" \
        "$pkg" \
        "$before_version" \
        "$after_version" \
        "$result" \
        "${macos_version:-unknown}" \
        "${brew_version:-unknown}" \
        "$final_log_file" \
        "$fail_reason"

    if [[ "$result" == "SUCCESS" && "$relation_tracking_available" -eq 1 ]]; then
        _brewup_append_related_history \
            "$before_snapshot_file" \
            "$after_snapshot_file" \
            "$candidate_edges_file" \
            "$candidate_dependents_file" \
            "$pkg" \
            "$start_time" \
            "$batch_id" \
            "${macos_version:-unknown}" \
            "${brew_version:-unknown}" \
            "$final_log_file" \
            "$tmp_log_file"
    fi

    _brewup_rm "$tmp_log_file"
    _brewup_rm "$raw_output_file"
    _brewup_rm "$candidate_nodes_file"
    _brewup_rm "$candidate_edges_file"
    _brewup_rm "$candidate_dependents_file"
    _brewup_rm "$before_snapshot_file"
    _brewup_rm "$after_snapshot_file"

    if [[ "$trap_installed" -eq 1 ]]; then
        trap - INT
    fi

    echo "📦 $pkg: $before_version -> $after_version ($result)"

    [[ "$result" == "SUCCESS" ]]
}

# -----------------------------
# 对外：升级一个或多个指定包
# -----------------------------
_brewup_print_usage() {
    echo "用法: brewup <package1> [package2 ...]"
    echo "示例:"
    echo "  brewup chatgpt"
    echo "  brewup git wget"
    echo
    echo "说明:"
    echo "  - 必须显式传入包名"
    echo "  - 不支持无参数升级全部包"
    echo "  - 支持 -h, --help 查看帮助"
    echo
    echo "历史命令:"
    echo "  brewup-history             查看完整历史"
    echo "  brewup-history-pkg <pkg>   查看指定包历史"
    echo "  brewup-history-tail [n]    查看最近 n 条历史，默认 10"
    echo "  brewup-stats               查看历史统计"
}

brewup() {
    if [[ $# -eq 0 ]]; then
        _brewup_print_usage
        return 1
    fi

    case "$1" in
        -h|--help)
            _brewup_print_usage
            return 0
            ;;
        -*)
            echo "错误: 不支持的选项: $1" >&2
            _brewup_print_usage >&2
            return 1
            ;;
    esac

    local overall_rc=0
    local batch_id
    local pkg=""
    batch_id="$(_brewup_batch_id)"

    for pkg in "$@"; do
        echo "🚀 开始处理: $pkg"
        _brewup_one "$batch_id" "$pkg"
        local rc=$?

        case "$rc" in
            0)
                ;;
            2)
                echo "ℹ️  已跳过未安装包: $pkg"
                ;;
            3)
                echo "ℹ️  用户取消升级: $pkg"
                ;;
            130)
                echo "🛑 用户中断，停止后续包升级"
                return 130
                ;;
            *)
                overall_rc=1
                ;;
        esac

        echo
    done

    return "$overall_rc"
}

# -----------------------------
# brewup 补全：仅提示可更新的包
# -----------------------------
_brewup_outdated_packages() {
    local -a formulae casks candidates filtered
    local pkg=""
    local i=0
    typeset -A selected_map

    (( $+commands[brew] )) || return 1

    formulae=("${(@f)$(command brew outdated --formula --quiet 2>/dev/null)}")
    casks=("${(@f)$(command brew outdated --cask --quiet 2>/dev/null)}")
    candidates=("${(@u)formulae[@]}" "${(@u)casks[@]}")
    candidates=("${(@u)candidates}")

    for (( i = 2; i < CURRENT; i++ )); do
        [[ -n "${words[i]}" ]] || continue
        selected_map["${words[i]}"]=1
    done

    for pkg in "${candidates[@]}"; do
        [[ -n "$pkg" ]] || continue
        [[ -n "${selected_map[$pkg]}" ]] && continue
        filtered+=("$pkg")
    done

    (( ${#filtered[@]} > 0 )) || return 1

    compadd "$@" -- "${filtered[@]}"
}

_brewup_completion() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[show usage]' \
        '*:outdated package:_brewup_outdated_packages'
}

_brewup_history_packages() {
    local history_file
    local -a packages

    history_file="$(_brewup_history_file)"
    [[ -f "$history_file" ]] || return 1

    packages=("${(@u)${(@f)$(awk -F '\t' 'NR > 1 && $3 != "" { print $3 }' "$history_file" 2>/dev/null)}}")
    (( ${#packages[@]} > 0 )) || return 1

    compadd "$@" -- "${packages[@]}"
}

_brewup_history_pkg_completion() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[show usage]' \
        '1:history package:_brewup_history_packages'
}

if (( $+functions[compdef] )); then
    compdef _brewup_completion brewup
    compdef _brewup_history_pkg_completion brewup-history-pkg
fi

# -----------------------------
# 查看完整历史
# -----------------------------
brewup-history() {
    case "${1:-}" in
        -h|--help)
            echo "用法: brewup-history"
            echo "说明: 查看全部升级历史记录"
            return 0
            ;;
    esac

    local history_file="$(_brewup_history_file)"

    if [[ ! -f "$history_file" ]]; then
        echo "历史表不存在: $history_file"
        return 1
    fi

    _brewup_render_history "$history_file" | column -t -s $'\t'
}

# -----------------------------
# 查看指定包历史
# -----------------------------
brewup-history-pkg() {
    case "${1:-}" in
        -h|--help)
            echo "用法: brewup-history-pkg <package>"
            echo "说明: 查看指定包的全部升级历史"
            return 0
            ;;
    esac

    local history_file="$(_brewup_history_file)"
    local pkg="$1"

    if [[ -z "$pkg" ]]; then
        echo "用法: brewup-history-pkg <package>"
        return 1
    fi

    if [[ ! -f "$history_file" ]]; then
        echo "历史表不存在: $history_file"
        return 1
    fi

    _brewup_render_history "$history_file" | awk -F '\t' -v p="$pkg" 'NR==1 || $3==p' | column -t -s $'\t'
}

# -----------------------------
# 统计
# -----------------------------
brewup-stats() {
    case "${1:-}" in
        -h|--help)
            echo "用法: brewup-stats"
            echo "说明: 统计升级历史的成功、失败和包数量"
            return 0
            ;;
    esac

    local history_file="$(_brewup_history_file)"

    if [[ ! -f "$history_file" ]]; then
        echo "历史表不存在: $history_file"
        return 1
    fi

    echo "==================== Upgrade Stats ===================="

    awk -F '\t' '
        NR==1 { next }
        {
            total++
            pkg_count[$3]++
            pkg_seen[$3]=1
            if ($9=="SUCCESS") success++
            else if ($9=="FAILED") failed++
        }
        END {
            pkg_total=0
            for (p in pkg_seen) pkg_total++

            printf "总记录数      : %d\n", total+0
            printf "成功次数      : %d\n", success+0
            printf "失败次数      : %d\n", failed+0
            printf "涉及包数量    : %d\n", pkg_total+0
        }
    ' "$history_file"

    echo
    echo "包升级次数:"

    awk -F '\t' '
        NR==1 { next }
        { pkg_count[$3]++ }
        END {
            for (p in pkg_count) {
                printf "%s\t%d\n", p, pkg_count[p]
            }
        }
    ' "$history_file" | sort -t $'\t' -k2,2nr -k1,1 | awk -F '\t' -v cols=9 '
        {
            item = sprintf("%s(%s)", $1, $2)
            items[++count] = item
            if (length(item) > max_width) {
                max_width = length(item)
            }
        }
        END {
            if (count == 0) {
                print "(empty)"
                exit
            }

            cell_width = max_width + 2

            for (i = 1; i <= count; i++) {
                printf "%-*s", cell_width, items[i]
                if (i % cols == 0 || i == count) {
                    printf "\n"
                }
            }
        }
    '
}

# -----------------------------
# 查看最近 N 条
# -----------------------------
brewup-history-tail() {
    case "${1:-}" in
        -h|--help)
            echo "用法: brewup-history-tail [n]"
            echo "说明: 查看最近 n 条升级历史，默认 10 条"
            return 0
            ;;
    esac

    local history_file="$(_brewup_history_file)"
    local n="${1:-10}"

    if [[ ! -f "$history_file" ]]; then
        echo "历史表不存在: $history_file"
        return 1
    fi

    {
        _brewup_render_history "$history_file" | head -n 1
        _brewup_render_history "$history_file" | tail -n "$n"
    } | column -t -s $'\t'
}
