################################################################################
# ZSH configuration
################################################################################

[[ -o interactive ]] || return

DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
setopt INC_APPEND_HISTORY
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

zle_highlight=('paste:none')

setopt autocd extendedglob nomatch menucomplete interactive_comments

[[ -t 0 ]] && stty stop undef

unsetopt correct_all BEEP

autoload -Uz colors && colors

################################################################################
# Command Completions
################################################################################

autoload -Uz compinit

if [ -d "/opt/homebrew/share/zsh/site-functions" ]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
else
  fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
fi

zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zmodload zsh/complist

_comp_options+=(globdots)

if [[ -f $ZDOTDIR/.zcompdump(#qNmh-24) ]]; then
  compinit -C
else
  compinit
fi

################################################################################
# Plugins and packages
################################################################################

source "$ZDOTDIR/user/packages.sh"

zsh_add_plugin "zsh-users/zsh-autosuggestions" "v0.7.1"
zsh_add_plugin "zsh-users/zsh-history-substring-search" "v1.1.0"
zsh_add_plugin "hlissner/zsh-autopair" "v1.0"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting" "0.8.0"

zsh_add_config "config/vim-mode.sh"
zsh_add_config "config/exports.sh"
zsh_add_config "config/aliases.sh"
zsh_add_config "config/worktrees.sh"
zsh_add_config "config/fzf.sh"

################################################################################
# Imports
################################################################################

zsh_add_file "$HOME/secrets.sh"

################################################################################
# Misc
################################################################################

if [[ -o login && -f ~/.ssh/id_rsa ]]; then
  (ssh-add -l &>/dev/null || ssh-add -q --apple-use-keychain ~/.ssh/id_rsa) &!
fi

ulimit -Sn 10240

################################################################################
# Extras
################################################################################

function _cached_eval() {
  local name=$1; shift
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  local cache_file="$cache_dir/$name.zsh"
  if [[ ! -f "$cache_file" || ! -s "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    "$@" > "$cache_file"
  fi
  source "$cache_file"
}

source "$ZDOTDIR/user/prompt.sh"
_cached_eval fzf fzf --zsh
