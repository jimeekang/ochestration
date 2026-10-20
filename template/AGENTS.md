<!-- orchestration:start -->
# 오케스트레이션: Codex 구현 담당
Codex는 Claude 팀장의 브리프에 적힌 역할로 일한다. 범위·금지·완료 조건을 지키고 범위 밖은 수정하지 않는다.
- 역할: .orchestration/roles/<역할>.md를 먼저 읽는다
- 규칙: .orchestration/rules.md
- 보고: 마지막 메시지를 .orchestration/report.md 형식으로 쓴다
역할이 없으면 implementer로 본다. Claude와 같은 폴더에서 일하므로 worktree·브랜치를 만들지 않는다.
<!-- orchestration:end -->
