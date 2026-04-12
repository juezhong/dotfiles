### Functions

# 返回当前 shell 所在的平台标识，避免每个函数重复写 uname 判断。
function _current_os
{
    uname -s
}

# 判断当前环境是否为 Windows 兼容层（Git Bash / MSYS / Cygwin 等）。
function _is_windows_like
{
    local os_type="$(_current_os)"
    [[ "$os_type" == CYGWIN* || "$os_type" == MINGW* || "$os_type" == MSYS* ]]
}

# 缓存外部命令输出的 shell 初始化代码，减少每次启动重复 fork 的成本。
function _source_cached_eval_output
{
    local cache_name="$1"
    local dependency_path="$2"
    shift 2

    if [[ -z "$cache_name" || "$#" -eq 0 ]]; then
        print -u2 -- "source_cached_eval_output: missing cache name or command"
        return 1
    fi

    local cache_dir="${ZSH_HOME}/eval_code"
    local cache_file="${cache_dir}/${cache_name}.zsh"
    local temp_file="${cache_file}.tmp.$$"
    local cache_signature="$*"
    local should_regenerate=0
    local existing_signature=""

    command mkdir -p -- "$cache_dir" || return $?

    if [[ ! -f "$cache_file" ]]; then
        should_regenerate=1
    else
        IFS= read -r existing_signature < "$cache_file"
        if [[ "$existing_signature" != "# cache-key: $cache_signature" ]]; then
            should_regenerate=1
        elif [[ -n "$dependency_path" && -e "$dependency_path" && "$dependency_path" -nt "$cache_file" ]]; then
            should_regenerate=1
        fi
    fi

    if (( should_regenerate )); then
        print -r -- "# cache-key: $cache_signature" >| "$temp_file" || return $?
        if ! "$@" >> "$temp_file"; then
            command rm -f -- "$temp_file"
            return 1
        fi
        command mv -f -- "$temp_file" "$cache_file" || return $?
    fi

    source "$cache_file"
}

