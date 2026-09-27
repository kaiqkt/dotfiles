#!/bin/bash
set -euo pipefail

case "${1:-}" in
  previous) command='previous track' ;;
  toggle) command='playpause' ;;
  next) command='next track' ;;
  *) exit 2 ;;
esac

osascript <<EOF
if application "Spotify" is running then
  tell application "Spotify" to $command
end if
EOF

sketchybar --trigger spotify_change
