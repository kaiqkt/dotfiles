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

# 3. Run the install script (packages, symlinks, display defaults, wallpaper and themes)
./install

# 4. Open a new terminal to load ZSH configuration
```

Display resolution, scaling, rotation, and arrangement are preserved. The
installer selects the highest safe refresh rate up to 60 Hz.

The first `nvim` launch bootstraps LazyVim and installs the configured plugins,
language servers, formatters, and Tree-sitter parsers. Run `:LazyHealth` after
that first launch to verify the installation.

VS Code is installed with IntelliSense, formatting, linting, tests, debugging,
Gradle/Maven, Spring Boot, and Docker tooling for Rust, Java, and Kotlin. It
uses the same formatters as Neovim (`rustfmt`, Google Java Format, and
`ktlint`). On the first Kotlin project, accept the license prompt required by
the official JetBrains language server; the Americas region and disabled data
sharing are already configured. The `code` command is also available from the
shell.

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
| Wallpaper automation    | Allow Terminal to control System Events if macOS requests permission        |

## Stack

- **AeroSpace** — tiling window manager
- **Sketchybar** — custom status bar
- **Kitty** — terminal (Nord theme)
- **Tmux** — terminal multiplexer (prefix: `Ctrl+A`)
- **ZSH** — shell with custom prompt, FZF integration, vim mode
- **Neovim** — LazyVim with Go, Java, Kotlin, Rust, LSP, formatting, search, and Git integration
- **VS Code** — Rust, Java, Kotlin, Spring Boot, and Docker tooling
- **LazyGit** — git TUI
- **FZF** — fuzzy finder
- **asdf** — version manager (Java, Kotlin, Go)
- **rustup** — Rust toolchain manager (stable, rust-analyzer, clippy, rustfmt)
- **Homebrew** — package manager

## Shortcuts

| Topic | File |
| ----- | ---- |
| Tmux keybinds & popups | [shortcuts/tmux.md](shortcuts/tmux.md) |
| AeroSpace keybinds & workspaces | [shortcuts/aerospace.md](shortcuts/aerospace.md) |
| ZSH aliases & functions | [shortcuts/zsh.md](shortcuts/zsh.md) |
| Neovim keybindings | [shortcuts/nvim.md](shortcuts/nvim.md) |
| Tools reference | [shortcuts/tools.md](shortcuts/tools.md) |
