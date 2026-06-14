# AeroSpace

## Workspaces

| Binding         | Description                           |
| --------------- | ------------------------------------- |
| `alt+1-9`       | Switch to workspace                   |
| `alt+shift+1-9` | Move window to workspace (and follow) |

Default app assignments:

| Workspace | Apps            | Monitor |
| --------- | --------------- | ------- |
| 1         | Chrome, Safari  | 1       |
| 2         | Kitty, Terminal | 1       |
| 3–5       | —               | 1       |
| 6–7       | —               | 2       |
| 8         | Claude          | 2       |
| 9         | Spotify         | 2       |

## Focus & Move

| Binding             | Description                     |
| ------------------- | ------------------------------- |
| `alt+h/j/k/l`       | Focus window left/down/up/right |
| `alt+shift+h/j/k/l` | Move window left/down/up/right  |

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
| `alt+/`           | Toggle tiles horizontal/vertical (h-tiles → v-tiles) |
| `alt+,`           | Toggle accordion horizontal/vertical                 |
| `alt+shift+space` | Toggle floating/tiling                               |
| `alt+f`           | Fullscreen                                           |

## Service Mode (`alt+shift+;`)

| Binding             | Description                      |
| ------------------- | -------------------------------- |
| `r`                 | Flatten workspace tree           |
| `f`                 | Toggle floating/tiling           |
| `backspace`         | Close all windows except current |
| `alt+shift+h/j/k/l` | Join with adjacent window        |
| `esc`               | Exit service mode                |

## CLI

```bash
aerospace reload-config
aerospace list-workspaces --all
aerospace list-windows --all
```
