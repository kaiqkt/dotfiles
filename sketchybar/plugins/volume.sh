#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"

set_icons() {
  local VOLUME="$1"
  case "$VOLUME" in
    [6-9][0-9]|100) ICON="􀊩" ;;
    [3-5][0-9])     ICON="􀊧" ;;
    [1-9]|[1-2][0-9]) ICON="􀊥" ;;
    *)              ICON="􀊣" ;;
  esac
  if [ "${MUTED:-false}" = true ]; then ICON="􀊣"; fi
  sketchybar --set volume icon="$ICON" \
             --set volume_slider slider.percentage="$VOLUME"
}

toggle_slider() {
  CURRENT_WIDTH=$(sketchybar --query volume_slider | python3 -c \
    "import sys,json; print(json.load(sys.stdin)['slider']['width'])" 2>/dev/null) || true
  if [ "${CURRENT_WIDTH:-0}" -gt 0 ]; then
    sketchybar --animate tanh 20 --set volume_slider slider.width=0 padding_right=0
  else
    sketchybar --animate tanh 20 --set volume_slider slider.width=80 padding_right=5
  fi
}

read_volume() {
  local settings
  settings=$(osascript -e 'set v to get volume settings' -e 'return (output volume of v as string) & "|" & (output muted of v as string)') || return 1
  IFS='|' read -r VOLUME MUTED <<< "$settings"
  [[ "$VOLUME" =~ ^[0-9]+$ ]] && [ "$VOLUME" -le 100 ]
}

case "${SENDER:-}" in
  volume_change|forced_update|system_woke)
    read_volume || exit 0
    set_icons "$VOLUME"
    ;;
  mouse.clicked)
    if [ "$NAME" = volume ]; then
      toggle_slider
    else
      [[ "${PERCENTAGE:-}" =~ ^[0-9]+$ ]] || exit 0
      [ "$PERCENTAGE" -le 100 ] || exit 0
      osascript -e "set volume output volume $PERCENTAGE"
      read_volume || exit 0
      set_icons "$VOLUME"
    fi
    ;;
  mouse.scrolled)
    [[ "${SCROLL_DELTA:-}" =~ ^-?[0-9]+$ ]] || exit 0
    [ "$SCROLL_DELTA" -ne 0 ] || exit 0
    read_volume || exit 0
    if [ "$SCROLL_DELTA" -gt 0 ]; then DELTA=5; else DELTA=-5; fi
    NEW=$(( VOLUME + DELTA ))
    if [ "$NEW" -gt 100 ]; then NEW=100; fi
    if [ "$NEW" -lt 0 ]; then NEW=0; fi
    osascript -e "set volume output volume $NEW"
    read_volume || exit 0
    set_icons "$VOLUME"
    ;;
esac
