# 오케스트레이션

← [tech.archive](../README.md)

여러 Claude 세션이 역할을 나눠 동시에 일하고, 지휘자 세션이 나누고·감시하고·합치는 방식입니다. tmux나 Orca로 터미널 여러 칸을 띄우는 것과 같은 구조를 클라우드 세션으로 구현합니다. 이 문서의 상태판은 **지휘자만** 고칩니다.

## 역할

| 역할 | 어디서 | 하는 일 | 쓰는 파일 |
|---|---|---|---|
| 지휘자 | 클라우드 (최초 세션) | 세션 생성·감시, 브랜치 병합, 상태판·크레딧 합산, Alexandria 승인·호출 | 이 문서, `orchestration-log.md`, 연구 폴더 `README.md` |
| 섹터 작업자 | 클라우드 (섹터당 1세션) | A단계: 리포트 정리 + 한국 보도 + Chrome 지시서 / B단계: Chrome 결과 통합, 최종 분석 | 자기 섹터 폴더의 `dossier.md`, `brief.md`, `chrome-brief.md`, `credits.md` |
| 구글 조사 담당 | **사용자 컴퓨터** (Claude in Chrome) | 섹터별 Chrome 지시서를 차례로 처리 | 각 섹터의 `chrome-findings.md` |
| 검수자 | 클라우드 (웨이브당 1세션, 작성에 참여 안 함) | 수치·날짜·인용·출처 대조 | 각 섹터의 `review.md` |

지시문: [sector-worker.md](prompts/sector-worker.md) · [chrome-researcher.md](prompts/chrome-researcher.md) · [reviewer.md](prompts/reviewer.md)

## 섹터 하나의 흐름

```
작업자 A단계 ──push──▶ 지휘자 병합 ──▶ Chrome 조사 ──push──▶ 지휘자 병합
                                                              │ send_message
검수자 ◀──── 지휘자 병합 ◀──push── 작업자 B단계 ◀───────────────┘
   │
   └─push──▶ 지휘자 병합 ──▶ 섹터 완료
```

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
| 지휘자 (통합) | `claude/festive-hypatia-4b15sz` |
| 섹터 작업자 | `claude/festive-hypatia-4b15sz-<slug>` (예: `-agents`) |
| 검수자 | `claude/festive-hypatia-4b15sz-review-a`, `-review-b` (시범은 `-review-pilot`) |
| 구글 조사 담당 | `claude/festive-hypatia-4b15sz-chrome` |

- 모든 세션은 통합 브랜치에서 출발하고, 다음 단계 전에 통합 브랜치를 `git pull`로 받아 시작합니다.
- 병합은 지휘자만 합니다. `main`에는 이 프로젝트 동안 아무것도 병합하지 않습니다.

## 메모리(컨텍스트) 관리 규칙

1. **파일이 기억이다.** 조사 결과는 채팅이 아니라 파일에 바로 쓴다. 세션 컨텍스트가 압축되거나 끊겨도 작업이 남는다.
2. **지휘자는 요약만 읽는다.** 지휘자는 섹터의 `brief.md`(30줄 이하)와 세션 상태만 본다. `dossier.md` 전체와 작업자의 대화 기록은 읽지 않는다(검수자 몫).
3. **필요한 만큼만 읽는다.** 244장 PDF를 통째로 넣지 않는다. 섹터 페이지 → 인용된 슬라이드 번호만 `pdftotext -f N -l N`으로 읽는다.
4. **한 파일엔 한 명만 쓴다.** 섹터 폴더의 파일마다 쓰는 사람이 정해져 있어 병합 충돌이 나지 않는다.
5. **폴링하지 않는다.** 지휘자는 약 20분 간격 예약 점검으로 상태를 확인한다.
6. **기록한다.** 시작·종료 시각, 크레딧, 컨텍스트 압축, 충돌, 개입을 `orchestration-log.md`에 남긴다.

## 시범 통과 조건

- [ ] 작업자 세션에서 Firecrawl 호출 성공
- [ ] 작업자 세션에서 네이버 API `curl` 응답 200
- [ ] 작업자 세션에서 stateof.ai `curl` 응답 200
- [ ] 작업자 브랜치 푸시 → 통합 브랜치 병합 시 충돌 0
- [ ] Chrome 세션이 지시서대로 `chrome-findings.md` 푸시
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

| 섹터 | 작업자 세션 | A단계 | Chrome | B단계 | 검수 | 크레딧 |
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
