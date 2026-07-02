function zsh_add_config() {
  [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
}

function zsh_add_file() {
  [ -f "$1" ] && source "$1"
}

# Usage: zsh_add_plugin <owner/repo> [tag]
# Pinning to a tag protects against a compromised plugin repo; bump tags manually.
function zsh_add_plugin() {
  PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
  PLUGIN_REF="${2:-}"

  if [ ! -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then
    if [ -n "$PLUGIN_REF" ]; then
      git clone -c advice.detachedHead=false --depth 1 --branch "$PLUGIN_REF" "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
    else
      git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
    fi
  fi

  zsh_add_config "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || zsh_add_config "plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
}
