# Codex 재개·진행 확인 (dispatcher)
재개 시 모델·effort·sandbox를 다시 지정한다. 생략하면 기본 모델로 바뀐다. 프로젝트 루트에서 실행한다.
codex exec resume <thread_id> -m <모델> -c model_reasoning_effort="<effort>" -c sandbox_mode="<sandbox>" --json -o .orchestration/runs/<역할>-2.txt '<추가 지시>'
오래 걸리면 Bash run_in_background로 실행하고 완료 알림을 기다린다. 결과를 report.md 기준으로 확인하고 부족하면 다시 재개한다.
