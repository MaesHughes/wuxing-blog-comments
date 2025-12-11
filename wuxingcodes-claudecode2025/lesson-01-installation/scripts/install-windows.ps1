# ClaudeCode Windows 一键安装脚本
# 作者：大熊掌门

param(
    [switch]$SkipGit,
    [switch]$SkipNode,
    [switch]$SkipVSCode
)

Write-Host "🚀 ClaudeCode Windows 安装脚本" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️  请以管理员身份运行此脚本" -ForegroundColor Yellow
    exit 1
}

# 创建安装目录
$installDir = "$env:USERPROFILE\ClaudeCode"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Set-Location $installDir

# 1. 安装 Git
if (-NOT $SkipGit) {
    Write-Host "`n[1/6] 安装 Git..." -ForegroundColor Green

    $gitVersion = git --version 2>$null
    if ($gitVersion) {
        Write-Host "✅ Git 已安装: $gitVersion"
    } else {
        Write-Host "📥 下载 Git..."
        $gitUrl = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.43.0-64-bit.exe"
        $gitInstaller = "$installDir\git-installer.exe"

        try {
            Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
            Write-Host "🔧 安装 Git 中..."
            Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
            Write-Host "✅ Git 安装完成"
        } catch {
            Write-Host "❌ Git 下载失败，请手动安装: https://git-scm.com/download/win" -ForegroundColor Red
        }
    }
}

# 2. 安装 Node.js
if (-NOT $SkipNode) {
    Write-Host "`n[2/6] 安装 Node.js..." -ForegroundColor Green

    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "✅ Node.js 已安装: $nodeVersion"
    } else {
        Write-Host "📥 下载 Node.js..."
        $nodeUrl = "https://nodejs.org/dist/v20.12.2/node-v20.12.2-x64.msi"
        $nodeInstaller = "$installDir\node-installer.msi"

        try {
            Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -UseBasicParsing
            Write-Host "🔧 安装 Node.js 中..."
            Start-Process -FilePath $nodeInstaller -ArgumentList "/quiet", "/norestart" -Wait
            Write-Host "✅ Node.js 安装完成"
        } catch {
            Write-Host "❌ Node.js 下载失败，请手动安装: https://nodejs.org/" -ForegroundColor Red
        }
    }
}

# 3. 安装 VSCode
if (-NOT $SkipVSCode) {
    Write-Host "`n[3/6] 安装 VS Code..." -ForegroundColor Green

    $codeVersion = code --version 2>$null
    if ($codeVersion) {
        Write-Host "✅ VS Code 已安装: $codeVersion"
    } else {
        Write-Host "📥 下载 VS Code..."
        $codeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
        $codeInstaller = "$installDir\vscode-installer.exe"

        try {
            Invoke-WebRequest -Uri $codeUrl -OutFile $codeInstaller -UseBasicParsing
            Write-Host "🔧 安装 VS Code 中..."
            Start-Process -FilePath $codeInstaller -ArgumentList "/VERYSILENT", "/NORESTART", "/MERGETASKS=!runcode" -Wait
            Write-Host "✅ VS Code 安装完成"
        } catch {
            Write-Host "❌ VS Code 下载失败，请手动安装: https://code.visualstudio.com/" -ForegroundColor Red
        }
    }
}

# 4. 安装 Python
Write-Host "`n[4/6] 安装 Python..." -ForegroundColor Green

$pythonVersion = python --version 2>$null
if ($pythonVersion) {
    Write-Host "✅ Python 已安装: $pythonVersion"
} else {
    Write-Host "📥 下载 Python..."
    $pythonUrl = "https://www.python.org/ftp/python/3.12.1/python-3.12.1-amd64.exe"
    $pythonInstaller = "$installDir\python-installer.exe"

    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -UseBasicParsing
        Write-Host "🔧 安装 Python 中..."
        Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait
        Write-Host "✅ Python 安装完成"
    } catch {
        Write-Host "❌ Python 下载失败，请手动安装: https://www.python.org/" -ForegroundColor Red
    }
}

# 5. 克隆 ClaudeCode 仓库
Write-Host "`n[5/6] 克隆 ClaudeCode 仓库..." -ForegroundColor Green

$claudeCodeDir = "$env:USERPROFILE\ClaudeCode-claude-desktop"
if (Test-Path $claudeCodeDir) {
    Write-Host "✅ ClaudeCode 仓库已存在"
} else {
    try {
        Write-Host "📥 克隆 ClaudeCode 仓库..."
        git clone https://github.com/anthropics/claude-desktop.git $claudeCodeDir
        Set-Location $claudeCodeDir
        Write-Host "✅ 仓库克隆完成"
    } catch {
        Write-Host "❌ 克隆失败，请检查网络连接或手动克隆" -ForegroundColor Red
    }
}

# 6. 安装依赖
Write-Host "`n[6/6] 安装依赖..." -ForegroundColor Green

try {
    Set-Location $claudeCodeDir
    npm install
    Write-Host "✅ 依赖安装完成"
} catch {
    Write-Host "❌ 依赖安装失败，请手动运行 'npm install'" -ForegroundColor Red
}

# 创建桌面快捷方式
Write-Host "`n🎯 创建桌面快捷方式..." -ForegroundColor Green

$desktopPath = [Environment]::GetFolderPath('Desktop')
$shortcutPath = "$desktopPath\ClaudeCode.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "node"
$shortcut.Arguments = "`"$claudeCodeDir\cli`""
$shortcut.WorkingDirectory = $claudeCodeDir
$shortcut.IconLocation = "$claudeCodeDir\assets\icon.ico"
$shortcut.Description = "ClaudeCode - AI编程助手"
$shortcut.Save()

Write-Host "`n🎉 安装完成！" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "📋 下一步：" -ForegroundColor Yellow
Write-Host "1. 配置 API 密钥（参考课程文档）" -ForegroundColor White
Write-Host "2. 启动 ClaudeCode: 双击桌面快捷方式" -ForegroundColor White
Write-Host "3. 或在命令行运行: cd $claudeCodeDir && npm run dev" -ForegroundColor White
Write-Host "4. 查看 VS Code 插件" -ForegroundColor White

Read-Host "`n按回车键退出..."