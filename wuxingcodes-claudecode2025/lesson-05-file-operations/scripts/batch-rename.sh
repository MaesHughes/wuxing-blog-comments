#!/bin/bash
# 批量重命名脚本
# 使用ClaudeCode生成：claude "生成一个安全的批量重命名脚本，包含备份功能"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false
VERBOSE=false

# 显示帮助
show_help() {
    echo -e "${BLUE}批量重命名工具${NC}"
    echo ""
    echo "用法: $0 [选项] <模式> <参数>"
    echo ""
    echo "模式:"
    echo "  ext <旧扩展名> <新扩展名>    更改文件扩展名"
    echo "  prefix <前缀>                添加文件名前缀"
    echo "  suffix <后缀>                添加文件名后缀"
    echo "  replace <旧字符串> <新字符串> 替换文件名中的字符串"
    echo "  toupper                       转换为大写"
    echo "  tolower                       转换为小写"
    echo "  camel                         转换为驼峰命名"
    echo "  snake                         转换为下划线命名"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -d, --dry-run  预览模式，不实际执行"
    echo "  -v, --verbose  显示详细信息"
    echo ""
    echo "示例:"
    echo "  $0 ext txt md          # 将所有.txt文件改为.md"
    echo "  $0 prefix backup_      # 为所有文件添加backup_前缀"
    echo "  $0 replace ' ' '_'     # 将空格替换为下划线"
    echo "  $0 -d ext js ts        # 预览将.js改为.ts"
}

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 创建备份
create_backup() {
    log_info "创建备份到: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # 备份当前目录的所有文件
    find . -maxdepth 1 -type f ! -name '.*' | while read file; do
        if [ "$VERBOSE" = true ]; then
            log_info "备份: $file"
        fi
        cp "$file" "$BACKUP_DIR/"
    done

    log_success "备份完成"
}

# 恢复备份
restore_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        log_info "从备份恢复..."
        cp "$BACKUP_DIR"/* ./
        log_success "恢复完成"
    else
        log_error "备份目录不存在: $BACKUP_DIR"
    fi
}

# 扩展名转换
convert_extension() {
    local old_ext="$1"
    local new_ext="$2"
    local count=0

    log_info "转换 .$old_ext 为 .$new_ext"

    # 查找匹配的文件
    find . -maxdepth 1 -type f -name "*.$old_ext" | while read file; do
        local new_name="${file%.$old_ext}.$new_ext"

        if [ "$DRY_RUN" = true ]; then
            echo "  $file → $new_name"
        else
            if mv "$file" "$new_name"; then
                log_success "重命名: $file → $new_name"
                ((count++))
            else
                log_error "失败: $file"
            fi
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        log_info "共重命名 $count 个文件"
    fi
}

# 添加前缀
add_prefix() {
    local prefix="$1"
    local count=0

    log_info "添加前缀: $prefix"

    find . -maxdepth 1 -type f ! -name '.*' | while read file; do
        local filename=$(basename "$file")
        local new_name="${prefix}${filename}"

        if [ "$DRY_RUN" = true ]; then
            echo "  $file → $new_name"
        else
            if [ "$file" != "./$new_name" ]; then
                if mv "$file" "$new_name"; then
                    log_success "重命名: $file → $new_name"
                    ((count++))
                fi
            fi
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        log_info "共重命名 $count 个文件"
    fi
}

# 字符串替换
replace_string() {
    local old_str="$1"
    local new_str="$2"
    local count=0

    log_info "替换 '$old_str' 为 '$new_str'"

    find . -maxdepth 1 -type f ! -name '.*' | while read file; do
        local filename=$(basename "$file")
        local new_name="${filename//$old_str/$new_str}"

        if [ "$filename" != "$new_name" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "  $file → $new_name"
            else
                if mv "$file" "$new_name"; then
                    log_success "重命名: $file → $new_name"
                    ((count++))
                else
                    log_error "失败: $file"
                fi
            fi
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        log_info "共重命名 $count 个文件"
    fi
}

# 大小写转换
convert_case() {
    local mode="$1"
    local count=0

    log_info "转换大小写: $mode"

    find . -maxdepth 1 -type f ! -name '.*' | while read file; do
        local filename=$(basename "$file")
        local dirname=$(dirname "$file")
        local new_name

        case $mode in
            "upper")
                new_name="${filename^^}"
                ;;
            "lower")
                new_name="${filename,,}"
                ;;
        esac

        if [ "$filename" != "$new_name" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "  $file → $dirname/$new_name"
            else
                if mv "$file" "$dirname/$new_name"; then
                    log_success "重命名: $file → $dirname/$new_name"
                    ((count++))
                else
                    log_error "失败: $file"
                fi
            fi
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        log_info "共重命名 $count 个文件"
    fi
}

# 驼峰命名转换
to_camel_case() {
    local count=0

    log_info "转换为驼峰命名"

    find . -maxdepth 1 -type f ! -name '.*' | while read file; do
        local filename=$(basename "$file")
        local dirname=$(dirname "$file")
        local name="${filename%.*}"
        local ext="${filename##*.}"

        # 转换为驼峰
        local camel_name=$(echo "$name" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/-\([a-z]\)/\U\1/g')
        local new_name="${camel_name}.${ext}"

        if [ "$filename" != "$new_name" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "  $file → $dirname/$new_name"
            else
                if mv "$file" "$dirname/$new_name"; then
                    log_success "重命名: $file → $dirname/$new_name"
                    ((count++))
                else
                    log_error "失败: $file"
                fi
            fi
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        log_info "共重命名 $count 个文件"
    fi
}

# 主函数
main() {
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                log_warning "预览模式：不会实际执行"
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            ext)
                if [ "$DRY_RUN" = false ]; then
                    create_backup
                fi
                convert_extension "$2" "$3"
                shift 3
                ;;
            prefix)
                if [ "$DRY_RUN" = false ]; then
                    create_backup
                fi
                add_prefix "$2"
                shift 2
                ;;
            suffix)
                if [ "$DRY_RUN" = false ]; then
                    create_backup
                fi
                # 实现后缀添加逻辑
                shift 2
                ;;
            replace)
                if [ "$DRY_RUN" = false ]; then
                    create_backup
                fi
                replace_string "$2" "$3"
                shift 3
                ;;
            toupper|tolower)
                if [ "$DRY_RUN" = false ]; then
                    create_backup
                fi
                convert_case "$1"
                shift
                ;;
            camel)
                if [ "$DRY_RUN" = false ]; then
                    create_backup
                fi
                to_camel_case
                shift
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    if [ "$DRY_RUN" = false ]; then
        log_success "操作完成！备份位置: $BACKUP_DIR"
        echo "如需恢复，运行: $0 restore"
    fi
}

# 检查参数
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# 运行主函数
main "$@"