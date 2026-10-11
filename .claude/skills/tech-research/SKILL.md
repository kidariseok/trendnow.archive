---
name: tech-research
description: "tech.archive의 State of AI Report 2026 섹터 분석부터 카드뉴스 제작까지 지휘한다. 수집가·웹 조사원·분석가·팩트체커·카피 담당·Figma 디자이너 에이전트를 웨이브 단위로 띄우고, 요약만 읽으며 상태판·크레딧·커밋을 관리한다. 'State of AI 섹터 분석 시작', '시범 섹터 진행', '웨이브 A/B 진행', 'tech.archive 리서치', '섹터 조사', '카드뉴스 만들어줘', '카드 제작', '각도 확정', '문안 작성', 'Figma 디자인', '상태 확인'에 사용하며, 다시 실행, 재실행, 업데이트, 수정, 보완, '02 agents만 다시', '분석만 다시', '검수 다시', '문안만 다시', '디자인만 다시', '이전 결과를 바탕으로 개선' 같은 후속 요청에도 사용한다. 섹터 하나의 자료 작성 방법은 sector-dossier, 문안은 card-copy, Figma 작업은 figma-cards, 하네스 자체를 고치는 일은 harness·harness-evolve가 맡는다."
---

# tech-research — State of AI 섹터 분석 지휘

메인 세션이 지휘자다. 지휘자는 직접 조사하지 않는다. 에이전트를 띄우고, 각 섹터의 `brief.md`(30줄 이하)와 반환 한 줄만 읽는다. 자료집 본문과 에이전트의 대화를 읽지 않아야 지휘자 컨텍스트가 9개 섹터를 끝까지 버틴다.

## 실행 모드: 혼합

| 단계 | 실행 모드 | 이유 |
|---|---|---|
| 1. 수집 | 서브에이전트 위임, 섹터마다 병렬 | 섹터끼리 독립적이고 결과만 받으면 된다 |
| 2. Chrome 조사 | 지속형 에이전트 1명 (`web-researcher`) | 브라우저가 하나뿐이라 순차 처리, 세션 내내 같은 조사원이 탭·사이트 권한 맥락을 유지한다 |
| 3. 분석 | 서브에이전트 위임, Chrome이 끝난 섹터부터 | 파일만 보고 새 컨텍스트로 시작하는 편이 사실과 해석을 섞지 않는다 |
| 4. 검수 | 서브에이전트 위임, 웨이브당 1명 | 작성에 참여하지 않은 한 명이 독립적으로 판정한다 |
| 5. 각도 확정 | 지휘자 + 사용자 | 어떤 이야기를 할지는 사람이 정한다 |
| 6. 문안 | 서브에이전트 위임, 섹터마다 | 자료집 파일만 보고 새 컨텍스트로 쓰는 편이 근거 밖의 말이 끼어들지 않는다 |
| 7. 디자인 | 지속형 에이전트 1명 (`card-designer`) | Figma 파일 하나와 MCP 권한 맥락을 세션 내내 유지하고, 한 파일에 동시에 쓰면 엉킨다 |
| 8. 카드 검수 | 서브에이전트 위임, 섹터마다 | 문안과 이미지를 만든 사람과 다른 한 명이 대조한다 |

목록(섹터)과 순서는 정해져 있지만 Chrome 단계와 Figma 단계가 각각 하나뿐인 도구와 사람의 권한 승인에 묶여 있어 Workflow로 돌리지 않는다.

## 에이전트 구성

| 이름 | `subagent_type` | 모델 | 스킬 | 산출물 (섹터 폴더) |
|---|---|---|---|---|
| (단발) | `report-collector` | sonnet | sector-dossier 「수집」 | `dossier.md` 1–3절, `chrome-brief.md`, `credits.md`, `brief.md` |
| `web-researcher` | `web-researcher` | sonnet | chrome-research | `chrome-findings.md` |
| (단발) | `sector-analyst` | opus | sector-dossier 「분석」 | `dossier.md` 4–7절, `brief.md` |
| (단발) | `fact-checker` | opus | fact-check | `review.md` (자료집), `card/card-review.md` (카드) |
| (단발) | `card-writer` | opus | card-copy | `card/slides.md`, `card/caption.txt` |
| `card-designer` | `card-designer` | sonnet | figma-cards | `card/01.jpg`~, `card/design-notes.md` |

