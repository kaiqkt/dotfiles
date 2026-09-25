#!/bin/bash

sketchybar --bar position=top height=40 \
          blur_radius=0 margin=10 y_offset=8 corner_radius=12 \
          border_width=0 \
          shadow=on \
          color=$BAR_COLOR

source "$CONFIG_DIR/items.sh"
