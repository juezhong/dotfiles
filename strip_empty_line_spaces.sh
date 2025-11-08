#!/bin/bash

# ====================================================================
# 脚本名称: strip_empty_line_spaces.sh
# 功能描述: 去除文件中空行里的空格，但保留空行本身
# 作者: Auto-generated
# 日期: 2025-11-08
# ====================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# 全局变量
PROCESSED_COUNT=0    # 已处理文件数
MODIFIED_COUNT=0     # 已修改文件数
BACKUP_ENABLED=true  # 是否启用备份
DRY_RUN=true         # 是否为预览模式（第一阶段预览，第二阶段处理）
FILES_TO_PROCESS=()  # 需要处理的文件列表

# ====================================================================
# 输出格式化函数
# ====================================================================

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

# ====================================================================
# 显示使用帮助
# ====================================================================
show_help() {
    print_header "使用说明"

    echo -e "${BOLD}功能:${NC}"
    echo "  去除文件中空行里的空格或制表符，但保留空行本身"
    echo
    echo -e "${BOLD}用法:${NC}"
    echo "  $0 [选项] <目标>"
    echo
    echo -e "${BOLD}参数:${NC}"
    echo "  <目标>              要处理的文件、文件夹或文件格式"
    echo "                      - 单个文件: /path/to/file.txt"
    echo "                      - 文件夹: /path/to/directory"
    echo "                      - 文件格式: *.sh 或 .sh (处理当前目录及子目录)"
    echo
    echo -e "${BOLD}选项:${NC}"
    echo "  -h, --help          显示此帮助信息"
    echo "  -b, --no-backup     不创建备份文件（默认会创建 .bak 备份）"
    echo "  -e, --extension EXT 指定要处理的文件扩展名（在文件夹模式下）"
    echo "                      可多次使用，如: -e sh -e zsh -e conf"
    echo "  -r, --recursive     递归处理子目录（在文件夹模式下，默认启用）"
    echo
    echo -e "${BOLD}示例:${NC}"
    echo "  # 处理单个文件（会先预览再询问确认）"
    echo "  $0 links.sh"
    echo
    echo "  # 处理整个文件夹中的所有 .sh 文件"
    echo "  $0 -e sh /path/to/scripts/"
    echo
    echo "  # 处理多种文件格式"
    echo "  $0 -e sh -e zsh -e conf ~/dotfiles/"
    echo
    echo "  # 处理当前目录及子目录下所有 .sh 文件"
    echo "  $0 \"*.sh\""
    echo
    echo "  # 不创建备份"
    echo "  $0 -b links.sh"
    echo
    echo -e "${BOLD}说明:${NC}"
    echo "  - 脚本会先预览要处理的文件，然后询问是否确认处理（强制安全模式）"
    echo "  - 默认会为每个修改的文件创建 .bak 备份"
    echo "  - 空行定义: 只包含空格、制表符或完全为空的行"
    echo "  - 处理后的空行: 完全为空（不含任何字符）"
    echo "  - 支持的空白字符: 空格、制表符(Tab)"
    echo "  - 路径末尾带不带斜杠都可以: /path/dir 或 /path/dir/ 均可"
    echo "  - 跨平台兼容: 支持 macOS (BSD) 和 GNU/Linux 系统"
    echo
}

# ====================================================================
# 检查文件是否包含需要处理的空行（只有空格/制表符的行）
# 参数: $1 - 文件路径
# 返回: 0 - 需要处理, 1 - 不需要处理
# ====================================================================
needs_processing() {
    local file="$1"

    # 检查是否存在只包含空格或制表符的行
    # 使用 -E 启用扩展正则表达式（兼容 BSD grep 和 GNU grep）
    if grep -E -q '^[[:blank:]]+$' "$file"; then
        return 0  # 需要处理
    fi
    return 1      # 不需要处理
}

