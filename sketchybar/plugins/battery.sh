#!/bin/bash

source "$CONFIG_DIR/colors.sh"

BATT="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT" | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(echo "$BATT" | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="􀛨" ;;
  [6-8][0-9]) ICON="􀺸" ;;
  [3-5][0-9]) ICON="􀺶" ;;
  [1-2][0-9]) ICON="􀛩" ;;
  *)          ICON="􀛪" ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="􀢋"
fi

if [ "$PERCENTAGE" -le 10 ]; then
  COLOR="$RED"
elif [ "$PERCENTAGE" -le 20 ]; then
  COLOR="$ORANGE"
else
  COLOR="$WHITE"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="${PERCENTAGE}%" \
  icon.color="$COLOR" \
  label.color="$COLOR"
