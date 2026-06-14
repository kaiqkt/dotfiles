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

```bash
lazygit        # via alias (sets config dir)
```

Also available as tmux popup: `prefix + g g`

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

## Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Config symlinked from `claude/settings.json` → `~/.claude/settings.json`.
