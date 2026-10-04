#!/usr/bin/env bash
set -euo pipefail


CALLER_PANE=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{pane_id}')
export CALLER_PANE
WINDOW_ID=$(tmux display-message -p -t "$CALLER_PANE" '#{window_id}')
TMUX_FZF_RESULT_FILE=$(mktemp "${TMPDIR:-/tmp}/tmux-fzf.XXXXXX")
export TMUX_FZF_RESULT_FILE

ORIG_STYLE=$(tmux show -t "$WINDOW_ID" -wv window-style 2>/dev/null || true)
ORIG_ACTIVE_STYLE=$(tmux show -t "$WINDOW_ID" -wv window-active-style 2>/dev/null || true)

restore() {
  rm -f "$TMUX_FZF_RESULT_FILE"
  if [[ -n "$ORIG_STYLE" ]]; then
    tmux set -t "$WINDOW_ID" -w window-style "$ORIG_STYLE" 2>/dev/null || true
  else
    tmux set -t "$WINDOW_ID" -wu window-style 2>/dev/null || true
  fi
  if [[ -n "$ORIG_ACTIVE_STYLE" ]]; then
    tmux set -t "$WINDOW_ID" -w window-active-style "$ORIG_ACTIVE_STYLE" 2>/dev/null || true
  else
    tmux set -t "$WINDOW_ID" -wu window-active-style 2>/dev/null || true
  fi
}
trap restore EXIT

tmux set -t "$WINDOW_ID" -w window-style "fg=colour8"
tmux set -t "$WINDOW_ID" -w window-active-style "fg=colour8"

"$@"
"$(dirname "$0")/fzf-open-result.sh"
