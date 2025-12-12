#!/bin/bash

echo "========================================"
echo "ClaudeCode 诊断工具"
echo "========================================"

echo -e "\n1. 检查Node.js版本:"
node --version || echo "Node.js未安装"

echo -e "\n2. 检查npm版本:"
npm --version || echo "npm未安装"

echo -e "\n3. 检查ClaudeCode安装:"
which claude && claude --version || echo "ClaudeCode未安装"

echo -e "\n4. 检查环境变量:"
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:20}..."
else
    echo "ANTHROPIC_API_KEY: 未设置"
fi

echo -e "\n5. 检查npm配置:"
npm config get registry

echo -e "\n6. 检查PATH:"
echo $PATH | tr ':' '\n' | grep -E "(npm|node)" || echo "未找到npm/node路径"

echo -e "\n7. 测试API连接:"
if [ -n "$ANTHROPIC_API_KEY" ]; then
    response=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "content-type: application/json" \
        -d '{"model":"claude-3-5-haiku-20241022","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
        https://api.anthropic.com/v1/messages)
    if [ "$response" = "200" ]; then
        echo "✅ API连接成功"
    else
        echo "❌ API连接失败 (HTTP $response)"
    fi
else
    echo "❌ 未设置API密钥"
fi

echo -e "\n8. 检查磁盘空间:"
df -h . 2>/dev/null | tail -1 || echo "无法获取磁盘信息"

echo -e "\n9. 检查内存使用:"
free -h 2>/dev/null || vm_stat 2>/dev/null || echo "无法获取内存信息"