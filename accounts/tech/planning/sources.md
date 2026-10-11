# 출처와 조사 도구

← [tech.archive](../README.md)

**기사를 찾는 도구와 사실을 확인하는 출처는 다르다.** 도구는 후보를 찾는 데 쓰고, 사실은 1차 출처에서 확인합니다.

## 출처 우선순위

1. 1차 출처: 기업 공식 블로그·발표, 논문(arXiv 등), 정부·기관 문서, 실적 자료
2. 분석 리포트: State of AI Report, Epoch AI, METR 등 (리포트가 인용한 원 출처까지 확인)
3. 주요 언론 보도: 해외 주요 매체, 국내 주요 언론
4. 블로그·SNS: 후보 발견용으로만. 근거로 쓰지 않음

## 도구별 역할과 예산

| 도구 | 역할 | 어디서 | 비용 |
|---|---|---|---|
| **Claude in Chrome** | **주 조사 도구.** 구글 검색, 기사·공식 자료 읽기, 추가 서칭 | `chrome` 창 하나 (`claude --chrome`) | 없음 (사용량만) |
| 네이버 검색 API | 한국 보도·한국 연관성 조사 (`/v1/search/news.json`) | 작업자 창 (`curl`) | 무료, 하루 25,000회 |
| curl | stateof.ai 섹터 페이지·데이터·PDF, 원 출처 읽기 | 작업자·검수자 창 | 없음 |
| Firecrawl 검색·스크랩 | curl로 안 열리는 핵심 1차 자료를 찾거나 읽을 때만 | 작업자·검수자 창 (호출마다 승인) | 월 1,000 크레딧 중 이번 프로젝트 상한 100 |
| Firecrawl Alexandria | 핵심 수치를 출처 있는 데이터 레코드로 확정할 때만 (논문·인용, 시세·재무, 기업 펀딩 등) | 지휘자만 호출 | 호출당 약 10크레딧, 프로젝트 전체 3회 이하 |

### Alexandria에 대해

Alexandria는 요약하거나 시사점을 뽑아 주는 도구가 아니라, **정리된 데이터 공급자 카탈로그**입니다(논문·인용 관계, 시장 가격·재무제표, 기업 기록·펀딩, 공공 기록 등). 요약·번역·시사점 추출은 Claude 세션이 크레딧 없이 합니다. 작업자는 Alexandria가 꼭 필요하면 `brief.md`의 요청 칸에 “무엇을, 왜, 다른 방법으로 안 되는 이유”를 적고, 지휘자가 모아서 판단합니다. 공급자 탐색(`firecrawl_find_tools`)은 무료입니다.

### Firecrawl을 아끼는 규칙

- 응답의 `creditsUsed`를 섹터 폴더의 `credits.md`에 매번 기록한다.
- 섹터 상한(6크레딧)에 닿으면 Firecrawl을 멈추고 남은 조사는 `chrome-brief.md`로 넘긴다.
- 같은 URL을 두 번 스크랩하지 않는다. 읽은 내용은 바로 파일에 메모한다.
- 검색은 `limit`을 작게(5 이하), 스크랩은 `onlyMainContent: true`로.

## 네이버 검색 API 호출 예

```bash
curl -s -G "https://openapi.naver.com/v1/search/news.json" \
  --data-urlencode "query=AI 에이전트" -d display=10 -d sort=date \
  -H "X-Naver-Client-Id: $NAVER_CLIENT_ID" \
  -H "X-Naver-Client-Secret: $NAVER_CLIENT_SECRET"
```

결과의 `title`·`description`은 HTML 태그가 섞여 있고 발췌일 뿐입니다. 근거로 쓸 기사는 `originallink`의 원문에서 확인합니다(curl로 안 열리면 Chrome 지시서로).

## 키 설정

네이버 키는 Mac의 `~/.zshrc`에 환경변수 `NAVER_CLIENT_ID`, `NAVER_CLIENT_SECRET`으로 둡니다. 저장소에는 넣지 않습니다. 자세한 순서는 [local-setup.md](local-setup.md).
