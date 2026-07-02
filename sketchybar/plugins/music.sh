#!/bin/bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
MAX_CHARS=30
ART_COUNTER_FILE="/tmp/sketchybar_art_counter"
ART_LAST_TITLE_FILE="/tmp/sketchybar_art_last_title"
ART_ITEM="${NAME}_art"

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
  local last_title counter art_file tmp_file
  last_title=$(cat "$ART_LAST_TITLE_FILE" 2>/dev/null) || true

  if [ "$title" = "$last_title" ]; then
    counter=$(cat "$ART_COUNTER_FILE" 2>/dev/null || echo 1)
    art_file="/tmp/sketchybar_art_${counter}.jpg"
    if [ -f "$art_file" ]; then echo "$art_file"; return; fi
  fi

  counter=$(( $(cat "$ART_COUNTER_FILE" 2>/dev/null || echo 0) + 1 ))
  echo "$counter" > "$ART_COUNTER_FILE"
  echo "$title" > "$ART_LAST_TITLE_FILE"

  art_file="/tmp/sketchybar_art_${counter}.jpg"
  tmp_file="${art_file}.tmp"

  curl -sL "$art_url" -o "$tmp_file" 2>/dev/null || true
  if [ -s "$tmp_file" ]; then
    sips -Z 96 "$tmp_file" >/dev/null 2>&1 || true
    find /tmp -maxdepth 1 -name "sketchybar_art_*.jpg" -delete 2>/dev/null || true
    mv "$tmp_file" "$art_file"
    echo "$art_file"
  else
    rm -f "$tmp_file"
  fi
}

set_artwork() {
  local art_file="$1"
  if [ -n "${art_file:-}" ] && [ -f "$art_file" ]; then
    sketchybar --set "$ART_ITEM" \
      drawing=on \
      background.image="$art_file" \
      background.image.drawing=on \
      background.image.scale=0.23 \
      background.image.corner_radius=4
  else
    sketchybar --set "$ART_ITEM" drawing=off
  fi
}

MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ') || true
if [ "${MONITOR_COUNT:-0}" -lt 2 ]; then
  sketchybar --set "$ART_ITEM" drawing=off
  sketchybar --set "$NAME" drawing=off label="" label.drawing=off
  exit 0
fi

# Single osascript call — avoids 5x AppleScript VM forks per update cycle
SPOTIFY_INFO=$(osascript 2>/dev/null <<'EOF'
if application "Spotify" is running then
  tell application "Spotify"
    if player state is playing then
      return (player state as string) & "|" & (name of current track) & "|" & (artist of current track) & "|" & (artwork url of current track)
    end if
  end tell
end if
return ""
EOF
) || true

if [ -n "$SPOTIFY_INFO" ]; then
  TRACK=$(echo "$SPOTIFY_INFO" | cut -d'|' -f2)
  ARTIST=$(echo "$SPOTIFY_INFO" | cut -d'|' -f3)
  ART_URL=$(echo "$SPOTIFY_INFO" | cut -d'|' -f4)

  if [ -n "$TRACK" ] && [ -n "$ARTIST" ]; then
    LABEL="$(truncate_str "$TRACK — $ARTIST")"
    ART_FILE=$(fetch_artwork "$TRACK" "$ART_URL") || true
    set_artwork "$ART_FILE"
    # width=208: label.width(200) + padding_right(8). art item adds ~34px → total 242px fixed.
    sketchybar --set "$NAME" drawing=on label="$LABEL" label.drawing=on width=208
    exit 0
  fi
fi

# Fallback: rmpc + jq (local MPD)
if command -v rmpc >/dev/null && command -v jq >/dev/null; then
  RAW_STATE=$(rmpc status | jq -r '.state' 2>/dev/null) || true
  STATE="$(echo "$RAW_STATE" | tr '[:upper:]' '[:lower:]')"
  if [ "$STATE" = "play" ]; then
    TITLE=$(rmpc song | jq -r '.metadata.title' 2>/dev/null) || true
    ARTIST=$(rmpc song | jq -r '.metadata.artist' 2>/dev/null) || true
    if [ -n "$TITLE" ] && [ -n "$ARTIST" ]; then
      LABEL="$(truncate_str "$TITLE — $ARTIST")"
      sketchybar --set "$ART_ITEM" drawing=off
      sketchybar --set "$NAME" drawing=on label="$LABEL" label.drawing=on width=242
      exit 0
    fi
  fi
fi

# Nothing playing — keep fixed-width invisible placeholder so center items don't drift.
# Total width 242 = art(34) + music(208) when playing; spacer absorbs that gap when stopped.
sketchybar --set "$ART_ITEM" drawing=off
sketchybar --set "$NAME" drawing=on label="" label.drawing=off width=242

exit 0
