# Tools

## Borders

Window border highlight via [JankyBorders](https://github.com/FelixKratz/JankyBorders). Active window gets blue (Catppuccin) border; inactive windows get subtle dark border.

Config: `~/.config/borders/bordersrc`

| Alias             | Description          |
| ----------------- | -------------------- |
| `borders:start`   | Start borders service |
| `borders:stop`    | Stop borders service  |
| `borders:restart` | Restart borders service |

To tweak colors at runtime (no restart needed):
```bash
borders active_color=0xffcba6f7  # change active to mauve
```

## Sketchybar

Custom status bar integrated with AeroSpace. Manage with:

| Alias             | Description                                    |
| ----------------- | ---------------------------------------------- |
| `sketchy:start`   | Start service + hide native menu bar           |
| `sketchy:stop`    | Stop service + restore native menu bar         |
| `sketchy:restart` | Restart service (picks up config changes)      |

Config: `~/.config/sketchybar/sketchybarrc`

## Cloudflare Speed Test

Network speed test via CLI.

```bash
cloudflare-speed-cli
```

Also available as tmux popup: `prefix + v`

## LazyGit

Git TUI with custom config at `~/.config/lazygit/`.

| Alias     | Description                           |
| --------- | ------------------------------------- |
| `lazygit` | Run lazygit with custom config dir    |

Also available as tmux popup: `prefix + g g`

### Universal keybindings

| Binding         | Action                                       |
| --------------- | -------------------------------------------- |
| `q` / `Ctrl+C`  | Quit                                         |
| `Esc`           | Return to previous menu / quit if top-level  |
| `Q`             | Quit without changing directory              |
| `Tab`           | Next panel                                   |
| `h/j/k/l`       | Navigate (or `←↑↓→`)                         |
| `,` / `.`       | Page up / down                               |
| `<` / `>`       | Top / bottom of list                         |
| `Space`         | Select                                       |
| `Enter` / `y`   | Confirm                                      |
| `d`             | Remove / delete                              |
| `n` / `e` / `o` | New / edit / open file                       |
| `K` / `J`       | Scroll main panel up / down (also `Ctrl+U/D`)|
| `:`             | Execute shell command                        |
| `m`             | Rebase options menu                          |
| `P` / `p`       | Push / pull                                  |
| `R`             | Refresh                                      |
| `Ctrl+P`        | Patch options menu                           |
| `]` / `[`       | Next / previous tab                          |
| `+` / `_`       | Next / previous screen mode                  |
| `z` / `Ctrl+Z`  | Undo / redo                                  |
| `Ctrl+S`        | Filtering menu                               |
| `W` / `Ctrl+E`  | Diffing menu                                 |
| `Ctrl+O`        | Copy selection to clipboard                  |
| `Alt+Enter`     | Append newline in editor                     |
| `@`             | Extras menu                                  |
| `Ctrl+W`        | Toggle whitespace in diff                    |
| `x` / `?`       | Help menu                                    |
| `n` / `N`       | Next / previous search match                 |
| `Ctrl+R`        | Open recent repos                            |

### Files panel

| Binding        | Action                                |
| -------------- | ------------------------------------- |
| `c` / `C`      | Commit / commit with editor           |
| `w`            | Commit without pre-commit hook        |
| `A`            | Amend last commit                     |
| `a`            | Stage / unstage all                   |
| `s` / `S`      | Stash all / stash options             |
| `D`            | Reset options                         |
| `i`            | Ignore file                           |
| `r`            | Refresh files                         |
| `f`            | Fetch                                 |
| `` ` ``        | Toggle tree view                      |

### Branches panel

| Binding   | Action                                            |
| --------- | ------------------------------------------------- |
| `c` / `F` | Checkout / force-checkout                         |
| `r`       | Rebase onto current                               |
| `M`       | Merge into current                                |
| `f`       | Fast-forward this branch from upstream            |
| `u`       | Set as upstream of checked-out branch             |
| `i`       | Git flow options                                  |
| `o` / `O` | Create PR / PR options                            |
| `P`       | Push tag                                          |

### Commits panel

| Binding        | Action                              |
| -------------- | ----------------------------------- |
| `s` / `S`      | Squash down / squash above          |
| `f` / `F`      | Mark as fixup / create fixup commit |
| `r` / `R`      | Rename / rename with editor         |
| `A`            | Amend to commit                     |
| `p`            | Pick (mid-rebase)                   |
| `t`            | Revert                              |
| `g`            | Reset options                       |
| `c` / `C`      | Cherry-pick copy / copy range       |
| `v`            | Paste cherry-picked commits         |
| `Ctrl+X`       | Reset cherry-pick                   |
| `T`            | Tag commit                          |
| `Space`        | Checkout commit                     |
| `Ctrl+J/K`     | Move commit down / up               |
| `Ctrl+Y`       | Copy commit message                 |

### Stash / Commit Files / Main / Submodules

| Panel         | Binding   | Action                              |
| ------------- | --------- | ----------------------------------- |
| Stash         | `g`       | Pop stash                           |
| Commit files  | `c`       | Checkout file                       |
| Main (diff)   | `v` / `V` | Toggle drag select                  |
| Main (diff)   | `a`       | Toggle hunk                         |
| Main (diff)   | `b`       | Pick both hunks (merge)             |
| Submodules    | `i`       | Init                                |
| Submodules    | `u`       | Update                              |
| Submodules    | `b`       | Bulk menu                           |

## FZF

Fuzzy finder. Shell bindings configured in `~/.config/zsh/config/fzf.sh`. Tmux popups use scripts in `~/.config/tmux/scripts/`.

## asdf

Version manager for Java, Kotlin, Go. Global versions defined in `~/.tool-versions` (symlinked from repo `tool-versions`). Per-project overrides via `.tool-versions` at repo root.

```bash
# List available versions
asdf list all java | grep temurin-21
asdf list all kotlin
asdf list all golang

# Install a specific version
asdf install java temurin-21.0.11+10.0.LTS

# Set global default
asdf set -u java temurin-21.0.11+10.0.LTS

# Set local (per-project) override
asdf set java temurin-17.0.13+11.0.LTS
```

JAVA_HOME is set automatically via the asdf-java plugin hook sourced in `exports.sh`.

## Brew

| Alias          | Description                          |
| -------------- | ------------------------------------ |
| `brew:upgrade` | `brew upgrade`                       |
| `brew:bundle`  | `brew bundle --file ~/.Brewfile`     |

## Docker Compose

| Alias | Command                      |
| ----- | ---------------------------- |
| `dc`  | `docker compose`             |
| `dcr` | `docker compose run --rm`    |
| `dce` | `docker compose exec`        |
| `dcw` | `docker compose watch`       |

### Functions

| Function        | Description                                             |
| --------------- | ------------------------------------------------------- |
| `docker-attach` | Attach to running compose container by service name     |
| `dc-dev`        | Start `app` service, watch for changes, attach to shell |

## Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Config symlinked from `claude/settings.json` → `~/.claude/settings.json`.
