#!/bin/bash
# tech.archive 로컬 오케스트레이션 도우미 (macOS 기본 bash 3.2에서 동작)
# 설명: accounts/tech/planning/local-setup.md
#
#   tech.sh worker <slug>                 섹터 작업자 창 열기 (예: worker agents)
#   tech.sh chrome <섹터 폴더...>          구글 조사 창 열기, 이미 열려 있으면 다음 섹터 전달
#   tech.sh reviewer <이름> <섹터 폴더...>  검수자 창 열기 (예: reviewer review-pilot 02-agents)
#   tech.sh send <창 이름> <메시지...>      열린 창에 메시지 입력 (예: send w-agents B단계 시작)
#   tech.sh merge <브랜치 접미사...>        통합 브랜치에 병합 (예: merge agents chrome)
#   tech.sh status                        창과 브랜치 상태 요약
#   tech.sh close <창 이름>                창 닫기 (worktree는 남음)
set -euo pipefail

BASE="claude/festive-hypatia-4b15sz"
SESSION="${TECH_TMUX_SESSION:-tech}"
CLAUDE_FLAGS="${TECH_CLAUDE_FLAGS:-}"
RESEARCH="accounts/tech/research/stateofai-2026"
PROMPT_DIR_REL="accounts/tech/planning/prompts"

MAIN="$(cd "$(git -C "$(dirname "$0")" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"
WT_ROOT="$(dirname "$MAIN")/$(basename "$MAIN")-worktrees"
PROMPTS="$WT_ROOT/_prompts"
mkdir -p "$PROMPTS"

die() { echo "tech.sh: $*" >&2; exit 1; }

sector_info() {
  case "$1" in
    research)    NN=01; NAME="AI progress" ;;
    agents)      NN=02; NAME="AI agents" ;;
    compute)     NN=03; NAME="Compute & infrastructure" ;;
    business)    NN=04; NAME="AI in business" ;;
    robotics)    NN=05; NAME="Robotics" ;;
    science)     NN=06; NAME="AI for science" ;;
    policy)      NN=07; NAME="Policy & geopolitics" ;;
    safety)      NN=08; NAME="Safety & security" ;;
    predictions) NN=09; NAME="Predictions" ;;
    *) die "모르는 섹터: $1 (research agents compute business robotics science policy safety predictions)" ;;
  esac
}

# sed 치환 문자열 안의 & / \ 를 그대로 쓰기 위한 이스케이프
esc() { printf '%s' "$1" | sed 's/[&/\]/\\&/g'; }

require_tmux() {
  tmux has-session -t "$SESSION" 2>/dev/null \
    || die "tmux 세션 '$SESSION'이 없습니다. 먼저 'tmux new -s $SESSION' 안에서 실행하세요."
}

window_exists() { tmux list-windows -t "$SESSION" -F '#W' | grep -x -- "$1" >/dev/null; }

ensure_worktree() { # <브랜치> <폴더>
  [ -d "$2" ] && return 0
  if git -C "$MAIN" show-ref --verify --quiet "refs/heads/$1"; then
    git -C "$MAIN" worktree add "$2" "$1" >/dev/null 2>&1 || die "worktree 생성 실패: $2"
  else
    git -C "$MAIN" worktree add -b "$1" "$2" "$BASE" >/dev/null 2>&1 || die "worktree 생성 실패: $2"
  fi
  echo "worktree: $2 ($1)"
}

# 지시문 파일에서 첫 '---' 줄 아래(실제 프롬프트)만 꺼내 치환
render() { # <지시문 파일> <출력 파일> <sed 식...>
  local src="$MAIN/$PROMPT_DIR_REL/$1" out="$2"; shift 2
  awk 'f && (NF || on) {on=1; print} /^---$/ && !f {f=1}' "$src" | sed "$@" > "$out"
}

open_window() { # <창 이름> <폴더> <프롬프트 파일> <추가 플래그>
  window_exists "$1" && die "창 '$1'이 이미 있습니다. 'tech.sh send $1 ...'로 메시지를 보내세요."
  tmux new-window -d -t "$SESSION:" -n "$1" -c "$2"
  tmux send-keys -t "$SESSION:$1" "claude $4 $CLAUDE_FLAGS \"\$(cat '$3')\"" Enter
  echo "창 열림: $1 (Ctrl+b → w 로 이동)"
}

