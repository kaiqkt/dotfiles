"""Keep occupied and fullscreen macOS Spaces when enforcing the empty-Space limit."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "yabai/scripts/limit-spaces"
FAKE_YABAI = """#!/bin/sh
set -eu
if [ "$2" = query ]; then
  if [ "$#" -eq 3 ]; then
    cat "$MOCK_SPACES"
  else
    jq --argjson index "$5" '.[] | select(.index == $index)' "$MOCK_SPACES"
  fi
elif [ "$2" = space ] && [ "$4" = --destroy ]; then
  jq --argjson index "$3" '[.[] | select(.index != $index) |
    .index = (if .index > $index then .index - 1 else .index end)]' \
    "$MOCK_SPACES" > "$MOCK_SPACES.next"
  mv "$MOCK_SPACES.next" "$MOCK_SPACES"
else
  exit 1
fi
"""


class LimitSpacesTests(unittest.TestCase):
    def run_limiter(self, extras):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            yabai = directory / "yabai"
            yabai.write_text(FAKE_YABAI)
            yabai.chmod(0o755)
            spaces = directory / "spaces.json"
            initial = [
                {"index": index, "windows": [], "is-native-fullscreen": False}
                for index in range(1, 11)
            ]
            spaces.write_text(json.dumps(initial + extras))
            environment = os.environ.copy()
            environment["PATH"] = f"{directory}:{environment['PATH']}"
            environment["MOCK_SPACES"] = str(spaces)
            subprocess.run([str(SCRIPT)], env=environment, check=True)
            return json.loads(spaces.read_text())

    def test_removes_only_empty_regular_spaces_above_ten(self):
        remaining = self.run_limiter([
            {"index": 11, "windows": [], "is-native-fullscreen": False},
            {"index": 12, "windows": [], "is-native-fullscreen": False},
        ])
        self.assertEqual(len(remaining), 10)

    def test_preserves_occupied_and_fullscreen_spaces(self):
        remaining = self.run_limiter([
            {"index": 11, "windows": [42], "is-native-fullscreen": False},
            {"index": 12, "windows": [], "is-native-fullscreen": True},
        ])
        self.assertEqual(len(remaining), 12)


if __name__ == "__main__":
    unittest.main()
