# ClaudeCode PowerShell 别名配置
# 作者：大熊掌门
# 使用方法：.\powershell_aliases.ps1

# 检查是否已加载
if ($null -eq $global:ClaudeCodeAliasesLoaded) {
    $global:ClaudeCodeAliasesLoaded = $true

    Write-Host "ClaudeCode PowerShell 别名已加载" -ForegroundColor Green
    Write-Host "输入 'Get-Alias cc*' 查看所有别名" -ForegroundColor Yellow
}

# === 基础别名 ===
Set-Alias -Name cc -Value "claudecode"
Set-Alias -Name cch -Value "claudecode --help"
Set-Alias -Name ccv -Value "claudecode --version"

# === 快速启动 ===
Set-Alias -Name cc-init -Value "claudecode --init"
Set-Alias -Name cca -Value "claudecode --add"
Set-Alias -Name ccr -Value "claudecode --remove"
Set-Alias -Name ccc -Value "claudecode --clear"
Set-Alias -Name cccx -Value "claudecode --context"

# === 项目类型初始化 ===
Set-Alias -Name cc-py -Value "claudecode --init --type python"
Set-Alias -Name cc-js -Value "claudecode --init --type javascript"
Set-Alias -Name cc-ts -Value "claudecode --init --type typescript"
Set-Alias -Name cc-react -Value "claudecode --init --type react"
Set-Alias -Name cc-vue -Value "claudecode --init --type vue"
Set-Alias -Name cc-node -Value "claudecode --init --type node"

# === 工作流别名 ===
Set-Alias -Name cc-review -Value 'claudecode "请审查这段代码，指出问题并提供改进建议"'
Set-Alias -Name cc-refactor -Value 'claudecode "请重构这段代码，提高代码质量"'
Set-Alias -Name cc-explain -Value 'claudecode "请详细解释这段代码的功能和原理"'
Set-Alias -Name cc-optimize -Value 'claudecode "请优化这段代码的性能"'
Set-Alias -Name cc-doc -Value 'claudecode "请为这段代码生成文档"'

# === 文件操作别名 ===
function cc-add {
    param([string[]]$files)
    if ($files.Count -eq 0) {
        Write-Host "用法: cc-add <文件1> [文件2] ..." -ForegroundColor Red
        return
    }
    claudecode --add @files
}

function cc-read {
    param([string]$file)
    if (-not (Test-Path $file)) {
        Write-Host "文件不存在: $file" -ForegroundColor Red
        return
    }
    claudecode "请读取并解释文件: $file" $file
}

function cc-create {
    param([string]$file, [string]$content)
    if (-not $content) {
        $content = "请创建文件: $file"
    }
    $content | Out-File -FilePath $file -Encoding UTF8
    Write-Host "文件已创建: $file" -ForegroundColor Green
}

# === 调试别名 ===
Set-Alias -Name cc-debug -Value "claudecode --debug"
Set-Alias -Name cc-verbose -Value "claudecode --verbose"
Set-Alias -Name cc-test -Value "claudecode --test"
Set-Alias -Name cc-dry -Value "claudecode --dry-run"

# === 配置别名 ===
Set-Alias -Name cc-config -Value "claudecode --config"
Set-Alias -Name cc-set -Value "claudecode --set"
Set-Alias -Name cc-env -Value "claudecode --env"
Set-Alias -Name cc-profile -Value "claudecode --profile"

# === 历史管理别名 ===
Set-Alias -Name cc-history -Value "claudecode --history"

function cc-save {
    param([string[]]$items)
    $items | Out-File -FilePath "$env:USERPROFILE\claudecode_history.txt" -Append -Encoding UTF8
}

# === 模板别名 ===
Set-Alias -Name cc-template -Value "claudecode --template"
Set-Alias -Name cc-templates -Value "claudecode --list-templates"

# === 插件别名 ===
Set-Alias -Name cc-plugins -Value "claudecode --list-plugins"
Set-Alias -Name cc-enable -Value "claudecode --enable"
Set-Alias -Name cc-disable -Value "claudecode --disable"

# === 多项目工作流 ===
function cc-work {
    param([string]$path)
    if (-not $path) {
        Write-Host "用法: cc-work <路径>" -ForegroundColor Red
        return
    }
    Set-Location $path
    claudecode
}

function cc-dev {
    param([string]$project)
    if (-not $project) {
        Write-Host "用法: cc-dev <项目名>" -ForegroundColor Red
        return
    }
    Set-Location "$env:USERPROFILE\dev\$project"
    claudecode --init
}

function cc-proj {
    param([string]$project)
    if (-not $project) {
        Write-Host "用法: cc-proj <项目名>" -ForegroundColor Red
        return
    }
    Set-Location "$env:USERPROFILE\projects\$project"
    claudecode --add .
}

