# 오케스트레이션

← [technow.archive](../README.md)

Mac에서 Claude Code **세션 하나**를 지휘자로 열고, 그 안에서 역할별 에이전트를 띄워 동시에 일하게 합니다. [harness](../../../.claude/skills/harness/SKILL.md) 스킬로 역할을 설계했습니다. 이 문서의 상태판은 **지휘자만** 고칩니다.

- 시작 방법: [local-setup.md](local-setup.md)
- 지휘 절차(실행 모드, 호출 방법, 오류 처리): [`tech-research` 스킬](../../../.claude/skills/tech-research/SKILL.md)

> 처음에는 클라우드 세션 여러 개 → 다음엔 tmux 창 여러 개 + git worktree로 계획했다가, 세션 하나 안의 에이전트 팀으로 바꿨습니다. 경위는 [운영 기록](orchestration-log.md)에 있습니다.

## 역할

| 역할 | 에이전트 정의 | 모델 · effort | 실행 방식 | 쓰는 파일 (섹터 폴더) |
|---|---|---|---|---|
| 지휘자 | 메인 세션 + `tech-research` 스킬 | 세션 모델 (fable 권장) | — | 이 문서, `orchestration-log.md`, 연구 폴더 `README.md` |
| 리포트 수집가 | [`report-collector`](../../../.claude/agents/report-collector.md) | sonnet · medium | 단발, 섹터마다 병렬 | `dossier.md` 1–3절, `chrome-brief.md`, `credits.md`, `brief.md` |
| 웹 조사원 | [`web-researcher`](../../../.claude/agents/web-researcher.md) | sonnet · medium | 지속형 1명, 섹터 순차 | `chrome-findings.md` |
| 섹터 분석가 | [`sector-analyst`](../../../.claude/agents/sector-analyst.md) | opus · high | 단발, 섹터마다 | `dossier.md` 4–7절, `brief.md` |
| 팩트체커 | [`fact-checker`](../../../.claude/agents/fact-checker.md) | opus · high | 단발, 웨이브당 1명 | `review.md` |
| 회고 | `harness-evolve` 스킬 | — | 웨이브 후 | 에이전트·스킬, `CLAUDE.md` |

스킬: [sector-dossier](../../../.claude/skills/sector-dossier/SKILL.md) (수집·분석 방법) · [chrome-research](../../../.claude/skills/chrome-research/SKILL.md) · [fact-check](../../../.claude/skills/fact-check/SKILL.md)

## 섹터 하나의 흐름

```
수집가 ─▶ 커밋 ─▶ 웹 조사원(Chrome, 한 섹터씩) ─▶ 커밋 ─▶ 분석가 ─▶ 커밋
                                                                    │
                       섹터 완료 ◀─ 커밋 ◀─ 팩트체커 ◀────────────────┘
                                          │ 수정 필요 → 분석가 다시 (최대 2회)
```

섹터마다 앞 단계가 끝나는 대로 다음 단계로 넘어갑니다. 다른 섹터를 기다리지 않습니다. 커밋은 지휘자가 하며, 단계 사이의 파일을 고정(동결)하는 역할을 합니다.

## 웨이브

| 웨이브 | 섹터 | 동시 실행 |
|---|---|---|
| 시범 | 02 agents | 수집가 1 → 조사원 1 → 분석가 1 → 팩트체커 1 |
| A | 01 research · 03 compute · 04 business · 08 safety | 수집가·분석가 최대 4 + 조사원 1 + 팩트체커 1 |
| B | 05 robotics · 06 science · 07 policy · 09 predictions | 같음. 09는 다른 섹터의 `brief.md`를 참고 |

## 브랜치

모든 작업은 `claude/festive-hypatia-4b15sz` 하나에서 합니다. 에이전트는 커밋하지 않고, 지휘자가 단계마다 커밋하고 푸시합니다. `main`에는 이 프로젝트 동안 아무것도 병합하지 않습니다.

## 메모리(컨텍스트) 관리 규칙

1. **파일이 기억이다.** 조사 결과는 대화가 아니라 파일에 바로 쓴다. 컨텍스트가 압축되거나 에이전트가 끝나도 작업이 남는다.
2. **지휘자는 요약만 읽는다.** 에이전트 반환값(= `brief.md`, 30줄 이하)과 한 줄 보고만 본다. `dossier.md` 본문과 에이전트 대화는 읽지 않는다.
3. **분석가는 새로 시작한다.** 수집가의 대화를 이어받지 않고 파일만 읽는다. 사실과 해석이 섞이지 않고, 파일에 빠진 것이 바로 드러난다.
4. **필요한 만큼만 읽는다.** 244장 PDF를 통째로 넣지 않는다. 섹터 페이지 → 인용된 슬라이드만 `pdftotext -f N -l N`.
5. **원자료는 `_workspace/`에.** pdftotext 출력, API 응답 원본은 커밋하지 않는 `_workspace/stateofai-2026/<섹터>/`에 둔다.
6. **한 파일엔 한 명만 쓴다.** 같은 폴더에서 여럿이 동시에 일해도 충돌하지 않는다.
7. **기록한다.** 단계 시각, 에이전트별 소요 시간·토큰, 크레딧, 컨텍스트 압축, 사람의 개입을 `orchestration-log.md`에 남긴다.

## 시범 통과 조건

- [ ] 수집가에게 Firecrawl 도구가 보임, 네이버 API·stateof.ai `curl` 응답 200
- [ ] 웹 조사원 첫 보고에 Claude in Chrome 도구가 있음 (없으면 지휘자가 대신 처리하고 기록)
- [ ] 섹터 Firecrawl 사용 ≤ 6크레딧
- [ ] 6개 파일(`dossier`, `brief`, `chrome-brief`, `chrome-findings`, `credits`, `review`)이 모두 생김
- [ ] 시범에서 드러난 문제를 `harness-evolve`로 에이전트·스킬에 반영

## 섹터 완료 조건

- [ ] `dossier.md`의 모든 수치에 출처 URL과 날짜
- [ ] 1차 출처 1개 이상
- [ ] 한국 보도 2건 이상 (네이버 API 또는 Chrome)
- [ ] Chrome 조사 출처 3개 이상
- [ ] `brief.md` 30줄 이하
- [ ] `review.md` 판정 “통과”

## 상태판

단계: `-` 대기 · `진행` · `완료` · `막힘`

| 섹터 | 수집 | Chrome | 분석 | 검수 | 크레딧 |
|---|---|---|---|---|---|
| 01 research | - | - | - | - | 0 |
| 02 agents (시범) | - | - | - | - | 0 |
| 03 compute | - | - | - | - | 0 |
| 04 business | - | - | - | - | 0 |
| 05 robotics | - | - | - | - | 0 |
| 06 science | - | - | - | - | 0 |
| 07 policy | - | - | - | - | 0 |
| 08 safety | - | - | - | - | 0 |
| 09 predictions | - | - | - | - | 0 |

**크레딧 합계**: 기획 조사 3 + 섹터 0 + 검수 0 + Alexandria 0 = **3 / 상한 100**

### Alexandria 요청

| 섹터 | 요청 | 결정 | 크레딧 |
|---|---|---|---|
| | | | |
