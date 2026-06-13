#!/bin/bash

source "$CONFIG_DIR/colors.sh"

sketchybar --set "$NAME" \
  icon="󰸘" \
  icon.color=$WHITE \
  label="$(date '+%d %b %a')  $(date '+%H:%M')" \
  label.color=$WHITE
