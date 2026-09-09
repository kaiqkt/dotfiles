# Neovim

The configuration is based on the official [LazyVim starter](https://www.lazyvim.org/installation).
It is available at `~/.config/nvim/`; run `:Lazy` to inspect or update plugins,
`:Mason` to manage language tooling, and `:LazyHealth` after the first launch.

## Customization

The leader key is `Space`. LazyVim provides the default keymaps; consult the
[online keymap reference](https://www.lazyvim.org/keymaps) for the full list.

| Item | Location |
| --- | --- |
| Core options, mappings, and autocommands | `lua/config/` |
| LazyVim configuration and language extras | `lua/plugins/lazyvim.lua` |
| Wallpaper-derived Base16 palette | `lua/config/generated_theme.lua` |

In terminal buffers, press `Esc` twice to return to Normal mode.

## Language tooling

LazyVim's Go, Java, and Kotlin extras configure their relevant language servers,
Tree-sitter parsers, and tooling. Mason also installs `google-java-format`,
`ktlint`, `stylua`, and `shfmt`; formatting runs on save.
