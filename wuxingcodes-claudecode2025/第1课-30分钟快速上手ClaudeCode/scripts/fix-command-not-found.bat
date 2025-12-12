@echo off
echo 解决 command not found 错误

REM 方法1：检查npm全局路径
for /f "tokens=*" %%i in ('npm config get prefix 2^>nul') do set NPM_PREFIX=%%i
echo npm全局路径: %NPM_PREFIX%

REM 方法2：添加到PATH
echo %PATH% | findstr /i "%NPM_PREFIX%" >nul
if %errorlevel% neq 0 (
    echo 添加npm路径到系统PATH...
    setx PATH "%PATH%;%NPM_PREFIX%"
    echo 已添加，请重新打开命令行窗口
) else (
    echo npm路径已在PATH中
)

REM 方法3：刷新环境变量
call refreshenv 2>nul

echo 已尝试修复PATH，请重新打开命令行窗口
pause