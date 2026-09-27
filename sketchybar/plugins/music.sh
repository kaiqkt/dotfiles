#!/bin/bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
MAX_CHARS=30
COMPACT="${1:-}"
if [ "$COMPACT" = compact ]; then
  MAX_CHARS=18
fi
ART_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/artwork"
ART_ITEM="${NAME}_art"
SHOW_ART=true
# Use the narrowest display budget so mirrored widgets fit on every screen.
if [ "$COMPACT" = compact ]; then
  displays=$(yabai -m query --displays 2>/dev/null) || displays='[]'
  budget=$(printf '%s' "$displays" | jq -er '
    [ .[] | select(.frame.w? != null and .spaces? != null) |
      (.frame.w / 2 - 110 - 24 - (.spaces | length) * 36 - 84 - 16) ] |
    if length > 0 then min | floor else empty end' 2>/dev/null) || budget=330
  if [ "$budget" -ge 160 ]; then
    budget=$((budget - 48))
  else
    SHOW_ART=false
  fi
  MAX_CHARS=$((budget / 14 - 1))
  [ "$MAX_CHARS" -le 18 ] || MAX_CHARS=18
  [ "$MAX_CHARS" -ge 0 ] || MAX_CHARS=0
fi

show_controls() {
  [ "$COMPACT" = compact ] || return 0
  local toggle_icon="⏸︎"
  if [ "$1" = paused ]; then
    toggle_icon="⏵︎"
  fi
  sketchybar --set "${NAME}.previous" drawing=on \
            --set "${NAME}.toggle" drawing=on icon="$toggle_icon" \
            --set "${NAME}.next" drawing=on
}

hide_controls() {
  [ "$COMPACT" = compact ] || return 0
  sketchybar --set "${NAME}.previous" drawing=off \
            --set "${NAME}.toggle" drawing=off \
            --set "${NAME}.next" drawing=off
}

show_track() {
  local label="$1" width="$2"
  if [ "$COMPACT" = compact ]; then
    width=dynamic
  fi
  sketchybar --set "$NAME" drawing=on label="$label" label.drawing=on width="$width"
}

truncate_str() {
  local s="$1"
  if [ "$MAX_CHARS" -eq 0 ]; then return; fi
  if [ "${#s}" -gt "$MAX_CHARS" ]; then
    echo "${s:0:$MAX_CHARS}…"
  else
    echo "$s"
  fi
}

fetch_artwork() {
  local art_url="$1" key art_file tmp_file
  mkdir -p "$ART_CACHE"
  key=$(printf '%s' "$art_url" | shasum -a 256 | awk '{print $1}')
  art_file="$ART_CACHE/$key.jpg"
  if [ -s "$art_file" ]; then printf '%s\n' "$art_file"; return; fi
  tmp_file=$(mktemp "$ART_CACHE/.download.XXXXXX")
  if curl --fail --silent --show-error --location --connect-timeout 2 --max-time 5 \
      "$art_url" -o "$tmp_file" 2>/dev/null &&
      [ -s "$tmp_file" ] && sips -s format jpeg -Z 96 "$tmp_file" >/dev/null 2>&1; then
    mv -f "$tmp_file" "$art_file"
    find "$ART_CACHE" -name '*.jpg' -mtime +7 -delete 2>/dev/null || true
    printf '%s\n' "$art_file"
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

show_spotify() {
  local label art_file=
  label="$(truncate_str "$TRACK — $SPOTIFY_ARTIST")"
  show_controls "$PLAYBACK_STATE"
  sketchybar --set "$NAME" click_script="open -a Spotify"
  show_track "$label" 208
  set_artwork ""
  if [ "$SHOW_ART" = true ] && [ -n "$ART_URL" ]; then
    art_file=$(fetch_artwork "$ART_URL") || true
  fi
  set_artwork "$art_file"
}

SPOTIFY_INFO=$(osascript -l JavaScript 2>/dev/null <<'EOF'
const spotify = Application('Spotify');
let info = {};
if (spotify.running()) {
  const state = spotify.playerState();
  if (state === 'playing' || state === 'paused') {
    const track = spotify.currentTrack();
    info = {state: state, title: track.name(), artist: track.artist(), artwork: track.artworkUrl()};
  }
}
JSON.stringify(info);
EOF
) || true

PLAYBACK_STATE=
TRACK=
SPOTIFY_ARTIST=
ART_URL=
if [ -n "$SPOTIFY_INFO" ]; then
  PLAYBACK_STATE=$(printf '%s' "$SPOTIFY_INFO" | jq -r '.state // empty') || true
  TRACK=$(printf '%s' "$SPOTIFY_INFO" | jq -r '.title // empty') || true
  SPOTIFY_ARTIST=$(printf '%s' "$SPOTIFY_INFO" | jq -r '.artist // empty') || true
  ART_URL=$(printf '%s' "$SPOTIFY_INFO" | jq -r '.artwork // empty') || true

  if [ -n "$TRACK" ] && [ -n "$SPOTIFY_ARTIST" ] &&
      [ "$PLAYBACK_STATE" = playing ]; then
    show_spotify
    exit 0
  fi
fi

if command -v rmpc >/dev/null && command -v jq >/dev/null; then
  RAW_STATE=$(rmpc status | jq -r '.state' 2>/dev/null) || true
  STATE="$(echo "$RAW_STATE" | tr '[:upper:]' '[:lower:]')"
  if [ "$STATE" = "play" ]; then
    SONG=$(rmpc song 2>/dev/null) || true
    TITLE=$(printf '%s' "$SONG" | jq -r '.metadata.title // empty' 2>/dev/null) || true
    ARTIST=$(printf '%s' "$SONG" | jq -r '.metadata.artist // empty' 2>/dev/null) || true
    if [ -n "$TITLE" ] && [ -n "$ARTIST" ]; then
      LABEL="$(truncate_str "$TITLE — $ARTIST")"
      sketchybar --set "$ART_ITEM" drawing=off
      sketchybar --set "$NAME" click_script=""
      show_track "$LABEL" 242
      hide_controls
      exit 0
    fi
  fi
fi

# A paused Spotify track is a fallback after players that are still playing.
if [ "$COMPACT" = compact ] && [ "$PLAYBACK_STATE" = paused ] &&
    [ -n "$TRACK" ] && [ -n "$SPOTIFY_ARTIST" ]; then
  show_spotify
  exit 0
fi

sketchybar --set "$ART_ITEM" drawing=off
hide_controls
if [ "$COMPACT" = compact ]; then
  sketchybar --set "$NAME" drawing=off label="" label.drawing=off
else
  sketchybar --set "$NAME" drawing=on label="" label.drawing=off width=242
fi

exit 0
