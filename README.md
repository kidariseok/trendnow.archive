# instagram.archive

Instagram 계정 여러 개의 게시용 최종 이미지·캡션을 한곳에 보관하는 아카이브입니다.
계정마다 콘셉트, 요청 방식, 폰트, 분위기가 다르므로 **각 계정의 세부 페이지(`accounts/<계정>/README.md`)를 먼저 읽고** 그 규칙대로 작업합니다.

## 계정

| 계정 | 다루는 것 | 분위기 | 게시물 | 세부 페이지 |
|---|---|---|---|---|
| `trendnow.archive` | 서울 전시·바·카페 직접 방문기 | 차분한 에디토리얼, 사진 위주 | 3 | [accounts/trendnow.archive](accounts/trendnow.archive/README.md) |
| `technow.archive` | AI·테크 뉴스 선별과 해설 | 미정 (기획·분석 단계) | 0 | [accounts/tech](accounts/tech/README.md) |

## 구조

```
accounts/
  <계정 폴더>/       보통 계정 핸들과 같음 (technow.archive는 tech)
    README.md      계정 세부 페이지: 콘셉트, 요청 방식, 폰트, 색, 캡션 규칙
    profile.json   위 내용을 기계가 읽을 수 있게 정리한 설정
    posts/<번호>/  장별 1080×1350 JPG, caption.txt, post.json(대체 텍스트), container.json(게시 기록)
  _template/       새 계정을 만들 때 복사할 틀
```

게시물 번호는 계정마다 001부터 따로 셉니다. 이름이 바뀔 수 있는 계정은 바뀌지 않는 폴더 이름(예: `tech`)을 쓰고, 실제 계정 이름은 `profile.json`의 `handle`에 둡니다. `technow.archive`도 임시 이름 `tech.archive`로 시작해 폴더는 `accounts/tech` 그대로입니다.

## 새 계정 추가

1. `accounts/_template`을 `accounts/<새 계정 핸들>`로 복사합니다.
2. `README.md`와 `profile.json`의 빈칸(콘셉트, 요청 방식, 폰트, 색, 캡션 규칙, 해시태그)을 채웁니다.
3. 위 계정 표에 한 줄 추가합니다.

## 요청할 때

어느 계정용인지 먼저 밝혀 주세요. 예: “`trendnow.archive`에 성수 카페 게시물 하나 만들어줘”, “`technow.archive` State of AI 시범 섹터 진행해줘”.
계정을 밝히지 않으면 작업 전에 어느 계정인지 확인합니다.

## 에이전트 하네스

`technow.archive`의 리서치는 Claude Code 세션 하나가 역할별 에이전트를 띄워 진행합니다.

| 위치 | 내용 |
|---|---|
| `CLAUDE.md` | 어떤 요청에 어떤 지휘 스킬을 쓰는지와 변경 이력 |
| `.claude/agents/` | 리포트 수집가, 웹 조사원, 섹터 분석가, 팩트체커 |
| `.claude/skills/` | 지휘(`tech-research`)와 작업 방법(`sector-dossier`, `chrome-research`, `fact-check`) |
| `.claude/skills/harness`, `harness-evolve` | 하네스 설계·회고 스킬. [revfactory/harness](https://github.com/revfactory/harness)에서 가져옴 (Apache-2.0, 각 폴더의 `SOURCE.md`) |

시작 방법은 [accounts/tech/planning/local-setup.md](accounts/tech/planning/local-setup.md)에 있습니다.
