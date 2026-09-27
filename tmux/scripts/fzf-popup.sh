#!/usr/bin/env bash
set -euo pipefail


WINDOW_ID=$(tmux list-panes -a -F '#{pane_id} #{window_id}' | awk -v pane="${TMUX_PANE:-}" '$1 != pane {print $2}' | head -1)

if [[ -z "$WINDOW_ID" ]]; then
  WINDOW_ID=$(tmux display-message -p '#{window_id}')
fi

CALLER_PANE=$(tmux list-panes -t "$WINDOW_ID" -F '#{pane_id} #{pane_active}' | awk '$2 == 1 {print $1}')
export CALLER_PANE

ORIG_STYLE=$(tmux show -t "$WINDOW_ID" -wv window-style 2>/dev/null || true)
ORIG_ACTIVE_STYLE=$(tmux show -t "$WINDOW_ID" -wv window-active-style 2>/dev/null || true)

tmux set -t "$WINDOW_ID" -w window-style "fg=#464f62,bg=#1c1f26"
tmux set -t "$WINDOW_ID" -w window-active-style "fg=#464f62,bg=#1c1f26"

restore() {
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

"$@"