# ====================================================================
# 处理单个文件
# 参数: $1 - 文件路径
# ====================================================================
process_file() {
    local file="$1"

    # 跳过备份文件
    if [[ "$file" == *.bak ]]; then
        return
    fi

    # 检查文件是否存在且可读
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        print_warning "无法读取文件: $file"
        return
    fi

    # 增加处理计数
    PROCESSED_COUNT=$((PROCESSED_COUNT + 1))

    # 检查是否需要处理
    if ! needs_processing "$file"; then
        if [ "$DRY_RUN" = true ]; then
            print_info "[预览] 跳过: $file (不需要处理)"
        fi
        return
    fi

    # 演习模式：收集需要处理的文件
    if [ "$DRY_RUN" = true ]; then
        print_warning "[预览] 将处理: $file"
        # 显示会被修改的行
        local line_num=1
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:blank:]]+$ ]]; then
                echo -e "    ${CYAN}行 $line_num:${NC} '${YELLOW}$line${NC}' → '${GREEN}(空行)${NC}'"
            fi
            line_num=$((line_num + 1))
        done < "$file"
        MODIFIED_COUNT=$((MODIFIED_COUNT + 1))
        FILES_TO_PROCESS+=("$file")
        return
    fi

    # 实际处理模式
    # 创建临时文件
    local temp_file=$(mktemp)

    # 处理文件：将只包含空格/制表符的行替换为空行
    # 使用 sed -E 启用扩展正则表达式（兼容 BSD sed 和 GNU sed）
    if sed -E 's/^[[:blank:]]+$//' "$file" > "$temp_file"; then
        # 检查处理后的文件是否与原文件不同
        if ! cmp -s "$file" "$temp_file"; then
            # 创建备份
            if [ "$BACKUP_ENABLED" = true ]; then
                cp "$file" "${file}.bak"
                print_info "已创建备份: ${file}.bak"
            fi

            # 替换原文件
            mv "$temp_file" "$file"
            print_success "已处理: $file"
            MODIFIED_COUNT=$((MODIFIED_COUNT + 1))
        else
            rm "$temp_file"
        fi
    else
        print_error "处理失败: $file"
        rm -f "$temp_file"
    fi
}