섹터 폴더: `accounts/tech/research/stateofai-2026/<NN>-<slug>/`. 원자료: `_workspace/stateofai-2026/<NN>-<slug>/` (커밋 안 됨).

## 작업 절차

### 0단계: 기존 작업 확인

1. `accounts/tech/planning/orchestration.md`의 **상태판**을 읽는다. 이것이 진행 상황의 기준이다.
2. 요청을 판단한다.
   - "시작", "웨이브 A 진행" → 상태판에서 다음 웨이브를 고른다(시범 → A → B, `orchestration.md`의 「웨이브」).
   - "<섹터>만 다시", "분석만 다시" → 해당 섹터의 해당 단계만 다시 실행하고, 기존 파일 경로를 프롬프트에 넣는다.
   - "상태 확인" → 상태판, 새로 생긴 `brief.md`, 살아 있는 에이전트를 확인하고 다음 단계를 진행한다.
   - "카드뉴스 만들어줘", "<섹터> 카드 제작" → 상태판에서 그 섹터의 검수가 `완료`인지 확인하고 6단계(각도 확정)부터 시작한다. 검수가 안 끝났으면 먼저 알린다.
   - "문안만 다시", "디자인만 다시" → 해당 단계만 다시 실행하고, 기존 `card/` 파일 경로를 프롬프트에 넣는다. 문안을 다시 쓰면 디자인도 다시 해야 하는지 사용자에게 알린다.

### 1단계: 준비 (지휘자가 직접)

- `git branch --show-current`가 `claude/festive-hypatia-4b15sz`인지. 이 프로젝트 동안 `main`에는 아무것도 병합하지 않는다.
- `NAVER_CLIENT_ID`, `NAVER_CLIENT_SECRET`이 있는지(값은 출력하지 않는다), `curl`로 stateof.ai 응답 코드.
- 문제가 있으면 `accounts/tech/planning/local-setup.md`의 해당 단계를 사용자에게 알리고 멈춘다.
- 이번 웨이브의 섹터 목록을 사용자에게 한 줄로 알린다.

### 2단계: 수집 — 서브에이전트, 병렬

한 메시지에서 섹터 수만큼 동시에 호출한다(웨이브당 최대 4).

```
Agent(subagent_type: "report-collector", description: "수집 <섹터>",
      prompt: "섹터: <NN>-<slug>. sector-dossier 스킬의 「수집」 절차대로 작업하고, 반환은 brief.md 내용 그대로.")
```

완료 알림이 오는 섹터부터 3단계로 넘긴다. 모두 끝나기를 기다리지 않는다.

### 3단계: Chrome 조사 — 지속형 1명

- 첫 섹터: `Agent(name: "web-researcher", subagent_type: "web-researcher", prompt: "먼저 쓸 수 있는 도구 목록을 보고하라. 첫 섹터: <섹터>. chrome-research 스킬대로.")`
- 다음 섹터부터: `SendMessage({to: "web-researcher"}, "다음 섹터: <섹터>")`. 한 번에 한 섹터만 넘긴다.
- 첫 보고에 `mcp__claude-in-chrome__` 도구가 없으면 → 오류 처리 표의 "Chrome 도구 없음"을 따른다.
- 섹터 완료 보고를 받으면 그 섹터를 커밋한다(아래 「커밋 = 동결」). 이후 `chrome-findings.md`는 고치지 않고 `_v2`로만 쓴다고 조사원 정의에 적혀 있다.

### 4단계: 분석 — 서브에이전트

Chrome이 끝난 섹터부터 호출한다. 동시에 최대 4.

