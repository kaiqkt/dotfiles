# yabai and skhd

## Workspaces

| Binding         | Description                           |
| --------------- | ------------------------------------- |
| `alt+1-9`       | Switch to native macOS Space                   |
| `alt+shift+1-9` | Move window to Space (and follow)             |

Default app assignments:

| Space | Apps            | One display | Two displays |
| ----- | --------------- | ----------- | ------------ |
| 1     | Chrome, Safari  | 1           | 1            |
| 2     | Kitty, Terminal | 1           | 1            |
| 3–5   | —               | 1           | 1            |
| 6–7   | —               | 1           | 2            |
| 8     | Claude          | 1           | 2            |
| 9     | Spotify         | 1           | 2            |

## Focus & Move

| Binding             | Description                     |
| ------------------- | ------------------------------- |
| `alt+h/j/k/l`       | Focus window left/down/up/right |
| `alt+shift+h/j/k/l` | Swap window left/down/up/right  |

## Resize

| Binding      | Description     |
| ------------ | --------------- |
| `alt+ctrl+h` | Decrease width  |
| `alt+ctrl+l` | Increase width  |
| `alt+ctrl+k` | Decrease height |
| `alt+ctrl+j` | Increase height |

## Layout

| Binding           | Description                                          |
| ----------------- | ---------------------------------------------------- |
| `alt+/`           | Rotate the BSP tree 90°                               |
| `alt+,`           | Toggle BSP/stack layout                               |
| `alt+shift+space` | Toggle floating/tiling                               |
| `alt+f`           | Zoom window to fill its Space                        |

## Service Mode (`alt+shift+;`)

| Binding             | Description                      |
| ------------------- | -------------------------------- |
| `r`                 | Balance Space split ratios        |
| `f`                 | Toggle floating/tiling           |
| `backspace`         | Close all windows except current |
| `alt+shift+h/j/k/l` | Warp beside adjacent window      |
| `esc`               | Exit service mode                |

Service mode stays active until `esc` is pressed.

## CLI

```bash
yabai --restart-service
skhd --restart-service
~/.config/yabai/scripts/setup-spaces
yabai -m query --spaces
yabai -m query --windows
```
