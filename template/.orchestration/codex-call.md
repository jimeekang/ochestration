# Codex 호출 (dispatcher, Bash 도구)
명령 하나만 쓴다(따옴표 안 줄바꿈은 가능). cd·&&·;·>·<<·$()는 권한 검사에 막히므로 쓰지 않는다. --worktree 금지. 값은 roles.md 참고.
codex exec -C "<루트>" -s <sandbox> -m <모델> -c model_reasoning_effort="<effort>" --json -o .orchestration/runs/<역할>.txt '<브리프>'
thread_id는 출력의 thread.started 줄, 결과는 -o 파일에 있다. 재개·진행 확인은 codex-resume.md.
