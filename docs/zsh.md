# ZSH

## Aliases

| Alias             | Command                                         |
| ----------------- | ----------------------------------------------- |
| `ls`              | `eza -s type`                                   |
| `la`              | `ls -la`                                        |
| `grep`            | `grep --color=auto`                             |
| `git_unlock`      | `rm -f .git/index.lock`                         |
| `lazygit`         | `lazygit -ucd ~/.config/lazygit/`               |
| `zsh:reload`      | `source $ZDOTDIR/.zshrc`                        |
| `zsh:edit`        | Open `.zshrc` in `$EDITOR`                      |
| `zsh:alias`       | Print aliases file                              |
| `zsh:alias:edit`  | Edit aliases in `$EDITOR`                       |
| `t`               | `tmux`                                          |
| `ta`              | `tmux attach -t`                                |
| `tls`             | `tmux ls`                                       |
| `tn`              | `tmux new -t`                                   |
| `brew:upgrade`    | `brew upgrade`                                  |
| `brew:bundle`     | `brew bundle --file ~/.Brewfile`                |
| `sketchy:start`   | Hide native menu bar + start sketchybar service |
| `sketchy:stop`    | Stop sketchybar + restore native menu bar       |
| `sketchy:restart` | Restart sketchybar                              |
| `dc`              | `docker compose`                                |
| `dcr`             | `docker compose run --rm`                       |
| `dce`             | `docker compose exec`                           |
| `dcw`             | `docker compose watch`                          |

## FZF Shell Bindings

| Binding  | Description                         |
| -------- | ----------------------------------- |
| `Ctrl+R` | Search shell history                |
| `Ctrl+T` | Find files/directories with preview |

## Docker Functions

| Function        | Description                                             |
| --------------- | ------------------------------------------------------- |
| `docker-attach` | Attach to running compose container by service name     |
| `dc-dev`        | Start `app` service, watch for changes, attach to shell |
