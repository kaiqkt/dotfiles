default=(
  padding_left=5
  padding_right=5
  icon.font="$ICON_FONT"
  label.font="$LABEL_FONT"
  icon.color=$WHITE
  label.color=$WHITE
  icon.padding_left=10
  icon.padding_right=0
  label.padding_left=10
  label.padding_right=10
  background.corner_radius=5
  background.color=$ITEM_BG_COLOR
  background.height=24
)
sketchybar --default "${default[@]}"


sketchybar --add event yabai_workspace_change


source "$CONFIG_DIR/spaces/main.sh"

sketchybar --add event spotify_change com.spotify.client.PlaybackStateChanged

sketchybar --add item music_art left \
           --set music_art \
             drawing=off \
             icon.drawing=off \
             label.drawing=off \
             padding_left=18 \
             padding_right=4 \
             background.color=$TRANSPARENT \
             background.border_width=0 \
             background.height=22 \
             background.corner_radius=4 \
             background.drawing=on \
             click_script="open -a Spotify"

sketchybar --add item music left \
           --set music \
             script="$PLUGIN_DIR/music.sh compact" \
             padding_left=8 \
             padding_right=8 \
             icon.drawing=off \
             icon.padding_left=0 \
             label.padding_left=0 \
             label.padding_right=0 \
             label.width=dynamic \
             label.color=$GREEN \
             click_script="open -a Spotify" \
             update_freq=15 \
             background.drawing=off \
           --subscribe music spotify_change system_woke

sketchybar --add bracket music.group music_art music \
           --set music.group \
             background.drawing=off

for control in previous toggle next; do
  case "$control" in
    previous) control_icon="⏮︎" ;;
    toggle) control_icon="⏸︎" ;;
    next) control_icon="⏭︎" ;;
  esac
  sketchybar --add item "music.$control" left \
             --set "music.$control" \
               drawing=off \
               width=24 \
               padding_left=2 \
               padding_right=2 \
               icon="$control_icon" \
               icon.font="$ICON_FONT" \
               icon.color="$WHITE" \
               icon.width=24 \
               icon.align=center \
               icon.padding_left=0 \
               icon.padding_right=0 \
               label.drawing=off \
               background.drawing=off \
               click_script="$PLUGIN_DIR/music_control.sh $control"
done

sketchybar --add item center.notch center \
           --set center.notch \
             width=220 \
             icon.drawing=off \
             label.drawing=off \
             background.drawing=off


sketchybar \
  --add item datetime right \
    --set datetime \
      update_freq=30 \
      label.font="$LABEL_FONT" \
      label.padding_left=10 \
      label.padding_right=10 \
      padding_right=0 \
      background.drawing=off \
      script="$PLUGIN_DIR/clock.sh" \
  \
  --add item weather right \
    --set weather \
      script="$PLUGIN_DIR/weather.sh" \
      icon="􀆭" \
      update_freq=1800 \
      label.padding_left=0 \
      label.padding_right=0 \
      icon.padding_right=4 \
      label.color=$WHITE \
      icon.color=$WHITE \
      background.drawing=off \
      click_script="open -a Weather" \
      --subscribe weather system_woke \
  \
  --add item battery right \
    --set battery \
      update_freq=120 \
      label.padding_right=0 \
      background.drawing=off \
      script="$PLUGIN_DIR/battery.sh" \
      --subscribe battery system_woke power_source_change \
  \
  --add graph cpu_usage right 42 \
     --set cpu_usage script="$PLUGIN_DIR/cpu_usage.sh" \
      update_freq=5 \
      icon="􀫥" \
      icon.drawing=on \
      icon.padding_left=0 \
      icon.padding_right=4 \
      label.font="$SMALL_FONT" \
      label.align=right \
      label.padding_right=0 \
      label.width=0 \
      label.y_offset=4 \
      background.color=$TRANSPARENT \
      background.border_color=$TRANSPARENT \
      background.drawing=on \
      graph.color=$BAR_BORDER_COLOR \
      graph.fill_color=0x44${BAR_BORDER_COLOR:4} \
      graph.line_width=2 \
  \
  --add bracket cpu.bracket cpu_usage \
     --set cpu.bracket \
      background.drawing=off \
  \
  --add slider volume_slider right 80 \
    --set volume_slider \
      updates=on \
      label.drawing=off \
      icon.drawing=off \
      slider.width=0 \
      padding_left=0 \
      padding_right=0 \
      background.color=$BAR_COLOR \
      slider.highlight_color=$BAR_BORDER_COLOR \
      slider.background.height=6 \
      slider.background.corner_radius=3 \
      slider.background.color=$SLIDER_BG_COLOR \
      slider.knob="⬤" \
      slider.knob.font="$KNOB_FONT" \
      slider.knob.y_offset=0 \
      slider.knob.color=$WHITE \
      script="$PLUGIN_DIR/volume.sh" \
      --subscribe volume_slider mouse.clicked mouse.scrolled \
  \
  --add item volume right \
    --set volume \
      script="$PLUGIN_DIR/volume.sh" \
      icon.padding_left=10 \
      icon.padding_right=4 \
      label.drawing=off \
      background.color=$BAR_COLOR \
      --subscribe volume volume_change mouse.clicked mouse.scrolled system_woke

sketchybar --set volume_slider background.color="$TRANSPARENT" background.drawing=off \
           --set volume background.color="$TRANSPARENT" background.drawing=off

sketchybar --update

sketchybar --trigger yabai_workspace_change
