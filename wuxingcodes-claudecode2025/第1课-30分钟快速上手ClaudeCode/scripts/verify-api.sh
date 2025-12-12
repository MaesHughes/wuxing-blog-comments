#!/bin/bash

# 验证API密钥脚本

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "错误：未设置ANTHROPIC_API_KEY环境变量"
    echo "请运行：export ANTHROPIC_API_KEY='你的API密钥'"
    exit 1
fi

echo "验证API连接..."

# 测试API连接 - 使用最新的模型
response=$(curl -s -w "%{http_code}" -o /dev/null \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -d '{
        "model": "claude-3-5-haiku-20241022",
        "max_tokens": 10,
        "messages": [{"role": "user", "content": "Hi"}]
    }' \
    https://api.anthropic.com/v1/messages)

if [ "$response" = "200" ]; then
    echo "✅ API连接成功！"
else
    echo "❌ API连接失败，HTTP状态码：$response"
    echo "请检查API密钥是否正确"
fi