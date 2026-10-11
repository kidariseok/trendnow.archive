# 로컬(Mac) 실행 안내

← [오케스트레이션](orchestration.md)

Claude Code 세션 하나를 지휘자로 열면, 그 세션이 수집가·웹 조사원·분석가·팩트체커 에이전트를 띄웁니다. tmux 창이나 git worktree는 필요 없습니다.

## 1. 처음 한 번만

### 프로그램 설치

```bash
brew install poppler jq             # poppler = pdftotext
claude --version                    # 없으면 아래로 설치
curl -fsSL https://claude.ai/install.sh | bash
```

### Claude in Chrome

1. Chrome 웹 스토어에서 Claude 확장을 설치하고, Claude Code와 같은 계정으로 로그인합니다.
2. `claude --chrome`을 실행하고 `/chrome`으로 연결 상태를 확인합니다.
3. 구글과 뉴스 사이트에 대한 권한 요청이 뜨면 허용합니다.

### Firecrawl

Claude Code에서 `/mcp`를 입력해 Firecrawl이 보이면 끝입니다(claude.ai에 연결해 둔 커넥터). 보이지 않으면 추가합니다.

```bash
claude mcp add --scope user --transport http firecrawl https://mcp.firecrawl.dev/v2/mcp-oauth
```

Firecrawl 호출은 승인 요청이 뜨게 둡니다. 크레딧을 쓰기 전에 사람이 한 번 보게 하는 장치입니다.

### 네이버 검색 API 키

developers.naver.com에서 애플리케이션을 등록(검색 API)한 뒤 `~/.zshrc` 맨 아래에 추가합니다. 저장소에는 넣지 않습니다.

```bash
export NAVER_CLIENT_ID="발급받은 ID"
export NAVER_CLIENT_SECRET="발급받은 Secret"
```

저장 후 `source ~/.zshrc`.

### 저장소

```bash
cd ~
git clone https://github.com/kidariseok/trendnow.archive.git
cd trendnow.archive
git checkout claude/festive-hypatia-4b15sz
```

## 2. 매번 시작할 때

```bash
cd ~/trendnow.archive && git pull
claude --chrome
```

지휘자 세션의 모델은 `/model`로 고릅니다. 여러 단계를 계획하고 조율하는 역할이라 fable을 권장하고, 없으면 opus를 씁니다. 하위 에이전트의 모델과 effort는 에이전트 정의에 정해져 있습니다(수집·조사 sonnet·medium, 분석·검수 opus·high).

그다음 이렇게 입력합니다.

```
State of AI 시범 섹터 진행해줘
```

`tech-research` 스킬이 불러와지고, 이후 진행은 "웨이브 A 진행해줘", "상태 확인", "02 agents 분석만 다시" 같은 말로 이어 갑니다. 저장소의 `CLAUDE.md`가 새 세션에도 이 스킬을 쓰도록 알려 줍니다.

## 3. 진행 중에 할 일

| 상황 | 할 일 |
|---|---|
| 승인 요청 (curl, Firecrawl, 파일 수정) | 지휘자 화면에서 승인. 하위 에이전트의 요청도 여기로 올라옵니다 |
| Chrome 사이트 권한 요청 | Chrome에서 허용 |
| 진행 상황 확인 | "상태 확인" 또는 `/agents`, 백그라운드 작업 목록 |
| 승인이 너무 많을 때 | `Shift+Tab`으로 권한 모드 변경. 저장소 `.claude/settings.json`은 git 커밋, `pdftotext`, `jq`를 미리 허용합니다. `curl`과 Firecrawl은 외부로 나가는 요청이라 일부러 허용하지 않았습니다 |

Mac이 잠자기에 들어가면 세션이 멈춥니다. 오래 돌릴 때는 전원을 연결하고 다른 터미널에서 `caffeinate -di`를 켜 둡니다.

## 4. 웨이브가 끝나면

"하네스 회고해줘"라고 하면 `harness-evolve` 스킬이 운영 기록을 보고 에이전트·스킬을 고칩니다.
