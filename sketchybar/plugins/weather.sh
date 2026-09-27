#!/bin/bash
set -euo pipefail

source "$CONFIG_DIR/colors.sh"

LAT="-23.5505"
LON="-46.6333"
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m&timezone=auto&temperature_unit=celsius"

unavailable() {
  sketchybar --set "$NAME" label="—" label.color="$WHITE"
  exit 0
}
DATA=$(curl -fsS --connect-timeout 2 --max-time 5 "$URL" 2>/dev/null) || unavailable
TEMP=$(echo "$DATA" | jq -er '.current.temperature_2m | numbers') || unavailable

if [ -z "$TEMP" ] || [ "$TEMP" = "null" ]; then unavailable; fi

TEMP_LABEL="$(printf "%.0f°C" "$TEMP")"

sketchybar --set "$NAME" label="$TEMP_LABEL" label.color="$WHITE"
