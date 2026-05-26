# 应用 Codex 省额度配置
# 会备份旧 config.toml 和旧全局 AGENTS.md

$ErrorActionPreference = "Stop"

$CodexDir = Join-Path $env:USERPROFILE ".codex"
$ConfigPath = Join-Path $CodexDir "config.toml"
$AgentsPath = Join-Path $CodexDir "AGENTS.md"
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (!(Test-Path $CodexDir)) {
    New-Item -ItemType Directory -Path $CodexDir | Out-Null
}

if (Test-Path $ConfigPath) {
    Copy-Item $ConfigPath "$ConfigPath.bak" -Force
    Write-Host "已备份旧 config.toml：$ConfigPath.bak"
}

if (Test-Path $AgentsPath) {
    Copy-Item $AgentsPath "$AgentsPath.bak" -Force
    Write-Host "已备份旧 AGENTS.md：$AgentsPath.bak"
}

Copy-Item (Join-Path $SourceDir "config.example.toml") $ConfigPath -Force
Copy-Item (Join-Path $SourceDir "GLOBAL_AGENTS.example.md") $AgentsPath -Force

Write-Host "已写入：$ConfigPath"
Write-Host "已写入：$AgentsPath"

try {
    python -c "import os, tomllib, pathlib; p=pathlib.Path(os.environ['USERPROFILE'])/'.codex'/'config.toml'; tomllib.loads(p.read_text(encoding='utf-8-sig')); print('TOML OK')"
} catch {
    Write-Host "未完成 Python TOML 校验，可手动检查 config.toml。"
}
