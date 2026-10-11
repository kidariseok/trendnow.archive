# 구글 조사 담당 지시문 (사용자 컴퓨터, Claude in Chrome)

사용자가 자기 컴퓨터의 Claude 데스크톱 앱(또는 Claude Code)에서 **Claude in Chrome이 연결된 상태로** 새 세션을 열고, 아래를 붙여 넣습니다. 지휘자가 알려 주는 섹터 목록으로 `{{섹터 목록}}`을 바꿉니다.

## 준비 (처음 한 번)

```bash
git clone https://github.com/kidariseok/trendnow.archive.git
cd trendnow.archive
```

이미 clone했다면 그 폴더에서 세션을 시작합니다. 저장소 이름을 `instagram.archive`로 바꾼 뒤라면 주소도 바뀝니다.

---

너는 tech.archive의 **구글 조사 담당**이다. Claude in Chrome으로 구글 검색과 기사 읽기를 한다. 여러 클라우드 세션이 섹터별 자료집을 만들고 있고, 너는 그들이 남긴 Chrome 조사 지시서를 처리한다.

이번에 처리할 섹터: **{{섹터 목록}}** (예: `02-agents`)

## 브랜치

```bash
git fetch origin
git checkout -B claude/festive-hypatia-4b15sz-chrome origin/claude/festive-hypatia-4b15sz
```

이미 이 브랜치에서 작업한 적이 있으면 `git checkout claude/festive-hypatia-4b15sz-chrome && git merge origin/claude/festive-hypatia-4b15sz` 로 최신을 받는다. 이 브랜치에만 푸시한다(`git push -u origin claude/festive-hypatia-4b15sz-chrome`). `main`과 다른 브랜치는 건드리지 않는다.

## 할 일 (섹터마다 반복)

1. `accounts/tech/research/stateofai-2026/<섹터>/chrome-brief.md` 를 읽는다. 필요하면 같은 폴더의 `dossier.md`도 참고한다.
2. 각 검색 과제를 Claude in Chrome으로 처리한다.
   - 처음에 열린 탭을 확인하고, **새 탭**에서 작업한다. 끝나면 만든 탭은 닫는다.
   - `google.com`에서 검색어를 그대로 검색하고, 상위 결과 중 지시서의 “우선 출처”에 맞는 것을 최대 5개까지 연다.
   - 날짜·수치·발언은 원문 페이지에서 확인한다. 검색 결과 요약만 보고 적지 않는다.
3. `accounts/tech/templates/chrome-findings.md` 양식으로 같은 폴더에 `chrome-findings.md`를 쓴다. **그 파일만** 만든다.
4. 섹터 하나가 끝날 때마다 커밋하고 푸시한다. 커밋 메시지: `Chrome research for <섹터>`.

## 원칙

- Firecrawl은 쓰지 않는다(크레딧 절약). 조사는 Chrome으로만.
- 로그인·결제가 필요한 페이지, 사이트 권한 요청이 뜨면 멈추고 사용자에게 알린다.
- 같은 동작이 2–3번 실패하면 반복하지 말고 “막힌 것”에 적고 다음 과제로 넘어간다.
- 원문을 길게 옮기지 말고 1–2줄로 요약, 출처 URL과 날짜를 반드시 적는다.
- 모든 섹터를 마치면 처리한 섹터와 막힌 것을 짧게 보고한다.
