#!/usr/bin/env bash
set -euo pipefail

: "${TMUX_FZF_RESULT_FILE:?Run through fzf-popup.sh}"

FD_BASE="fd --type f --strip-cwd-prefix --follow --exclude .git --exclude node_modules"

file=$($FD_BASE | \
  fzf --no-tmux --preview 'fzf-preview.sh {}' \
    --prompt '> ' \
    --header 'Enter: edit here · Ctrl-S: edit in pane · Ctrl-H: toggle hidden' \
    --bind 'ctrl-s:become(printf "%s\0" {} > "$TMUX_FZF_RESULT_FILE")' \
    --bind "ctrl-h:transform:[[ \$FZF_PROMPT == '> ' ]] && echo 'change-prompt(hidden> )+reload($FD_BASE --hidden)' || echo 'change-prompt(> )+reload($FD_BASE)'" \
    --exit-0) || exit 0

if [[ -n "$file" ]]; then
  ${EDITOR:-nvim} "$file"
fi
