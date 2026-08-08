# =============================================================================
# translate-shell helpers
#
# 两套等价命名，功能完全一致：
#   entozh* / en2zh* : -> zh-CN
#   zhtoen* / zh2en* : -> en
#
# suffix:
#   c = clipboard
#   d = dictionary
#   f = file
#   l = log
#
# 正式命名用易读拼写（2 -> to），旧命名作兼容转发保留。
# =============================================================================


# -----------------------------------------------------------------------------
# 普通文本
#
# entozh "some text"
# echo "some text" | entozh
# -----------------------------------------------------------------------------

_trans_text() {
    local target="$1"
    shift

    local -a opts=(
        -b
        -no-ansi
        -no-autocorrect
        -t "$target"
    )

    if (( $# )); then
        command trans "${opts[@]}" "$*"
    else
        command trans "${opts[@]}"
    fi
}


# -----------------------------------------------------------------------------
# 文件
#
# 同时支持：
#   entozhf FILE
#   cat FILE | entozhf
#   entozhf < FILE
# -----------------------------------------------------------------------------

_trans_file() {
    local name="$1"
    local target="$2"
    shift 2

    local -a opts=(
        -b
        -no-ansi
        -no-autocorrect
        -t "$target"
    )

    case $# in
        0)
            # 从 stdin 读取
            command trans "${opts[@]}"
            ;;

        1)
            if [[ ! -r "$1" ]]; then
                print -u2 -- "$name: cannot read file: $1"
                return 2
            fi

            # 大文件直接交给 translate-shell 读取
            command trans "${opts[@]}" -i "$1"
            ;;

        *)
            print -u2 -- "usage: $name [FILE]"
            return 2
            ;;
    esac
}


# -----------------------------------------------------------------------------
# Dictionary
#
# 短词自动语言识别容易出错，因此固定 source language。
#
# entozhd coherent
# echo coherent | entozhd
# -----------------------------------------------------------------------------

_trans_dict() {
    local source="$1"
    local target="$2"
    shift 2

    local -a opts=(
        -d
        -no-ansi
        -no-autocorrect
        -s "$source"
        -t "$target"
    )

    if (( $# )); then
        command trans "${opts[@]}" "$*"
    else
        command trans "${opts[@]}"
    fi
}


# -----------------------------------------------------------------------------
# Clipboard
#
# 译文同时：
#   1. 输出 stdout
#   2. 写入 macOS clipboard
# -----------------------------------------------------------------------------

_trans_clipboard() {
    local target="$1"
    shift

    local result

    result="$(_trans_text "$target" "$@")" || return

    print -r -- "$result"
    print -rn -- "$result" | pbcopy
}


# =============================================================================
# Public functions
#
# 每类命令提供两套等价的命名：
#   entozh* / zhtoen* : 正式命名（易读，2 -> to）
#   en2zh*  / zh2en*  : 兼容命名（转发到正式名，行为永远一致）
# =============================================================================


# 普通文本

entozh() {
    _trans_text zh-CN "$@"
}

zhtoen() {
    _trans_text en "$@"
}

en2zh() {
    entozh "$@"
}

zh2en() {
    zhtoen "$@"
}


# Clipboard

entozhc() {
    _trans_clipboard zh-CN "$@"
}

zhtoenc() {
    _trans_clipboard en "$@"
}

en2zhc() {
    entozhc "$@"
}

zh2enc() {
    zhtoenc "$@"
}


# Dictionary

entozhd() {
    _trans_dict en zh-CN "$@"
}

zhtoend() {
    _trans_dict zh-CN en "$@"
}

en2zhd() {
    entozhd "$@"
}

zh2end() {
    zhtoend "$@"
}


# File / document

entozhf() {
    _trans_file entozhf zh-CN "$@"
}

zhtoenf() {
    _trans_file zhtoenf en "$@"
}

en2zhf() {
    entozhf "$@"
}

zh2enf() {
    zhtoenf "$@"
}


# Log
#
# 日志本质上仍作为普通文本翻译，但单独保留命令入口，
# 方便从补全和使用语义上区分。
#
# entozhl kernel.log
# cat kernel.log | entozhl
# dmesg | entozhl

entozhl() {
    _trans_file entozhl zh-CN "$@"
}

zhtoenl() {
    _trans_file zhtoenl en "$@"
}

en2zhl() {
    entozhl "$@"
}

zh2enl() {
    zhtoenl "$@"
}
