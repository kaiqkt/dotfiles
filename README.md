# dotfiles

My macOS focused development environment dotfiles.

## Installation

### Fresh macOS Setup

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Clone the repo
git clone https://github.com/kaiqkt/dotfiles.git ~/Projects/dotfiles
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

## Stack

- **AeroSpace** — tiling window manager
- **Sketchybar** — custom status bar
- **Kitty** — terminal (Nord theme)
- **Tmux** — terminal multiplexer (prefix: `Ctrl+A`)
- **ZSH** — shell with custom prompt, FZF integration, vim mode
- **LazyGit** — git TUI
- **FZF** — fuzzy finder
- **asdf** — version manager (Java, Kotlin, Go)
- **Homebrew** — package manager

## Docs

| Topic | File |
| ----- | ---- |
| Tmux keybinds & popups | [docs/tmux.md](docs/tmux.md) |
| AeroSpace keybinds & workspaces | [docs/aerospace.md](docs/aerospace.md) |
| ZSH aliases & functions | [docs/zsh.md](docs/zsh.md) |
| Tools reference | [docs/tools.md](docs/tools.md) |
