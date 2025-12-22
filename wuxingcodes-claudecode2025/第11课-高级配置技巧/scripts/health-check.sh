#!/bin/bash

# ClaudeCode 健康检查脚本
# 用于检查ClaudeCode的运行状态和配置

echo "🔍 ClaudeCode 健康检查"
echo "=================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查结果统计
PASSED=0
WARNINGS=0
ERRORS=0

# 检查函数
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $2${NC}"
        ((ERRORS++))
    fi
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

# 1. 检查ClaudeCode安装
echo -e "\n📦 检查安装状态"
if command -v claude &> /dev/null; then
    VERSION=$(claude --version 2>/dev/null | head -n1)
    check_result 0 "ClaudeCode已安装: $VERSION"
else
    check_result 1 "ClaudeCode未安装"
fi

# 2. 检查配置文件
echo -e "\n⚙️  检查配置文件"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # 验证JSON格式
    if python -c "import json; json.load(open('$SETTINGS_FILE'))" 2>/dev/null; then
        check_result 0 "配置文件格式正确"
    else
        check_result 1 "配置文件JSON格式错误"
    fi

    # 检查文件权限
    PERMISSIONS=$(stat -c "%a" "$SETTINGS_FILE" 2>/dev/null)
    if [ "$PERMISSIONS" = "600" ] || [ "$PERMISSIONS" = "644" ]; then
        check_result 0 "配置文件权限正确 ($PERMISSIONS)"
    else
        warning "配置文件权限过于宽松 ($PERMISSIONS)，建议设置为600或644"
    fi
else
    warning "配置文件不存在，将使用默认配置"
fi

# 3. 检查认证状态
echo -e "\n🔐 检查认证状态"
AUTH_FILE="$HOME/.config/claude-code/auth.json"

if [ -f "$AUTH_FILE" ]; then
    # 检查文件权限
    PERMISSIONS=$(stat -c "%a" "$AUTH_FILE" 2>/dev/null)
    if [ "$PERMISSIONS" = "600" ]; then
        check_result 0 "认证文件权限正确"
    else
        warning "认证文件权限过于宽松 ($PERMISSIONS)，建议设置为600"
    fi

    # 检查文件内容是否为空
    if [ -s "$AUTH_FILE" ]; then
        check_result 0 "认证文件存在且不为空"
    else
        check_result 1 "认证文件为空"
    fi
else
    check_result 1 "认证文件不存在，需要重新登录"
fi

# 4. 检查环境变量
echo -e "\n🌍 检查环境变量"

# API密钥
if [ -n "$ANTHROPIC_API_KEY" ]; then
    # 简单验证API密钥格式
    if [[ "$ANTHROPIC_API_KEY" =~ ^sk-ant-api03-[A-Za-z0-9_-]{95}$ ]]; then
        check_result 0 "API密钥格式正确"
    else
        warning "API密钥格式可能不正确"
    fi
else
    warning "ANTHROPIC_API_KEY未设置"
fi

# 其他重要环境变量
DEBUG_VAR=${CLAUDE_DEBUG:-0}
if [ "$DEBUG_VAR" = "0" ]; then
    check_result 0 "调试模式已关闭"
else
    warning "调试模式已启用 ($CLAUDE_DEBUG)"
fi

# 5. 检查网络连接
echo -e "\n🌐 检查网络连接"
if curl -s --connect-timeout 5 https://api.anthropic.com > /dev/null 2>&1; then
    check_result 0 "可以连接到Anthropic API"
else
    check_result 1 "无法连接到Anthropic API"
fi

# 6. 检查依赖工具
echo -e "\n🛠️  检查依赖工具"

# ripgrep
if command -v rg &> /dev/null; then
    RG_VERSION=$(rg --version | head -n1)
    check_result 0 "ripgrep已安装: $RG_VERSION"

    # 检查是否在环境变量中配置使用ripgrep
    if [ "$USE_BUILTIN_RIPGREP" = "0" ]; then
        check_result 0 "已配置使用ripgrep"
    else
        warning "未配置使用ripgrep，搜索性能可能不佳"
    fi
