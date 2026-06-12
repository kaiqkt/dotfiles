#!/bin/bash

source "$CONFIG_DIR/colors.sh"

DATE="$(date '+%d %b %a')"
TIME="$(date '+%H:%M')"

sketchybar --set "$NAME" \
  icon="$DATE" \
  icon.color=$WHITE \
  label="$TIME" \
  label.color=$WHITE
