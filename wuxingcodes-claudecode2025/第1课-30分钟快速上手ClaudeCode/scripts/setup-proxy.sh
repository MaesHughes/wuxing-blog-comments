#!/bin/bash

echo "配置代理环境"

# 设置代理
read -p "请输入代理地址 (格式: http://proxy.company.com:8080): " PROXY

if [ -z "$PROXY" ]; then
    echo "未输入代理地址，退出配置"
    exit 0
fi

# 设置npm代理
npm config set proxy $PROXY
npm config set https-proxy $PROXY

# 设置环境变量
export HTTP_PROXY=$PROXY
export HTTPS_PROXY=$PROXY
export NO_PROXY=localhost,127.0.0.1

# 添加到shell配置
add_to_shell() {
    local shell_file="$1"

    if [ -f "$shell_file" ]; then
        grep -q "HTTP_PROXY" "$shell_file" || echo "export HTTP_PROXY=$PROXY" >> "$shell_file"
        grep -q "HTTPS_PROXY" "$shell_file" || echo "export HTTPS_PROXY=$PROXY" >> "$shell_file"
        grep -q "NO_PROXY" "$shell_file" || echo "export NO_PROXY=localhost,127.0.0.1" >> "$shell_file"
        echo "已添加到 $shell_file"
    fi
}

add_to_shell ~/.zshrc
add_to_shell ~/.bashrc
add_to_shell ~/.profile

echo "代理配置完成"
echo ""
echo "如需取消代理，运行："
echo "npm config delete proxy"
echo "npm config delete https-proxy"
echo "unset HTTP_PROXY HTTPS_PROXY NO_PROXY"