## 하네스: technow.archive 리서치

**목표:** State of AI Report 2026을 9개 섹터로 나눠, 섹터마다 출처가 검증된 심층 자료집을 만들고, 확정한 각도로 Figma 카드뉴스(1080×1350 캐러셀)와 캡션까지 만든다.

**호출 조건:** State of AI 섹터 분석, technow.archive 리서치(이전 이름 tech.archive), 섹터 조사·분석·검수, 각도 확정, 카드뉴스·문안·캡션·Figma 디자인 제작, 웨이브 진행, 상태 확인과 그 재실행·수정 요청을 받으면 `tech-research` 스킬을 사용한다. 단순 질문에는 직접 답해도 된다.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
| --- | --- | --- | --- |
| 2026-10-11 | Harness v2로 처음 구성 (report-collector, web-researcher, sector-analyst, fact-checker / tech-research, sector-dossier, chrome-research, fact-check) | 전체 | tmux 창 여러 개 방식에서 세션 하나 안의 에이전트 팀으로 전환 |
| 2026-10-11 | 에이전트별 effort 지정 (수집가·웹 조사원 medium, 분석가·팩트체커 high) | 에이전트 4개 | 사용자가 직접 조정 (PR #1) |
| 2026-10-11 | 계정 이름을 technow.archive로 확정 | CLAUDE.md, tech-research, 에이전트 4개 | 임시 이름 tech.archive 교체. 폴더 `accounts/tech`와 스킬 이름 `tech-research`는 유지 |
| 2026-10-11 | 카드뉴스 제작 단계 추가: card-writer(opus), card-designer(sonnet, 지속형, Figma) / card-copy, figma-cards 스킬 / fact-check에 「카드 검수」 절, tech-research에 6–9단계(각도 확정·문안·디자인·카드 검수), 상태판에 각도·문안·디자인·카드검수 열 | 에이전트·스킬·tech-research·orchestration.md | 하네스가 자료집(각도 후보)에서 끝나 계정의 최종 목표인 카드뉴스를 만드는 에이전트가 없었음. 각도는 사람이 확정, 섹터당 게시물 1개, Figma 템플릿은 시범 섹터에서 새로 제작 |
