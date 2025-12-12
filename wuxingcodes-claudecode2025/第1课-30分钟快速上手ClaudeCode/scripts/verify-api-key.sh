#!/bin/bash

echo "API密钥诊断和修复"

# 检查API密钥格式
if [ -n "$ANTHROPIC_API_KEY" ]; then
    if [[ $ANTHROPIC_API_KEY == sk-ant-* ]]; then
        echo "✅ API密钥格式正确"
    else
        echo "❌ API密钥格式错误，应该以sk-ant-开头"
    fi

    # 测试API密钥
    echo "测试API连接..."
    response=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "content-type: application/json" \
        -d '{"model":"claude-3-5-haiku-20241022","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
        https://api.anthropic.com/v1/messages)

    if [ "$response" = "200" ]; then
        echo "✅ API密钥有效"
    elif [ "$response" = "401" ]; then
        echo "❌ API密钥无效"
    else
        echo "⚠️ API响应异常: HTTP $response"
    fi
else
    echo "❌ 未设置API密钥"
    echo ""
    echo "请设置API密钥："
    echo "export ANTHROPIC_API_KEY='sk-ant-xxx'"
    echo ""
    echo "或添加到 ~/.zshrc："
    echo "echo 'export ANTHROPIC_API_KEY=\"sk-ant-xxx\"' >> ~/.zshrc"
fi

echo ""
echo "提示：请将 sk-ant-xxx 替换为您的实际API密钥"