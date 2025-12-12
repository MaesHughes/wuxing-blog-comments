@echo off
echo 正在安装ClaudeCode...

REM 检查Node.js是否已安装
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未检测到Node.js，请先安装Node.js 18+
    echo 下载地址：https://nodejs.org
    pause
    exit /b 1
)

REM 安装ClaudeCode
echo 正在通过npm安装ClaudeCode...
npm install -g @anthropic-ai/claude-code

REM 验证安装
echo 验证安装...
claude --version

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo    ClaudeCode安装成功！
    echo ========================================
    echo.
    echo 下一步：
    echo 1. 设置API密钥（可选，可稍后设置）
    set /p api_key=请输入您的API密钥（sk-ant-开头，直接回车跳过）:
    if not "%api_key%"=="" (
        setx ANTHROPIC_API_KEY "%api_key%"
        echo API密钥已设置
    )
    echo.
    echo 2. 创建测试项目
    mkdir claude-test
    cd claude-test
    claude init
    echo 测试项目创建成功！
    echo.
    echo 开始使用ClaudeCode吧！
) else (
    echo 安装失败，请检查错误信息
)

pause