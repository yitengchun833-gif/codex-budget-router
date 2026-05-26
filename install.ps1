# 安装 codex-budget-router Skill
# 用法：在本目录 PowerShell 执行：
# powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"

$SkillName = "codex-budget-router"
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetRoot = Join-Path $env:USERPROFILE ".codex\skills"
$TargetDir = Join-Path $TargetRoot $SkillName

if (!(Test-Path $TargetRoot)) {
    New-Item -ItemType Directory -Path $TargetRoot | Out-Null
}

if (Test-Path $TargetDir) {
    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $BackupDir = Join-Path $TargetRoot ".trash\$Stamp-$SkillName"
    New-Item -ItemType Directory -Path (Split-Path -Parent $BackupDir) -Force | Out-Null
    Move-Item $TargetDir $BackupDir
    Write-Host "已备份旧 Skill 到：$BackupDir"
}

Copy-Item $SourceDir $TargetDir -Recurse -Force
Write-Host "已安装 Skill 到：$TargetDir"
Write-Host "请重启 Codex 后测试。"
