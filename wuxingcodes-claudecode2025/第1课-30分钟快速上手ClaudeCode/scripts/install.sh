#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        print_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
    print_message "检测到操作系统: $OS"
}

# 检查Node.js
check_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | cut -d'v' -f2)
        REQUIRED_VERSION="18.0.0"

        if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
            print_message "Node.js版本: $NODE_VERSION ✓"
        else
            print_error "Node.js版本过低: $NODE_VERSION，需要18.0.0+"
            install_nodejs
        fi
    else
        print_error "未检测到Node.js"
        install_nodejs
    fi
}

# 安装Node.js
install_nodejs() {
    print_message "正在安装Node.js..."

    if [[ "$OS" == "macos" ]]; then
        # 检查Homebrew
        if command -v brew &> /dev/null; then
            brew install node@18
        else
            print_error "请先安装Homebrew: https://brew.sh/"
            exit 1
        fi
    else
        # Linux
        print_message "请访问 https://nodejs.org 下载Node.js 18+"
        exit 1
    fi
}

# 安装ClaudeCode
install_claudecode() {
    print_message "正在安装ClaudeCode..."

    if npm install -g @anthropic-ai/claude-code; then
        print_message "ClaudeCode安装成功！"
    else
        print_error "ClaudeCode安装失败"
        exit 1
    fi
}

# 验证安装
verify_installation() {
    print_message "验证安装..."

    if command -v claude &> /dev/null; then
        VERSION=$(claude --version 2>/dev/null || echo "安装成功")
        print_message "ClaudeCode版本: $VERSION"
        return 0
    else
        print_error "ClaudeCode未成功安装"
        return 1
    fi
}

# 主安装流程
main() {
    echo "========================================"
    echo "    ClaudeCode 一键安装脚本"
    echo "========================================"
    echo

    # 检测操作系统
    detect_os

    # 检查Node.js
    check_nodejs

    # 安装ClaudeCode
    install_claudecode

    # 验证安装
    if verify_installation; then
        echo
        print_message "✅ 安装完成！"
        echo
        echo "下一步："
        echo "1. 设置API密钥："
        echo "   export ANTHROPIC_API_KEY='sk-ant-xxx'"
        echo
        echo "2. 创建测试项目："
        echo "   mkdir claude-test && cd claude-test"
        echo "   claude init"
        echo
        print_message "📚 更多教程：关注'大熊掌门'"
    else
        print_error "安装失败，请查看错误信息"
        exit 1
    fi
}

# 运行主程序
main "$@"