# deploy.ps1 — создаёт репозиторий, пушит код и включает GitHub Pages одной командой.
# Использование:  .\deploy.ps1 -Repo "yola-glamping"
#   -Repo     имя нового репозитория (= адрес сайта)
#   -Private  сделать репозиторий приватным (по умолчанию public)
#   -Path     папка с сайтом (по умолчанию текущая)

param(
  [Parameter(Mandatory=$true)][string]$Repo,
  [switch]$Private,
  [string]$Path = "."
)

$ErrorActionPreference = "Stop"
Set-Location $Path

# 1. git init + коммит, если ещё не репозиторий
if (-not (Test-Path ".git")) { git init -b main | Out-Null }
git add -A
if (git status --porcelain) { git commit -m "Deploy $Repo" | Out-Null }

# 2. создать репозиторий на GitHub и запушить
$vis = if ($Private) { "--private" } else { "--public" }
gh repo create $Repo $vis --source=. --remote=origin --push

# 3. включить GitHub Pages (branch main / root) через API
$owner = gh api user --jq ".login"
gh api -X POST "repos/$owner/$Repo/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null

Write-Host ""
Write-Host "Готово. Сайт через ~1 минуту будет тут:" -ForegroundColor Green
Write-Host "https://$owner.github.io/$Repo/" -ForegroundColor Cyan