```
Agent(subagent_type: "sector-analyst", description: "분석 <섹터>",
      prompt: "섹터: <NN>-<slug>. sector-dossier 스킬의 「분석」 절차대로. 반환은 brief.md 내용 그대로.")
```

### 5단계: 검수 — 서브에이전트, 웨이브당 1명

웨이브의 분석이 모두 끝나면 커밋하고 호출한다.

```
Agent(subagent_type: "fact-checker", description: "검수 <웨이브>",
      prompt: "검수할 섹터: <섹터 목록>. fact-check 스킬대로.")
```

"수정 필요" 섹터는 `sector-analyst`를 `review.md` 경로와 함께 다시 부르고, 그 섹터만 다시 검수한다. **최대 2회.** 그래도 남으면 상태판에 "막힘"으로 두고 사용자에게 알린다.

### 6단계: 각도 확정 — 지휘자와 사용자

검수가 "통과"한 섹터마다 한다. 이 단계는 사람의 결정이라 자동으로 넘어가지 않는다.

1. `dossier.md` 6절의 후보 각도, 첫 장 훅, 5점 점수와 `review.md`에서 남은 "확인 불가" 항목만 사용자에게 보여 준다. 본문을 통째로 읽어 주지 않는다.
2. 사용자가 고른 각도를 7절 "결정"에 기록한다. 이 칸은 지휘자가 사용자의 선택으로 갱신하는 유일한 예외다. 이유도 한 줄 남긴다.
3. "보류"나 "추가 조사"를 고르면 그 섹터는 카드 단계로 넘어가지 않고 상태판에 이유를 적는다.
4. 확정한 섹터의 상태판 각도 열을 `완료`로 하고 커밋한다.

### 7단계: 문안 — 서브에이전트

```
Agent(subagent_type: "card-writer", description: "문안 <섹터>",
      prompt: "섹터: <NN>-<slug>. 확정 각도: <각도>. card-copy 스킬대로. 반환은 한 줄 요약.")
```

각도가 확정된 섹터마다 동시에 최대 4. 끝나면 커밋한다.

### 8단계: 디자인 — 지속형 1명 (Figma)

- 첫 섹터: `Agent(name: "card-designer", subagent_type: "card-designer", prompt: "먼저 쓸 수 있는 도구 목록을 보고하라. 첫 섹터: <섹터>. 템플릿이 아직 없으니 figma-cards 스킬의 「템플릿 만들기」부터.")`
- 다음 섹터부터: `SendMessage({to: "card-designer"}, "다음 섹터: <섹터>")`. 한 번에 한 섹터만 넘긴다.
- 첫 보고에 `mcp__Figma__use_figma`, `get_screenshot`, `download_assets`가 없으면 → 오류 처리 표의 "Figma 도구 없음"을 따른다.
- 첫 섹터에서 받은 Figma 파일 키·URL을 `accounts/tech/planning/figma.md`에 기록하고, 확정한 디자인 규칙을 `accounts/tech/README.md`의 "슬라이드 디자인 규칙"에 옮긴다(로드맵 T07).
- 템플릿을 처음 만든 직후 사용자에게 한 장 스크린샷을 보여 주고 방향이 맞는지 확인받는다. 이후 섹터는 이 템플릿을 따른다.
- 섹터 완료 보고를 받으면 커밋한다.

### 9단계: 카드 검수 — 서브에이전트, 섹터마다 1명

```
Agent(subagent_type: "fact-checker", description: "카드 검수 <섹터>",
      prompt: "카드 검수. 섹터: <NN>-<slug>. fact-check 스킬의 「카드 검수」대로.")
```

- "수정 필요(문안)" → `card-writer`를 `card-review.md` 경로와 함께 다시 부르고, 고쳐진 장만 `card-designer`에게 보낸 뒤 다시 검수한다.
- "수정 필요(디자인)" → `card-designer`에게 해당 장만 다시 하게 하고 다시 검수한다.
- **최대 2회.** 그래도 남으면 상태판 "막힘"으로 두고 사용자에게 알린다.
- 통과하면 커밋하고, 사용자에게 `card/` 이미지를 보여 주며 **최종 확인**을 받는다. 게시 승인은 사람만 한다.

