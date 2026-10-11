---
name: chrome-research
description: "Claude in Chrome으로 섹터별 Chrome 조사 지시서(chrome-brief.md)를 처리해 구글 검색·원문 확인 결과를 chrome-findings.md로 남기는 방법. web-researcher가 사용한다. 구글 조사, Chrome 조사, 추가 서칭, 지시서 처리, 특정 섹터 Chrome 조사 다시 하기 요청에 사용한다. Firecrawl이나 curl로 하는 조사, 리포트 본문 수집에는 쓰지 않는다(sector-dossier)."
---

# Chrome 조사

구글 검색은 사람이 보는 결과와 같은 화면에서 최신 기사와 공식 발표를 찾을 수 있어서 이 계정의 주 조사 수단이다. 대신 브라우저가 하나뿐이라 한 번에 한 섹터씩, 지시서 범위 안에서만 움직인다.

## 시작할 때 (세션에서 처음 한 번)

1. Claude in Chrome 도구(`mcp__claude-in-chrome__*`)가 지연 로딩 상태면 필요한 도구를 **한 번의 ToolSearch**로 불러온다: `tabs_context_mcp`, `tabs_create_mcp`, `navigate`, `read_page`, `computer`, `tabs_close_mcp`.
2. `tabs_context_mcp`로 사용자의 열린 탭을 확인한다. 사용자의 탭은 건드리지 않고 **새 탭**에서 일한다.
3. 도구가 없거나 확장이 연결돼 있지 않으면 작업하지 않고 그 사실만 보고한다.

## 섹터마다

1. `accounts/tech/research/stateofai-2026/<섹터>/chrome-brief.md`를 읽는다. 필요하면 같은 폴더 `dossier.md`를 참고한다.
2. 검색 과제마다:
   - `google.com`에서 검색어를 그대로 검색한다.
   - 상위 결과 중 지시서의 "우선 출처"에 맞는 것을 **최대 5개**만 연다. 범위를 정해 두지 않으면 조사가 끝없이 늘어난다.
   - 날짜·수치·발언은 원문 페이지에서 확인한다.
3. `accounts/tech/templates/chrome-findings.md` 양식으로 같은 폴더에 `chrome-findings.md`를 쓴다. 과제 하나를 끝낼 때마다 바로 적는다. 페이지 전문을 대화에 남겨 두지 않는다.
4. 만든 탭을 닫는다.
5. "<섹터> 완료 · 출처 N개 · 막힌 것 N건" 한 줄로 보고한다.

## 멈춰야 할 때

- 로그인·결제가 필요한 페이지, 사이트 권한 요청: 사용자에게 알리고 기다린다. 우회하지 않는다.
- 확인·삭제 같은 대화상자가 뜰 만한 버튼은 누르지 않는다. 대화상자가 뜨면 브라우저가 멈춘다.
- 같은 동작이 2–3번 실패하면 "막힌 것"에 적고 다음 과제로.

## 쓰기 원칙

- 출처마다 URL, 날짜, 우리 말 1–2줄 요약, 신뢰도(1차 / 주요 언론 / 기타).
- 지시서의 "확인이 필요한 수치·주장"에는 확인됨 / 다름 / 못 찾음과 근거 URL을 꼭 적는다.
- 지시서에 없지만 중요한 자료는 "새로 발견한 것"에.
- Firecrawl은 쓰지 않는다.
