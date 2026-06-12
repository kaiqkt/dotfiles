# dotfiles

My macOS focused development environment dotfiles.

## Installation

### Fresh macOS Setup

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Clone the repo
git clone https://github.com/YOUR_USER/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles

# 3. Run the install script (installs Homebrew + dotbot, symlinks everything, runs brew bundle)
./install

# 4. Open a new terminal to load ZSH configuration
```

### Post-Install

```bash
# Install tmux plugins (open tmux first, then press prefix + I)
tmux

# Open AeroSpace and grant Accessibility permission
open -a AeroSpace
# System Settings → Privacy & Security → Accessibility → AeroSpace → enable

# Reload AeroSpace config
aerospace reload-config
```

### Requirements

- macOS (Apple Silicon — paths assume `/opt/homebrew/`)
- Xcode Command Line Tools (`xcode-select --install`)
- SSH key at `~/.ssh/id_rsa` (optional, for git/GitHub)
- `~/secrets.sh` for private environment variables (optional)

### Manual Steps

| Step                    | Description                                                                 |
| ----------------------- | --------------------------------------------------------------------------- |
| AeroSpace Accessibility | System Settings → Privacy & Security → Accessibility → enable AeroSpace     |
| Hack Nerd Font          | Installed via Brewfile — select in Kitty if not applied automatically       |
| `~/secrets.sh`          | Create with private env vars (tokens, API keys) — sourced by zsh if present |
| Sketchybar menu bar     | Run `sketchy:start` — hides native menu bar and starts sketchybar           |

## Applications

- **AeroSpace** — tiling window manager
- **Sketchybar** — custom status bar
- **Kitty** — terminal (Nord theme)
- **Tmux** — terminal multiplexer
- **ZSH** — shell with custom prompt, FZF integration, vim mode
- **LazyGit** — git TUI
- **FZF** — fuzzy finder
- **Homebrew** — package manager

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

## Tmux

Prefix: `Ctrl+A`

### Panes

| Binding       | Description                |
| ------------- | -------------------------- |
| `prefix + \`  | Split vertical             |
| `prefix + -`  | Split horizontal           |
| `C-h/j/k/l`   | Navigate panes (vim-aware) |
| `M-[` / `M-]` | Swap pane down/up          |
| `prefix + z`  | Zoom pane                  |
| `prefix + x`  | Close pane                 |

### Windows

| Binding            | Description             |
| ------------------ | ----------------------- |
| `prefix + c`       | New window (same path)  |
| `prefix + ,`       | Rename window           |
| `prefix + &`       | Close window            |
| `prefix + 0-9`     | Select window by number |
| `prefix + n` / `p` | Next/previous window    |

### Sessions

| Binding      | Description    |
| ------------ | -------------- |
| `prefix + d` | Detach session |
| `prefix + $` | Rename session |
| `prefix + s` | List sessions  |

### Copy Mode (vi)

| Binding       | Description                |
| ------------- | -------------------------- |
| `prefix + [`  | Enter copy mode            |
| `v`           | Begin selection            |
| `V`           | Select line                |
| `y` / `Enter` | Copy to clipboard (pbcopy) |
| `prefix + P`  | Paste buffer               |
| `q`           | Exit copy mode             |

### Popups

| Binding      | Description                 |
| ------------ | --------------------------- |
| `prefix + h` | Htop                        |
| `prefix + v` | Cloudflare speed test       |
| `prefix + K` | Kill process (fuzzy)        |
| `prefix + N` | Browse ports / kill process |

### FZF (`prefix + t`, then second key)

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

### Git (`prefix + g`, then second key)

| Binding        | Description                                     |
| -------------- | ----------------------------------------------- |
| `prefix + g g` | LazyGit                                         |
| `prefix + g b` | Git branch switcher (recent, with log preview)  |
| `prefix + g l` | Git log browser (Enter: diff, Ctrl-O: checkout) |
| `prefix + g s` | Git stash browser (Enter: apply, Ctrl-D: drop)  |

### Misc

| Binding      | Description        |
| ------------ | ------------------ |
| `prefix + r` | Reload tmux config |

## FZF Shell Functions

| Command  | Description                         |
| -------- | ----------------------------------- |
| `Ctrl+R` | Search shell history                |
| `Ctrl+T` | Find files/directories with preview |

## AeroSpace

### Workspaces

| Binding         | Description                           |
| --------------- | ------------------------------------- |
| `alt+1-9`       | Switch to workspace                   |
| `alt+shift+1-9` | Move window to workspace (and follow) |

Default app assignments:

| Workspace | Apps            | Monitor |
| --------- | --------------- | ------- |
| 1         | Chrome, Safari  | 1       |
| 2         | Kitty, Terminal | 1       |
| 3–5       | —               | 1       |
| 6–7       | —               | 2       |
| 8         | Claude          | 2       |
| 9         | Spotify         | 2       |

### Focus & Move

| Binding             | Description                     |
| ------------------- | ------------------------------- |
| `alt+h/j/k/l`       | Focus window left/down/up/right |
| `alt+shift+h/j/k/l` | Move window left/down/up/right  |

### Resize

| Binding      | Description     |
| ------------ | --------------- |
| `alt+ctrl+h` | Decrease width  |
| `alt+ctrl+l` | Increase width  |
| `alt+ctrl+k` | Decrease height |
| `alt+ctrl+j` | Increase height |

### Layout

| Binding           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| `alt+/`           | Toggle tiles horizontal/vertical (h-tiles → v-tiles) |
| `alt+,`           | Toggle accordion horizontal/vertical                 |
| `alt+shift+space` | Toggle floating/tiling                               |
| `alt+f`           | Fullscreen                                           |

### Service Mode (`alt+shift+;`)

| Binding             | Description                      |
| ------------------- | -------------------------------- |
| `r`                 | Flatten workspace tree           |
| `f`                 | Toggle floating/tiling           |
| `backspace`         | Close all windows except current |
| `alt+shift+h/j/k/l` | Join with adjacent window        |
| `esc`               | Exit service mode                |

### CLI

```bash
aerospace reload-config       # reload config
aerospace list-workspaces --all
aerospace list-windows --all
```

## Claude

Install `claude-code`:

```bash
npm install -g @anthropic-ai/claude-code
```

Config is symlinked from `claude/settings.json` → `~/.claude/settings.json`.