# ====================================================================
# 处理文件夹
# 参数: $1 - 文件夹路径
#       $@ - 文件扩展名数组（可选）
# ====================================================================
process_directory() {
    local dir="$1"
    shift
    local extensions=("$@")

    # 移除路径末尾的斜杠（如果有）
    dir="${dir%/}"

    if [ ! -d "$dir" ]; then
        print_error "目录不存在: $dir"
        exit 1
    fi

    print_header "扫描目录: $dir"

    # 构建 find 命令
    local find_cmd="find \"$dir\" -type f"

    # 如果指定了扩展名，添加过滤条件
    if [ ${#extensions[@]} -gt 0 ]; then
        find_cmd="$find_cmd \("
        local first=true
        for ext in "${extensions[@]}"; do
            # 移除扩展名前的点（如果有）
            ext="${ext#.}"
            if [ "$first" = true ]; then
                find_cmd="$find_cmd -name \"*.$ext\""
                first=false
            else
                find_cmd="$find_cmd -o -name \"*.$ext\""
            fi
        done
        find_cmd="$find_cmd \)"
    fi

    # 执行 find 命令并处理每个文件
    while IFS= read -r file; do
        process_file "$file"
    done < <(eval $find_cmd)
}

# ====================================================================
# 按文件格式处理（glob 模式）
# 参数: $1 - 文件格式模式（如 *.sh）
# ====================================================================
process_pattern() {
    local pattern="$1"
    local dir="."

    # 如果模式包含路径，提取目录部分
    if [[ "$pattern" == */* ]]; then
        dir=$(dirname "$pattern")
        pattern=$(basename "$pattern")
    fi

    # 提取扩展名
    if [[ "$pattern" == \*.* ]]; then
        local ext="${pattern#\*.}"
        print_header "在目录 '$dir' 中查找所有 .$ext 文件"
        process_directory "$dir" "$ext"
    elif [[ "$pattern" == .* ]]; then
        local ext="${pattern#.}"
        print_header "在目录 '$dir' 中查找所有 .$ext 文件"
        process_directory "$dir" "$ext"
    else
        print_error "无效的文件格式模式: $pattern"
        print_info "支持的格式: *.sh 或 .sh"
        exit 1
    fi
}

# ====================================================================
# 主程序
# ====================================================================
main() {
    local extensions=()
    local target=""
    local recursive=true

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--no-backup)
                BACKUP_ENABLED=false
                print_info "备份已禁用"
                shift
                ;;
            -e|--extension)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    print_error "选项 -e 需要指定扩展名"
                    exit 1
                fi
                extensions+=("$2")
                shift 2
                ;;
            -r|--recursive)
                recursive=true
                shift
                ;;
            -*)
                print_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                if [ -z "$target" ]; then
                    target="$1"
                else
                    print_error "只能指定一个目标"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # 检查是否提供了目标
    if [ -z "$target" ]; then
        print_error "错误: 未指定目标"
        echo
        show_help
        exit 1
    fi

    print_header "空行空格清理工具 🧹"
    print_info "预览模式，将先展示需要处理的内容"

    # 第一阶段：预览模式
    # 判断目标类型并处理
    if [ -f "$target" ]; then
        # 单个文件
        print_info "处理模式: 单个文件"
        process_file "$target"
    elif [ -d "$target" ]; then
        # 文件夹（移除末尾斜杠）
        target="${target%/}"
        print_info "处理模式: 文件夹"
        if [ ${#extensions[@]} -eq 0 ]; then
            print_warning "未指定文件扩展名，将处理所有文件"
            read -p "$(echo -e "${YELLOW}是否继续？[y/N]:${NC} ")" confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_info "操作已取消"
                exit 0
            fi
        else
            print_info "文件扩展名: ${extensions[*]}"
        fi
        process_directory "$target" "${extensions[@]}"
    elif [[ "$target" == \*.* ]] || [[ "$target" == .* ]]; then
        # 文件格式模式
        print_info "处理模式: 文件格式模式"
        process_pattern "$target"
    else
        print_error "错误: 目标不存在或格式无效: $target"
        exit 1
    fi

    # 显示预览结果并询问是否确认
    if [ "$MODIFIED_COUNT" -gt 0 ]; then
        # 有文件需要处理
        echo
        print_header "预览完成"
        echo -e "${BOLD}统计信息:${NC}"
        echo -e "  扫描文件数: ${CYAN}$PROCESSED_COUNT${NC}"
        echo -e "  需要处理的文件数: ${YELLOW}$MODIFIED_COUNT${NC}"
        echo

        read -p "$(echo -e "${BOLD}${YELLOW}确认处理以上文件？[y/N]:${NC} ")" confirm_choice

        if [[ "$confirm_choice" =~ ^[Yy]$ ]]; then
            echo
            print_header "开始处理文件"

            # 重置计数器
            PROCESSED_COUNT=0
            MODIFIED_COUNT=0

            # 切换到实际处理模式
            DRY_RUN=false

            # 第二阶段：实际处理收集到的文件
            for file in "${FILES_TO_PROCESS[@]}"; do
                process_file "$file"
            done

            # 显示最终统计信息
            print_header "处理完成 ✨"
            echo -e "${BOLD}统计信息:${NC}"
            echo -e "  处理文件数: ${CYAN}${#FILES_TO_PROCESS[@]}${NC}"
            echo -e "  成功修改: ${GREEN}$MODIFIED_COUNT${NC}"

            if [ "$MODIFIED_COUNT" -gt 0 ] && [ "$BACKUP_ENABLED" = true ]; then
                echo
                print_success "所有修改的文件都已创建备份（.bak）"
                print_info "如果需要恢复，可以使用备份文件"
            fi
        else
            print_info "操作已取消，未修改任何文件"
            exit 0
        fi
    else
        # 没有需要处理的文件
        print_header "预览完成"
        echo -e "${BOLD}统计信息:${NC}"
        echo -e "  扫描文件数: ${CYAN}$PROCESSED_COUNT${NC}"
        echo -e "  需要处理的文件数: ${GREEN}0${NC}"
        echo
        print_success "没有发现需要处理的文件"
    fi
}

# 执行主程序
main "$@"
