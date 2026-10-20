# Orca 후속 지시(재개)
같은 터미널에서 이어간다. 모델·맥락은 유지되고 launch는 비어 있다.
orca orchestration task-create --spec '<추가 지시>' --json
orca orchestration worker-start --task <task_id> --terminal <handle> --worktree current --json
handle은 worker-show --dispatch <id>에서 얻는다. check --ack <이전 deliveryId> --wait 로 ack와 대기를 함께 한다. 이전 dispatch는 retained가 정상, 마지막만 release한다.
