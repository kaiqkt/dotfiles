#!/bin/bash

source "$CONFIG_DIR/colors.sh"

LAT="-23.5505"
LON="-46.6333"
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m&timezone=auto&temperature_unit=celsius"

DATA=$(curl -s --max-time 5 "$URL")
TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m')

[ -z "$TEMP" ] || [ "$TEMP" = "null" ] && exit 0

TEMP_LABEL="$(printf "%.0f°C" "$TEMP")"

sketchybar --set "$NAME" label="$TEMP_LABEL" label.color=$WHITE