else
    warning "ripgrep未安装，建议安装以提升搜索性能"
fi

# Node.js (如果需要)
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    check_result 0 "Node.js已安装: $NODE_VERSION"
else
    warning "Node.js未安装（某些功能可能需要）"
fi

# 7. 检查磁盘空间
echo -e "\n💾 检查磁盘空间"
HOME_USAGE=$(df -h "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$HOME_USAGE" -lt 80 ]; then
    check_result 0 "主目录磁盘空间充足 (使用${HOME_USAGE}%)"
else
    warning "主目录磁盘空间不足 (使用${HOME_USAGE}%)"
fi

# 检查Claude目录大小
if [ -d "$CLAUDE_DIR" ]; then
    CLAUDE_SIZE=$(du -sh "$CLAUDE_DIR" 2>/dev/null | cut -f1)
    echo -e "   Claude配置目录大小: $CLAUDE_SIZE"
fi

# 8. 检查日志文件
echo -e "\n📝 检查日志文件"
LOG_DIR="$CLAUDE_DIR/logs"

if [ -d "$LOG_DIR" ]; then
    LOG_COUNT=$(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l)
    check_result 0 "发现 $LOG_COUNT 个日志文件"

    # 检查日志文件大小
    LARGE_LOGS=$(find "$LOG_DIR" -name "*.log" -size +10M 2>/dev/null | wc -l)
    if [ "$LARGE_LOGS" -eq 0 ]; then
        check_result 0 "日志文件大小正常"
    else
        warning "发现 $LARGE_LOGS 个大型日志文件 (>10MB)"
    fi
else
    warning "日志目录不存在"
fi

# 9. 运行ClaudeCode内置检查
echo -e "\n🔧 运行内置诊断"
if command -v claude &> /dev/null; then
    # 尝试运行/doctor命令
    if claude /doctor &> /dev/null; then
        check_result 0 "内置诊断通过"
    else
        warning "内置诊断发现问题"
    fi
fi

# 10. 生成报告
echo -e "\n"$(printf '=%.0s' {1..50})
echo "📊 健康检查总结"
echo $(printf '=%.0s' {1..50})

echo -e "通过: ${GREEN}$PASSED${NC}"
echo -e "警告: ${YELLOW}$WARNINGS${NC}"
echo -e "错误: ${RED}$ERRORS${NC}"

# 总体评估
TOTAL=$((PASSED + WARNINGS + ERRORS))
if [ $ERRORS -gt 0 ]; then
    echo -e "\n${RED}❌ 发现严重问题，请立即处理！${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  发现警告，建议尽快处理${NC}"
    exit 0
else
    echo -e "\n${GREEN}✅ 系统状态良好！${NC}"
    exit 0
fi

# 保存报告
REPORT_DIR="$CLAUDE_DIR/reports"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/health-check-$(date +%Y%m%d_%H%M%S).txt"

{
    echo "ClaudeCode 健康检查报告"
    echo "====================="
    echo "时间: $(date)"
    echo "通过: $PASSED"
    echo "警告: $WARNINGS"
    echo "错误: $ERRORS"
    echo ""
    echo "系统信息:"
    echo "操作系统: $(uname -s)"
    echo "内核版本: $(uname -r)"
    echo "Shell: $SHELL"
    echo ""
    echo "环境变量:"
    echo "CLAUDE_DEBUG: ${CLAUDE_DEBUG:-未设置}"
    echo "USE_BUILTIN_RIPGREP: ${USE_BUILTIN_RIPGREP:-未设置}"
    echo "DISABLE_PROMPT_CACHING: ${DISABLE_PROMPT_CACHING:-未设置}"
} > "$REPORT_FILE"

echo -e "\n📄 报告已保存到: $REPORT_FILE"