function _nvm_alias_value
{
    local alias_name="$1"
    local alias_file="${NVM_DIR}/alias/${alias_name}"
    local alias_value=""

    [[ -f "$alias_file" ]] || return 1

    IFS= read -r alias_value < "$alias_file" || return 1
    alias_value="${alias_value#"${alias_value%%[![:space:]]*}"}"
    alias_value="${alias_value%"${alias_value##*[![:space:]]}"}"

    [[ -n "$alias_value" ]] || return 1
    print -r -- "$alias_value"
}

function _resolve_nvm_default_version
{
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    local alias_name="default"
    local alias_value=""
    local max_depth=10

    while (( max_depth > 0 )); do
        alias_value="$(_nvm_alias_value "$alias_name")" || return 1

        if [[ "$alias_value" == v* ]]; then
            print -r -- "$alias_value"
            return 0
        fi

        if [[ -d "${NVM_DIR}/versions/node/${alias_value}" ]]; then
            print -r -- "$alias_value"
            return 0
        fi

        alias_name="$alias_value"
        (( max_depth-- ))
    done

    return 1
}

function _prepend_path_if_dir
{
    local target_dir="$1"

    [[ -d "$target_dir" ]] || return 1

    typeset -gU path PATH
    path=("$target_dir" $path)
    export PATH
}

function _setup_nvm_base_node_path
{
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    local default_version=""
    local node_bin=""

    default_version="$(_resolve_nvm_default_version 2>/dev/null)"
    if [[ -n "$default_version" ]]; then
        node_bin="${NVM_DIR}/versions/node/${default_version}/bin"
    fi

    if [[ ! -d "$node_bin" ]]; then
        local version_dir=""
        for version_dir in "${NVM_DIR}"/versions/node/*(N/); do
            node_bin="${version_dir}/bin"
        done
    fi

    [[ -d "$node_bin" ]] || return 1

    _prepend_path_if_dir "$node_bin" || return $?
    typeset -g NVM_LAZY_DEFAULT_BIN="$node_bin"
}

function _load_nvm_lazy
{
    if [[ -n "${__nvm_lazy_loaded:-}" ]]; then
        return 0
    fi

    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    local nvm_script="/opt/homebrew/opt/nvm/nvm.sh"
    local nvm_completion="/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

    [[ -s "$nvm_script" ]] || return 1

    \. "$nvm_script" --no-use || return $?
    [[ -s "$nvm_completion" ]] && \. "$nvm_completion"

    typeset -g __nvm_lazy_loaded=1
}

function nvm
{
    _load_nvm_lazy || return $?
    nvm "$@"
}

# 从标准输入读取内容并复制到系统剪贴板。
# 这里集中处理平台差异，业务函数只负责生成文本内容。
function _copy_to_clipboard
{
    local content
    content="$(cat)"

    if [[ -z "$content" ]]; then
        print -u2 -- "copy_to_clipboard: no content to copy"
        return 1
    fi

    local os_type="$(_current_os)"

    if [[ "$os_type" == "Darwin" ]]; then
        if ! command -v pbcopy >/dev/null 2>&1; then
            print -u2 -- "copy_to_clipboard: pbcopy not found"
            return 1
        fi

        print -rn -- "$content" | pbcopy
        return $?
    fi

    if [[ "$os_type" == "Linux" ]]; then
        if command -v xclip >/dev/null 2>&1; then
            # 同步 clipboard 和 primary，保持原先 Linux 下的使用习惯。
            print -rn -- "$content" | xclip -selection clipboard -rmlastnl
            print -rn -- "$content" | xclip -selection primary -rmlastnl
            return $?
        fi

        if command -v wl-copy >/dev/null 2>&1; then
            print -rn -- "$content" | wl-copy
            return $?
        fi

        print -u2 -- "copy_to_clipboard: no clipboard tool found (need xclip or wl-copy)"
        return 1
    fi

    if _is_windows_like; then
        # Windows 终端里优先沿用原有 GBK 转码流程，减少 CLIP 的乱码概率。
        if command -v clip.exe >/dev/null 2>&1; then
            if command -v iconv >/dev/null 2>&1; then
                print -rn -- "$content" | iconv -c -f UTF-8 -t GBK | clip.exe
            else
                print -rn -- "$content" | clip.exe
            fi
            return $?
        fi

        if command -v CLIP >/dev/null 2>&1; then
            if command -v iconv >/dev/null 2>&1; then
                print -rn -- "$content" | iconv -c -f UTF-8 -t GBK | CLIP
            else
                print -rn -- "$content" | CLIP
            fi
            return $?
        fi

        print -u2 -- "copy_to_clipboard: no clipboard tool found (need clip.exe or CLIP)"
        return 1
    fi

    print -u2 -- "copy_to_clipboard: unsupported platform: $os_type"
    return 1
}

# 根据文件路径跳转到其所在目录。
# 如果传入的是目录，则直接进入该目录；如果传入的是文件或不存在的路径，则进入其父目录。
function fcd
{
    local target_path="$1"

    if [[ -z "$target_path" ]]; then
        print -u2 -- "Usage: fcd <file-or-directory>"
        return 1
    fi

    local destination_dir="$target_path"
    if [[ ! -d "$target_path" ]]; then
        destination_dir="${target_path:h}"
    fi

    destination_dir="${destination_dir:-.}"

    if [[ ! -d "$destination_dir" ]]; then
        print -u2 -- "fcd: directory not found: $destination_dir"
        return 1
    fi

    builtin cd -- "$destination_dir"
}

# 复制指定层级的目录树到系统剪贴板，方便贴到文档或聊天窗口。
function tree_cp
{
    local level="${1:-}"

    if [[ -z "$level" ]]; then
        print -u2 -- "Usage: tree_cp <level>"
        return 1
    fi

    if [[ ! "$level" =~ '^[0-9]+$' ]]; then
        print -u2 -- "tree_cp: level must be a non-negative integer"
        return 1
    fi

    if ! command -v tree >/dev/null 2>&1; then
        print -u2 -- "tree_cp: tree command not found"
        return 1
    fi

    local tree_output
    # 显式绕过 alias，并关闭颜色输出，避免复制到剪贴板时带上 ANSI 转义序列。
    tree_output="$(command tree -n -L "$level")" || return $?

    print -r -- "$tree_output" | _copy_to_clipboard || return $?
    print -- "Copied tree output (level=$level) to clipboard."
}

# 优先根据 /etc/os-release 判断 Ubuntu，只有缺少系统信息时才回退到内核版本字符串。
function is_ubuntu
{
    if [[ -r /etc/os-release ]]; then
        grep -iq '^ID=ubuntu$' /etc/os-release
        return $?
    fi

    if [[ -r /proc/version ]]; then
        grep -iq 'ubuntu' /proc/version
        return $?
    fi

    return 1
}

function is_windows
{
    _is_windows_like
}

# 记录简单日志到 ~/log_zsh.txt，保留原始参数内容，避免 echo 的转义和压缩行为。
# Usage: logger "message"
function logger
{
    local log_file="$HOME/log_zsh.txt"
    print -r -- "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$log_file"
}

### End of functions
