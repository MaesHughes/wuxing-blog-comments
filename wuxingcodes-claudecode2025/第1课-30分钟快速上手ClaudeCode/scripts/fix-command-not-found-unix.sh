#!/bin/bash

echo "解决 command not found 错误"

# 方法1：查找npm全局路径
NPM_PREFIX=$(npm config get prefix)
echo "npm全局路径: $NPM_PREFIX"

# 方法2：添加到shell配置
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# 添加到PATH
if ! grep -q "$NPM_PREFIX/bin" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"\$PATH:$NPM_PREFIX/bin\"" >> "$SHELL_RC"
    echo "已添加到 $SHELL_RC"
fi

# 方法3：立即生效
export PATH="$PATH:$NPM_PREFIX/bin"

# 方法4：创建符号链接
if [ -w "/usr/local/bin" ]; then
    sudo ln -sf "$NPM_PREFIX/bin/claude" /usr/local/bin/claude 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "已创建符号链接到 /usr/local/bin/claude"
    fi
fi

echo "请运行: source $SHELL_RC 或重新打开终端"