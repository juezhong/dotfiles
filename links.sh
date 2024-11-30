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

created_links=()

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

# 检查是否需要 sudo 权限
# 参数: $1 - 要检查的文件或目录路径
# 返回: 0 - 需要 sudo, 1 - 不需要 sudo
needs_sudo() {
    local path="$1"
    local dir=$(dirname "$path")
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
    echo -e "  ${CYAN}links.sh all${NC}              # 根据 default_links 文件创建软链接"
    echo -e "  ${CYAN}links.sh add LINK TARGET${NC}  # 添加一个从 LINK 到 TARGET 的软链接"
    echo -e "  ${CYAN}links.sh clean${NC}            # 清理所有软链接并清空配置文件"
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
    fi
    # 跳过操作文件总是清理
    [ -f "$SKIPPED_OPERATIONS_FILE" ] && rm "$SKIPPED_OPERATIONS_FILE"
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

    while IFS=',' read -r link target; do
        # 跳过空行或格式不正确的行
        if [ -z "$link" ] || [ -z "$target" ]; then
            continue
        fi

        local original_link="$link"
        local original_target="$target"

        # 展开路径（处理 ~ 和相对路径）
        link=$(expand_path "$link")
        target=$(expand_path "$target")

        # 检查目标文件否存在
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
    done < "$DEFAULT_LINKS_FILE"
    
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

    # 检查并更新配置文件
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

    # 更新配置文件
    mv "$temp_file" "$DEFAULT_LINKS_FILE"
    if [ "$config_updated" = true ]; then
        log_message "已更新配置文件中的链接: $config_link -> $input_target"
    else
        log_message "已添加新配置到文件: $config_link -> $input_target"
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

    # 在创建软链接前先记录到 CACHE_FILE
    echo "$input_link,$input_target" >> "$CACHE_FILE"

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

    print_info "以下是将要清理的软链接:"
    echo

    # 首先显示所有要清理的链接
    local found_links=false
    while IFS=',' read -r link target; do
        if [ -z "$link" ] || [ -z "$target" ]; then
            continue
        fi
        expanded_link=$(expand_path "$link")
        expanded_target=$(expand_path "$target")
        if [ -L "$expanded_link" ]; then
            echo -e "  ${CYAN}$expanded_link${NC} -> $expanded_target"
            found_links=true
        fi
    done < "$DEFAULT_LINKS_FILE"
    
    # 如果没有找到任何链接，直接返回
    if [ "$found_links" = false ]; then
        print_warning "未找到任何有效的软链接"
        return
    fi
    
    # 确认是否删除
    echo
    read -p "$(echo -e "${YELLOW}是否确认删除以上软链接？${NC}[y/N]: ")" choice
    echo

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        # 执行删除操作
        while IFS=',' read -r link target; do
            if [ -z "$link" ] || [ -z "$target" ]; then
                continue
            fi
            expanded_link=$(expand_path "$link")
            expanded_target=$(expand_path "$target")
            if [ -L "$expanded_link" ]; then
                if needs_sudo "$expanded_link"; then
                    if confirm_operation "删除软链接" "$expanded_link"; then
                        if sudo rm "$expanded_link"; then
                            log_message "成功删除软链接: $expanded_link -> $target"
                        else
                            log_message "Error: 删除软链接失败: $expanded_link"
                        fi
                    else
                        log_message "Warning: 用户取消删除软链接: $expanded_link"
                        record_skipped_operation "sudo rm $expanded_link"
                    fi
                else
                    if rm "$expanded_link"; then
                        log_message "成功删除软链接: $expanded_link -> $target"
                    else
                        log_message "Error: 删除软链接失败: $expanded_link"
                    fi
                fi
            fi
        done < "$DEFAULT_LINKS_FILE"
        log_message "清理软链接完成"
    else
        log_message "用户取消清理操作"
    fi
}

# 检查输入参数
if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

# 根据参数选择功能
case "$1" in
    all)
        create_links_from_default
        ;;
    add)
        if [ "$#" -ne 3 ]; then
            print_error "错误: 'add' 命令参数无效"
            show_help
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
