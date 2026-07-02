#!/usr/bin/env bash
set -euo pipefail

# Wrapper that dims the background panes while a popup script runs.
# Usage: fzf-popup.sh <script> [args...]
#
# Detects the parent window automatically via TMUX_PANE.

# Find the window containing the pane that launched this popup
WINDOW_ID=$(tmux list-panes -a -F '#{pane_id} #{window_id}' | awk -v pane="${TMUX_PANE:-}" '$1 != pane {print $2}' | head -1)

# Fallback: use the active window of the current client
if [[ -z "$WINDOW_ID" ]]; then
  WINDOW_ID=$(tmux display-message -p '#{window_id}')
fi

# Export the active pane in the original window so scripts can send commands to it
CALLER_PANE=$(tmux list-panes -t "$WINDOW_ID" -F '#{pane_id} #{pane_active}' | awk '$2 == 1 {print $1}')
export CALLER_PANE

# Capture current styles before dimming so restore always matches the active theme
ORIG_STYLE=$(tmux show -t "$WINDOW_ID" -wv window-style 2>/dev/null || true)
ORIG_ACTIVE_STYLE=$(tmux show -t "$WINDOW_ID" -wv window-active-style 2>/dev/null || true)

# Dim the original window's panes
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

# Run the actual script
"$@"
