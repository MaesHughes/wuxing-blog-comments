# Windows PowerShell权限修复脚本

Write-Host "修复Windows权限错误" -ForegroundColor Green

# 方法1：以管理员身份运行
Write-Host "请确保以管理员身份运行PowerShell" -ForegroundColor Yellow

# 方法2：设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 方法3：修复npm权限
try {
    $npmPath = npm config get prefix
    if (Test-Path $npmPath) {
        $acl = Get-Acl $npmPath
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $env:USERNAME,
            "FullControl",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        $acl.SetAccessRule($accessRule)
        Set-Acl $npmPath $acl
        Write-Host "已修复npm目录权限" -ForegroundColor Green
    }
} catch {
    Write-Host "修复npm权限失败: $_" -ForegroundColor Red
}

# 方法4：配置npm使用用户目录
$userNpmPath = "$env:APPDATA\npm"
if (!(Test-Path $userNpmPath)) {
    New-Item -ItemType Directory -Path $userNpmPath -Force | Out-Null
}
npm config set prefix $userNpmPath

Write-Host "权限修复完成！" -ForegroundColor Green