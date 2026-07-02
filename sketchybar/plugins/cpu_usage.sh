#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"

raw=$(top -l 1 | awk '/CPU usage/ {print $3}' | sed 's/%//')
if [ -z "$raw" ]; then exit 0; fi
load=$(printf "%.0f" "$raw")
normalized=$(echo "$raw / 100" | bc -l)

if [ "$load" -ge 80 ]; then
  COLOR=$RED
elif [ "$load" -ge 60 ]; then
  COLOR=$ORANGE
elif [ "$load" -ge 30 ]; then
  COLOR=$YELLOW
else
  COLOR=$BAR_BORDER_COLOR
fi

sketchybar --set "$NAME" \
  label="${load}%" \
  label.color="$WHITE" \
  graph.color="$COLOR" \
  graph.fill_color="0x55${COLOR:4}"

sketchybar --push cpu_usage "$normalized"
