#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"

sketchybar --set "$NAME" \
  icon.drawing=off \
  label="$(date '+%d %b %a')  $(date '+%H:%M')" \
  label.color="$WHITE"
