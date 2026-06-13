#!/bin/bash

source "$CONFIG_DIR/colors.sh"

LAT="-23.5505"
LON="-46.6333"
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m,weather_code&timezone=auto&temperature_unit=celsius"

DATA=$(curl -s "$URL")

TEMP=$(echo "$DATA" | jq -r '.current.temperature_2m')
CODE=$(echo "$DATA" | jq -r '.current.weather_code')

# Map WMO code to icon 
case $CODE in
  0) ICON="" ;;      # Clear sky
  1) ICON="" ;;      # Mainly clear
  2) ICON="" ;;      # Partly cloudy
  3) ICON="" ;;      # Overcast
  45|48) ICON="" ;;  # Fog or depositing rime fog
  51|53|55) ICON="" ;;  # Drizzle: Light, moderate, dense
  56|57) ICON="?" ;;      # Freezing drizzle
  61|63|65) ICON="" ;;  # Rain: slight, moderate, heavy
  66|67) ICON="?" ;;      # Freezing rain
  71|73|75) ICON="󰖘" ;;  # Snowfall
  77) ICON="?" ;;         # Snow grains
  80|81|82) ICON="" ;;  # Rain showers
  85|86) ICON="?" ;;      # Snow showers
  95) ICON="󰖓" ;;        # Thunderstorm
  96|99) ICON="?" ;;      # Thunderstorm with hail
  *) ICON="" ;;         # Unknown
esac

# Format temp: round to nearest integer, add degree symbol
TEMP_LABEL="$(printf "%.0f°C" "$TEMP")"

sketchybar --set "$NAME" icon="$ICON" label="$TEMP_LABEL" icon.color=$WHITE label.color=$WHITE
