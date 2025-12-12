#!/bin/bash

echo "管理Node.js版本"

# 检查当前版本
echo "当前Node.js版本: $(node -v 2>/dev/null || echo '未安装')"

# 使用nvm管理版本
if command -v nvm &> /dev/null; then
    echo "可用的Node.js版本:"
    nvm ls 2>/dev/null || echo "未找到已安装的版本"

    echo ""
    echo "安装并切换到Node.js 18:"
    nvm install 18
    nvm use 18
    nvm alias default 18

    echo "重新安装ClaudeCode..."
    npm install -g @anthropic-ai/claude-code

    echo "验证安装:"
    claude --version 2>/dev/null || echo "ClaudeCode未安装"
else
    echo "nvm未安装"
    echo ""
    echo "安装nvm："
    echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo ""
    echo "或直接从 https://nodejs.org 下载Node.js 18+"
fi