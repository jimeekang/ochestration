# 작업 흐름
1. 팀장(Claude): 요청 분석→계획·설계→작업 단위로 나눠 brief.md 형식의 브리프 작성.
2. 분배: UI/UX 구현은 ui-implementer(Claude). 그 외 구현·분석·탐색은 dispatcher가 Codex 역할에 전달.
3. dispatcher: 결과 확인, 부족하면 resume으로 추가 지시, 팀장에 보고.
4. 리뷰: Codex reviewer가 변경을 비판적으로 검토. 결함은 2단계로 돌려 수정.
5. integrator(Claude): 코드 검토·빌드·테스트·통합 확인. 통과하면 팀장이 사용자에게 최종 보고.
