# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Overview

macOS development environment dotfiles for a Kotlin/Java/Go developer. Uses dotbot for symlink management, AeroSpace as window manager, and Sketchybar as status bar.

## Stack

- **Languages**: Kotlin, Java, Go
- **Version manager**: asdf (installed via brew)
- **Shell**: ZSH with custom prompt, FZF integration, vim mode
- **Terminal**: Kitty (Nord theme)
- **Multiplexer**: Tmux (prefix: Ctrl+A)
- **WM**: AeroSpace (alt-based keybindings)
- **Status bar**: Sketchybar (integrated with AeroSpace)
- **Git TUI**: LazyGit

## Key Files

| File | Purpose |
|------|---------|
| `install.conf.yaml` | Dotbot symlink definitions |
| `install` | Bootstrap script (Homebrew, dotbot, macOS defaults) |
| `uninstall` | Reverses all symlinks and macOS changes |
| `homebrew/Brewfile` | All packages and casks |
| `zsh/config/aliases.sh` | Shell aliases |
| `zsh/config/exports.sh` | PATH and env vars |
| `aerospace/aerospace.toml` | WM config (workspaces, keybindings) |
| `sketchybar/sketchybarrc` | Status bar layout and plugins |

## Install / Uninstall

```bash
./install    # bootstrap everything
./uninstall  # remove symlinks and macOS changes
```

## Adding a New Tool

1. Add package to `homebrew/Brewfile`
2. Create config directory (e.g. `newtool/`)
3. Add symlink to `install.conf.yaml`
4. Add alias to `zsh/config/aliases.sh` if needed
5. Update `README.md` and `uninstall` symlink list

## macOS Defaults Applied by install

- Dock auto-hide with no delay
- Disable space auto-rearranging
- Finder: show hidden files, path bar, status bar, all extensions
- Disable auto-correct and window animations

## AeroSpace Workspace Layout

| Workspace | Apps |
|-----------|------|
| 1 | Chrome, Safari |
| 2 | Kitty, Terminal |
| 8 | Claude |
| 9 | Spotify |
