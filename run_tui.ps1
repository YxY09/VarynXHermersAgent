<#
.SYNOPSIS
  一键启动 Hermes TUI(带 varynx 皮肤),自动处理 Windows 的 UTF-8 编码坑。

.DESCRIPTION
  - 设 UTF-8(否则 ▲ ✦ 龙形 logo 会乱码)
  - HERMES_HOME 指向仓库内 workspace\(和 run.ps1 一致,config.yaml 在那里)
  - 用 node 直接跑已 build 的 ui-tui\dist\entry.js
#>
$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot

# 1. UTF-8(必须在启动 hermes 前设进进程)
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
# 让 Node/Ink 也按 UTF-8 输出
$env:LANG = 'C.UTF-8'
chcp 65001 > $null

# 2. HERMES_HOME 跟随源码(workspace\ 内放 config.yaml / .env)
$env:HERMES_HOME = Join-Path $Root 'workspace'
if (-not (Test-Path $env:HERMES_HOME)) {
    New-Item -ItemType Directory -Force -Path $env:HERMES_HOME | Out-Null
}

# 3. 首次运行:没有 .env 就从模板生成并提示填 key
$envFile = Join-Path $env:HERMES_HOME '.env'
if (-not (Test-Path $envFile)) {
    $tpl = Join-Path $env:HERMES_HOME '.env.example'
    if (Test-Path $tpl) {
        Copy-Item $tpl $envFile
        Write-Host ""
        Write-Host "[varynx] 首次运行:已生成 workspace\.env" -ForegroundColor Yellow
        Write-Host "[varynx] 请填入 MINIMAX_API_KEY 后再跑:" -ForegroundColor Yellow
        Write-Host "         $envFile" -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }
}

# 4. 检查 TUI 是否已 build
$tuiEntry = Join-Path $Root 'ui-tui\dist\entry.js'
if (-not (Test-Path $tuiEntry)) {
    Write-Host "[varynx] TUI 还没 build。先跑:" -ForegroundColor Yellow
    Write-Host "         cd ui-tui; npm install; npm run build --prefix packages\hermes-ink; npm run build" -ForegroundColor Cyan
    exit 1
}

Write-Host "[varynx] HERMES_HOME = $env:HERMES_HOME" -ForegroundColor DarkGray
Write-Host "[varynx] 启动 TUI (varynx 皮肤)..." -ForegroundColor DarkGray
& node $tuiEntry
exit $LASTEXITCODE
