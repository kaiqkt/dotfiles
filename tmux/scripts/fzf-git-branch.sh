#!/usr/bin/env bash
set -euo pipefail

branch=$(git branch -a --sort=-committerdate \
  --format='%(refname:short) %(committerdate:relative) %(subject)' | \
  fzf --no-tmux --header 'Switch branch' \
      --preview 'git log --oneline --graph --color=always {1} -- | head -20' \
      --exit-0 | \
  awk '{print $1}') || exit 0

if [[ -n "$branch" ]]; then
  branch="${branch#origin/}"
  git checkout "$branch" 2>/dev/null || git checkout -b "$branch" "origin/$branch"
fi
