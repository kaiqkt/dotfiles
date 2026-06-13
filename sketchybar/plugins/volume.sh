#!/bin/bash

set_volume() {
  local VOLUME="$1"
  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾" ;;
    [3-5][0-9])     ICON="󰖀" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿" ;;
    *)              ICON="󰖁" ;;
  esac

  if [ "$VOLUME" -ne 0 ]; then
    sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" drawing=on
  else
    sketchybar --set "$NAME" drawing=off
  fi
}

if [ "$SENDER" = "volume_change" ]; then
  set_volume "$INFO"

elif [ "$SENDER" = "mouse.scrolled" ]; then
  CURRENT=$(osascript -e 'output volume of (get volume settings)')
  DELTA=$([ "$SCROLL_DELTA" -gt 0 ] && echo 5 || echo -5)
  NEW=$(( CURRENT + DELTA ))
  [ "$NEW" -gt 100 ] && NEW=100
  [ "$NEW" -lt 0 ]   && NEW=0
  osascript -e "set volume output volume $NEW"
  set_volume "$NEW"
fi
