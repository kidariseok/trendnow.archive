# 오케스트레이션

← [tech.archive](../README.md)

여러 Claude Code 세션이 역할을 나눠 동시에 일하고, 지휘자 세션이 나누고·감시하고·합치는 방식입니다. **사용자의 Mac에서 tmux 창 여러 개 + git worktree로 실행합니다.** 주 조사 도구인 Claude in Chrome이 로컬에서만 돌기 때문입니다(처음엔 클라우드 세션으로 계획했다가 옮김). 이 문서의 상태판은 **지휘자만** 고칩니다.

- 설치와 시작: [local-setup.md](local-setup.md)
- 창 열기·메시지·병합 도구: [`scripts/tech.sh`](../scripts/tech.sh)

## 역할

| 역할 | 어디서 | 하는 일 | 쓰는 파일 |
|---|---|---|---|
| 지휘자 | tmux 첫 창, 저장소 폴더 | `tech.sh`로 창 열기·메시지, 브랜치 병합·백업 푸시, 상태판·크레딧 합산, Alexandria 요청 정리 | 이 문서, `orchestration-log.md`, 연구 폴더 `README.md` |
| 섹터 작업자 | tmux 창 `w-<slug>`, 섹터별 worktree | A단계: 리포트 정리 + 한국 보도 + Chrome 지시서 / B단계: Chrome 결과 통합, 최종 분석 | 자기 섹터 폴더의 `dossier.md`, `brief.md`, `chrome-brief.md`, `credits.md` |
| 구글 조사 담당 | tmux 창 `chrome`, `claude --chrome` (Chrome을 쓰는 유일한 창) | 섹터별 Chrome 지시서를 차례로 처리 | 각 섹터의 `chrome-findings.md` |
| 검수자 | tmux 창 `review-<이름>`, 웨이브당 1개 (작성에 참여 안 함) | 수치·날짜·인용·출처 대조 | 각 섹터의 `review.md` |

지시문: [conductor.md](prompts/conductor.md) · [sector-worker.md](prompts/sector-worker.md) · [chrome-researcher.md](prompts/chrome-researcher.md) · [reviewer.md](prompts/reviewer.md)

## 섹터 하나의 흐름

```
작업자 A단계 ─commit─▶ tech.sh merge ─▶ tech.sh chrome ─▶ Chrome 조사 ─commit─▶ tech.sh merge
                                                                              │ tech.sh send "B단계 시작"
검수자 ◀─ tech.sh reviewer ◀─ tech.sh merge ◀─commit─ 작업자 B단계 ◀───────────┘
   │
   └─commit─▶ tech.sh merge ─▶ 섹터 완료 (지휘자가 통합 브랜치 푸시)
```

모든 창이 같은 저장소의 worktree라서 푸시 없이 로컬 브랜치끼리 병합합니다.

## 웨이브

| 웨이브 | 섹터 | 동시 세션 |
|---|---|---|
| 시범 | 02 agents | 작업자 1 |
| A | 01 research · 03 compute · 04 business · 08 safety | 작업자 4 + 검수자 1 |
| B | 05 robotics · 06 science · 07 policy · 09 predictions | 작업자 4 + 검수자 1 |

Chrome은 브라우저 하나를 공유하므로 구글 조사 담당은 한 세션이 섹터를 차례로 처리합니다. 09 predictions는 다른 섹터의 `brief.md`를 참고합니다.

## 브랜치

| 누가 | 브랜치 |
|---|---|
| 지휘자 (통합, 저장소 폴더) | `claude/festive-hypatia-4b15sz` |
| 섹터 작업자 | `claude/festive-hypatia-4b15sz-<slug>` (예: `-agents`) |
| 검수자 | `claude/festive-hypatia-4b15sz-review-a`, `-review-b` (시범은 `-review-pilot`) |
| 구글 조사 담당 | `claude/festive-hypatia-4b15sz-chrome` |

- 나머지 브랜치는 `tech.sh`가 통합 브랜치에서 만들어 `../<저장소 폴더>-worktrees/<이름>`에 worktree로 엽니다.
- 작업자·Chrome·검수자는 **커밋만** 하고, 다음 단계 전에 `git merge claude/festive-hypatia-4b15sz`로 최신을 받습니다.
- 병합과 GitHub 푸시(통합 브랜치 백업)는 지휘자만 합니다. `main`에는 이 프로젝트 동안 아무것도 병합하지 않습니다.

## 메모리(컨텍스트) 관리 규칙

1. **파일이 기억이다.** 조사 결과는 채팅이 아니라 파일에 바로 쓴다. 세션 컨텍스트가 압축되거나 끊겨도 작업이 남는다.
2. **지휘자는 요약만 읽는다.** 지휘자는 섹터의 `brief.md`(30줄 이하)와 세션 상태만 본다. `dossier.md` 전체와 작업자의 대화 기록은 읽지 않는다(검수자 몫).
3. **필요한 만큼만 읽는다.** 244장 PDF를 통째로 넣지 않는다. 섹터 페이지 → 인용된 슬라이드 번호만 `pdftotext -f N -l N`으로 읽는다.
4. **한 파일엔 한 명만 쓴다.** 섹터 폴더의 파일마다 쓰는 사람이 정해져 있어 병합 충돌이 나지 않는다.
5. **폴링하지 않는다.** 지휘자는 일을 넘긴 뒤 턴을 끝내고, 사용자가 “상태 확인”이라고 하면 `tech.sh status`와 새 `brief.md`만 본다.
6. **기록한다.** 시작·종료 시각, 크레딧, 컨텍스트 압축, 충돌, 개입을 `orchestration-log.md`에 남긴다.

## 시범 통과 조건

- [ ] 작업자 창에서 Firecrawl 도구가 보임
- [ ] 작업자 창에서 네이버 API `curl` 응답 200
- [ ] 작업자 창에서 stateof.ai `curl` 응답 200
- [ ] 작업자 커밋 → `tech.sh merge` 충돌 0
- [ ] Chrome 창이 지시서대로 `chrome-findings.md` 커밋
- [ ] 섹터 Firecrawl 사용 ≤ 6크레딧
- [ ] 시범에서 드러난 문제를 템플릿·지시문에 반영

## 섹터 완료 조건

- [ ] `dossier.md`의 모든 수치에 출처 URL과 날짜
- [ ] 1차 출처 1개 이상
- [ ] 한국 보도 2건 이상 (네이버 API 또는 Chrome)
- [ ] Chrome 조사 출처 3개 이상
- [ ] `brief.md` 30줄 이하
- [ ] `review.md` 판정 “통과”

## 상태판

단계: `-` 대기 · `진행` · `완료` · `막힘`

| 섹터 | 창 | A단계 | Chrome | B단계 | 검수 | 크레딧 |
|---|---|---|---|---|---|---|
| 01 research | | - | - | - | - | 0 |
| 02 agents (시범) | | - | - | - | - | 0 |
| 03 compute | | - | - | - | - | 0 |
| 04 business | | - | - | - | - | 0 |
| 05 robotics | | - | - | - | - | 0 |
| 06 science | | - | - | - | - | 0 |
| 07 policy | | - | - | - | - | 0 |
| 08 safety | | - | - | - | - | 0 |
| 09 predictions | | - | - | - | - | 0 |

**크레딧 합계**: 기획 조사 3 + 섹터 0 + Alexandria 0 = **3 / 상한 100**

### Alexandria 요청

| 섹터 | 요청 | 결정 | 크레딧 |
|---|---|---|---|
| | | | |
