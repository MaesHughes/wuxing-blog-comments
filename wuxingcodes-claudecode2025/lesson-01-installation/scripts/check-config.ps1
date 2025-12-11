# ClaudeCode 配置检查脚本
# 作者：大熊掌门

Write-Host "🔍 ClaudeCode 配置检查工具" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

$checks = @()
$passed = 0
$total = 0

# 检查函数
function Check-Item {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$Tip
    )

    $total++
    try {
        $result = & $Test
        if ($result) {
            Write-Host "✅ $Name" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "❌ $Name" -ForegroundColor Red
            if ($Tip) {
                Write-Host "   💡 $Tip" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "❌ $Name (检查出错)" -ForegroundColor Red
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Gray
    }
}

# 1. 检查 Git
Check-Item "Git 安装" {
    git --version 2>$null
} "请访问 https://git-scm.com 下载安装"

# 2. 检查 Node.js
Check-Item "Node.js 安装" {
    node --version 2>$null
} "请访问 https://nodejs.org 下载安装"

# 3. 检查 ClaudeCode 仓库
$claudeCodeDir = "$env:USERPROFILE\ClaudeCode-claude-desktop"
Check-Item "ClaudeCode 仓库" {
    Test-Path $claudeCodeDir
} "请运行 git clone https://github.com/anthropics/claude-desktop.git $claudeCodeDir"

# 4. 检查依赖安装
Check-Item "Node.js 依赖" {
    Test-Path "$claudeCodeDir\node_modules"
} "进入仓库目录，运行 npm install"

# 5. 检查配置文件
$configDir = "$env:APPDATA\Claude"
Check-Item "配置目录" {
    Test-Path $configDir
} "首次运行 ClaudeCode 会自动创建"

# 6. 检查 Python (可选)
Check-Item "Python (可选)" {
    python --version 2>$null
} "Python 不是必需的，但某些功能需要"

# 7. 检查 VSCode (可选)
Check-Item "VSCode (可选)" {
    code --version 2>$null
} "VSCode 是推荐的编辑器"

# 8. 检查环境变量
$envPath = $env:Path
$hasNodeInPath = $envPath -like "*node*"
Check-Item "Node.js 在 PATH 中" {
    $hasNodeInPath
} "请将 Node.js 安装目录添加到系统 PATH"

# 9. 检查端口占用
$port = 5173
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
Check-Item "端口 $port 可用" {
    -not $portInUse
} "端口被占用，请关闭其他程序或更改端口"

# 10. 检查网络连接
Check-Item "网络连接" {
    Test-Connection "github.com" -Count 1 -Quiet
} "请检查网络连接"

# 输出结果
Write-Host "`n" + "─" * 40 -ForegroundColor Cyan
Write-Host "检查结果: $passed/$total 项通过" -ForegroundColor $(
    if ($passed -eq $total) { "Green" } elseif ($passed -gt $total * 0.7) { "Yellow" } else { "Red" }
)

if ($passed -eq $total) {
    Write-Host "`n🎉 配置检查全部通过！ClaudeCode 可以正常运行。" -ForegroundColor Green
    Write-Host "`n快速启动命令:" -ForegroundColor White
    Write-Host "cd $claudeCodeDir" -ForegroundColor Gray
    Write-Host "npm run dev" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  发现 $total - $passed 项问题需要解决" -ForegroundColor Yellow
    Write-Host "请根据上述提示完成配置后重新检查" -ForegroundColor Yellow
}

# 生成配置报告
$report = @"
ClaudeCode 配置检查报告
检查时间: $(Get-Date)
检查结果: $passed/$total 项通过

环境信息:
- 操作系统: $([System.Environment]::OSVersion)
- PowerShell: $($PSVersionTable.PSVersion)
- 用户: $env:USERNAME

"@

$report | Out-File -FilePath "$claudeCodeDir\config-check-report.txt" -Encoding UTF8
Write-Host "`n📄 报告已保存到: $claudeCodeDir\config-check-report.txt" -ForegroundColor Cyan

Read-Host "`n按回车键退出..."