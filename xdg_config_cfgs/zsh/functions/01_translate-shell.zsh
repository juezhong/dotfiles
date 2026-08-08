# =============================================================================
# translate-shell helpers
#
# en2zh* : -> zh-CN
# zh2en* : -> en
#
# suffix:
#   c = clipboard
#   d = dictionary
#   f = file
#   l = log
# =============================================================================


# -----------------------------------------------------------------------------
# 普通文本
#
# en2zh "some text"
# echo "some text" | en2zh
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
#   en2zhf FILE
#   cat FILE | en2zhf
#   en2zhf < FILE
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
# en2zhd coherent
# echo coherent | en2zhd
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
# =============================================================================


# 普通文本

en2zh() {
    _trans_text zh-CN "$@"
}

zh2en() {
    _trans_text en "$@"
}


# Clipboard

en2zhc() {
    _trans_clipboard zh-CN "$@"
}

zh2enc() {
    _trans_clipboard en "$@"
}


# Dictionary

en2zhd() {
    _trans_dict en zh-CN "$@"
}

zh2end() {
    _trans_dict zh-CN en "$@"
}


# File / document

en2zhf() {
    _trans_file en2zhf zh-CN "$@"
}

zh2enf() {
    _trans_file zh2enf en "$@"
}


# Log
#
# 日志本质上仍作为普通文本翻译，但单独保留命令入口，
# 方便从补全和使用语义上区分。
#
# en2zhl kernel.log
# cat kernel.log | en2zhl
# dmesg | en2zhl

en2zhl() {
    _trans_file en2zhl zh-CN "$@"
}

zh2enl() {
    _trans_file zh2enl en "$@"
}
