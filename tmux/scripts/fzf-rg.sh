#!/usr/bin/env bash
set -euo pipefail

RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"

: "${TMUX_FZF_RESULT_FILE:?Run through fzf-popup.sh}"

result=$(fzf --no-tmux --ansi --disabled \
    --bind "start:reload:$RG_PREFIX {q} || true" \
    --bind "change:reload:$RG_PREFIX {q} || true" \
    --delimiter : \
    --header 'Enter: edit here, Ctrl-S: edit in pane' \
    --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' \
    --preview-window '+{2}/2' \
    --bind 'ctrl-s:become(printf "%s\0" +{2} {1} > "$TMUX_FZF_RESULT_FILE")' \
    --exit-0) || exit 0

if [[ -n "$result" ]]; then
  file=$(echo "$result" | awk -F: '{print $1}')
  line=$(echo "$result" | awk -F: '{print $2}')
  ${EDITOR:-nvim} "+$line" "$file"
fi
