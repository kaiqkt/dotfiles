"""Check the compact Spotify controls for playing, paused, and idle states."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


MUSIC_SCRIPT = Path(__file__).resolve().parents[1] / "sketchybar/plugins/music.sh"
CONTROL_SCRIPT = Path(__file__).resolve().parents[1] / "sketchybar/plugins/music_control.sh"


class SketchybarMusicTests(unittest.TestCase):
    def test_player_priority_with_one_monitor_and_display_query_failure(self):
        wrapper = '''
yabai() { printf '%s\\n' "$MOCK_DISPLAYS"; return "$MOCK_DISPLAY_STATUS"; }
osascript() { cat >/dev/null; printf '%s\\n' "$MOCK_SPOTIFY_INFO"; }
rmpc() {
  if [ "$1" = status ]; then
    printf '{"state":"%s"}\\n' "$MOCK_MPD_STATE"
  else
    printf '%s\\n' "$MOCK_MPD_SONG"
  fi
}
sketchybar() { printf '%s\\n' "$*" >> "$MOCK_LOG"; }
source "$MUSIC_SCRIPT" compact
'''
        cases = (
            ("playing", "play", "MPD", "Spotify — Artist", "on"),
            ("paused", "play", "MPD", "MPD — Other", "off"),
            ("paused", "stop", "MPD", "Spotify — Artist", "on"),
            ("paused", "play", "", "Spotify — Artist", "on"),
            ("", "play", "MPD", "MPD — Other", "off"),
        )
        with tempfile.TemporaryDirectory() as directory:
            log = Path(directory) / "calls.log"
            for displays, status in (("[{}]", "0"), ("[{},{}]", "0"), ("", "1")):
                for spotify, mpd, title, label, controls in cases:
                    with self.subTest(displays=displays, spotify=spotify,
                                      mpd=mpd, title=title):
                        log.write_text("")
                        environment = dict(os.environ, MUSIC_SCRIPT=str(MUSIC_SCRIPT),
                                           MOCK_LOG=str(log), NAME="music",
                                           MOCK_DISPLAYS=displays,
                                           MOCK_DISPLAY_STATUS=status,
                                           MOCK_SPOTIFY_INFO=(json.dumps({"state": spotify, "title": "Spotify",
                                                                          "artist": "Artist", "artwork": ""})
                                                              if spotify else ""),
                                           MOCK_MPD_STATE=mpd,
                                           MOCK_MPD_SONG=(
                                               '{"metadata":{"title":"' + title +
                                               '","artist":"Other"}}'))
                        subprocess.run(["bash", "-c", wrapper], env=environment,
                                       check=True, capture_output=True, text=True)
                        calls = log.read_text()
                        self.assertIn(f"--set music drawing=on label={label} ", calls)
                        for control in ("previous", "toggle", "next"):
                            self.assertIn(f"--set music.{control} drawing={controls}",
                                          calls)
                        if controls == "off":
                            self.assertNotIn("label=Spotify", calls)

    def test_controls_send_spotify_commands_and_refresh(self):
        wrapper = '''
osascript() { cat > "$MOCK_APPLESCRIPT"; }
sketchybar() { printf '%s\\n' "$*" > "$MOCK_LOG"; }
source "$CONTROL_SCRIPT" "$ACTION"
'''
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            environment = os.environ.copy()
            environment.update({
                "CONTROL_SCRIPT": str(CONTROL_SCRIPT),
                "MOCK_APPLESCRIPT": str(root / "command.applescript"),
                "MOCK_LOG": str(root / "calls.log"),
            })
            for action, command in (("previous", "previous track"),
                                    ("toggle", "playpause"),
                                    ("next", "next track")):
                environment["ACTION"] = action
                subprocess.run(["bash", "-c", wrapper], env=environment,
                               check=True, capture_output=True, text=True)
                self.assertIn(f'tell application "Spotify" to {command}',
                              (root / "command.applescript").read_text())
                self.assertEqual((root / "calls.log").read_text(),
                                 "--trigger spotify_change\n")

    def test_compact_controls_follow_playback_state(self):
        wrapper = '''
yabai() { printf '[{},{}]\\n'; }
osascript() { cat >/dev/null; printf '%s\\n' "$MOCK_SPOTIFY_INFO"; }
rmpc() { printf '{"state":"stop"}\\n'; }
sketchybar() { printf '%s\\n' "$*" >> "$MOCK_LOG"; }
source "$MUSIC_SCRIPT" compact
'''
        with tempfile.TemporaryDirectory() as directory:
            log = Path(directory) / "calls.log"
            environment = os.environ.copy()
            environment.update({
                "MUSIC_SCRIPT": str(MUSIC_SCRIPT),
                "MOCK_LOG": str(log),
                "NAME": "music",
            })

            for state, icon in (("playing", "⏸︎"), ("paused", "⏵︎")):
                log.write_text("")
                environment["MOCK_SPOTIFY_INFO"] = json.dumps({"state": state, "title": "Track", "artist": "Artist", "artwork": ""})
                subprocess.run(["bash", "-c", wrapper], env=environment,
                               check=True, capture_output=True, text=True)
                calls = log.read_text()
                self.assertIn("--set music.previous drawing=on", calls)
                self.assertIn(f"--set music.toggle drawing=on icon={icon}", calls)
                self.assertIn("--set music.next drawing=on", calls)
                self.assertIn("--set music drawing=on label=Track — Artist ", calls)
                self.assertIn("width=dynamic", calls)

            log.write_text("")
            environment["MOCK_SPOTIFY_INFO"] = ""
            subprocess.run(["bash", "-c", wrapper], env=environment,
                           check=True, capture_output=True, text=True)
            calls = log.read_text()
            self.assertIn("--set music.previous drawing=off", calls)
            self.assertIn("--set music drawing=off", calls)


if __name__ == "__main__":
    unittest.main()
