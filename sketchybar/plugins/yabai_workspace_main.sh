#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/fonts.sh"

spaces=$(yabai -m query --spaces 2>/dev/null) || exit 0
printf '%s' "$spaces" | jq -e 'type == "array" and length > 0' >/dev/null || exit 0
# After a failed initial query, rebuild the missing items on the next refresh.
expected=$(printf '%s' "$spaces" | jq -c '[.[].index] | sort')
actual=$(sketchybar --query bar | jq -c '[.items[] | select(test("^space\\.[0-9]+$")) | split(".")[1] | tonumber] | sort') || exit 0
if [ "$expected" != "$actual" ]; then
  sketchybar --reload
  exit 0
fi
windows=$(yabai -m query --windows 2>/dev/null) || exit 0
updates=()
while IFS=$'\t' read -r sid visible app; do
  if [ -n "$app" ]; then
    label=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app")
    font=$APP_ICON_FONT
    inactive_color=$BAR_COLOR
  else
    label="●"
    font=$LABEL_FONT
    inactive_color="0x33${BAR_COLOR:4}"
  fi
  if [ "$visible" = true ]; then
    updates+=(--set "space.$sid" background.drawing=on background.color="$BAR_COLOR"
      label="$label" label.font="$font" label.color="$WHITE")
  else
    updates+=(--set "space.$sid" background.drawing=off
      label="$label" label.font="$font" label.color="$inactive_color")
  fi
done < <(jq -rn --argjson spaces "$spaces" --argjson windows "$windows" '
  $spaces[] | . as $space |
  [$windows[] | select(.space == $space.index and .app? != null and .app != "")] |
  (map(select(."has-focus" == true))[0] // .[0] // {}) as $window |
  [$space.index, $space."is-visible", ($window.app // "")] | @tsv')
[ "${#updates[@]}" -eq 0 ] || sketchybar "${updates[@]}"
