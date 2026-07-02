#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"

LAT="-23.5505"
LON="-46.6333"
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m&timezone=auto&temperature_unit=celsius"

DATA=$(curl -s --max-time 5 "$URL") || exit 0
TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m') || exit 0

if [ -z "$TEMP" ] || [ "$TEMP" = "null" ]; then exit 0; fi

TEMP_LABEL="$(printf "%.0f°C" "$TEMP")"

sketchybar --set "$NAME" label="$TEMP_LABEL" label.color="$WHITE"
