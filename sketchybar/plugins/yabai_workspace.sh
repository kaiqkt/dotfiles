#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"

space_index="${1:?space index required}"
visible=$(yabai -m query --spaces --space "$space_index" 2>/dev/null | jq -r '."is-visible"') || exit 0

if [ "$visible" = true ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$ITEM_BG_COLOR" \
    background.border_width=2 \
    label.shadow.drawing=on \
    icon.shadow.drawing=on
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    background.border_width=0 \
    label.shadow.drawing=off \
    icon.shadow.drawing=off
fi

apps=$(yabai -m query --windows --space "$space_index" 2>/dev/null | jq -r '.[].app') || true
if [ -n "$apps" ]; then
  icon_strip=" "
  while IFS= read -r app; do
    icon_strip+=" $("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app") "
  done <<< "$apps"
  sketchybar --set "$NAME" label="$icon_strip" drawing=on
else
  sketchybar --set "$NAME" label="" drawing=on
fi
