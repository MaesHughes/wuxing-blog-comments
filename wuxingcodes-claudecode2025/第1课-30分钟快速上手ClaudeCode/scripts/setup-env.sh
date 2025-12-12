#!/bin/bash

echo "设置ClaudeCode环境变量..."

# 创建环境变量文件
cat > ~/.claude-env << 'EOF'
# ClaudeCode环境变量
export ANTHROPIC_API_KEY="sk-ant-xxx"
export ANTHROPIC_DEFAULT_MODEL="claude-3-5-sonnet-20241022"
export CLAUDE_CACHE_ENABLED="1"
export CLAUDE_CACHE_SIZE="1GB"
export CLAUDE_LOG_LEVEL="info"
EOF

# 添加到shell配置文件
if [ -f ~/.zshrc ]; then
    echo 'source ~/.claude-env' >> ~/.zshrc
    echo "已添加到 ~/.zshrc"
elif [ -f ~/.bashrc ]; then
    echo 'source ~/.claude-env' >> ~/.bashrc
    echo "已添加到 ~/.bashrc"
fi

# 立即生效
source ~/.claude-env

echo "环境变量设置完成！"