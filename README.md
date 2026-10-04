# dotfiles

My macOS focused development environment dotfiles.

## AI agent instructions

`AGENTS.md` contains repository guidance independent of the selected model.
Codex reads it automatically. Other tools can load it as an instruction file.
Shared resources live in `ai/`, linked to `~/.config/ai` by the installer.
Agents can read `ai/RTK.md` directly and run `rtk git status`, `rtk git diff`, and `rtk gain` explicitly.
`ai/mcp-servers.json` preserves shared server definitions as a reference;
register them in each client's supported MCP configuration format.
Permissions, hooks, plugins, and model selection remain client-specific.

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

Colima uses the linked `colima/colima.yaml` configuration: 6 CPUs, 8 GiB of
memory, and a 15 GiB disk for container data. Start it with `colima start`.
The VM's system disk and metadata use additional space on macOS, so the
`~/.colima` folder can exceed 15 GiB even with this data disk limit.
Colima can grow an existing disk but cannot shrink it; changing an existing
larger VM to this limit requires deleting and recreating that VM, which removes
its Docker images, containers, and volumes.

VS Code is installed with IntelliSense, formatting, linting, tests, debugging,
Gradle/Maven, Spring Boot, Docker, and SQLFluff tooling for Go, Rust, Java,
Kotlin, and SQL. It uses the same formatting tools as Neovim (`gofumpt`,
`rustfmt`, Google Java Format, and `ktlint`).

Go uses the official `golang.go` extension with `gopls` for IntelliSense,
navigation, refactoring, diagnostics, and Staticcheck analysis. Saving a Go
file formats it with `gofumpt` and organizes imports through `gopls`. The
installer adds `gopls` and Delve (`dlv`) to the asdf-managed Go toolchain for
language features and debugging; the extension also provides test execution.
After switching Go toolchains, use `Go: Install/Update Tools` in the Command
Palette to install `gopls` and `dlv` for that toolchain, then run `asdf reshim golang`.

Markdown Preview Enhanced provides a live preview with synchronized scrolling,
Mermaid diagrams, and math rendering. With a Markdown file open, run
`Markdown Preview Enhanced: Open Preview to the Side` from the Command Palette.

SQL files use SQLFluff for linting and formatting on save.
Set the SQL dialect in the project's `.sqlfluff` or `pyproject.toml`; no dialect
is forced in the global VS Code settings. For example, a PostgreSQL project
can use this `.sqlfluff`:

```ini
[sqlfluff]
dialect = postgres
```

Without a configured dialect, SQLFluff cannot lint or format SQL. For a
standalone file, set `sqlfluff.dialect` in VS Code to the appropriate dialect.
Clear that setting when returning to projects that configure their own dialect,
as the extension passes it as a command-line override.

On the first Kotlin project, accept the license prompt required by the official
JetBrains language server; the Americas region and disabled data sharing are
already configured. The `code` command is also available from the shell.

### Post-Install

```bash
# Install tmux plugins (open tmux first, then press prefix + I)
tmux

# Start the window manager and hotkey daemon
yabai --start-service
skhd --start-service
# System Settings → Privacy & Security → Accessibility → enable yabai and skhd

# Reload their configs after editing
yabai --restart-service
skhd --restart-service
```

Yabai uses native macOS Spaces. At startup and when a display is connected or
disconnected, `~/.config/yabai/scripts/setup-spaces` ensures Spaces 1–9 are on
the available display, or Spaces 1–5 are on display 1 and 6–9 on display 2.
You can run the script manually to recheck the layout. It moves existing Spaces
between displays and adds missing ones. Setup and the ten-desktop limit count
only regular desktops; native fullscreen Spaces do not consume a slot. The
limiter removes only empty regular desktops beyond the tenth.
The app placement rules and `alt+1–9` shortcuts target regular desktops 1–9,
even when fullscreen temporarily shifts their Mission Control indices.
Placement rules apply to new windows; fullscreen transitions do not reapply
them to windows you have already placed.
`~/.config/yabai/scripts/select-space 2` focuses the second regular desktop;
adding `--move` moves the window and
follows it. The same helper accepts `id:ID` for SketchyBar clicks.
Keep "Show Items On Desktop" enabled and set "Click wallpaper to reveal
Desktop" to "Only in Stage Manager" in Desktop & Dock. Disabling the Finder
Desktop prevents yabai from focusing empty Spaces, including via SketchyBar.
Disable “Automatically rearrange Spaces based on most recent use” in Desktop &
Dock so the regular desktops keep their order.

On macOS 26.6, the Space creation fix is currently only in yabai HEAD, which
the Brewfile installs. After updating yabai, refresh the binary hash in
`/private/etc/sudoers.d/yabai` before restarting its service. Because Homebrew
signs HEAD builds ad hoc, macOS may also require you to remove and add yabai
again in Privacy & Security → Accessibility.

