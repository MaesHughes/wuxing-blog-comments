#!/bin/bash

echo "修复权限错误"

# 方法1：修改npm目录权限
echo "修复npm权限..."
sudo chown -R $(whoami):$(whoami) ~/.npm 2>/dev/null
sudo chown -R $(whoami):$(whoami) $(npm config get prefix)/lib/node_modules 2>/dev/null

# 方法2：使用nvm
if ! command -v nvm &> /dev/null; then
    echo "是否安装nvm？(y/n)"
    read -r answer
    if [ "$answer" = "y" ]; then
        echo "安装nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install 18
        nvm use 18
        echo "请重启终端"
    fi
fi

# 方法3：配置npm使用用户目录
echo "配置npm使用用户目录..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# 添加到PATH
add_to_shell() {
    local shell_file="$1"
    local line="export PATH=~/.npm-global/bin:\$PATH"

    if [ -f "$shell_file" ] && ! grep -q "npm-global/bin" "$shell_file"; then
        echo "$line" >> "$shell_file"
        echo "已添加到 $shell_file"
    fi
}

add_to_shell ~/.zshrc
add_to_shell ~/.bashrc
add_to_shell ~/.profile

echo "权限修复完成！"
echo "请运行: source ~/.zshrc 或 source ~/.bashrc"