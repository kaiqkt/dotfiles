# ZSH

## Aliases

| Alias            | Command                    |
| ---------------- | -------------------------- |
| `ls`             | `eza -s type`              |
| `la`             | `ls -la`                   |
| `grep`           | `grep --color=auto`        |
| `git_unlock`     | `rm -f .git/index.lock`    |
| `zsh:reload`     | `source $ZDOTDIR/.zshrc`   |
| `zsh:edit`       | Open `.zshrc` in `$EDITOR` |
| `zsh:alias`      | Print aliases file         |
| `zsh:alias:edit` | Edit aliases in `$EDITOR`  |

Tool-specific aliases live on their own pages:

- Tmux (`t`, `ta`, `tls`, `tn`, `tk`, `tka`): [tmux.md](tmux.md#aliases)
- Git worktrees (`wt:*`): [worktrees.md](worktrees.md)
- Borders, Sketchybar, LazyGit, Brew, Docker Compose: [tools.md](tools.md)

## FZF Shell Bindings

| Binding  | Description                                                |
| -------- | ---------------------------------------------------------- |
| `Ctrl+R` | Search shell history (`Ctrl+Y` copies selection to clipboard) |
| `Ctrl+T` | Find files/directories with `bat` preview                  |

## FZF Functions

Defined in `zsh/config/fzf.sh`. Use `fd` under the hood (hidden + follow, `.git` excluded).

| Function       | Description                                                            |
| -------------- | ---------------------------------------------------------------------- |
| `fcd [path]`   | Fuzzy `cd` into a directory                                            |
| `fe [pattern]` | Open file(s) in `$EDITOR` — auto-opens if only one match (`--select-1`) |
| `fo [pattern]` | Open file — `Enter` opens in `$EDITOR`, `Ctrl-O` opens via macOS `open` |

## Vim Mode

ZSH runs in vi keymap (`bindkey -v`). `KEYTIMEOUT=1` for snappy mode switches.
Cursor changes shape per mode: block in normal, beam in insert.

Menuselect (tab-completion menu) keys are vim-friendly:

| Binding             | Action                |
| ------------------- | --------------------- |
| `Ctrl+h` / `Ctrl+l` | Previous / next char  |
| `Ctrl+k` / `Ctrl+j` | Up / down line        |
| `Ctrl+Shift+Tab`    | Up (alternate)        |
| `Ctrl+?` (Backspace) | Backward delete char  |
