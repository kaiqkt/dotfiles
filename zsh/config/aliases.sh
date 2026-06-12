################################################################################
# Aliases
################################################################################

# General
alias ls="eza -s type"
alias la="ls -la"
alias grep="grep --color=auto"
alias git_unlock="rm -f .git/index.lock"

# Lazygit
alias lazygit="lazygit -ucd ~/.config/lazygit/"

# ZSH
alias zsh:reload='source $ZDOTDIR/.zshrc'
alias zsh:edit="$EDITOR $ZDOTDIR/.zshrc"
alias zsh:alias="cat ~/.config/zsh/config/aliases.sh"
alias zsh:alias:edit="$EDITOR ~/.config/zsh/config/aliases.sh"

# Tmux
alias t="tmux"
alias ta="t a -t"
alias tls="t ls"
alias tn="t new -t"

# Brew
alias brew:upgrade="brew upgrade"
alias brew:bundle="brew bundle --file ~/.Brewfile"

# Docker Compose
alias dc="docker compose"
alias dcr="docker compose run --rm"
alias dce="docker compose exec"
alias dcw="docker compose watch"

function docker-attach() {
  docker attach $(docker-compose ps -q $1)
}

function dc-dev() {
  dc up -d app || return 1
  dcw &
  local watch_pid=$!
  trap "kill $watch_pid 2>/dev/null" EXIT INT TERM
  docker-attach app
}

# Sketchybar
alias sketchy:start="brew services start sketchybar && defaults write NSGlobalDomain _HIHideMenuBar -bool true && killall SystemUIServer"
alias sketchy:stop="brew services stop sketchybar && defaults write NSGlobalDomain _HIHideMenuBar -bool false && killall SystemUIServer"
alias sketchy:restart="brew services restart sketchybar"

# Utilities
function list_colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}
