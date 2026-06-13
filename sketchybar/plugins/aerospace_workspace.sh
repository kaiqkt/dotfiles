#!/bin/bash

source "$CONFIG_DIR/colors.sh"

WS_ID="$1"

if [ "$WS_ID" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$ITEM_BG_COLOR \
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

# Refresh app icons, show/hide based on occupancy
apps=$(aerospace list-windows --workspace "$WS_ID" 2>/dev/null \
       | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

if [ -n "$apps" ]; then
  icon_strip=" "
  while IFS= read -r app; do
    icon_strip+=" $("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app") "
  done <<< "$apps"
  sketchybar --set "$NAME" label="$icon_strip" drawing=on
else
  # Always show focused workspace even if empty
  if [ "$WS_ID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" label="" drawing=on
  else
    sketchybar --set "$NAME" drawing=off
  fi
fi
