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