On macOS 27.0.1 build 26A434, upstream yabai HEAD cannot load its scripting
addition, so Space creation, movement, and some focus commands fail. Run
`./scripts/install-yabai-macos27` for the temporary workaround. It checks the
Dock binary, builds a pinned [macOS 27 fork](https://github.com/AhsanFazal/yabai),
updates the yabai sudo rule through a macOS administrator prompt, and restarts
the service. Re-enable yabai in Accessibility if macOS asks. A Homebrew upgrade
can replace this temporary binary; rerun the script after verifying the new
macOS build is supported.

The configured 98% opacity requires partially disabling macOS System Integrity
Protection (SIP) and loading yabai's scripting addition. Follow the
[upstream SIP instructions](https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection)
in macOS Recovery, then [configure the scripting addition](https://github.com/asmvik/yabai/wiki/Installing-yabai-%28latest-release%29#configure-scripting-addition)
and restart yabai. Tiling and the other supported controls work without this
step; transparency will not.

### Uninstall yabai and restore SIP

While yabai is still installed, stop it and remove its scripting addition and
passwordless `sudo` rule:

```bash
yabai --stop-service
sudo yabai --uninstall-sa
sudo rm -f /private/etc/sudoers.d/yabai
./uninstall
```

Answer **yes** when `./uninstall` asks to remove services and Homebrew packages.
The uninstall script cannot restore SIP because macOS requires Recovery for
that change. Before entering Recovery, inspect `nvram boot-args`. If its only
value is `-arm64e_preview_abi` (set for yabai on Apple Silicon), remove it with
`sudo nvram -d boot-args`. If other boot arguments are present, preserve them
and remove only the yabai flag.

Shut down the Mac, hold the power button until startup options appear, then
choose **Options → Continue**. In **Utilities → Terminal**, run `csrutil enable`
and restart. Back in macOS, run `csrutil status` and confirm it reports
`enabled`. See [Apple's Recovery instructions](https://support.apple.com/pt-br/102518)
and [yabai's SIP restoration instructions](https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection).

### Requirements

- macOS (Apple Silicon — paths assume `/opt/homebrew/`)
- Xcode Command Line Tools (`xcode-select --install`)
- SSH key at `~/.ssh/id_rsa` (optional, for git/GitHub)
- `~/secrets.sh` for private environment variables (optional)

### Manual Steps

| Step                    | Description                                                                 |
| ----------------------- | --------------------------------------------------------------------------- |
| yabai/skhd Accessibility | System Settings → Privacy & Security → Accessibility → enable both          |
| Hack Nerd Font          | Installed via Brewfile — select in Kitty if not applied automatically       |
| `~/secrets.sh`          | Create with private env vars (tokens, API keys) — sourced by zsh if present |
| Sketchybar menu bar     | Optional: run `sketchy:start` to replace the native menu bar; `sketchy:stop` restores it |
| Wallpaper automation    | Allow Terminal to control System Events if macOS requests permission        |

The macOS menu bar is visible by default. SketchyBar remains installed but is
started only with `sketchy:start`; `sketchy:stop` restores the native bar.
When enabled, SketchyBar uses the `main` profile: a full-width bar with
horizontal spaces in a light pill, one app icon per occupied space, a dark
active space, and dots for empty spaces. Spotify appears after the spaces while
playing or paused, with
previous, play/pause, and next controls, including with a single monitor.
When Spotify is paused, an MPD track currently playing takes priority.
Clicking Spotify's title opens Spotify; MPD titles have no click action.
On narrower displays, the title is shortened and artwork is omitted to leave
room for playback controls. Spotify notifications update the player immediately,
with a 15-second polling fallback. Spaces recover from temporary yabai failures
on their next refresh (at most 30 seconds after yabai becomes available).
Native fullscreen Spaces are included. Items and clicks use stable Space IDs
instead of temporary Mission Control indices. Space creation, removal, and
display changes update the space items in one batch and restore the order of
the left section: Spaces, artwork, track title, then playback controls.
Workspace events are grouped over 200 ms and processed by one worker at a time;
events arriving during a refresh trigger another pass.
Weather shows `—` when its latest request fails.
`sketchy:bar main` selects and reloads this profile; `sketchy:bar` lists available
profiles.

## Stack

- **yabai** — tiling window manager
- **skhd** — window manager keyboard shortcuts
- **Sketchybar** — custom status bar
- **Kitty** — terminal (wallpaper theme generated with Matugen)
- **Tmux** — terminal multiplexer (prefix: `Ctrl+A`)
- **ZSH** — shell with custom prompt, FZF integration, vim mode
- **Neovim** — LazyVim with Go, Java, Kotlin, Rust, LSP, formatting, search, and Git integration
- **VS Code** — Go, Rust, Java, Kotlin, SQL, Markdown preview, Spring Boot, and Docker tooling
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
These checks use solid colors; the translucent status bar also depends on what
is behind it.

Edit `matugen/config.toml` for semantic color anchors,
`scripts/generate-wallpaper-theme` for Material-to-Base16 mappings, and
`flavours/templates/` for application styling. Generated files are overwritten
on every application. `flavours/config.toml` is linked into the installed
configuration so new targets and reload hooks stay synchronized.

Kitty loads `kitty/colors.conf`, generated by flavours from
`flavours/templates/kitty/templates/default.mustache`. Change that template
and regenerate the theme to adjust Kitty's colors.

Kitty, Sketchybar, Tmux and Borders reload on application. Neovim reloads when
it regains focus (or with `:ThemeReload`); Zsh reads prompt colors before the
next prompt; FZF reads colors on its next launch. After upgrading these
dotfiles, reload Zsh and restart Neovim once to enable the new reload logic.
VS Code uses our own Wallpaper (Matugen) theme extension for the interface,
terminal ANSI colors, TextMate syntax and semantic syntax. The updater preserves
other preferences in `vscode/settings.json`. Symbols provides the file icons.
Run `~/.local/bin/apply-vscode-theme` to regenerate and select the theme after
editing its mappings.

Run the palette regression checks with `python3 -B -m unittest discover -s tests`.

## Shortcuts

| Topic | File |
| ----- | ---- |
| Tmux keybinds & popups | [shortcuts/tmux.md](shortcuts/tmux.md) |
| yabai keybinds & Spaces | [shortcuts/yabai.md](shortcuts/yabai.md) |
| ZSH aliases & functions | [shortcuts/zsh.md](shortcuts/zsh.md) |
| Neovim keybindings | [shortcuts/nvim.md](shortcuts/nvim.md) |
| Tools reference | [shortcuts/tools.md](shortcuts/tools.md) |
