@echo off
echo ========================================
echo ClaudeCode 诊断工具
echo ========================================

echo.
echo 1. 检查Node.js版本:
node --version

echo.
echo 2. 检查npm版本:
npm --version

echo.
echo 3. 检查ClaudeCode安装:
claude --version 2>nul || echo ClaudeCode未安装

echo.
echo 4. 检查环境变量:
echo ANTHROPIC_API_KEY=%ANTHROPIC_API_KEY%

echo.
echo 5. 检查npm配置:
npm config list | findstr registry

echo.
echo 6. 测试API连接:
powershell -Command "try { $response = Invoke-RestMethod -Uri 'https://api.anthropic.com/v1/messages' -Method POST -Headers @{'x-api-key'='%ANTHROPIC_API_KEY%'; 'content-type'='application/json'} -Body '{\"model\":\"claude-3-5-haiku-20241022\",\"max_tokens\":1,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}' -TimeoutSec 10; Write-Host 'API连接成功' -ForegroundColor Green } catch { Write-Host 'API连接失败' -ForegroundColor Red }"

pause