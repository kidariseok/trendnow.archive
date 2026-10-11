---
name: sector-dossier
description: "State of AI Report 2026 섹터 하나의 자료집(dossier)을 만드는 방법. 리포트 섹터 페이지·데이터·슬라이드 읽기, 원 출처 확인, 네이버 뉴스 검색, Firecrawl 크레딧 관리, Chrome 조사 지시서 작성(「수집」)과, 수집 자료와 Chrome 결과를 통합해 의미·한계·게시물 각도를 분석하는 절차(「분석」)를 담는다. report-collector와 sector-analyst가 사용한다. 섹터 자료집 작성, 섹터 수집, 섹터 분석, dossier 보완·수정 요청에 사용한다. 여러 섹터를 조율하는 일은 tech-research, 검수는 fact-check 스킬이 맡는다."
---

# 섹터 자료집 만들기

자료집은 게시물이 아니라 **게시물의 근거**다. 나중에 슬라이드를 만들 사람이 이 파일만 보고 사실과 출처를 믿고 쓸 수 있어야 한다. 그래서 수집과 분석을 나누고, 모든 수치에 출처를 붙인다.

## 기준 문서 (필요할 때 읽는다)

| 문서 | 언제 |
|---|---|
| `accounts/tech/planning/analysis-workflow.md` | 통과 조건, 5점 평가표, 출처 표기 원칙이 필요할 때 |
| `accounts/tech/planning/sources.md` | 출처 우선순위, 도구 역할, 네이버 API 사용법 |
| `accounts/tech/templates/sector-dossier.md` | 자료집 양식 |
| `accounts/tech/templates/sector-brief.md` | 30줄 요약 양식 |
| `accounts/tech/templates/chrome-brief.md` | Chrome 조사 지시서 양식 |

## 섹터와 주소

섹터 폴더는 `accounts/tech/research/stateofai-2026/<NN>-<slug>/`. 섹터 페이지는 `https://www.stateof.ai/2026-explore/<slug>`, 데이터는 `https://www.stateof.ai/2026-explore/data/<slug>.json`, PDF는 `https://www.stateof.ai/State-of-AI-Report-2026.pdf`(244장).

원자료는 `_workspace/stateofai-2026/<NN>-<slug>/`에 둔다(`01_collector_slides.txt`, `01_collector_naver.json` 형식). `_workspace/`는 커밋되지 않으므로 저작권이 있는 원문을 저장소에 올리지 않게 된다.

## 수집 (report-collector)

### 0. 환경 확인 — 결과를 `credits.md` 맨 위에 적는다

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://www.stateof.ai/2026-explore/<slug>
curl -s -o /dev/null -w "%{http_code}\n" -G https://openapi.naver.com/v1/search/news.json \
  --data-urlencode "query=AI" -H "X-Naver-Client-Id: $NAVER_CLIENT_ID" -H "X-Naver-Client-Secret: $NAVER_CLIENT_SECRET"
```

- Firecrawl 도구가 보이는지도 적는다(호출하지 말고 목록만).
- stateof.ai가 200이 아니면 섹터 페이지만 Firecrawl `firecrawl_scrape`(`onlyMainContent: true`)로 읽는다. 섹터 예산에 포함.
- 네이버가 200이 아니면 한국 보도 조사를 Chrome 지시서로 넘기고 `brief.md`에 "네이버 미사용"이라 적는다.

### 1. 리포트 읽기

섹터 페이지와 data JSON을 먼저 읽는다. 244장 PDF를 통째로 읽지 않는다. 섹터 페이지가 인용한 슬라이드 번호만 `pdftotext -f N -l N`으로 읽는다(PDF는 `_workspace/`에 한 번만 내려받는다). 컨텍스트를 아껴야 분석에 필요한 내용이 밀려나지 않는다.

### 2. 원 출처 확인

리포트가 인용한 1차 출처 중 핵심 2–3개를 curl로 연다. 리포트 표현과 원문이 다르면(예: 퍼센트포인트와 퍼센트) 2절에 적는다. 안 열리면 꼭 필요할 때만 Firecrawl, 아니면 Chrome 지시서로.

### 3. 한국 보도

네이버 뉴스 검색 3–5회. 섹터 핵심 키워드를 한국어로 바꿔 검색한다. 결과의 `title`·`description`은 발췌일 뿐이니 근거로 쓸 기사는 `originallink`를 기록한다. 한국 기업·정책·시장과의 연결점을 3절에 한 단락으로.

### 4. Chrome 조사 지시서

`chrome-brief.md`에 구글 검색 과제를 8개 이하로. 각 과제에 "확인할 것"과 "우선 출처"를 적는다. 1–3절에서 1차 출처를 못 찾은 수치는 반드시 넣는다.

### 5. 마무리

`dossier.md` 1–3절, `chrome-brief.md`, `credits.md`, 수집 단계 `brief.md`를 쓴다. 반환값은 `brief.md` 내용 그대로.

## 분석 (sector-analyst)

1. `dossier.md` 1–3절과 `chrome-findings.md`를 읽는다. 다시 호출됐다면 `review.md`도.
2. **4절**: Chrome 결과에서 리포트 이후 소식, 반론, 다른 기관 수치를 정리한다. 리포트와 다르면 둘 다 적고 판단 이유를 쓴다.
3. **5절**: What happened / Why it matters / What's next / 한국 독자에게 / 한계와 불확실성. 근거가 파일에 없는 문장은 쓰지 않는다.
4. **6절**: 게시물 각도 2–3개. 각도마다 첫 장 훅 한 줄, 핵심 근거, 5점 평가(시의성·영향력·관련성·새로움·설명가치).
5. **7절**: 게시 / 추가 조사 / 보류 / 폐기와 이유. 통과 조건을 못 넘으면 점수가 높아도 "게시"로 쓰지 않는다.
6. `brief.md`를 분석 기준으로 갱신(30줄 이하). 반환값은 그 내용 그대로.

## Firecrawl 예산

- 섹터 상한 **6크레딧**(리포트 읽기 대체 포함). 응답의 `creditsUsed`를 매번 `credits.md`에 적는다:

  ```
  환경: stateof.ai <코드> · naver <코드> · firecrawl <있음/없음>
  | 시각 | 도구 | 대상 | creditsUsed | 이유 |
  합계: N / 6
  ```
- 검색은 `limit` 5 이하, 스크랩은 `onlyMainContent: true`. 같은 URL을 두 번 스크랩하지 않는다.
- **Alexandria는 호출하지 않는다.** 꼭 필요하면 `brief.md` 요청 칸에 "무엇을 · 왜 · 다른 방법으로 안 되는 이유"를 적는다. 호출당 약 10크레딧이라 지휘자가 사용자 승인을 받아 호출한다.

## 쓰기 원칙

- 모든 수치에 출처 URL과 날짜. 리포트의 기준(퍼센트포인트, 연환산, 자체 측정)을 그대로.
- 원문을 길게 옮기지 않고 우리 말로 요약. 인용은 짧게.
- 자기 섹터 폴더의 정해진 파일만 쓴다. 상태판·README·다른 섹터는 지휘자와 다른 에이전트의 몫이다.
