# Orca 방식 (우선)
ORCA_TERMINAL_HANDLE이 있고 orca status가 되면 Orca로 위임한다. 아니면 codex-call.md.
- 같은 폴더(--worktree current)에서 일한다
- Codex는 YOLO(샌드박스 없음). 읽기 전용 역할은 브리프로 막고 git status로 확인한다
- 작업당 Run 한 번: orca orchestration run-create --objective '<목표>' --json
- 순서: orca-call → orca-wait → orca-resume
