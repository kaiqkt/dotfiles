#!/bin/bash
# Append only workspace items to the controller's atomic update.
empty_space_color="0x33${BAR_COLOR:4}"
space_items=()
space_displays=()
while read -r sid monitor_id; do
  space_items+=("space.$sid")
  space_displays+=("$monitor_id")
  updates+=(--add item "space.$sid" left \
             --set "space.$sid" \
               display="$monitor_id" \
               width=32 \
               padding_left=2 \
               padding_right=2 \
               icon.drawing=off \
               icon.padding_left=0 \
               icon.padding_right=0 \
               label="●" \
               label.font="$LABEL_FONT" \
               label.width=32 \
               label.align=center \
               label.padding_left=0 \
               label.padding_right=0 \
               label.color="$empty_space_color" \
               background.drawing=off \
               background.height=26 \
               background.corner_radius=8 \
               click_script="yabai -m space --focus $sid" \
               updates=off
             --move "space.$sid" before spaces.controller)
done < <(printf '%s' "$spaces" | jq -r '.[] | "\(.index) \(.display)"')

seen_displays=" "
for monitor_id in "${space_displays[@]}"; do
  case "$seen_displays" in
    *" $monitor_id "*) continue ;;
  esac
  seen_displays+="$monitor_id "
  display_spaces=()
  for ((i=0; i<${#space_items[@]}; i++)); do
    if [[ "${space_displays[$i]}" == "$monitor_id" ]]; then
      display_spaces+=("${space_items[$i]}")
    fi
  done
  updates+=(--add bracket "spaces.group.$monitor_id" "${display_spaces[@]}" \
             --set "spaces.group.$monitor_id" \
               background.drawing=on \
               background.color="$WHITE" \
               background.height=30 \
               background.corner_radius=10)
done

