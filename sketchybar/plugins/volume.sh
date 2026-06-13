#!/bin/bash

source "$CONFIG_DIR/colors.sh"

set_icons() {
  local VOLUME="$1"
  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾" ;;
    [3-5][0-9])     ICON="󰖀" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿" ;;
    *)              ICON="󰖁" ;;
  esac
  sketchybar --set volume icon="$ICON" \
             --set volume_slider slider.percentage="$VOLUME"
}

toggle_slider() {
  CURRENT_WIDTH=$(sketchybar --query volume_slider | python3 -c \
    "import sys,json; print(json.load(sys.stdin)['slider']['width'])" 2>/dev/null)
  if [ "${CURRENT_WIDTH:-0}" -gt 0 ]; then
    sketchybar --animate tanh 20 --set volume_slider slider.width=0
  else
    sketchybar --animate tanh 20 --set volume_slider slider.width=80
  fi
}

if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$(osascript -e 'output volume of (get volume settings)')
  set_icons "$VOLUME"

elif [ "$SENDER" = "mouse.clicked" ] && [ "$NAME" = "volume" ]; then
  toggle_slider

elif [ "$SENDER" = "mouse.clicked" ] && [ "$NAME" = "volume_slider" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
  set_icons "$PERCENTAGE"

elif [ "$SENDER" = "mouse.scrolled" ]; then
  CURRENT=$(osascript -e 'output volume of (get volume settings)')
  DELTA=$([ "$SCROLL_DELTA" -gt 0 ] && echo 5 || echo -5)
  NEW=$(( CURRENT + DELTA ))
  [ "$NEW" -gt 100 ] && NEW=100
  [ "$NEW" -lt 0 ]   && NEW=0
  osascript -e "set volume output volume $NEW"
  set_icons "$NEW"
fi
