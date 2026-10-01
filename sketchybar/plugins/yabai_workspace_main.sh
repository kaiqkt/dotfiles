#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/fonts.sh"

spaces=$(yabai -m query --spaces 2>/dev/null) || exit 0
printf '%s' "$spaces" | jq -e 'type == "array" and length > 0' >/dev/null || exit 0
# Empty/invalid IPC replies are transient, never a reason to reload the bar.
bar=$(sketchybar --query bar) || exit 0
printf '%s' "$bar" | jq -e 'type == "object" and (.items | type == "array")' >/dev/null || exit 0
controller=$(sketchybar --query spaces.controller) || exit 0
printf '%s' "$controller" | jq -e 'type == "object"' >/dev/null || exit 0
signature=$(printf '%s' "$spaces" | jq -c '[.[] | [.id, .display]]')
previous=$(printf '%s' "$controller" | jq -r '.label.value // ""')
expected=$(printf '%s' "$spaces" | jq -c '[.[].id] | sort')
actual=$(printf '%s' "$bar" | jq -c '[.items[] | select(test("^space\\.[0-9]+$")) | split(".")[1] | tonumber] | sort')
windows=$(yabai -m query --windows 2>/dev/null) || exit 0
printf '%s' "$windows" | jq -e 'type == "array"' >/dev/null || exit 0
updates=()
if [ "$signature" != "$previous" ] || [ "$expected" != "$actual" ]; then
  # SketchyBar uses POSIX basic regex: + is literal, use [0-9][0-9]*.
  updates+=(--remove '/^spaces\.group\.[0-9][0-9]*$/' --remove '/^space\.[0-9][0-9]*$/')
  source "$CONFIG_DIR/spaces/build.sh"
  updates+=(--set spaces.controller label="$signature")
fi
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
  [$space.id, $space."is-visible", ($window.app // "")] | @tsv')
# Keep the entire left section in order, including after recovering a stale bar.
# Reordering only workspace items leaves displaced music controls in front.
order=()
while IFS= read -r item; do
  order+=("$item")
done < <(jq -rn --argjson spaces "$spaces" --argjson bar "$bar" '
  ($spaces[] | "space.\(.id)"),
  (["spaces.controller", "music_art", "music", "music.previous", "music.toggle", "music.next"][] |
    . as $name | select($bar.items | index($name)))')
updates+=(--reorder "${order[@]}")
[ "${#updates[@]}" -eq 0 ] || sketchybar "${updates[@]}"
