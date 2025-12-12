#!/bin/bash

echo "完全清理ClaudeCode"

# 确认操作
echo "警告：这将删除所有ClaudeCode相关配置和缓存"
read -p "确定要继续吗？(y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "取消清理"
    exit 0
fi

# 停止所有ClaudeCode进程
echo "停止ClaudeCode进程..."
pkill -f claude 2>/dev/null || echo "没有运行中的ClaudeCode进程"

# 清理npm全局安装
echo "卸载ClaudeCode..."
npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || echo "ClaudeCode未通过npm全局安装"

# 清理配置文件
echo "清理配置文件..."
rm -rf ~/.claude 2>/dev/null
rm -rf ~/.config/claude 2>/dev/null

# 清理缓存
echo "清理缓存..."
npm cache clean --force 2>/dev/null

# 清理日志
rm -rf ~/.claude-logs 2>/dev/null

# 清理环境变量（可选）
echo ""
echo "是否从shell配置中移除ClaudeCode相关环境变量？(y/n)"
read -r remove_env
if [ "$remove_env" = "y" ]; then
    for shell_file in ~/.zshrc ~/.bashrc ~/.profile; do
        if [ -f "$shell_file" ]; then
            # 创建临时文件
            temp_file=$(mktemp)
            grep -v "ANTHROPIC_API_KEY\|CLAUDE_" "$shell_file" > "$temp_file"
            mv "$temp_file" "$shell_file"
            echo "已清理 $shell_file"
        fi
    done
fi

echo ""
echo "清理完成！"
echo "请重新打开终端，然后可以重新安装ClaudeCode"