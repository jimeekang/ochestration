<#
.SYNOPSIS
  Claude x Codex 오케스트레이션 템플릿을 프로젝트에 설치한다.
.EXAMPLE
  .\install.ps1 -Target "C:\path\to\project"
  .\install.ps1 -Target "C:\path\to\project" -Force
#>
[CmdletBinding()]
param(
  [string]$Target = (Get-Location).Path,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Tpl = Join-Path $Root 'template'
$Utf8 = New-Object System.Text.UTF8Encoding $false
$StartMark = '<!-- orchestration:start -->'
$EndMark = '<!-- orchestration:end -->'

if (-not (Test-Path $Tpl)) { throw "template 폴더가 없습니다: $Tpl" }
if (-not (Test-Path $Target)) { New-Item -ItemType Directory -Path $Target | Out-Null }
$Target = (Resolve-Path $Target).Path

function Read-Text([string]$p) { [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }
function Write-Text([string]$p, [string]$c) {
  $dir = Split-Path -Parent $p
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($p, $c, $Utf8)
}

# CLAUDE.md / AGENTS.md: 없으면 생성, 있으면 마커 블록을 덧붙이고, -Force면 기존 블록을 교체한다.
function Merge-Block([string]$dest, [string]$block) {
  if (-not (Test-Path $dest)) { Write-Text $dest $block; return 'created' }
  $cur = Read-Text $dest
  $si = $cur.IndexOf($StartMark); $ei = $cur.IndexOf($EndMark)
  if ($si -ge 0 -and $ei -gt $si) {
    if (-not $Force) { return 'exists' }
    $new = $cur.Substring(0, $si) + $block.TrimEnd() + $cur.Substring($ei + $EndMark.Length)
    Write-Text $dest $new; return 'replaced'
  }
  $sep = "`n`n"; if ($cur.EndsWith("`n")) { $sep = "`n" }
  Write-Text $dest ($cur + $sep + $block); return 'appended'
}

Write-Host "설치 대상: $Target"
$files = Get-ChildItem -Path $Tpl -Recurse -File -Force | Sort-Object FullName
foreach ($f in $files) {
  $rel = $f.FullName.Substring($Tpl.Length).TrimStart('\', '/')
  $dest = Join-Path $Target $rel
  if ($rel -eq 'CLAUDE.md' -or $rel -eq 'AGENTS.md') {
    $r = Merge-Block $dest (Read-Text $f.FullName)
    Write-Host ("[{0}] {1}" -f $r, $rel)
    continue
  }
  if ((Test-Path $dest) -and -not $Force) { Write-Host "[skip] $rel"; continue }
  Write-Text $dest (Read-Text $f.FullName)
  Write-Host "[copy] $rel"
}

# .gitignore: Codex 결과 파일(.orchestration/runs/)은 커밋하지 않는다.
$gi = Join-Path $Target '.gitignore'
$lines = @('.orchestration/runs/*', '!.orchestration/runs/.gitkeep')
$cur = ''; if (Test-Path $gi) { $cur = Read-Text $gi }
$missing = $lines | Where-Object { ($cur -split "`r?`n") -notcontains $_ }
if ($missing) {
  $sep = ''; if ($cur -and -not $cur.EndsWith("`n")) { $sep = "`n" }
  Write-Text $gi ($cur + $sep + (($missing -join "`n") + "`n"))
  Write-Host "[gitignore] .orchestration/runs/ 제외 규칙 추가"
}

Write-Host ""
Write-Host "다음 단계:"
Write-Host " 1. Codex 신뢰: 프로젝트에서 codex를 한 번 실행해 신뢰를 허용한다. (.codex/ 설정은 신뢰된 프로젝트에서만 로드됨)"
Write-Host " 2. Claude Code 세션을 다시 시작해 .claude/agents와 CLAUDE.md를 불러온다."
Write-Host " 3. 길이 검사: check-md-length.ps1 -Path `"$Target`""
