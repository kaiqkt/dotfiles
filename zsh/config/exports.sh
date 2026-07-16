################################################################################
# Exported Variables
################################################################################

path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $HOME/.asdf/shims
  $HOME/.local/scripts
  $HOME/.local/bin
  $HOME/.bin
  /usr/local/bin
  $path
)

export EDITOR=vim

# asdf java home
[ -f "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/java/set-java-home.zsh" ] && \
  . "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/java/set-java-home.zsh"
export LANG=en_US.UTF-8
export HOMEBREW_NO_ENV_HINTS=1
export TERMINAL=kitty
export FUNCNEST=100
export COLORTERM=truecolor

# testcontainers + colima: ryuk monta o socket do daemon; o path do host
# (~/.colima/...) não existe dentro da VM, então aponta pro socket interno
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
