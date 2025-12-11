#!/bin/bash
# 项目清理脚本
# 使用ClaudeCode生成：claude "生成一个项目清理脚本，删除临时文件和缓存"

echo "🧹 开始清理项目..."

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 统计变量
removed_files=0
removed_dirs=0

# 清理函数
cleanup_files() {
    echo -e "${YELLOW}清理临时文件...${NC}"

    # 清理日志文件
    find . -name "*.log" -type f -delete 2>/dev/null
    find . -name "*.logs" -type f -delete 2>/dev/null

    # 清理临时文件
    find . -name "*.tmp" -type f -delete 2>/dev/null
    find . -name "*.temp" -type f -delete 2>/dev/null
    find . -name ".DS_Store" -type f -delete 2>/dev/null
    find . -name "Thumbs.db" -type f -delete 2>/dev/null

    # 清理编辑器临时文件
    find . -name "*.swp" -type f -delete 2>/dev/null
    find . -name "*.swo" -type f -delete 2>/dev/null
    find . -name "*~" -type f -delete 2>/dev/null

    # 清理备份文件
    find . -name "*.bak" -type f -delete 2>/dev/null
    find . -name "*.backup" -type f -delete 2>/dev/null

    echo -e "${GREEN}✓ 临时文件清理完成${NC}"
}

# 清理目录
cleanup_dirs() {
    echo -e "${YELLOW}清理缓存目录...${NC}"

    # 清理node_modules（如果存在lock文件）
    if [ -f "package-lock.json" ] || [ -f "yarn.lock" ]; then
        if [ -d "node_modules" ]; then
            rm -rf node_modules
            echo -e "${GREEN}✓ 删除 node_modules${NC}"
            ((removed_dirs++))
        fi
    fi

    # 清理dist/build目录
    [ -d "dist" ] && rm -rf dist && echo -e "${GREEN}✓ 删除 dist${NC}" && ((removed_dirs++))
    [ -d "build" ] && rm -rf build && echo -e "${GREEN}✓ 删除 build${NC}" && ((removed_dirs++))
    [ -d ".next" ] && rm -rf .next && echo -e "${GREEN}✓ 删除 .next${NC}" && ((removed_dirs++))
    [ -d ".nuxt" ] && rm -rf .nuxt && echo -e "${GREEN}✓ 删除 .nuxt${NC}" && ((removed_dirs++))
    [ -d ".vuepress/dist" ] && rm -rf .vuepress/dist && echo -e "${GREEN}✓ 删除 .vuepress/dist${NC}" && ((removed_dirs++))

    # 清理缓存目录
    [ -d ".cache" ] && rm -rf .cache && echo -e "${GREEN}✓ 删除 .cache${NC}" && ((removed_dirs++))
    [ -d ".parcel-cache" ] && rm -rf .parcel-cache && echo -e "${GREEN}✓ 删除 .parcel-cache${NC}" && ((removed_dirs++))
    [ -d "coverage" ] && rm -rf coverage && echo -e "${GREEN}✓ 删除 coverage${NC}" && ((removed_dirs++))
    [ -d ".nyc_output" ] && rm -rf .nyc_output && echo -e "${GREEN}✓ 删除 .nyc_output${NC}" && ((removed_dirs++))

    # 清理IDE配置
    [ -d ".vscode" ] && rm -rf .vscode && echo -e "${GREEN}✓ 删除 .vscode${NC}" && ((removed_dirs++))
    [ -d ".idea" ] && rm -rf .idea && echo -e "${GREEN}✓ 删除 .idea${NC}" && ((removed_dirs++))
}

# 清理Git
cleanup_git() {
    if [ -d ".git" ]; then
        echo -e "${YELLOW}清理Git...${NC}"

        # Git清理
        git clean -fd 2>/dev/null
        git gc --prune=now 2>/dev/null

        echo -e "${GREEN}✓ Git清理完成${NC}"
    fi
}

# 显示统计
show_stats() {
    echo ""
    echo -e "${GREEN}🎉 清理完成！${NC}"
    echo "-------------------"
    echo "删除的目录数: $removed_dirs"
    echo "删除的文件数: $(find . -type f -newer /tmp/start_time 2>/dev/null | wc -l)"
    echo ""
    echo "建议运行: npm install 重新安装依赖"
}

# 创建时间戳文件
touch /tmp/start_time

# 主流程
main() {
    echo -e "${GREEN}项目路径: $(pwd)${NC}"
    echo ""

    # 确认是否继续
    read -p "确认要清理这个项目吗？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}取消清理${NC}"
        exit 1
    fi

    # 执行清理
    cleanup_files
    cleanup_dirs
    cleanup_git

    # 显示统计
    show_stats

    # 删除时间戳文件
    rm -f /tmp/start_time
}

# 运行主函数
main