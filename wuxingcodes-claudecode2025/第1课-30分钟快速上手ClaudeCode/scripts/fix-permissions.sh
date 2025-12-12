#!/bin/bash

# macOS/Linux权限修复脚本

echo "修复npm权限..."

# 修复npm目录权限
sudo chown -R $(whoami) ~/.npm

# 修复全局模块目录权限
sudo chown -R $(whoami) /usr/local/lib/node_modules/

# 或者配置npm使用用户目录
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'

# 添加到PATH（如果还没有）
if ! grep -q 'npm-global/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
fi

echo "权限修复完成！"
echo "请运行：source ~/.zshrc 或 source ~/.bashrc"