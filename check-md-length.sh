#!/usr/bin/env bash
# md 파일의 글자 수(줄바꿈 포함, CRLF는 1자로 계산)를 확인하고 상한을 넘으면 실패한다.
#   ./check-md-length.sh [path] [max]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P="${1:-$ROOT/template}"; MAX="${2:-350}"; bad=0; count=0
P="$(cd "$P" && pwd)"
count_chars() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -I -c 'import sys;print(len(open(sys.argv[1],encoding="utf-8-sig").read().replace("\r\n","\n")))' "$1"
  elif command -v python >/dev/null 2>&1; then
    python -I -c 'import sys;print(len(open(sys.argv[1],encoding="utf-8-sig").read().replace("\r\n","\n")))' "$1"
  else
    tr -d '\r' < "$1" | LC_ALL=C.UTF-8 wc -m | tr -d ' '
  fi
}
while IFS= read -r -d '' f; do
  n="$(count_chars "$f")"; count=$((count+1))
  if [ "$n" -gt "$MAX" ]; then flag=OVER; bad=$((bad+1)); else flag=ok; fi
  printf '%5d %-4s %s\n' "$n" "$flag" "${f#"$P"/}"
done < <(find "$P" -type f -name '*.md' -print0 | sort -z)
if [ "$bad" -gt 0 ]; then echo "${bad}개 파일이 ${MAX}자를 넘습니다."; exit 1; fi
echo "모든 md 파일이 ${MAX}자 이하입니다. (${count}개)"
