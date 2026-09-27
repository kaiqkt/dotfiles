export FZF_DEFAULT_OPTS_FILE=~/.fzfrc

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'CTRL-Y to copy into clipboard'
  --height=100%
  --preview-window=:hidden"

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,.DS_Store
  --preview 'fzf-preview.sh {}'
  --height=100%"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'

fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git ${1:+--search-path "$1"} | \
    fzf --no-tmux --no-preview) && cd "$dir"
}

fe() {
  IFS=$'\n' files=($(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | \
    fzf --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

fo() {
  IFS=$'\n' out=("$(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | \
    fzf --query="$1" --exit-0 --expect=ctrl-o)")
  key=$(head -1 <<<"$out")
  file=$(head -2 <<<"$out" | tail -1)
  if [[ -n "$file" ]]; then
    [[ "$key" = ctrl-o ]] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}