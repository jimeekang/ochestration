# Orca 대기·정산
orca orchestration check --wait --types "worker_done,escalation,question" --timeout-ms 240000 --json
빈 결과는 실패가 아니다. 다시 기다리고 재실행·중지하지 않는다. 상태는 worker-show·worker-read로 본다.
worker_done의 outcome(있으면 filesModified)을 보고한다. 끝나면 worker-release --dispatch <id>, 이어 check --ack <deliveryId> --timeout-ms 1000.
