# 섹터 작업자 지시문

지휘자가 `accounts/tech/scripts/tech.sh worker <slug>`를 실행하면, 아래 `---` 밑의 내용이 `{{ }}` 자리가 채워진 채로 새 tmux 창의 Claude Code 첫 메시지로 들어갑니다.

---

너는 tech.archive의 **섹터 작업자**다. State of AI Report 2026의 **{{NN}} {{섹터 이름}}** 섹터(`{{slug}}`)를 맡는다. 여러 세션이 동시에 다른 섹터를 작업하고 있고, 지휘자 세션이 결과를 합친다.

## 먼저 읽을 것

- `accounts/tech/planning/orchestration.md` 중 “메모리(컨텍스트) 관리 규칙”
- `accounts/tech/planning/analysis-workflow.md`
- `accounts/tech/planning/sources.md`
- `accounts/tech/templates/` 의 네 양식

## 쓰기 범위와 브랜치

- **오직 `accounts/tech/research/stateofai-2026/{{NN}}-{{slug}}/` 안의 `dossier.md`, `brief.md`, `chrome-brief.md`, `credits.md`만 만들고 고친다.** 다른 파일은 건드리지 않는다(상태판·README는 지휘자 몫).
- 너는 이미 자기 git worktree 폴더에서, **`claude/festive-hypatia-4b15sz-{{slug}}`** 브랜치로 시작했다. `git branch --show-current`로 확인하고, 브랜치를 바꾸지 않는다.
- **커밋만 하고 푸시하지 않는다.** 병합과 푸시는 지휘자가 한다. `main`은 건드리지 않는다.

## 0. 환경 확인 (결과를 credits.md 맨 위에 기록)

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://www.stateof.ai/2026-explore/{{slug}}
curl -s -o /dev/null -w "%{http_code}\n" -G https://openapi.naver.com/v1/search/news.json \
  --data-urlencode "query=AI" -H "X-Naver-Client-Id: $NAVER_CLIENT_ID" -H "X-Naver-Client-Secret: $NAVER_CLIENT_SECRET"
```

- Firecrawl 도구가 보이는지도 확인해 적는다(호출하지 않고 목록만).
- stateof.ai가 200이 아니면: 섹터 페이지만 Firecrawl `firecrawl_scrape`(`onlyMainContent: true`)로 읽는다(최대 2크레딧, 섹터 예산에 포함).
- 네이버가 200이 아니면: 한국 보도 조사를 `chrome-brief.md` 검색 과제로 넘기고 `brief.md`에 “네이버 미사용”이라고 적는다. **결과를 지어내지 않는다.**

## A단계

1. **리포트 읽기**: `https://www.stateof.ai/2026-explore/{{slug}}` 와 `https://www.stateof.ai/2026-explore/data/{{slug}}.json`. 244장 PDF 전체를 읽지 않는다. 섹터 페이지가 인용한 슬라이드만 PDF를 한 번 내려받아 `pdftotext -f N -l N` 로 읽는다(PDF는 `/tmp` 같은 저장소 밖 폴더에 두고 커밋하지 않는다).
2. **원 출처 확인**: 리포트가 인용한 1차 출처 중 핵심 2–3개를 curl로 연다. 열리지 않고 꼭 필요하면 Firecrawl 스크랩, 아니면 Chrome 지시서로 넘긴다.
3. **한국 보도**: 네이버 뉴스 검색 3–5회(섹터 핵심 키워드를 한국어로). 근거로 쓸 기사는 `originallink`를 기록한다.
4. **파일 작성**: 템플릿대로 `dossier.md` 1–3절, `chrome-brief.md`(검색어 8개 이하), `brief.md`(30줄 이하), `credits.md`.
5. 읽은 내용은 **바로바로 파일에 적는다.** 긴 원문을 대화에 붙여 두지 않는다.
6. 커밋한 뒤(`A단계: {{NN}} {{slug}}`), 마지막 답변은 `brief.md` 내용 그대로 짧게.

## Firecrawl 예산

- 섹터 상한 **6크레딧**(리포트 읽기 대체 포함). 응답의 `creditsUsed`를 `credits.md`에 매번 기록한다.
- 검색은 `limit` 5 이하, 스크랩은 `onlyMainContent: true`. 같은 URL을 두 번 스크랩하지 않는다.
- **Alexandria는 직접 호출하지 않는다.** 꼭 필요하면 `brief.md`의 요청 칸에 적는다.
- 상한에 닿으면 Firecrawl을 멈추고 남은 조사는 `chrome-brief.md`로.

`credits.md` 형식:

```
환경: stateof.ai <코드> · naver <코드>
| 시각 | 도구 | 대상 | creditsUsed | 이유 |
합계: N / 6
```

## B단계 (지휘자가 이 창에 “B단계 시작”을 보내면)

1. `git merge claude/festive-hypatia-4b15sz` 로 통합 브랜치의 최신을 받는다(같은 저장소의 로컬 브랜치라 fetch 불필요, rebase 금지).
2. 같은 섹터 폴더의 `chrome-findings.md`를 읽고 `dossier.md` 4–7절을 채운다. Chrome 결과가 리포트와 다르면 둘 다 적고 무엇을 믿을지 이유를 쓴다.
3. `brief.md`를 B단계 기준으로 갱신(30줄 이하)하고 커밋(`B단계: {{NN}} {{slug}}`). 마지막 답변은 `brief.md` 내용 그대로.

## 원칙

- 모든 수치에 출처 URL과 날짜. 리포트 표현의 기준(퍼센트포인트, 연환산, 자체 측정 등)을 그대로 적는다.
- 회사 자체 발표는 “○○ 발표 기준”으로.
- 원문을 길게 옮기지 말고 우리 말로 요약한다. 인용은 짧게.
- 막히면 같은 시도를 반복하지 말고 `brief.md`의 “남은 의문·막힌 것”에 적고 끝낸다.
