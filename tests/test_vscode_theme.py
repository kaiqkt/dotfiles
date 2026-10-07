"""Ensure wallpaper updates produce valid ANSI keys and keep user preferences."""

import json
from pathlib import Path
import runpy
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class VSCodeThemeTests(unittest.TestCase):
    def test_update_preserves_color_overrides_and_uses_named_ansi_colors(self):
        script = runpy.run_path(str(ROOT / 'scripts/apply-vscode-theme'))
        with tempfile.TemporaryDirectory() as directory:
            settings = Path(directory) / 'settings.json'
            theme_file = Path(directory) / 'theme.json'
            preferences = {
                'editor.fontSize': 17,
                'workbench.colorCustomizations': {'editor.background': '#123456'},
                'editor.tokenColorCustomizations': {'comments': '#654321'},
                'editor.semanticTokenColorCustomizations': {'enabled': False},
            }
            settings.write_text(json.dumps(preferences))
            script['main'].__globals__.update(SETTINGS=settings, THEME_FILE=theme_file)
            script['main']()
            updated = json.loads(settings.read_text())
            for key, value in preferences.items():
                self.assertEqual(updated[key], value)
            self.assertEqual(updated['workbench.colorTheme'], 'Wallpaper (Matugen)')
            theme = json.loads(theme_file.read_text())
            ansi = {key for key in theme['colors'] if key.startswith('terminal.ansi')}
            names = ('Black', 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan', 'White')
            expected = {f'terminal.ansi{bright}{name}' for bright in ('', 'Bright') for name in names}
            self.assertEqual(ansi, expected)


if __name__ == '__main__':
    unittest.main()
