# Repository guidance

This repository configures a macOS development environment. Dotbot links files
from this checkout into the home directory; edit the source files here, not
their installed paths. The user-facing setup and wallpaper instructions are in
`README.md`, and shortcuts are in `shortcuts/`.

## Where to change things

- `install.conf.yaml` defines installed symlinks and setup commands. Keep the
  `SYMLINKS` list in `uninstall` aligned when adding or removing a link.
- `homebrew/Brewfile` lists packages; `tool-versions` pins asdf runtimes.
- `zsh/.zshrc`, `zsh/config/`, and `zsh/user/` define shell behavior. Update
  `shortcuts/zsh.md` when changing a documented shortcut.
- `tmux/config/` and `tmux/scripts/` define tmux behavior. Update
  `shortcuts/tmux.md` when changing a documented shortcut.
- `yabai/`, `skhd/`, `sketchybar/`, `borders/`, `nvim/`, and `vscode/`
  contain the corresponding application configuration.
- Git worktree helpers live in `zsh/config/worktrees.sh`. They expect a bare
  repository in `ProjectName/.bare/` and sibling worktrees.

## Wallpaper and theme flow

`set-wallpaper /path/to/image` applies the image to every macOS desktop and
updates the theme. It calls `scripts/generate-wallpaper-theme`, which runs
Matugen using `matugen/config.toml`, maps its colors to Base16, validates
contrast, and applies the palette with flavours. `flavours/config.toml` lists
output files and reload hooks; `flavours/templates/` defines their styling.
`scripts/apply-vscode-theme` generates the local VS Code theme extension from
the palette and selects it in `vscode/settings.json`.

The generated palette, theme files, and color sections are outputs. Change the
generator, Matugen anchors, or a flavours template to change their behavior,
then regenerate the outputs so the checked-in copies stay in sync. Preserve
unrelated preferences in `vscode/settings.json`. The desktop change command
does not adjust display modes; `scripts/configure-displays` handles display
modes during installation.

For theme work, use the existing regression checks with
`python3 -B -m unittest discover -s tests`. They require Matugen and flavours.
For shell edits, check syntax with `bash -n` or `zsh -n` as appropriate.

## Conventions

- Sketchybar plugins that need palette colors source `sketchybar/colors.sh`;
  use variables from `sketchybar/fonts.sh` for fonts.
- Document changed user commands in `README.md` and changed shortcuts in the
  matching `shortcuts/` page.
- Use Conventional Commits: `<type>[optional scope]: <description>`.