# === 快速提示词函数 ===
# 代码生成
function cc-gen {
    param([string]$prompt, [string[]]$args)
    if (-not $prompt) {
        Write-Host "用法: cc-gen <提示词> [参数...]" -ForegroundColor Red
        return
    }
    claudecode $prompt $args
}

# Bug修复
function cc-fix {
    param([string]$file, [string]$error)
    if (-not $file) {
        Write-Host "用法: cc-fix <文件> [错误信息]" -ForegroundColor Red
        return
    }
    $errorMsg = if ($error) { $error } else { "" }
    claudecode "请修复这个bug：" --file $file --error $errorMsg
}

# 代码审查
function cc-review-file {
    param([string]$file)
    if (-not (Test-Path $file)) {
        Write-Host "文件不存在: $file" -ForegroundColor Red
        return
    }
    claudecode "请审查这个文件中的代码，指出潜在问题：" $file
}

# 生成测试
function cc-test-gen {
    param([string]$file)
    if (-not (Test-Path $file)) {
        Write-Host "文件不存在: $file" -ForegroundColor Red
        return
    }
    claudecode "请为这个文件生成单元测试：" $file
}

# API文档生成
function cc-api-doc {
    param([string]$file)
    if (-not (Test-Path $file)) {
        Write-Host "文件不存在: $file" -ForegroundColor Red
        return
    }
    claudecode "请为这个API生成文档：" $file
}

# === 环境切换 ===
Set-Alias -Name cc-dev -Value "claudecode --profile development"
Set-Alias -Name cc-prod -Value "claudecode --profile production"
Set-Alias -Name cc-test -Value "claudecode --profile testing"

# === 常用快捷命令 ===
Set-Alias -Name cc-hello -Value 'claudecode "Hello! 我是ClaudeCode，有什么可以帮你的吗？"'
Set-Alias -Name cc-summarize -Value 'claudecode "请总结当前目录的内容"'
Set-Alias -Name cc-plan -Value 'claudecode "请为我制定一个开发计划"'

# === 性能监控 ===
Set-Alias -Name cc-speed -Value 'Measure-Command { claudecode $args }'
Set-Alias -Name cc-stats -Value "claudecode --stats"

# === 清理功能 ===
Set-Alias -Name cc-clean -Value "claudecode --clean"
Set-Alias -Name cc-reset -Value "claudecode --reset-all"

# === 备份功能 ===
function cc-backup {
    $backupDir = "$env:USERPROFILE\.claudecode-backups"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $backupPath = Join-Path $backupDir "config-$timestamp"

    if (Test-Path "$env:APPDATA\Claude") {
        Copy-Item -Recurse "$env:APPDATA\Claude" $backupPath -Force
        Write-Host "配置已备份到: $backupPath" -ForegroundColor Green
    }
}

# === 实用函数：快速生成项目结构 ===
function cc-make-project {
    param([string]$projectName, [string]$projectType)

    if (-not $projectName) {
        Write-Host "用法: cc-make-project <项目名> [项目类型]" -ForegroundColor Red
        return
    }

    New-Item -ItemType Directory -Path $projectName -Force | Out-Null
    Set-Location $projectName

    # 创建基本项目结构
    New-Item -ItemType Directory -Path "src" -Force | Out-Null
    New-Item -ItemType Directory -Path "tests" -Force | Out-Null
    New-Item -ItemType Directory -Path "docs" -Force | Out-Null
    "# $projectName" | Out-File -FilePath "README.md" -Encoding UTF8

    # 创建.gitignore
    @"
node_modules
dist
build
.env
.env.local
.DS_Store
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

    # 根据项目类型创建配置
    switch ($projectType) {
        "react" { "frontend" } {
            npm init -y
            npm install react react-dom @types/react @types/react-dom
        }
        "node" { "backend" } {
            npm init -y
            npm install express
        }
        "python" {
            python -m venv venv
            .\venv\Scripts\Activate.ps1
            pip install pytest
        }
    }

    # 添加项目到ClaudeCode上下文
    claudecode --add .

    Write-Host "✅ 项目 '$projectName' 创建成功！" -ForegroundColor Green
}

# === 列出所有别名 ===
function cc-aliases {
    Write-Host "ClaudeCode PowerShell 别名列表:" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan

    # 获取所有以 'cc-' 开头的别名
    Get-Alias | Where-Object { $_.Name.StartsWith('cc-') } | Sort-Object Name | Format-Table @{
        Name = $_.Name;
        Definition = $_.Definition
    }
}

# === 初始化提示 ===
Write-Host "已设置 ClaudeCode PowerShell 别名" -ForegroundColor Green
Write-Host "输入 'cc-aliases' 查看所有别名" -ForegroundColor Yellow
Write-Host "输入 'Get-Alias cc*' 查看具体别名定义" -ForegroundColor Yellow