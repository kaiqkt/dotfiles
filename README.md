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
- **Kitty** — terminal (wallpaper theme generated with Matugen)
- **Tmux** — terminal multiplexer (prefix: `Ctrl+A`)
- **ZSH** — shell with custom prompt, FZF integration, vim mode
- **Neovim** — LazyVim with Go, Java, Kotlin, Rust, LSP, formatting, search, and Git integration
- **VS Code** — Rust, Java, Kotlin, Spring Boot, and Docker tooling
- **LazyGit** — git TUI
- **FZF** — fuzzy finder
- **asdf** — version manager (Java, Kotlin, Go)
- **rustup** — Rust toolchain manager (stable, rust-analyzer, clippy, rustfmt)
- **Homebrew** — package manager

## Wallpaper themes

Matugen 4.2.0 generates a dark Material You **Tonal Spot** palette. The adapter
maps neutral surfaces and near-white text to Base16, harmonizes separate
semantic colors for syntax/alerts, and uses the wallpaper's primary color for
focus, selection and borders. Flavours renders the application configs.

### Change the wallpaper

After installation, run this from any directory (quote paths containing spaces):

```bash
set-wallpaper "$HOME/Pictures/My Wallpaper.jpg"
```

This changes the image on every macOS desktop and applies matching colors to
Kitty, Neovim, Zsh, Sketchybar, Tmux, Borders, FZF and VS Code. It preserves
display resolution, scaling, refresh rate and layout. To use an image from this
checkout, run `set-wallpaper wallpaper/eva-red-wallpaper.jpg` from the repo root.
The same command can be run without the installed shortcut with
`python3 scripts/set-wallpaper /path/to/image.jpg` once Matugen and flavours are
installed.

Changes made directly in macOS Settings are not watched. If macOS refuses the
desktop change, grant Terminal permission to control System Events and rerun
the command; the theme may already have been applied.

### Preview or apply only the theme

```bash
# Preview a Base16 palette without modifying files or the desktop
python3 scripts/generate-wallpaper-theme wallpaper/rei-plush-wallpaper.png --stdout

# Apply just the theme, keeping the desktop image
python3 scripts/generate-wallpaper-theme wallpaper/rei-plush-wallpaper.png --apply
```

The installer installs Matugen with Cargo into `~/.local/bin`. Generation is
noninteractive and checks contrast before writing the palette: at least 7:1
for body text and 4.5:1 for the checked secondary text and semantic color pairs.
These checks use solid colors; Kitty transparency and the transparent status
bar also depend on what is behind them.

Edit `matugen/config.toml` for semantic color anchors,
`scripts/generate-wallpaper-theme` for Material-to-Base16 mappings, and
`flavours/templates/` for application styling. Generated files are overwritten
on every application. `flavours/config.toml` is linked into the installed
configuration so new targets and reload hooks stay synchronized.

Kitty, Sketchybar, Tmux and Borders reload on application. Neovim reloads when
it regains focus (or with `:ThemeReload`); Zsh reads prompt colors before the
next prompt; FZF reads colors on its next launch. After upgrading these
dotfiles, reload Zsh and restart Neovim once to enable the new reload logic.
VS Code uses our own Wallpaper (Matugen) theme extension for the interface,
terminal ANSI colors, TextMate syntax and semantic syntax. The updater preserves
other preferences in `vscode/settings.json`. Run
`~/.local/bin/apply-vscode-theme` to regenerate and select the theme after
editing its mappings.

VS Code also uses [Vibrancy Continued](https://github.com/illixion/vscode-vibrancy-continued)
for macOS background blur with `0.88` opacity, matching Kitty's opacity while
keeping the Wallpaper (Matugen) theme. To activate it, open the Command Palette,
run `Reload Vibrancy`, and restart VS Code when prompted. Repeat after VS Code
updates. The extension patches VS Code's internal files, which can trigger an
installation integrity warning. Adjust `vscode_vibrancy.opacity` in
`vscode/settings.json` (`0` is transparent, `1` is opaque); run `Disable Vibrancy`
and restart to remove the effect.

Run the palette regression checks with `python3 -B -m unittest discover -s tests`.

## Shortcuts

| Topic | File |
| ----- | ---- |
| Tmux keybinds & popups | [shortcuts/tmux.md](shortcuts/tmux.md) |
| AeroSpace keybinds & workspaces | [shortcuts/aerospace.md](shortcuts/aerospace.md) |
| ZSH aliases & functions | [shortcuts/zsh.md](shortcuts/zsh.md) |
| Neovim keybindings | [shortcuts/nvim.md](shortcuts/nvim.md) |
| Tools reference | [shortcuts/tools.md](shortcuts/tools.md) |
