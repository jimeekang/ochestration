<#
.SYNOPSIS
  md 파일의 글자 수(줄바꿈 포함, CRLF는 1자로 계산)를 확인하고 상한을 넘으면 실패한다.
.EXAMPLE
  .\check-md-length.ps1                 # template 폴더 검사
  .\check-md-length.ps1 -Path "C:\proj" # 설치된 프로젝트 검사
#>
param(
  [string]$Path = (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'template'),
  [int]$Max = 350
)
$Path = (Resolve-Path $Path).Path
$bad = 0
$files = Get-ChildItem -Path $Path -Recurse -File -Force -Filter *.md | Sort-Object FullName
foreach ($f in $files) {
  $t = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8) -replace "`r`n", "`n"
  $n = $t.Length
  $flag = 'ok'
  if ($n -gt $Max) { $flag = 'OVER'; $bad++ }
  "{0,5} {1,-4} {2}" -f $n, $flag, $f.FullName.Substring($Path.Length).TrimStart('\', '/')
}
if ($bad -gt 0) { Write-Host "${bad}개 파일이 ${Max}자를 넘습니다."; exit 1 }
Write-Host "모든 md 파일이 ${Max}자 이하입니다. ($($files.Count)개)"; exit 0
