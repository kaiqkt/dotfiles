#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
MAX_CHARS=30
ART_COUNTER_FILE="/tmp/sketchybar_art_counter"
ART_LAST_TITLE_FILE="/tmp/sketchybar_art_last_title"

truncate_str() {
  local s="$1"
  if [ "${#s}" -gt "$MAX_CHARS" ]; then
    echo "${s:0:$MAX_CHARS}…"
  else
    echo "$s"
  fi
}

fetch_artwork() {
  local title="$1"
  local art_url="$2"
  local last_title counter art_file
  last_title=$(cat "$ART_LAST_TITLE_FILE" 2>/dev/null)

  if [ "$title" = "$last_title" ]; then
    counter=$(cat "$ART_COUNTER_FILE" 2>/dev/null || echo 1)
    art_file="/tmp/sketchybar_art_${counter}.jpg"
    [ -f "$art_file" ] && echo "$art_file" && return
  fi

  counter=$(( $(cat "$ART_COUNTER_FILE" 2>/dev/null || echo 0) + 1 ))
  echo "$counter" > "$ART_COUNTER_FILE"
  echo "$title" > "$ART_LAST_TITLE_FILE"

  art_file="/tmp/sketchybar_art_${counter}.jpg"
  rm -f /tmp/sketchybar_art_*.jpg 2>/dev/null

  curl -sL "$art_url" -o "$art_file" 2>/dev/null
  if [ -s "$art_file" ]; then
    sips -Z 96 "$art_file" >/dev/null 2>&1
    echo "$art_file"
  else
    rm -f "$art_file"
  fi
}

set_artwork() {
  local art_file="$1"
  if [ -n "$art_file" ]; then
    sketchybar --set music_art \
      drawing=on \
      background.image="$art_file" \
      background.image.drawing=on \
      background.image.scale=0.23 \
      background.image.corner_radius=4
  else
    sketchybar --set music_art drawing=off
  fi
}

# Spotify (explicit check — avoids picking up browser/YouTube)
if osascript -e 'application "Spotify" is running' &>/dev/null; then
  STATE=$(osascript -e 'tell application "Spotify" to player state' 2>/dev/null)
  if [ "$STATE" = "playing" ]; then
    TRACK=$(osascript -e 'tell application "Spotify" to name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track' 2>/dev/null)
    ART_URL=$(osascript -e 'tell application "Spotify" to artwork url of current track' 2>/dev/null)

    if [ -n "$TRACK" ] && [ -n "$ARTIST" ]; then
      LABEL="$(truncate_str "$TRACK — $ARTIST")"
      ART_FILE=$(fetch_artwork "$TRACK" "$ART_URL")
      set_artwork "$ART_FILE"
      sketchybar --set "$NAME" label="$LABEL" label.drawing=on
      exit 0
    fi
  fi
fi

# Fallback: rmpc + jq (local MPD)
if command -v rmpc >/dev/null && command -v jq >/dev/null; then
  RAW_STATE=$(rmpc status | jq -r '.state' 2>/dev/null)
  STATE="$(echo "$RAW_STATE" | tr '[:upper:]' '[:lower:]')"
  if [ "$STATE" = "play" ]; then
    TITLE=$(rmpc song | jq -r '.metadata.title' 2>/dev/null)
    ARTIST=$(rmpc song | jq -r '.metadata.artist' 2>/dev/null)
    if [ -n "$TITLE" ] && [ -n "$ARTIST" ]; then
      LABEL="$(truncate_str "$TITLE — $ARTIST")"
      sketchybar --set music_art drawing=off
      sketchybar --set "$NAME" label="$LABEL" label.drawing=on
      exit 0
    fi
  fi
fi

# Nothing playing
sketchybar --set music_art drawing=off
sketchybar --set "$NAME" label="" label.drawing=off

exit 0