send_msg() { # <창 이름> <메시지>
  window_exists "$1" || die "창 '$1'이 없습니다."
  tmux send-keys -t "$SESSION:$1" -l "$2"
  sleep 0.3
  tmux send-keys -t "$SESSION:$1" Enter
}

cmd="${1:-}"; [ -n "$cmd" ] || die "사용법은 이 파일 맨 위 주석을 보세요."; shift

case "$cmd" in
  worker)
    [ $# -eq 1 ] || die "worker <slug>"
    require_tmux; sector_info "$1"
    dir="$WT_ROOT/$1"; ensure_worktree "$BASE-$1" "$dir"
    out="$PROMPTS/w-$1.md"
    render sector-worker.md "$out" \
      -e "s/{{NN}}/$NN/g" -e "s/{{섹터 이름}}/$(esc "$NAME")/g" -e "s/{{slug}}/$1/g"
    open_window "w-$1" "$dir" "$out" ""
    ;;
  chrome)
    [ $# -ge 1 ] || die "chrome <섹터 폴더...> (예: chrome 02-agents)"
    require_tmux
    for s in "$@"; do [ -f "$MAIN/$RESEARCH/$s/chrome-brief.md" ] || die "$s/chrome-brief.md가 통합 브랜치에 없습니다. 작업자 A단계를 먼저 병합하세요."; done
    list="$(printf '%s, ' "$@")"; list="${list%, }"
    if window_exists chrome; then
      send_msg chrome "다음 섹터를 처리해: $list. 시작 전에 'git merge $BASE'로 최신 지시서를 받아."
      echo "chrome 창에 전달: $list"
    else
      dir="$WT_ROOT/chrome"; ensure_worktree "$BASE-chrome" "$dir"
      git -C "$dir" merge --no-edit "$BASE" >/dev/null
      out="$PROMPTS/chrome.md"
      render chrome-researcher.md "$out" -e "s/{{섹터 목록}}/$(esc "$list")/g"
      open_window chrome "$dir" "$out" "--chrome"
    fi
    ;;
  reviewer)
    [ $# -ge 2 ] || die "reviewer <이름> <섹터 폴더...> (예: reviewer review-pilot 02-agents)"
    require_tmux; name="$1"; shift
    list="$(printf '%s, ' "$@")"; list="${list%, }"
    dir="$WT_ROOT/$name"; ensure_worktree "$BASE-$name" "$dir"
    git -C "$dir" merge --no-edit "$BASE" >/dev/null
    out="$PROMPTS/$name.md"
    render reviewer.md "$out" -e "s/{{섹터 목록}}/$(esc "$list")/g" -e "s/{{review-이름}}/$name/g"
    open_window "$name" "$dir" "$out" ""
    ;;
  send)
    [ $# -ge 2 ] || die "send <창 이름> <메시지...>"
    require_tmux; w="$1"; shift; send_msg "$w" "$*"; echo "전달: $w"
    ;;
  merge)
    [ $# -ge 1 ] || die "merge <브랜치 접미사...> (예: merge agents chrome)"
    [ "$(git -C "$MAIN" branch --show-current)" = "$BASE" ] || die "지휘자 폴더가 $BASE 브랜치가 아닙니다."
    for s in "$@"; do
      git -C "$MAIN" merge --no-edit "$BASE-$s" >/dev/null && echo "병합: $BASE-$s"
    done
    ;;
  status)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      echo "[창]"; tmux list-windows -t "$SESSION" -F '  #W'
    fi
    echo "[브랜치: 마지막 커밋 · 통합 브랜치에 없는 커밋 수]"
    git -C "$MAIN" for-each-ref --format='%(refname:short)' "refs/heads/$BASE-*" | while read -r b; do
      ahead="$(git -C "$MAIN" rev-list --count "$BASE..$b")"
      echo "  ${b#$BASE-}: $(git -C "$MAIN" log -1 --format='%cr · %s' "$b") · 미병합 $ahead"
    done
    ;;
  close)
    [ $# -eq 1 ] || die "close <창 이름>"
    tmux kill-window -t "$SESSION:$1" && echo "닫음: $1"
    ;;
  *) die "모르는 명령: $cmd" ;;
esac
