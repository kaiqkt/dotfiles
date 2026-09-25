#!/bin/bash

sketchybar --bar position=top height=40 \
          blur_radius=0 margin=0 y_offset=0 corner_radius=0 \
          border_width=0 \
          shadow=on \
          color=$BAR_COLOR

source "$CONFIG_DIR/items.sh"
