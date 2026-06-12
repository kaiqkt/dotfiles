#!/bin/sh

source "$CONFIG_DIR/colors.sh"

sketchybar --set "$NAME" \
  icon="$(date '+%H:%M')" \
  icon.color=$ACCENT_COLOR \
  label="$(date '+%d %b %a')" \
  label.color=$WHITE
