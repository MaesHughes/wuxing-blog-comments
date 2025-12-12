@echo off
echo 设置ClaudeCode环境变量...

REM API密钥
setx ANTHROPIC_API_KEY "sk-ant-xxx"

REM 默认模型
setx ANTHROPIC_DEFAULT_MODEL "claude-3-5-sonnet-20241022"

REM 缓存配置
setx CLAUDE_CACHE_ENABLED "1"
setx CLAUDE_CACHE_SIZE "1GB"

REM 日志级别
setx CLAUDE_LOG_LEVEL "info"

echo 环境变量设置完成！
echo 请重启命令行窗口以使更改生效。