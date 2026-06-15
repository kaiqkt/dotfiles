# ZSH

## Aliases

| Alias            | Command                           |
| ---------------- | --------------------------------- |
| `ls`             | `eza -s type`                     |
| `la`             | `ls -la`                          |
| `grep`           | `grep --color=auto`               |
| `git_unlock`     | `rm -f .git/index.lock`           |
| `zsh:reload`     | `source $ZDOTDIR/.zshrc`          |
| `zsh:edit`       | Open `.zshrc` in `$EDITOR`        |
| `zsh:alias`      | Print aliases file                |
| `zsh:alias:edit` | Edit aliases in `$EDITOR`         |

Tool-specific aliases live in their own pages:

- Tmux (`t`, `ta`, `tls`, `tn`, `tk`, `tka`): [tmux.md](tmux.md#aliases)
- Borders, Sketchybar, LazyGit, Brew, Docker Compose: [tools.md](tools.md)

## FZF Shell Bindings

| Binding  | Description                         |
| -------- | ----------------------------------- |
| `Ctrl+R` | Search shell history                |
| `Ctrl+T` | Find files/directories with preview |
