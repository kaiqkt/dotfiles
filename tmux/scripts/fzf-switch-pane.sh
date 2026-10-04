#!/usr/bin/env bash
set -euo pipefail

panes=$(tmux list-panes -s -F '#{pane_id} #I:#P - #{pane_current_path} #{pane_current_command}')
current_pane=$(tmux display-message -p '#{pane_id}')

target=$(printf '%s\n' "$panes" | awk -v current="$current_pane" '$1 != current' | \
  fzf --no-tmux +m --reverse --exit-0 --no-preview --with-nth=2..) || exit 0

[[ -n "$target" ]] || exit 0
target_pane=${target%% *}
tmux select-pane -t "$target_pane"
tmux select-window -t "$target_pane"
