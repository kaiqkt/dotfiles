# Tmux

Prefix: `Ctrl+A`

## Panes

| Binding       | Description                |
| ------------- | -------------------------- |
| `prefix + \`  | Split vertical             |
| `prefix + -`  | Split horizontal           |
| `C-h/j/k/l`   | Navigate panes (vim-aware) |
| `M-[` / `M-]` | Swap pane down/up          |
| `prefix + z`  | Zoom pane                  |
| `prefix + x`  | Close pane                 |

## Windows

| Binding            | Description             |
| ------------------ | ----------------------- |
| `prefix + c`       | New window (same path)  |
| `prefix + ,`       | Rename window           |
| `prefix + &`       | Close window            |
| `prefix + 0-9`     | Select window by number |
| `prefix + n` / `p` | Next/previous window    |

## Sessions

| Binding      | Description    |
| ------------ | -------------- |
| `prefix + d` | Detach session |
| `prefix + $` | Rename session |
| `prefix + s` | List sessions  |

## Copy Mode (vi)

| Binding       | Description                |
| ------------- | -------------------------- |
| `prefix + [`  | Enter copy mode            |
| `v`           | Begin selection            |
| `V`           | Select line                |
| `y` / `Enter` | Copy to clipboard (pbcopy) |
| `prefix + P`  | Paste buffer               |
| `q`           | Exit copy mode             |

## Popups

| Binding      | Description           |
| ------------ | --------------------- |
| `prefix + h` | Htop                  |
| `prefix + v` | Cloudflare speed test |
| `prefix + K` | Kill process (fuzzy)  |
| `prefix + N` | Browse ports          |

## FZF (`prefix + t`, then second key)

| Binding        | Description                                           |
| -------------- | ----------------------------------------------------- |
| `prefix + t f` | Find and edit file (Enter: in popup, Ctrl-S: in pane) |
| `prefix + t h` | Find and edit file from `~`                           |
| `prefix + t g` | Live ripgrep search                                   |
| `prefix + t p` | Switch pane                                           |
| `prefix + t e` | Sessionizer — find project and open/switch session    |
| `prefix + t s` | Sessions browser                                      |
| `prefix + t n` | New named session                                     |
| `prefix + t t` | Toggle status bar                                     |

## Git (`prefix + g`, then second key)

| Binding        | Description                                     |
| -------------- | ----------------------------------------------- |
| `prefix + g g` | LazyGit                                         |
| `prefix + g b` | Git branch switcher (recent, with log preview)  |
| `prefix + g l` | Git log browser (Enter: diff, Ctrl-O: checkout) |
| `prefix + g s` | Git stash browser (Enter: apply, Ctrl-D: drop)  |

## Misc

| Binding      | Description        |
| ------------ | ------------------ |
| `prefix + r` | Reload tmux config |

## Aliases

| Alias | Command          |
| ----- | ---------------- |
| `t`   | `tmux`           |
| `ta`  | `tmux attach -t` |
| `tls` | `tmux ls`        |
| `tn`  | `tmux new -t`    |
