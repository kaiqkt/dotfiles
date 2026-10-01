"""Verify the main SketchyBar profile and its space icons."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


CONFIG = Path(__file__).resolve().parents[1] / "sketchybar"


class SketchybarProfilesTests(unittest.TestCase):
    def test_main_is_default_and_removed_profiles_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "config"
            bars = config / "bars"
            bars.mkdir(parents=True)
            for filename in ("sketchybarrc", "select-bar"):
                shutil.copy2(CONFIG / filename, config / filename)
            for filename in ("colors.sh", "fonts.sh"):
                (config / filename).write_text("")
            for name in ("main",):
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

            self.assertEqual(run(str(config / "select-bar")).stdout, "* main\n")
            run(str(config / "sketchybarrc"))
            self.assertEqual(log.read_text(), "main\n")

            run(str(config / "select-bar"), "main")
            self.assertEqual(
                (root / ".local/state/sketchybar/active-bar").read_text(),
                "main\n",
            )
            run(str(config / "sketchybarrc"))
            self.assertIn("main\n", log.read_text())
            self.assertIn("reload:--reload", log.read_text())

            for removed in ("edge", "floating", "floating-custom"):
                rejected = run(str(config / "select-bar"), removed, check=False)
                self.assertNotEqual(rejected.returncode, 0)
            traversal = run(str(config / "select-bar"), "../main", check=False)
            self.assertNotEqual(traversal.returncode, 0)
            self.assertEqual(run(str(config / "select-bar"), "current").stdout,
                             "main\n")

            (root / ".local/state/sketchybar/active-bar").write_text("edge\n")
            self.assertEqual(run(str(config / "select-bar"), "current").stdout,
                             "main\n")
            run(str(config / "sketchybarrc"))
            self.assertTrue(log.read_text().endswith("main\n"))

    def test_main_shows_one_app_or_empty_dot(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            yabai = root / "yabai"
            yabai.write_text(
                '#!/bin/sh\n'
                'case "$3" in\n'
                '  --spaces) printf \'[{"id":2,"index":2,"display":1,"is-visible":%s}]\\n\' "$MOCK_VISIBLE" ;;\n'
                '  --windows) printf \'%s\\n\' "$MOCK_WINDOWS" ;;\n'
                'esac\n'
            )
            yabai.chmod(0o755)
            sketchybar = root / "sketchybar"
            sketchybar.write_text('#!/bin/sh\nif [ "$1" = --query ]; then echo \'{"items":["space.2"]}\'; else printf "%s\\n" "$*" >> "$MOCK_LOG"; fi\n')
            sketchybar.chmod(0o755)
            log = root / "calls.log"
            environment = os.environ.copy()
            environment.update({
                "CONFIG_DIR": str(CONFIG),
                "MOCK_LOG": str(log),
                "NAME": "space.2",
                "PATH": f"{root}:{environment['PATH']}",
            })
            plugin = CONFIG / "plugins/yabai_workspace_main.sh"

            environment.update({
                "MOCK_VISIBLE": "true",
                "MOCK_WINDOWS": '[{"space":2,"app":"Safari","has-focus":false},'
                                '{"space":2,"app":"Code","has-focus":true}]',
            })
            subprocess.run([str(plugin), "2"], env=environment, check=True)
            active = log.read_text()
            self.assertIn("background.drawing=on", active)
            self.assertIn("label=:code:", active)
            self.assertNotIn(":safari:", active)

            environment.update({"MOCK_VISIBLE": "false", "MOCK_WINDOWS": "[]"})
            subprocess.run([str(plugin), "2"], env=environment, check=True)
            empty = log.read_text().splitlines()[-1]
            self.assertIn("background.drawing=off", empty)
            self.assertIn("label=●", empty)


if __name__ == "__main__":
    unittest.main()
