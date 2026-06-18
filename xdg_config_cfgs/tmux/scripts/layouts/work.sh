#!/usr/bin/env bash
# ==============================================================================
# tmux 固定工作区脚本
#
# 功能：
#   1. 如果 work session 不存在，就新建
#   2. 创建 13 个固定 window
#   3. 每个 window 可以自动执行 ssh 或其他命令
#   4. 如果某个 window 命令为空，例如 "window013|"，则只打开普通 shell
#   5. 如果 work session 已存在，默认直接切换/进入
#   6. 使用 --reset 可以强制删除旧 work session 并重建
#
# 使用方式：
#   bash work.sh
#   bash work.sh --reset
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 基础配置
# ------------------------------------------------------------------------------

# 固定 session 名称
SESSION="work"

# 默认工作目录
# 如果你希望所有 window 都从某个目录打开，可以改这里
START_DIR="${HOME}"

# 是否强制重建 session
RESET=0

# 是否只创建 session，不自动 attach/switch
NO_ATTACH=0

# 解析命令行参数
for arg in "$@"; do
    case "$arg" in
        --reset)
            RESET=1
            ;;
        --no-attach|--create-only)
            NO_ATTACH=1
            ;;
        *)
            echo "[错误] 未知参数：$arg" >&2
            echo "[用法] $0 [--reset] [--no-attach]" >&2
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Window 配置
#
# 格式：
#   "window名称|启动命令"
#
# 说明：
#   1. | 左边是 window 名称
#   2. | 右边是启动命令
#   3. 如果不想执行命令，就写成 "window名称|"
#
# 示例：
#   "gateway|ssh root@192.168.1.10"
#   "build|ssh -p 2222 dev@build-server"
#   "backup|"
# ------------------------------------------------------------------------------

# WINDOWS=(
#     "Fedora|ssh fedora42"
#     "Fedora|ssh fedora42"
#     "Fedora|ssh fedora42"
#     "host src|ssh euler"
#     "host build|ssh euler"
#     "bitbake|ssh euler"
#     "50 Server|ssh 50server"
#     "50 Server|ssh 50server"
#     "30 Server|ssh 30server"
#     "board|ssh board"
#     "Windows local|"
#     "Windows local|"
#     "yocto|ssh yocto"
# )
WINDOWS=()

# ------------------------------------------------------------------------------
# 函数：进入或切换到指定 session
# ------------------------------------------------------------------------------

attach_or_switch() {
    local session_name="$1"

    # 如果当前已经在 tmux 里面，则切换到目标 session
    if [[ -n "${TMUX:-}" ]]; then
        tmux switch-client -t "$session_name"
    else
        # 如果当前不在 tmux 里面，则 attach 到目标 session
        tmux attach-session -t "$session_name"
    fi
}

# ------------------------------------------------------------------------------
# 函数：检查 window 配置格式
# ------------------------------------------------------------------------------

validate_window_item() {
    local item="$1"

    if [[ "$item" != *"|"* ]]; then
        echo "[错误] window 配置格式不正确：$item" >&2
        echo "[提示] 正确格式：window名称|启动命令" >&2
        echo "[提示] 如果不想执行命令，请写成：window名称|" >&2
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# 函数：解析 window 名称
# ------------------------------------------------------------------------------

get_window_name() {
    local item="$1"

    validate_window_item "$item"

    printf '%s' "${item%%|*}"
}

# ------------------------------------------------------------------------------
# 函数：解析 window 命令
# ------------------------------------------------------------------------------

get_window_command() {
    local item="$1"

    validate_window_item "$item"

    printf '%s' "${item#*|}"
}

# ------------------------------------------------------------------------------
# 函数：向 pane 中发送命令
#
# 说明：
#   这里使用 send-keys，而不是把 ssh 当作 tmux window 的启动程序。
#
# 好处：
#   1. window 会先稳定创建
#   2. session 一定会存在
#   3. ssh 失败后，shell 仍然保留
#   4. 不容易因为 ssh 退出导致 window/session 被销毁
# ------------------------------------------------------------------------------

send_command_if_needed() {
    local pane_id="$1"
    local command="$2"

    if [[ -n "$command" ]]; then
        tmux send-keys -t "$pane_id" "$command" C-m
    fi
}

# ------------------------------------------------------------------------------
# 如果 session 已存在
# ------------------------------------------------------------------------------
if tmux has-session -t "$SESSION" 2>/dev/null; then
    if (( RESET )); then
        # 强制重建：先删除旧 session
        tmux kill-session -t "$SESSION"
    else
        if (( NO_ATTACH )); then
            exit 0
        fi
        # 默认行为：session 已存在就直接进入，不重复创建
        attach_or_switch "$SESSION"
        exit 0
    fi
fi

# ------------------------------------------------------------------------------
# 检查 window 配置
# ------------------------------------------------------------------------------

if [[ "${#WINDOWS[@]}" -eq 0 ]]; then
    echo "[错误] WINDOWS 配置为空，至少需要一个 window" >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# 创建第一个 window
#
# 注意：
#   第一个 window 必须通过 new-session 创建。
#   这里先创建普通 shell，然后再 send-keys 执行命令。
# ------------------------------------------------------------------------------

first_item="${WINDOWS[0]}"
first_name="$(get_window_name "$first_item")"
first_command="$(get_window_command "$first_item")"

if [[ -z "$first_name" ]]; then
    echo "[错误] 第一个 window 名称不能为空" >&2
    exit 1
fi

first_pane_id="$(
    tmux new-session \
        -d \
        -P \
        -F '#{pane_id}' \
        -s "$SESSION" \
        -n "$first_name" \
        -c "$START_DIR"
)"

send_command_if_needed "$first_pane_id" "$first_command"

# ------------------------------------------------------------------------------
# 创建剩余 window
# ------------------------------------------------------------------------------

for item in "${WINDOWS[@]:1}"; do
    window_name="$(get_window_name "$item")"
    window_command="$(get_window_command "$item")"

    if [[ -z "$window_name" ]]; then
        echo "[错误] window 名称不能为空，配置项：$item" >&2
        exit 1
    fi

    pane_id="$(
        tmux new-window \
            -d \
            -P \
            -F '#{pane_id}' \
            -t "$SESSION:" \
            -n "$window_name" \
            -c "$START_DIR"
    )"

    send_command_if_needed "$pane_id" "$window_command"
done

# ------------------------------------------------------------------------------
# 默认选中第一个 window
# ------------------------------------------------------------------------------

tmux select-window -t "$SESSION:$first_name"

# ------------------------------------------------------------------------------
# 最后确认 session 是否创建成功
# ------------------------------------------------------------------------------

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "[错误] session 创建失败：$SESSION" >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# 进入 session
# ------------------------------------------------------------------------------

if (( NO_ATTACH )); then
    exit 0
fi

attach_or_switch "$SESSION"
