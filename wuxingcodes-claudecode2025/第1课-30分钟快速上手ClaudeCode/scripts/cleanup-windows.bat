@echo off
echo 完全清理ClaudeCode

echo 警告：这将删除所有ClaudeCode相关配置和缓存
set /p confirm=确定要继续吗？(y/n):
if /i not "%confirm%"=="y" (
    echo 取消清理
    pause
    exit /b 0
)

REM 停止所有ClaudeCode进程
echo 停止ClaudeCode进程...
taskkill /F /IM claude.exe 2>nul
taskkill /F /IM node.exe /FI "WINDOWTITLE eq *claude*" 2>nul

REM 卸载npm包
echo 卸载ClaudeCode...
npm uninstall -g @anthropic-ai/claude-code 2>nul

REM 清理配置文件
echo 清理配置文件...
rd /s /q "%APPDATA%\Claude" 2>nul
rd /s /q "%LOCALAPPDATA%\Claude" 2>nul
rd /s /q "%USERPROFILE%\.claude" 2>nul

REM 清理环境变量
echo.
echo 是否清理环境变量？(y/n)
set /p clear_env=
if /i "%clear_env%"=="y" (
    setx ANTHROPIC_API_KEY ""
    setx CLAUDE_DEBUG ""
    setx CLAUDE_CACHE_ENABLED ""
    setx CLAUDE_CACHE_SIZE ""
    setx CLAUDE_LOG_LEVEL ""
    setx ANTHROPIC_DEFAULT_MODEL ""
    echo 环境变量已清理
)

REM 清理npm缓存
echo 清理npm缓存...
npm cache clean --force 2>nul

echo.
echo 清理完成！
echo 请重新打开命令行窗口，然后可以重新安装ClaudeCode
pause