#!/usr/bin/env bash
# Claude x Codex 오케스트레이션 템플릿을 프로젝트에 설치한다.
#   ./install.sh "<project path>" [--force]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL="$ROOT/template"
TARGET="$PWD"; FORCE=0
for a in "$@"; do
  case "$a" in
    --force) FORCE=1 ;;
    *) TARGET="$a" ;;
  esac
done
[ -d "$TPL" ] || { echo "template 폴더가 없습니다: $TPL" >&2; exit 1; }
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
S='<!-- orchestration:start -->'
E='<!-- orchestration:end -->'

# CLAUDE.md / AGENTS.md: 없으면 생성, 있으면 마커 블록을 덧붙이고, --force면 기존 블록을 교체한다.
merge_block() {
  local dest="$1" src="$2" rel="$3"
  if [ ! -f "$dest" ]; then
    mkdir -p "$(dirname "$dest")"; cp "$src" "$dest"; echo "[created] $rel"; return
  fi
  if grep -qF "$S" "$dest" && grep -qF "$E" "$dest"; then
    if [ "$FORCE" -ne 1 ]; then echo "[exists] $rel"; return; fi
    local tmp; tmp="$(mktemp)"
    awk -v s="$S" -v e="$E" -v src="$src" '
      index($0, s) == 1 { while ((getline line < src) > 0) print line; skip = 1; next }
      index($0, e) == 1 { skip = 0; next }
      !skip { print }' "$dest" > "$tmp"
    mv "$tmp" "$dest"; echo "[replaced] $rel"; return
  fi
  { [ -n "$(tail -c1 "$dest")" ] && echo; echo; cat "$src"; } >> "$dest"
  echo "[appended] $rel"
}

echo "설치 대상: $TARGET"
while IFS= read -r -d '' f; do
  rel="${f#"$TPL"/}"
  dest="$TARGET/$rel"
  case "$rel" in
    CLAUDE.md|AGENTS.md) merge_block "$dest" "$f" "$rel"; continue ;;
  esac
  if [ -f "$dest" ] && [ "$FORCE" -ne 1 ]; then echo "[skip] $rel"; continue; fi
  mkdir -p "$(dirname "$dest")"; cp "$f" "$dest"; echo "[copy] $rel"
done < <(find "$TPL" -type f -print0 | sort -z)

# .gitignore: Codex 결과 파일(.orchestration/runs/)은 커밋하지 않는다.
GI="$TARGET/.gitignore"; added=0
for l in '.orchestration/runs/*' '!.orchestration/runs/.gitkeep'; do
  if ! { [ -f "$GI" ] && grep -qxF -- "$l" "$GI"; }; then
    { [ -f "$GI" ] && [ -n "$(tail -c1 "$GI")" ] && echo; echo "$l"; } >> "$GI"; added=1
  fi
done
[ "$added" -eq 1 ] && echo "[gitignore] .orchestration/runs/ 제외 규칙 추가"

cat <<EOF

다음 단계:
 1. Codex 신뢰: 프로젝트에서 codex를 한 번 실행해 신뢰를 허용한다. (.codex/ 설정은 신뢰된 프로젝트에서만 로드됨)
 2. Claude Code 세션을 다시 시작해 .claude/agents와 CLAUDE.md를 불러온다.
 3. 길이 검사: $ROOT/check-md-length.sh "$TARGET"
EOF
