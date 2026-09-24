"""Palette regressions using the real Matugen binary and wallpaper fixtures."""

import colorsys
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
THEME = runpy.run_path(str(ROOT / "scripts/generate-wallpaper-theme"))


class WallpaperThemeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.palettes = {}
        for image in sorted((ROOT / "wallpaper").iterdir()):
            if image.suffix in (".png", ".jpg"):
                cls.palettes[image.name] = THEME["build_scheme"](THEME["matugen_colors"](image))

    def test_wallpapers_keep_neutral_readable_text_and_distinct_semantics(self):
        for name, bases in self.palettes.items():
            with self.subTest(wallpaper=name):
                self.assertEqual(len(bases), 16)
                THEME["validate_scheme"](bases)
                text = [int(bases[5][i:i + 2], 16) for i in (0, 2, 4)]
                self.assertLessEqual(max(text) - min(text), 24)
                self.assertGreaterEqual(min(text), 210)
                self.assertEqual(len(set(bases[:8])), 8)
                self.assertEqual(len(set(bases[8:15])), 7)
                for color, target in zip(bases[8:15], (0, 30, 55, 120, 185, 220, 285)):
                    rgb = [int(color[i:i + 2], 16) / 255 for i in (0, 2, 4)]
                    hue = colorsys.rgb_to_hsv(*rgb)[0] * 360
                    self.assertLess(abs((hue - target + 180) % 360 - 180), 50)

    def test_wallpaper_changes_accent_without_large_text_changes(self):
        rei = self.palettes["rei-plush-wallpaper.png"]
        eva = self.palettes["eva-red-wallpaper.jpg"]
        self.assertNotEqual(rei[15], eva[15])
        self.assertLess(abs(THEME["luminance"](rei[5]) - THEME["luminance"](eva[5])), 0.05)

    def test_monochrome_images_have_distinct_surfaces(self):
        with tempfile.TemporaryDirectory() as directory:
            for value in (0, 128, 255):
                with self.subTest(value=value):
                    image = Path(directory) / "single color.ppm"
                    image.write_bytes(b"P6\n8 8\n255\n" + bytes([value, value, value]) * 64)
                    bases = THEME["build_scheme"](THEME["matugen_colors"](image))
                    self.assertEqual(len(set(bases[:8])), 8)

    def test_invalid_or_low_contrast_palette_is_rejected(self):
        with self.assertRaisesRegex(RuntimeError, "Unexpected Matugen"):
            THEME["build_scheme"]({"colors": {}})
        with self.assertRaisesRegex(RuntimeError, "Insufficient contrast"):
            THEME["validate_scheme"](["222222"] * 16)

    def test_failed_write_preserves_previous_scheme(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "wallpaper.yaml"
            path.write_text("previous palette")
            with patch("os.replace", side_effect=OSError("simulated failure")):
                with self.assertRaises(OSError):
                    THEME["write_scheme"](path, "replacement palette")
            self.assertEqual(path.read_text(), "previous palette")
            self.assertEqual(list(Path(directory).iterdir()), [path])

    def test_all_flavours_templates_render_with_each_palette(self):
        with tempfile.TemporaryDirectory() as directory:
            scheme = Path(directory) / "wallpaper.yaml"
            for name, bases in self.palettes.items():
                scheme.write_text(THEME["scheme_yaml"](bases))
                for template in sorted((ROOT / "flavours/templates").glob("*/templates/default.mustache")):
                    with self.subTest(wallpaper=name, template=template.parent.parent.name):
                        rendered = subprocess.run(
                            ["flavours", "build", str(scheme), str(template)],
                            capture_output=True, text=True, check=True,
                        ).stdout
                        self.assertNotIn("{{", rendered)
                        self.assertTrue(rendered.strip())


if __name__ == "__main__":
    unittest.main()