### 10단계: 정리 (지휘자가 직접)

1. 상태판 갱신: 단계 상태, 섹터 `credits.md` 합계, 크레딧 총합(상한 100).
2. `orchestration-log.md`에 기록: 단계 시작·종료 시각, 에이전트별 소요 시간·토큰(완료 알림에 나오는 값), 컨텍스트 압축, 사람의 개입.
3. `brief.md`의 Alexandria 요청을 모아 사용자에게 보여 주고, 승인한 것만 지휘자가 호출한다.
4. 커밋하고 `git push origin claude/festive-hypatia-4b15sz`로 백업한다.
5. 웨이브가 끝나면 `harness-evolve`로 회고할지 사용자에게 묻는다.

## 데이터 전달

| 단계 → 단계 | 방법 |
|---|---|
| 수집 → Chrome | 파일 `chrome-brief.md` + 메시지로 섹터 이름 |
| Chrome → 분석 | 파일 `chrome-findings.md` |
| 수집·분석 → 지휘자 | 반환값 = `brief.md` (30줄 이하) |
| 분석 → 검수 → 분석 | 파일 `dossier.md`, `review.md` |
| 검수 통과 → 각도 확정 | 지휘자가 `brief.md`·6절 요약을 사용자에게 보이고, 선택을 `dossier.md` 7절에 기록 |
| 각도 → 문안 → 디자인 | 파일 `dossier.md`(읽기 전용) → `card/slides.md`, `card/caption.txt` → `card/NN.jpg` |
| 디자인 → 카드 검수 → 문안·디자인 | 파일 `card/card-review.md` |
| 문안·디자인 → 지휘자 | 반환값 한 줄 요약. Figma 링크는 `design-notes.md` |

**커밋 = 동결.** 단계가 끝날 때마다 지휘자가 그 섹터 파일을 커밋한다. 다음 단계는 커밋된 파일을 읽고, 나중에 바뀌면 `git diff`로 바로 보인다. 에이전트는 커밋하지 않는다.

**한 파일엔 한 명만 쓴다.** 섹터 폴더 파일마다 쓰는 에이전트가 정해져 있고, 상태판·로그·연구 폴더 `README.md`는 지휘자만 쓴다. 같은 폴더에서 여럿이 동시에 일해도 충돌하지 않는 이유다.

## 오류 처리

