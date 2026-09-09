# Neovim / LazyVim

Leader: `Space`; local leader: `\`.

Press `Space` and wait for which-key to show the available continuation keys.
These bindings follow the enabled LazyVim defaults; see the
[LazyVim commands reference](https://steffenbew.com/lazyvim-the-commands/) and
[official keymaps](https://www.lazyvim.org/keymaps) for the complete list.

## Modes & Basics

| Binding | Description |
| --- | --- |
| `i` / `a` | Insert before / after cursor |
| `v` / `V` | Character / line visual mode |
| `Esc` / `Ctrl-c` | Return to Normal mode |
| `Ctrl-s` / `:w` | Save file |
| `:q` | Quit current window |
| `leader + q q` | Quit all windows |
| `.` | Repeat last change |
| `u` / `Ctrl-r` | Undo / redo |

## Movement

| Binding | Description |
| --- | --- |
| `h` / `j` / `k` / `l` | Move left / down / up / right |
| `0` / `$` | Start / end of line |
| `g g` / `G` | Start / end of file |
| `*` | Next occurrence of word under cursor |
| `Ctrl-u` / `Ctrl-d` | Scroll half page up / down |
| `Ctrl-e` / `Ctrl-y` | Scroll one line up / down |
| `Ctrl-o` / `Ctrl-i` | Previous / next jump location |
| `zz` | Center current line |
| `%` | Jump to matching bracket |

## Editing

| Binding | Description |
| --- | --- |
| `o` / `O` | New line below / above |
| `I` / `A` | Insert at line start / end |
| `x` | Delete character under cursor |
| `r` / `R` | Replace character / enter overwrite mode |
| `dd` / `d{motion}` | Delete line / using a motion |
| `c{motion}` | Change using a motion |
| `yy` / `y{motion}` | Copy line / using a motion |
| `p` | Paste after cursor |
| `gcc` / `vgc` | Toggle line / selection comment |
| `vi(` / `va(` | Select inside / around parentheses |
| `Ctrl-v`, then `I` or `A`, then `Esc` | Blockwise multiline insert |
| `Ctrl-Space` | Expand Treesitter selection |

## Files & Search

| Binding | Description |
| --- | --- |
| `leader + Space` / `leader + f f` | Find files in project root |
| `leader + f F` | Find files in current directory |
| `leader + f b` | Find open buffers |
| `leader + f r` | Recent files |
| `leader + f p` | Find projects |
| `leader + /` / `leader + s g` | Grep project root |
| `leader + s r` | Search and replace in project |
| `/<pattern>` then `n` / `N` | Search; next / previous match |
| `f{character}` / `F{character}`, then `;` | Find character forward / backward; repeat |
| `s{character}` | Jump to a labelled match |
| `:%s/old/new/gc` | Replace in file, confirming each match |
| `leader + s k` / `leader + ?` | Search all / buffer-local keymaps |

## Buffers & Windows

| Binding | Description |
| --- | --- |
| `Shift-h` / `Shift-l` | Previous / next buffer |
| `leader + f n` | New file |
| `leader + b d` | Delete current buffer |
| `leader + b p` / `leader + b P` | Pin buffer / close unpinned buffers |
| `leader + \|` / `leader + -` | Vertical / horizontal split |
| `Ctrl-h` / `Ctrl-j` / `Ctrl-k` / `Ctrl-l` | Move between windows |
| `leader + w m` | Toggle current-window zoom |
| `leader + w d` | Close current window |

## Code & Diagnostics

| Binding | Description |
| --- | --- |
| `g d` / `g r` | Go to definition / references |
| `K` | Show hover documentation |
| `leader + c a` | Code action |
| `leader + c r` | Rename symbol |
| `leader + c f` | Format buffer |
| `leader + c l` | LSP information |
| `[ d` / `] d` | Previous / next diagnostic |
| `leader + u d` | Toggle diagnostics |
| `leader + u f` | Toggle format on save |

## Tools & Terminal

| Binding | Description |
| --- | --- |
| `leader + l` | Open Lazy plugin manager |
| `leader + c m` | Open Mason tool manager |
| `leader + g s` | Git status |
| `leader + e` | File explorer |
| `leader + f t` / `leader + f T` | Terminal in project root / current directory |
| `Ctrl-/` | Terminal in project root |
| `Esc` then `Esc` | Leave Terminal mode |

## Configuration

| Item | Location |
| --- | --- |
| Core options, mappings, and autocommands | `lua/config/` |
| LazyVim configuration and language extras | `lua/plugins/lazyvim.lua` |
| Wallpaper-derived Base16 palette | `lua/config/generated_theme.lua` |

## Language Tooling

LazyVim's Go, Java, and Kotlin extras configure their relevant language servers,
Tree-sitter parsers, and tooling. Mason also installs `google-java-format`,
`ktlint`, `stylua`, and `shfmt`; formatting runs on save.
