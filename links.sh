#!/bin/bash

# 获取当前脚本所在的目录
CURRENT_DIR=$(pwd)
DEFAULT_LINKS_FILE="default_links"

# 日志文件定义
declare -a LOG_FILES=(
    "cache_links.log"
    "create_links.log"
    "skipped_operations.log"
)
CACHE_FILE="${LOG_FILES[0]}"
LOG_FILE="${LOG_FILES[1]}"
SKIPPED_OPERATIONS_FILE="${LOG_FILES[2]}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# 输出格式化函数
print_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# 展开路径中的 ~ 为实际的 HOME 路径，并将相对路径转为绝对路径
expand_path() {
    local path=$1
    if [[ "$path" == ~* ]]; then
        echo "${path/#\~/$HOME}"  # 将 ~ 替换为 $HOME
    elif [[ "$path" != /* ]]; then
        echo "$CURRENT_DIR/$path" # 相对路径转换为绝对路径
    else
        echo "$path"              # 已是绝对路径则直接返回
    fi
}

# 计算路径深度（通过统计 / 的数量）
# 参数: $1 - 路径
# 返回: 路径深度（数字）
get_path_depth() {
    local path="$1"
    # 移除开头和结尾的 /，然后计算剩余 / 的数量
    path="${path#/}"
    path="${path%/}"
    if [ -z "$path" ]; then
        echo 0
    else
        echo "$path" | tr -cd '/' | wc -c | tr -d ' '
    fi
}

# 检查是否需要 sudo 权限
# 参数: $1 - 要检查的文件或目录路径
# 返回: 0 - 需要 sudo, 1 - 不需要 sudo
needs_sudo() {
    local path="$1"
    local dir=$(dirname "$path")

    # 递归查找第一个存在的父目录
    while [ ! -e "$dir" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    # 检查目录是否可写
    if [ ! -w "$dir" ]; then
        return 0  # 目录不可写，需要 sudo
    fi
    return 1     # 目录可写，不需要 sudo
}

# 用户确认函数
# 参数: 
#   $1 - 操作类型（如：创建目录、删除软链接等）
#   $2 - 操作路径
# 返回: 0 - 用户确认, 1 - 用户取消
confirm_operation() {
    local operation="$1"
    local path="$2"
    echo
    print_warning "需要 sudo 权限执行以下操作："
    echo -e "${CYAN}$operation${NC}: ${BOLD}$path${NC}"
    echo
    read -p "$(echo -e "${YELLOW}是否继续？${NC}[y/N]: ")" choice
    case "$choice" in
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

# 记录跳过的操作到日志文件
# 参数: $1 - 被跳过的命令
record_skipped_operation() {
    local operation="$1"
    echo "$operation" >> "$SKIPPED_OPERATIONS_FILE"
}

# 显示所有跳过的操作
show_skipped_operations() {
    if [ -f "$SKIPPED_OPERATIONS_FILE" ] && [ -s "$SKIPPED_OPERATIONS_FILE" ]; then
        print_header "跳过操作"
        print_warning "以下操作被跳过，需要手动执行："
        echo
        while IFS= read -r cmd; do
            echo -e "  ${CYAN}$cmd${NC}"
        done < "$SKIPPED_OPERATIONS_FILE"
        echo
        rm "$SKIPPED_OPERATIONS_FILE"
    fi
}

# 帮助信息
show_help() {
    print_header "使用说明"
    echo -e "${BOLD}用法:${NC}"
    echo -e "  ${CYAN}links.sh status${NC}            # 显示所有软链接的状态信息"
    echo -e "  ${CYAN}links.sh all${NC}               # 根据 default_links 文件创建软链接"
    echo -e "  ${CYAN}links.sh add LINK TARGET${NC}   # 添加一个从 LINK 到 TARGET 的软链接"
    echo -e "  ${CYAN}links.sh clean${NC}             # 交互式删除软链接"
    echo
    echo -e "${BOLD}说明:${NC}"
    echo -e "  ${GREEN}status${NC}  - 检查并显示软链接状态（已创建/未创建/冲突）"
    echo -e "  ${GREEN}all${NC}     - 批量创建软链接，已存在的会自动跳过或询问覆盖"
    echo -e "  ${GREEN}add${NC}     - 添加单个软链接到配置文件并创建"
    echo -e "  ${GREEN}clean${NC}   - 选择性删除已创建的软链接"
    echo
}

# 清理函数：在脚本退出时执行
# - 成功退出时清理临时文件
# - 失败退出时回滚已创建的软链接
cleanup() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        print_success "所有操作已完成"
        # 正常退出时清理所有日志文件
        clean_logs
        show_skipped_operations
    else
        print_error "发生错误，正在清理..."
        if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
            while IFS=',' read -r link _target; do
                local expanded_link=$(expand_path "$link")
                if [ -L "$expanded_link" ]; then
                    if needs_sudo "$expanded_link"; then
                        sudo rm "$expanded_link"
                    else
                        rm "$expanded_link"
                    fi
                    print_info "已回滚软链接: $expanded_link"
                fi
            done < "$CACHE_FILE"
        fi
        # 发生错误时保留所有日志文件并提示用户
        print_warning "操作失败，请查看以下日志文件了解详情："
        for log_file in "${LOG_FILES[@]}"; do
            if [ -f "$log_file" ] && [ -s "$log_file" ]; then
                print_info "- $log_file"
            fi
        done
        # 失败退出时也显示跳过的操作
        show_skipped_operations
    fi
}

# 设置退出钩子
trap cleanup EXIT

# 添加日志函数
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
    if [[ "$1" == *"Error"* ]]; then
        print_error "$1"
    elif [[ "$1" == *"Warning"* ]]; then
        print_warning "$1"
    else
        print_info "$1"
    fi
}

# 根据 default_links 文件创建软链接
# 格式：每行一个配置，格式为 "链接路径,目标路径"
create_links_from_default() {
    > "$CACHE_FILE"
    > "$SKIPPED_OPERATIONS_FILE"
    log_message "开始批量创建软链接"

    # 检查配置文件是否存在
    if [ ! -f "$DEFAULT_LINKS_FILE" ]; then
        log_message "Error: 在当前目录未找到 default_links 文件"
        exit 1
    fi

    # 先读取所有配置到临时文件，并添加深度信息
    local temp_sorted=$(mktemp)
    while IFS=',' read -r link target; do
        # 跳过空行或格式不正确的行
        if [ -z "$link" ] || [ -z "$target" ]; then
            continue
        fi
        # 展开路径以计算实际深度
        local expanded_link=$(expand_path "$link")
        local depth=$(get_path_depth "$expanded_link")
        # 格式：深度|原始link|原始target
        echo "$depth|$link|$target" >> "$temp_sorted"
    done < "$DEFAULT_LINKS_FILE"

    # 按深度排序（从浅到深），确保父目录先创建
    sort -t'|' -k1 -n "$temp_sorted" > "${temp_sorted}.sorted"

    # 按排序后的顺序创建软链接
    while IFS='|' read -r depth link target; do
        local original_link="$link"
        local original_target="$target"

        # 展开路径（处理 ~ 和相对路径）
        link=$(expand_path "$link")
        target=$(expand_path "$target")

        # 检查目标文件是否存在
        if [ ! -e "$target" ]; then
            log_message "Error: 目标文件不存在: $target"
            exit 1
        fi

        # 创建链接所在的目录（如果不存在）
        link_dir=$(dirname "$link")
        if [ ! -d "$link_dir" ]; then
            if needs_sudo "$link_dir"; then
                if confirm_operation "创建目录" "$link_dir"; then
                    if ! sudo mkdir -p "$link_dir"; then
                        log_message "Error: 创建目录失败: $link_dir"
                        exit 1
                    fi
                else
                    log_message "Warning: 用户取消创建目录: $link_dir"
                    record_skipped_operation "sudo mkdir -p $link_dir"
                    continue
                fi
            elif ! mkdir -p "$link_dir"; then
                log_message "Error: 创建目录失败: $link_dir"
                exit 1
            fi
            log_message "成功创建目录: $link_dir"
        fi

        # 检查软链接是否已存在
        if [ -e "$link" ]; then
            if [ -L "$link" ]; then
                current_target=$(readlink "$link")
                if [ "$current_target" = "$target" ]; then
                    log_message "跳过已存在的软链接: $link -> $target"
                    continue
                fi
                log_message "Warning: 发现冲突的软链接:"
                log_message "Warning: - 当前: $link -> $current_target"
                log_message "Warning: - 新的: $link -> $target"
            else
                log_message "Warning: 路径已存在且不是软链接: $link"
            fi
            read -p "$(echo -e "${YELLOW}是否覆盖？[y/N]:${NC} ")" override_choice < /dev/tty
            if [[ ! "$override_choice" =~ ^[Yy]$ ]]; then
                print_info "跳过创建: $link"
                continue
            fi
        fi

        # 创建软链接
        if needs_sudo "$link"; then
            if confirm_operation "创建软链接" "$link -> $target"; then
                if [ -L "$link" ]; then
                    sudo rm "$link"
                    log_message "删除已存在的软链接: $link"
                fi
                if ! sudo ln -s "$target" "$link"; then
                    log_message "Error: 创建软链接失败: $link -> $target"
                    exit 1
                fi
            else
                log_message "Warning: 用户取消创建软链接: $link -> $target"
                record_skipped_operation "sudo ln -s $target $link"
                continue
            fi
        else
            if [ -L "$link" ]; then
                rm "$link"
                log_message "删除已存在的软链接: $link"
            fi
            if ! ln -s "$target" "$link"; then
                log_message "Error: 创建软链接失败: $link -> $target"
                exit 1
            fi
        fi

        # 记录已创建的链接（用于出错时回滚）
        echo "$original_link,$original_target" >> "$CACHE_FILE"
        print_success "已创建软链接: $link -> $target"
    done < "${temp_sorted}.sorted"

    # 清理临时文件
    rm -f "$temp_sorted" "${temp_sorted}.sorted"

    log_message "批量创建软链接完成"
}

# 添加单个软链接并保存到 default_links
add_link() {
    local input_link="$1"
    local input_target="$2"

    local link=$(expand_path "$1")
    local target=$(expand_path "$2")

    # 创建临时文件用于存储更新后的配置
    local temp_file=$(mktemp)
    local config_updated=false

    # 准备配置文件更新内容（先不写入，等软链接创建成功后再更新）
    if [ -f "$DEFAULT_LINKS_FILE" ]; then
        while IFS=',' read -r existing_link existing_target || [ -n "$existing_link" ]; do
            if [ -z "$existing_link" ] || [ -z "$existing_target" ]; then
                continue
            fi
            if [ "$input_link" = "$existing_link" ] || [ "$(expand_path "$existing_link")" = "$link" ]; then
                # 找到匹配的链接，写入新的目标路径（使用原始格式）
                echo "$input_link,$input_target" >> "$temp_file"
                config_updated=true
            else
                # 保持其他配置不变
                echo "$existing_link,$existing_target" >> "$temp_file"
            fi
        done < "$DEFAULT_LINKS_FILE"
    fi

    # 如果是新的配置，添加到文件末尾
    # 将 HOME 路径转换为 ~
    local config_link="$input_link"
    if [[ "$config_link" == "$HOME"* ]]; then
        config_link="~${config_link#$HOME}"
    fi

    if [ "$config_updated" = false ]; then
        echo "$config_link,$input_target" >> "$temp_file"
    fi

    > "$CACHE_FILE"
    > "$SKIPPED_OPERATIONS_FILE"

    print_header "添加新的软链接"
    print_info "$input_link -> $input_target"

    if [ ! -e "$target" ]; then
        print_error "错误: 目标文件不存在: $target"
        log_message "Error: 目标文件不存在: $target"
        exit 1
    fi

    local link_dir=$(dirname "$link")
    if [ ! -d "$link_dir" ]; then
        if needs_sudo "$link_dir"; then
            if confirm_operation "创建目录" "$link_dir"; then
                if ! sudo mkdir -p "$link_dir"; then
                    log_message "Error: 创建目录失败: $link_dir"
                    exit 1
                fi
            else
                log_message "Warning: 用户取消创建目录: $link_dir"
                record_skipped_operation "sudo mkdir -p $link_dir"
                exit 1
            fi
        elif ! mkdir -p "$link_dir"; then
            log_message "Error: 创建目录失败: $link_dir"
            exit 1
        fi
        log_message "成功创建目录: $link_dir"
    fi

    if [ -e "$link" ]; then
        if [ -L "$link" ]; then
            current_target=$(readlink "$link")
            if [ "$current_target" = "$target" ]; then
                log_message "软链接已存在且指向相同目标: $link -> $target"
                exit 0
            fi
            log_message "Warning: 发现冲突的软链接:"
            log_message "Warning: - 当前: $link -> $current_target"
            log_message "Warning: - 新的: $link -> $target"
        else
            log_message "Warning: 路径已存在且不是软链接: $link"
        fi
        read -p "$(echo -e "${YELLOW}是否覆盖？[y/N]:${NC} ")" override_choice < /dev/tty
        if [[ ! "$override_choice" =~ ^[Yy]$ ]]; then
            log_message "用户取消覆盖操作: $link"
            exit 0
        fi
    fi

    if needs_sudo "$link"; then
        if confirm_operation "创建软链接" "$link -> $target"; then
            if [ -L "$link" ]; then
                sudo rm "$link"
                log_message "删除已存在的软链接: $link"
            fi
            if ! sudo ln -s "$target" "$link"; then
                log_message "Error: 创建软链接失败: $link -> $target"
                exit 1
            fi
        else
            log_message "Warning: 用户取消创建软链接: $link -> $target"
            record_skipped_operation "sudo ln -s $target $link"
            exit 1
        fi
    else
        if [ -L "$link" ]; then
            rm "$link"
            log_message "删除已存在的软链接: $link"
        fi
        if ! ln -s "$target" "$link"; then
            log_message "Error: 创建软链接失败: $link -> $target"
            exit 1
        fi
    fi

    print_success "已创建软链接: $link -> $target"
    log_message "成功创建软链接: $link -> $target"

    # 记录已创建的链接到 CACHE_FILE（用于出错时回滚）
    echo "$input_link,$input_target" >> "$CACHE_FILE"

    # 软链接创建成功后，更新配置文件
    mv "$temp_file" "$DEFAULT_LINKS_FILE"
    if [ "$config_updated" = true ]; then
        log_message "已更新配置文件中的链接: $config_link -> $input_target"
    else
        log_message "已添加新配置到文件: $config_link -> $input_target"
    fi

    if [[ "$input_link" == "$HOME"* ]]; then
        input_link="~${input_link#$HOME}"
    fi
}

# 清理所有日志文件
clean_logs() {
    local cleaned=0
    for log_file in "${LOG_FILES[@]}"; do
        if [ -f "$log_file" ]; then
            rm -f "$log_file"
            cleaned=1
        fi
    done
    [ $cleaned -eq 1 ] && print_success "已清理所有日志文件"
}

# 解析用户选择的编号
# 参数: $1 - 用户输入的选择字符串（如 "1,2,3" 或 "1-3" 或 "all"）
#       $2 - 最大编号
# 返回: 空格分隔的编号列表
parse_selection() {
    local input="$1"
    local max_num="$2"
    local result=""

    # 处理 "all" 或 "*"
    if [[ "$input" =~ ^(all|\*|a)$ ]]; then
        for ((i=1; i<=max_num; i++)); do
            result="$result $i"
        done
        echo "$result"
        return 0
    fi

    # 移除空格
    input="${input// /}"

    # 按逗号分割
    IFS=',' read -ra PARTS <<< "$input"

    for part in "${PARTS[@]}"; do
        # 检查是否是范围（如 1-3）
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"

            # 验证范围
            if [ "$start" -gt "$end" ]; then
                echo "Error: 无效范围 $part" >&2
                return 1
            fi
            if [ "$start" -lt 1 ] || [ "$end" -gt "$max_num" ]; then
                echo "Error: 范围超出 1-$max_num: $part" >&2
                return 1
            fi

            # 添加范围内的所有数字
            for ((i=start; i<=end; i++)); do
                result="$result $i"
            done
        # 检查是否是单个数字
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            if [ "$part" -lt 1 ] || [ "$part" -gt "$max_num" ]; then
                echo "Error: 编号超出范围 1-$max_num: $part" >&2
                return 1
            fi
            result="$result $part"
        else
            echo "Error: 无效输入: $part" >&2
            return 1
        fi
    done

    # 去重并排序
    echo "$result" | tr ' ' '\n' | sort -u -n | tr '\n' ' '
    return 0
}

# 显示软链接状态
show_status() {
    print_header "软链接状态检查"

    if [ ! -f "$DEFAULT_LINKS_FILE" ]; then
        print_error "在当前目录未找到 default_links 文件"
        return 1
    fi

    if [ ! -s "$DEFAULT_LINKS_FILE" ]; then
        print_warning "default_links 文件为空"
        return 0
    fi

    # 统计计数器
    local count_ok=0
    local count_missing=0
    local count_conflict=0
    local count_occupied=0
    local total=0

    # 存储每种状态的链接信息
    local -a ok_links
    local -a missing_links
    local -a conflict_links
    local -a occupied_links

    while IFS=',' read -r link target; do
        # 跳过空行或格式不正确的行
        if [ -z "$link" ] || [ -z "$target" ]; then
            continue
        fi

        total=$((total + 1))

        # 展开路径
        local expanded_link=$(expand_path "$link")
        local expanded_target=$(expand_path "$target")

        # 检查链接状态
        if [ -L "$expanded_link" ]; then
            # 是软链接，检查目标是否正确
            local current_target=$(readlink "$expanded_link")
            if [ "$current_target" = "$expanded_target" ]; then
                # ✓ 已创建且正确
                ok_links+=("✓|$expanded_link|$expanded_target|OK")
                count_ok=$((count_ok + 1))
            else
                # ⚠ 冲突：指向不同目标
                conflict_links+=("⚠|$expanded_link|$expanded_target|$current_target")
                count_conflict=$((count_conflict + 1))
            fi
        elif [ -e "$expanded_link" ]; then
            # ⚠ 路径存在但不是软链接
            occupied_links+=("⚠|$expanded_link|$expanded_target|占用")
            count_occupied=$((count_occupied + 1))
        else
            # ✗ 不存在
            missing_links+=("✗|$expanded_link|$expanded_target|未创建")
            count_missing=$((count_missing + 1))
        fi
    done < "$DEFAULT_LINKS_FILE"

    # 显示已创建且正确的链接
    if [ ${#ok_links[@]} -gt 0 ]; then
        echo
        print_success "已正确创建 ($count_ok)"
        for item in "${ok_links[@]}"; do
            IFS='|' read -r icon link target status <<< "$item"
            echo -e "  ${GREEN}$icon${NC} ${link} ${YELLOW}→${NC} ${target}"
        done
    fi

    # 显示未创建的链接
    if [ ${#missing_links[@]} -gt 0 ]; then
        echo
        print_error "未创建 ($count_missing)"
        for item in "${missing_links[@]}"; do
            IFS='|' read -r icon link target status <<< "$item"
            echo -e "  ${RED}$icon${NC} ${link} ${YELLOW}→${NC} ${target}"
        done
    fi

    # 显示冲突的链接
    if [ ${#conflict_links[@]} -gt 0 ]; then
        echo
        print_warning "目标冲突 ($count_conflict)"
        for item in "${conflict_links[@]}"; do
            IFS='|' read -r icon link target current <<< "$item"
            echo -e "  ${YELLOW}$icon${NC} ${link}"
            echo -e "     ${CYAN}期望${NC}: ${target}"
            echo -e "     ${RED}实际${NC}: ${current}"
        done
    fi

    # 显示被占用的路径
    if [ ${#occupied_links[@]} -gt 0 ]; then
        echo
        print_warning "路径被占用（不是软链接） ($count_occupied)"
        for item in "${occupied_links[@]}"; do
            IFS='|' read -r icon link target status <<< "$item"
            echo -e "  ${YELLOW}$icon${NC} ${link}"
            echo -e "     ${CYAN}期望${NC}: 软链接 → ${target}"
            echo -e "     ${RED}实际${NC}: 文件或目录"
        done
    fi

    # 显示统计摘要
    echo
    print_header "状态摘要"
    echo -e "  ${BOLD}总计${NC}: $total"
    echo -e "  ${GREEN}✓ 已正确创建${NC}: $count_ok"
    echo -e "  ${RED}✗ 未创建${NC}: $count_missing"
    echo -e "  ${YELLOW}⚠ 目标冲突${NC}: $count_conflict"
    echo -e "  ${YELLOW}⚠ 路径被占用${NC}: $count_occupied"

    # 给出建议
    echo
    if [ $count_missing -gt 0 ] || [ $count_conflict -gt 0 ] || [ $count_occupied -gt 0 ]; then
        print_info "建议: 运行 '${CYAN}./links.sh all${NC}' 来创建或修复软链接"
    else
        print_success "所有软链接都已正确创建！"
    fi
}

# 清理软链接和文件
clean_links() {
    log_message "开始清理软链接"

    if [ ! -f "$DEFAULT_LINKS_FILE" ]; then
        log_message "Error: 在当前目录未找到 default_links 文件"
        exit 1
    fi

    if [ ! -s "$DEFAULT_LINKS_FILE" ]; then
        log_message "Warning: default_links 文件为空，无需清理"
        return
    fi

    # 先读取所有配置到临时文件，并添加深度信息
    local temp_sorted=$(mktemp)
    while IFS=',' read -r link target; do
        if [ -z "$link" ] || [ -z "$target" ]; then
            continue
        fi
        local expanded_link=$(expand_path "$link")
        local depth=$(get_path_depth "$expanded_link")
        # 格式：深度|原始link|原始target
        echo "$depth|$link|$target" >> "$temp_sorted"
    done < "$DEFAULT_LINKS_FILE"

    # 按深度反向排序（从深到浅），确保子目录先删除
    sort -t'|' -k1 -nr "$temp_sorted" > "${temp_sorted}.sorted"

    print_header "已创建的软链接列表"

    # 将已存在的软链接存储到数组中
    declare -a link_list
    declare -a target_list
    declare -a expanded_link_list
    declare -a expanded_target_list
    local index=0

    while IFS='|' read -r depth link target; do
        expanded_link=$(expand_path "$link")
        expanded_target=$(expand_path "$target")
        if [ -L "$expanded_link" ]; then
            index=$((index + 1))
            link_list[$index]="$link"
            target_list[$index]="$target"
            expanded_link_list[$index]="$expanded_link"
            expanded_target_list[$index]="$expanded_target"
            echo -e "  ${BOLD}${CYAN}[$index]${NC} ${expanded_link} ${YELLOW}→${NC} ${expanded_target}"
        fi
    done < "${temp_sorted}.sorted"

    # 如果没有找到任何链接，清理临时文件并返回
    if [ "$index" -eq 0 ]; then
        print_warning "未找到任何有效的软链接"
        rm -f "$temp_sorted" "${temp_sorted}.sorted"
        return
    fi

    echo
    print_info "提示: 可以输入单个编号(如 1)、多个编号(如 1,2,3)、范围(如 1-3)或 'all' 选择全部"
    echo

    # 循环直到用户输入有效选择或取消
    local selected_indices=""
    while true; do
        read -p "$(echo -e "${YELLOW}请选择要删除的软链接编号${NC} [1-$index 或 all]: ")" user_input

        # 如果用户按 Ctrl+C 或输入空，取消操作
        if [ -z "$user_input" ]; then
            print_warning "操作已取消"
            log_message "用户取消清理操作"
            rm -f "$temp_sorted" "${temp_sorted}.sorted"
            return
        fi

        # 解析用户输入
        selected_indices=$(parse_selection "$user_input" "$index" 2>&1)
        if [ $? -eq 0 ]; then
            break
        else
            print_error "$selected_indices"
        fi
    done

    # 显示选中的项
    echo
    print_info "您选择删除以下软链接（按删除顺序）:"
    echo
    for i in $selected_indices; do
        echo -e "  ${BOLD}${CYAN}[$i]${NC} ${expanded_link_list[$i]} ${YELLOW}→${NC} ${expanded_target_list[$i]}"
    done

    # 最终确认
    echo
    read -p "$(echo -e "${BOLD}${YELLOW}确认删除以上软链接？[y/N]:${NC} ")" confirm_choice
    echo

    if [[ ! "$confirm_choice" =~ ^[Yy]$ ]]; then
        print_warning "操作已取消"
        log_message "用户取消清理操作"
        rm -f "$temp_sorted" "${temp_sorted}.sorted"
        return
    fi

    # 执行删除操作（按选择的顺序）
    for i in $selected_indices; do
        local expanded_link="${expanded_link_list[$i]}"
        local target="${target_list[$i]}"

        if [ -L "$expanded_link" ]; then
            if needs_sudo "$expanded_link"; then
                if confirm_operation "删除软链接" "$expanded_link"; then
                    if sudo rm "$expanded_link"; then
                        print_success "已删除: $expanded_link"
                        log_message "成功删除软链接: $expanded_link -> $target"
                    else
                        print_error "删除失败: $expanded_link"
                        log_message "Error: 删除软链接失败: $expanded_link"
                    fi
                else
                    log_message "Warning: 用户取消删除软链接: $expanded_link"
                    record_skipped_operation "sudo rm $expanded_link"
                fi
            else
                if rm "$expanded_link"; then
                    print_success "已删除: $expanded_link"
                    log_message "成功删除软链接: $expanded_link -> $target"
                else
                    print_error "删除失败: $expanded_link"
                    log_message "Error: 删除软链接失败: $expanded_link"
                fi
            fi
        else
            print_warning "软链接已不存在: $expanded_link"
        fi
    done

    log_message "清理软链接完成"

    # 清理临时文件
    rm -f "$temp_sorted" "${temp_sorted}.sorted"
}

# 检查输入参数
if [ "$#" -eq 0 ]; then
    show_help
    trap - EXIT  # 移除退出钩子，这样不会执行清理操作
    exit 1
fi

# 根据参数选择功能
case "$1" in
    status)
        trap - EXIT  # status 命令不需要 cleanup 钩子
        show_status
        ;;
    all)
        create_links_from_default
        ;;
    add)
        if [ "$#" -ne 3 ]; then
            print_error "错误: 'add' 命令参数无效"
            show_help
            trap - EXIT  # 移除退出钩子，这样不会执行清理操作
            exit 1
        fi
        add_link "$2" "$3"
        ;;
    clean)
        clean_links
        ;;
    *)
        print_error "错误: 未知命令 '$1'"
        show_help
        trap - EXIT  # 移除退出钩子，这样不会执行清理操作
        exit 1
        ;;
esac
