#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:

sketchybar --set "$NAME" icon="󰸘" label="$(date '+%A, %d %B  %H:%M')"

