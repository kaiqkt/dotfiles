"""Fullscreen must not redirect desktop shortcuts or move existing windows."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[1] / 'yabai/scripts'
FAKE_YABAI = '''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
root = Path(os.environ['MOCK_ROOT'])
with (root / 'calls').open('a') as log:
    log.write(json.dumps(args) + '\\n')
spaces = json.loads((root / 'spaces').read_text())
rules = json.loads((root / 'rules').read_text())
if args[1:3] == ['query', '--spaces']:
    if '--display' in args:
        spaces = [s for s in spaces if s['display'] == int(args[-1])]
    print(json.dumps(spaces))
elif args[1:3] == ['query', '--displays']:
    print('[{"index":1},{"index":2}]')
elif args[1:3] == ['rule', '--list']:
    print(json.dumps(rules))
elif args[1:3] == ['rule', '--remove']:
    rules = [r for r in rules if r['label'] != args[3]]
elif args[1:3] == ['rule', '--add']:
    rule = dict(a.split('=', 1) for a in args[3:])
    rule['space'] = int(rule['space'])
    rules.append(rule)
elif args[1:3] == ['rule', '--apply']:
    sys.exit('Unexpected movement of existing windows')
elif args[1] == 'space' and ('--create' in args or '--display' in args):
    sys.exit('Unexpected desktop creation/movement')
(root / 'rules').write_text(json.dumps(rules))
'''


class YabaiWorkspaceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / 'rules').write_text('[]')
        for name, content in [('yabai', FAKE_YABAI), ('sketchybar', '#!/bin/sh\nexit 0\n')]:
            script = self.root / name
            script.write_text(content)
            script.chmod(0o755)
        config = self.root / '.config/yabai'
        config.mkdir(parents=True)
        (config / 'scripts').symlink_to(SCRIPTS)
        self.env = dict(os.environ, HOME=str(self.root), MOCK_ROOT=str(self.root),
                        PATH=f"{self.root}:{os.environ['PATH']}")
        self.normal = [dict(id=n * 10, index=n, display=1 if n <= 5 else 2,
                            **{'is-native-fullscreen': False}) for n in range(1, 10)]

    def spaces(self, fullscreen):
        spaces = [dict(s) for s in self.normal]
        if fullscreen:
            spaces.insert(1, dict(id=999, display=1, **{'is-native-fullscreen': True}))
        for index, space in enumerate(spaces, 1):
            space['index'] = index
        (self.root / 'spaces').write_text(json.dumps(spaces))

    def run_script(self, name, *args):
        (self.root / 'calls').write_text('')
        subprocess.run([str(SCRIPTS / name), *args], env=self.env, check=True)
        return [json.loads(line) for line in (self.root / 'calls').read_text().splitlines()]

    def test_rules_follow_regular_desktops_through_fullscreen_cycle(self):
        for fullscreen in (False, True, True, False):
            self.spaces(fullscreen)
            calls = self.run_script('sync-rules')
            rules = json.loads((self.root / 'rules').read_text())
            self.assertEqual({r['label']: r['space'] for r in rules}, {
                'dotfiles_browsers': 1, 'dotfiles_terminals': 2 + fullscreen,
                'dotfiles_claude': 8 + fullscreen, 'dotfiles_spotify': 9 + fullscreen,
            })
            self.assertFalse(any('--apply' in c or c[1] == 'window' for c in calls))

    def test_shortcuts_skip_fullscreen_and_bar_clicks_resolve_id(self):
        for fullscreen in (False, True, False):
            self.spaces(fullscreen)
            for target in ('2', 'id:20'):
                calls = self.run_script('select-space', target, '--move')
                self.assertEqual(calls[-2:], [
                    ['-m', 'window', '--space', str(2 + fullscreen)],
                    ['-m', 'space', '--focus', str(2 + fullscreen)],
                ])
        self.spaces(True)
        self.assertEqual(self.run_script('select-space', 'id:999')[-1],
                         ['-m', 'space', '--focus', '2'])

    def test_setup_counts_only_regular_desktops(self):
        self.spaces(True)
        self.run_script('setup-spaces')


if __name__ == '__main__':
    unittest.main()
