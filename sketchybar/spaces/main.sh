#!/bin/bash

# One controller refreshes every space and recovers from unavailable yabai.
sketchybar --add item spaces.controller left \
           --set spaces.controller drawing=off updates=on update_freq=30 \
             script="$PLUGIN_DIR/workspace_refresh.py" \
           --subscribe spaces.controller yabai_workspace_change space_change display_change system_woke
