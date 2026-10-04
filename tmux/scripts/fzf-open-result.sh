#!/usr/bin/env bash
set -euo pipefail

[[ -s "${TMUX_FZF_RESULT_FILE:-}" ]] || exit 0
args=()
while IFS= read -r -d '' arg; do
  args+=("$arg")
done < "$TMUX_FZF_RESULT_FILE"
[[ ${#args[@]} -gt 0 ]] || exit 0

# Resolve the selected file in the popup's directory (which can be ~).
file_index=$((${#args[@]} - 1))
[[ ${args[$file_index]} == /* ]] || args[$file_index]="$PWD/${args[$file_index]}"
printf -v command '%q ' "${EDITOR:-nvim}" "${args[@]}"
tmux send-keys -t "$CALLER_PANE" -l "$command"
tmux send-keys -t "$CALLER_PANE" Enter
