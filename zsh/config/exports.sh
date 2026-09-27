path=(
  $HOME/.cargo/bin
  /opt/homebrew/opt/rustup/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $HOME/.asdf/shims
  $HOME/.local/scripts
  $HOME/.local/bin
  $HOME/.bin
  /usr/local/bin
  $path
)

export EDITOR=nvim
export VISUAL=nvim

[ -f "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/java/set-java-home.zsh" ] && \
  . "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/java/set-java-home.zsh"
export LANG=en_US.UTF-8
export HOMEBREW_NO_ENV_HINTS=1
export TERMINAL=kitty
export FUNCNEST=100
export COLORTERM=truecolor

export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
