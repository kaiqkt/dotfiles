"""Verify SketchyBar profile selection persists and rejects unknown profiles."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


CONFIG = Path(__file__).resolve().parents[1] / "sketchybar"


class SketchybarProfilesTests(unittest.TestCase):
    def test_switches_profiles_without_changing_config_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "config"
            bars = config / "bars"
            bars.mkdir(parents=True)
            for filename in ("sketchybarrc", "select-bar"):
                shutil.copy2(CONFIG / filename, config / filename)
            for filename in ("colors.sh", "fonts.sh"):
                (config / filename).write_text("")
            for name in ("edge", "floating"):
                (bars / f"{name}.sh").write_text(
                    f'printf "%s\\n" "{name}" >> "$MOCK_LOG"\n'
                )
            fake_sketchybar = root / "sketchybar"
            fake_sketchybar.write_text(
                '#!/bin/sh\nprintf "reload:%s\\n" "$*" >> "$MOCK_LOG"\n'
            )
            fake_sketchybar.chmod(0o755)
            log = root / "calls.log"
            environment = os.environ.copy()
            environment.update({
                "HOME": str(root),
                "CONFIG_DIR": str(config),
                "MOCK_LOG": str(log),
                "PATH": f"{root}:{environment['PATH']}",
            })

            def run(*arguments, check=True):
                return subprocess.run(arguments, env=environment, check=check,
                                      capture_output=True, text=True)

            self.assertIn("* edge", run(str(config / "select-bar")).stdout)
            run(str(config / "sketchybarrc"))
            self.assertEqual(log.read_text(), "edge\n")

            run(str(config / "select-bar"), "floating")
            self.assertEqual(
                (root / ".local/state/sketchybar/active-bar").read_text(),
                "floating\n",
            )
            run(str(config / "sketchybarrc"))
            self.assertIn("floating\n", log.read_text())
            self.assertIn("reload:--reload", log.read_text())

            rejected = run(str(config / "select-bar"), "missing", check=False)
            self.assertNotEqual(rejected.returncode, 0)
            traversal = run(str(config / "select-bar"), "../edge", check=False)
            self.assertNotEqual(traversal.returncode, 0)
            self.assertEqual(run(str(config / "select-bar"), "current").stdout,
                             "floating\n")

    def test_empty_visible_spaces_are_highlighted(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            yabai = root / "yabai"
            yabai.write_text(
                '#!/bin/sh\n'
                'if [ "$3" = "--spaces" ]; then\n'
                '  case ",$VISIBLE_SPACES," in\n'
                '    *",$5,"*) printf \'{"is-visible":true}\\n\' ;;\n'
                '    *) printf \'{"is-visible":false}\\n\' ;;\n'
                '  esac\n'
                'else\n'
                '  printf \'[]\\n\'\n'
                'fi\n'
            )
            yabai.chmod(0o755)
            sketchybar = root / "sketchybar"
            sketchybar.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$MOCK_LOG"\n')
            sketchybar.chmod(0o755)
            log = root / "calls.log"
            environment = os.environ.copy()
            environment.update({
                "CONFIG_DIR": str(CONFIG),
                "VISIBLE_SPACES": "5,8",
                "MOCK_LOG": str(log),
                "PATH": f"{root}:{environment['PATH']}",
            })
            plugin = CONFIG / "plugins/yabai_workspace.sh"
            for index, expected in ((5, "on"), (8, "on"), (4, "off")):
                environment["NAME"] = f"space.{index}"
                subprocess.run([str(plugin), str(index)], env=environment,
                               check=True)
                calls = log.read_text().splitlines()
                self.assertIn(f"background.drawing={expected}", calls[-2])


if __name__ == "__main__":
    unittest.main()
