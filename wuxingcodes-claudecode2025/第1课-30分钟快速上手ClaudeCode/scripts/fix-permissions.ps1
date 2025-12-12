# Windows PowerShell权限修复脚本

Write-Host "修复PowerShell执行策略..." -ForegroundColor Green

# 设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Host "执行策略已设置为 RemoteSigned" -ForegroundColor Green

Write-Host "修复npm权限..." -ForegroundColor Green

# 获取npm全局路径
$npmPath = npm config get prefix
$npmBinPath = Join-Path $npmPath "node_modules\.bin"

# 添加到用户PATH（如果还没有）
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$npmBinPath*") {
    [Environment]::SetEnvironmentVariable("Path", $userPath + ";" + $npmBinPath, "User")
    Write-Host "npm路径已添加到用户PATH" -ForegroundColor Green
}

Write-Host "权限修复完成！" -ForegroundColor Green
Write-Host "请重启PowerShell以使更改生效" -ForegroundColor Yellow