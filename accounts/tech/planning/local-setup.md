# 로컬(Mac) 실행 안내

← [오케스트레이션](orchestration.md)

tmux 창 여러 개에 Claude Code를 하나씩 띄우고, 지휘자 창이 나머지를 열고 합칩니다. 창마다 별도 git worktree(같은 저장소의 작업용 복사본)를 써서 서로 파일을 덮어쓰지 않습니다.

```
tmux 세션 "tech"
├─ 창 0  지휘자        ~/trendnow.archive                     (통합 브랜치)
├─ 창    w-agents      ~/trendnow.archive-worktrees/agents     (…-agents)
├─ 창    w-research …  ~/trendnow.archive-worktrees/research   (…-research)
├─ 창    chrome        ~/trendnow.archive-worktrees/chrome     (…-chrome, claude --chrome)
└─ 창    review-pilot  ~/trendnow.archive-worktrees/review-pilot
```

## 1. 처음 한 번만

### 프로그램 설치

```bash
brew install tmux poppler jq        # poppler = pdftotext
claude --version                    # 없으면 아래로 설치
curl -fsSL https://claude.ai/install.sh | bash
```

### tmux 설정 (`~/.tmux.conf`)

```bash
set -g mouse on
set -g history-limit 50000
set -g base-index 1
set -g renumber-windows on
set -g status-right "#S"
```

### Claude in Chrome

1. Chrome 웹 스토어에서 Claude 확장을 설치하고, Claude Code와 같은 계정으로 로그인합니다.
2. 아무 폴더에서 `claude --chrome`을 실행하고 `/chrome`으로 연결 상태를 확인합니다.
3. 구글과 뉴스 사이트에 대한 권한 요청이 뜨면 허용합니다.

### Firecrawl

Claude Code에서 `/mcp`를 입력해 Firecrawl이 보이면 끝입니다(claude.ai에 연결해 둔 커넥터). 보이지 않으면 **모든 폴더에서 쓰이도록 user 범위로** 추가합니다. worktree마다 폴더가 달라서, 기본 범위로 추가하면 다른 창에서 안 보입니다.

```bash
claude mcp add --scope user --transport http firecrawl https://mcp.firecrawl.dev/v2/mcp-oauth
```

Firecrawl 호출은 창마다 승인 요청이 뜨게 둡니다. 크레딧을 쓰기 전에 사람이 한 번 보게 하는 장치입니다.

### 네이버 검색 API 키

developers.naver.com에서 애플리케이션을 등록(검색 API)한 뒤 `~/.zshrc` 맨 아래에 추가합니다. 저장소에는 넣지 않습니다.

```bash
export NAVER_CLIENT_ID="발급받은 ID"
export NAVER_CLIENT_SECRET="발급받은 Secret"
```

저장 후 `source ~/.zshrc`. tmux가 이미 켜져 있었다면 `tmux kill-server` 후 다시 시작해야 새 창에 키가 들어갑니다.

### 저장소

```bash
cd ~
git clone https://github.com/kidariseok/trendnow.archive.git
cd trendnow.archive
git checkout claude/festive-hypatia-4b15sz
```

저장소 이름을 `instagram.archive`로 바꿨다면 주소만 바꿔서 clone합니다. 폴더 이름은 무엇이든 괜찮습니다(worktree는 그 옆의 `<폴더>-worktrees`에 생깁니다).

## 2. 매번 시작할 때

```bash
cd ~/trendnow.archive
git pull
tmux new -s tech            # 이미 있으면: tmux attach -t tech
claude                      # 지휘자
```

지휘자 Claude Code에 이 한 줄을 입력합니다.

```
accounts/tech/planning/prompts/conductor.md 파일의 --- 아래 지시를 읽고 그대로 따라.
```

이후 지휘자가 `accounts/tech/scripts/tech.sh`로 작업자·Chrome·검수자 창을 엽니다. 각 창은 자기 지시문을 첫 메시지로 받고 시작합니다.

새 worktree 폴더에서 Claude Code를 처음 열면 “이 폴더를 신뢰하나요?” 확인이 뜹니다. 창이 열렸다는 안내가 나오면 그 창으로 가서 한 번 승인해야 작업이 시작됩니다.

## 3. 창 다루기

| 하고 싶은 것 | 방법 |
|---|---|
| 창 목록 보고 이동 | `Ctrl+b` → `w` |
| 다음 / 이전 창 | `Ctrl+b` → `n` / `p` |
| 빠져나오기 (모두 계속 실행) | `Ctrl+b` → `d`, 다시 들어가기 `tmux attach -t tech` |
| 권한 승인 | 승인 요청이 뜬 창으로 이동해 선택 |
| 지휘자에게 진행 요청 | 지휘자 창에 “상태 확인” |

작업자 창은 기본 권한 모드로 시작합니다. 승인 요청이 너무 많으면 그 창에서 `Shift+Tab`으로 모드를 바꾸거나, 지휘자를 시작하기 전에 `export TECH_CLAUDE_FLAGS="--permission-mode acceptEdits"`로 파일 수정 승인을 생략할 수 있습니다. 저장소의 `.claude/settings.json`은 git 커밋·병합, `pdftotext`, `jq`, `tech.sh`를 미리 허용해 둡니다. `curl`과 Firecrawl은 외부로 나가는 요청이라 일부러 허용하지 않았습니다.

## 4. 노트북을 덮을 때

Mac이 잠자기에 들어가면 모든 창이 멈춥니다. 돌려 두려면 전원을 연결하고 다른 터미널에서 `caffeinate -di`를 켜 둡니다.

## 5. 정리

프로젝트가 끝나면 worktree를 지웁니다(커밋은 브랜치에 남습니다).

```bash
git worktree list
git worktree remove ../trendnow.archive-worktrees/agents
```