| 상황 | 대응 |
|---|---|
| 에이전트 하나 실패 | 한 번 다시 호출. 또 실패하면 상태판 "막힘", 보고에 누락을 밝히고 다른 섹터는 계속 |
| 사용량 한도, 인증 만료, 권한 거부 | 다시 호출하지 않는다. 남은 파일을 직접 열어 어디까지 됐는지 확인하고 `_workspace/`에 기록, 사용자에게 보고(한도면 풀리는 시각도) |
| Chrome 도구 없음 (`web-researcher` 첫 보고) | 조사원을 중지(TaskStop)하고, 메인 세션이 `claude --chrome`으로 열려 있으면 지휘자가 chrome-research 스킬로 직접 섹터를 차례로 처리한다. 페이지 내용은 바로 파일에 쓰고 대화에 남기지 않는다. 로그에 기록 |
| Chrome 연결 끊김·사이트 권한 요청 | 사용자에게 그대로 전하고 기다린다 |
| Figma 도구 없음 (`card-designer` 첫 보고) | 디자이너를 중지(TaskStop)하고, 지휘자 세션에 `mcp__Figma__*`가 있으면 지휘자가 figma-cards 스킬로 직접 처리한다. 둘 다 없으면 사용자에게 Figma 연결이 필요하다고 알리고 문안(7단계)까지만 진행한다. 로그에 기록 |
| Figma 플랜 선택·폰트 부재·파일 권한 | 사용자에게 그대로 전하고 기다린다. 임의로 고르지 않는다 |
| `card-designer` 응답 없음 | SendMessage로 상태 확인 → 그래도 없으면 `card-designer-2`로 새로 띄우고, Figma 파일 키와 남은 섹터 목록을 넘긴다 |
| 디자이너가 "글자 넘침" 보고 | `card-writer`에게 해당 장 글자 수 상한을 알려 다시 쓰게 한다. 디자이너가 문장을 줄이지 않는다 |
| `web-researcher` 응답 없음 | SendMessage로 상태 확인 → 그래도 없으면 `web-researcher-2`로 새로 띄우고 남은 섹터 목록을 넘긴다 |
| Firecrawl 섹터 상한·전체 상한 도달 | 해당 섹터의 남은 조사는 Chrome으로. 전체 상한이면 Firecrawl 사용을 멈추고 사용자에게 알린다 |
| 출처끼리 충돌 | 지우지 않고 출처와 함께 나란히 남긴다 |
| 절반 넘는 섹터 실패 | 사용자에게 알리고 계속할지 묻는다 |
| 에이전트가 남긴 빈 곳 | 지휘자는 직접 확인한 사실만 채운다. 에이전트의 판단(왜 어떤 자료를 뺐는지)은 추측해 쓰지 않는다 |

## 테스트 시나리오

### 정상 흐름 (시범)
1. 사용자: "State of AI 시범 섹터 진행해줘" → 0단계에서 상태판이 모두 `-` → 시범(02-agents) 선택.
2. 수집가 1명 → `brief.md` 반환, 크레딧 ≤6 → 커밋.
3. 조사원 첫 보고에 Chrome 도구 있음 → `chrome-findings.md` → 커밋.
4. 분석가 → `brief.md` 반환 → 커밋. 검수자 → "통과" → 커밋·푸시, 상태판 갱신.
5. 예상 결과: `02-agents/`에 6개 파일, 상태판 02 행이 모두 `완료`, 로그에 단계별 시각.

### 정상 흐름 (카드 시범)
1. 사용자: "02 agents 카드뉴스 만들어줘" → 상태판 02 행의 검수가 `완료`임을 확인.
2. 지휘자가 6절 후보와 훅을 보여 주고 사용자가 각도 A를 고른다 → 7절 기록, 각도 열 `완료`.
3. 카피 담당 → `card/slides.md`, `caption.txt` → 커밋.
4. 디자이너 첫 보고에 `mcp__Figma__*` 있음 → 템플릿 파일 생성 → 사용자가 첫 장 스크린샷 확인 → 캐러셀 → `card/01.jpg`~ → 커밋.
5. 카드 검수 "통과" → 사용자가 이미지를 최종 확인.
6. 예상 결과: `02-agents/card/`에 `slides.md`, `caption.txt`, `design-notes.md`, `card-review.md`, JPG N장. 상태판 02 행이 모두 `완료`, `figma.md`에 파일 키.

### 오류 흐름
1. 조사원 첫 보고에 `mcp__claude-in-chrome__` 도구가 없다.
2. 조사원을 중지하고 지휘자가 chrome-research 스킬로 02-agents를 직접 처리한다.
3. 로그에 "하위 에이전트에 Chrome 도구가 넘어가지 않음 → 지휘자가 직접 처리"를 남기고, 웨이브 회고에서 `harness-evolve`로 조사원 정의를 고친다.

### 오류 흐름 (카드 검수)
1. 카드 검수가 "수정 필요(문안): 3장 수치가 자료집(12.5%)과 다름(13%)"을 낸다.
2. 카피 담당이 3장만 고쳐 반환 → 디자이너가 3장만 다시 그려 JPG를 교체 → 다시 검수한다. 2회째에도 남으면 상태판 "막힘"으로 두고 사용자에게 알린다.
