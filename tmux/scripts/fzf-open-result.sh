#!/usr/bin/env bash
set -euo pipefail

RESULT_FILE=/tmp/tmux-fzf-result

[[ -f "$RESULT_FILE" ]] || exit 0

args=$(cat "$RESULT_FILE")
rm -f "$RESULT_FILE"

tmux send-keys "${EDITOR:-nvim} $args" Enter
