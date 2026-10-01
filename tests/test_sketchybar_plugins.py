"""Regression checks for widget failures, metadata, and recovery."""
import json
import os
import shlex
from pathlib import Path
import subprocess
import tempfile
import unittest

CONFIG = Path(__file__).resolve().parents[1] / 'sketchybar'


class WidgetTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.env = dict(os.environ, CONFIG_DIR=str(CONFIG), NAME='music',
                        XDG_CACHE_HOME=str(self.root), MOCK_LOG=str(self.root / 'log'),
                        MOCK_SPOTIFY=json.dumps({}), MOCK_STATE='stop', MOCK_SONG='{}',
                        MOCK_DISPLAYS='[]', MOCK_CURL='ok', MOCK_SIPS='ok')

    def run_plugin(self, plugin, mocks='', args=''):
        wrapper = '''
sketchybar() { printf '%s\\n' "$*" >> "$MOCK_LOG"; }
yabai() { printf '%s\\n' "$MOCK_DISPLAYS"; }
osascript() { cat >/dev/null; printf '%s\\n' "$MOCK_SPOTIFY"; }
rmpc() {
  if [ "$1" = status ]; then printf '{"state":"%s"}\\n' "$MOCK_STATE";
  else printf '%s\\n' "$MOCK_SONG"; echo SONG_QUERY >> "$MOCK_LOG"; fi
}
curl() {
  printf 'DOWNLOAD %s\\n' "$*" >> "$MOCK_LOG"
  [ "$MOCK_CURL" = ok ] || return 22
  while [ "$1" != -o ]; do shift; done
  printf 'image' > "$2"
}
sips() { [ "$MOCK_SIPS" = ok ]; }
''' + mocks + f'\nsource "$CONFIG_DIR/plugins/{plugin}.sh" {args}\n'
        subprocess.run(['bash', '-c', wrapper], env=self.env, check=True,
                       capture_output=True, text=True)
        log = self.root / 'log'
        return log.read_text() if log.exists() else ''

    def spotify(self, title='Same', url='https://example.invalid/a', state='playing'):
        self.env['MOCK_SPOTIFY'] = json.dumps(dict(state=state, title=title,
                                                  artist='Artist', artwork=url))

    def test_cpu_includes_system_usage(self):
        calls = self.run_plugin('cpu_usage', '''
top() { printf 'CPU usage: 5.0%% user, 85.0%% sys, 10.0%% idle\\n'; }
''')
        self.assertIn('label=90%', calls)
        self.assertIn('--push cpu_usage .900', calls)

    def test_muted_and_zero_or_invalid_scroll(self):
        self.env.update(NAME='volume', SENDER='volume_change')
        calls = self.run_plugin('volume', 'osascript() { echo "65|true"; }')
        self.assertIn('icon=􀊣', calls)
        self.assertIn('slider.percentage=65', calls)
        for delta in ('0', '', 'bad'):
            (self.root / 'log').write_text('')
            self.env.update(SENDER='mouse.scrolled', SCROLL_DELTA=delta)
            calls = self.run_plugin('volume', 'osascript() { echo WRITE >> "$MOCK_LOG"; }')
            self.assertEqual(calls, '')

    def test_missing_mpd_metadata_falls_back_and_reads_song_once(self):
        self.spotify(url='', state='paused')
        self.env.update(MOCK_STATE='play', MOCK_SONG='{"metadata":{}}')
        calls = self.run_plugin('music', args='compact')
        self.assertNotIn('null', calls)
        self.assertIn('label=Same — Artist', calls)
        self.assertEqual(calls.count('SONG_QUERY'), 1)

    def test_mpd_clears_spotify_click(self):
        self.env.update(MOCK_STATE='play', MOCK_SONG='{"metadata":{"title":"MPD","artist":"Artist"}}')
        calls = self.run_plugin('music', args='compact')
        self.assertIn('--set music click_script=\n', calls)
        self.assertIn('music.toggle drawing=off', calls)

    def test_pipe_in_metadata_and_artwork_cache_key(self):
        self.spotify(title='A|B')
        first = self.run_plugin('music', args='compact')
        self.assertIn('label=A|B — Artist', first)
        self.assertLess(first.index('label=A|B'), first.index('DOWNLOAD'))
        self.assertIn('--max-time 5', first)
        self.run_plugin('music', args='compact')
        self.spotify(title='A|B', url='https://example.invalid/b')
        all_calls = self.run_plugin('music', args='compact')
        self.assertEqual(all_calls.count('DOWNLOAD'), 2)
        self.assertEqual(len(list((self.root / 'sketchybar/artwork').glob('*.jpg'))), 2)

    def test_failed_download_or_invalid_image_is_not_cached(self):
        self.spotify()
        for curl, sips in (('fail', 'ok'), ('ok', 'fail')):
            self.env.update(MOCK_CURL=curl, MOCK_SIPS=sips)
            calls = self.run_plugin('music', args='compact')
            self.assertIn('label=Same — Artist', calls)
            self.assertNotIn('background.image=', calls)
            self.assertEqual(list((self.root / 'sketchybar/artwork').iterdir()), [])

    def test_narrow_display_keeps_controls_and_omits_artwork(self):
        self.spotify(title='Long title to truncate')
        self.env['MOCK_DISPLAYS'] = json.dumps([dict(frame=dict(w=1280), spaces=list(range(9)))])
        calls = self.run_plugin('music', args='compact')
        self.assertNotIn('DOWNLOAD', calls)
        self.assertIn('music.next drawing=on', calls)
        label = calls.split('label=')[1].split(' label.drawing=')[0]
        self.assertLessEqual(len(label), 5)

    def test_weather_failure_replaces_old_temperature(self):
        self.env.update(NAME='weather', MOCK_CURL='fail')
        calls = self.run_plugin('weather')
        self.assertIn('label=—', calls)

    def test_space_recovery_and_transient_query_failure(self):
        mocks = '''
yabai() { echo '[{"id":1,"index":1,"is-visible":true}]'; }
sketchybar() {
  if [ "$1" = --query ]; then echo '{"items":[]}';
  else printf '%s\\n' "$*" >> "$MOCK_LOG"; fi
}
'''
        calls = self.run_plugin('yabai_workspace_main', mocks)
        self.assertNotIn('--reload', calls)
        self.assertIn('--add item space.1', calls)
        self.assertIn('--move space.1 before spaces.controller', calls)
        (self.root / 'log').write_text('')
        calls = self.run_plugin('yabai_workspace_main', 'yabai() { return 1; }')
        self.assertEqual(calls, '')

    def test_fullscreen_topology_changes_without_reloading_widgets(self):
        normal = [dict(id=10, index=1, display=1),
                  dict(id=20, index=2, display=2)]
        fullscreen = [normal[0], dict(id=30, index=2, display=1,
                                    **{'is-native-fullscreen': True}),
                      dict(id=20, index=3, display=2)]
        moved = [dict(id=10, index=1, display=2), normal[1]]
        renumbered = [normal[0], dict(id=20, index=3, display=2)]
        mocks = '''
yabai() {
  if [ "$3" = --spaces ]; then echo "$MOCK_SPACES"; else echo '[]'; fi
}
sketchybar() {
  if [ "$1" = --query ]; then
    if [ "$2" = bar ]; then echo "$MOCK_BAR"; else echo "$MOCK_CONTROLLER"; fi
  else printf '%s\\n' "$*" >> "$MOCK_LOG"; fi
}
'''
        for before, after in ((normal, fullscreen), (fullscreen, normal),
                              (normal, moved), (normal, normal), (normal, renumbered)):
            with self.subTest(before=before, after=after):
                (self.root / 'log').write_text('')
                signature = json.dumps([[s['id'], s['display']]
                                        for s in before], separators=(',', ':'))
                self.env.update(
                    MOCK_SPACES=json.dumps(after),
                    MOCK_BAR=json.dumps({'items': ['music.previous', 'music.toggle', 'music.next'] +
                                        [f"space.{s['id']}" for s in before] +
                                        ['spaces.controller', 'music_art', 'music']}),
                    MOCK_CONTROLLER=json.dumps({'label': {'value': signature}}))
                calls = self.run_plugin('yabai_workspace_main', mocks)
                self.assertNotIn('--reload', calls)
                self.assertNotIn('--remove music', calls)
                order = shlex.split(calls.split('--reorder ')[1])
                self.assertEqual(order, [f"space.{s['id']}" for s in after] +
                                 ['spaces.controller', 'music_art', 'music',
                                  'music.previous', 'music.toggle', 'music.next'])
                if before == after or after == renumbered:
                    self.assertNotIn('--add', calls)
                else:
                    for space in after:
                        self.assertIn(f"--set space.{space['id']} display={space['display']}", calls)
                        self.assertIn(f"/scripts/select-space id:{space['id']}", calls)
                    self.assertEqual(calls.count('--remove'), 2)

    def test_workspace_cleanup_matches_native_basic_regex(self):
        calls = self.run_plugin('yabai_workspace_main', '''
yabai() { echo '[{"id":1,"index":1,"display":1}]'; }
sketchybar() {
  if [ "$1" = --query ]; then echo '{"items":["space.1","space.10"]}';
  else printf '%s\\n' "$*" >> "$MOCK_LOG"; fi
}
''')
        args = shlex.split(calls)
        patterns = [args[i + 1][1:-1] for i, arg in enumerate(args)
                    if arg == '--remove']
        names = ['space.1', 'space.10', 'spaces.group.1', 'spaces.group.12',
                 'spaces.controller', 'music', 'music.group']
        removed = set()
        for pattern in patterns:
            # grep defaults to POSIX BRE, as does SketchyBar's regcomp(..., 0).
            result = subprocess.run(['grep', pattern], input='\n'.join(names),
                                    capture_output=True, text=True, check=True)
            removed.update(result.stdout.splitlines())
        self.assertEqual(removed, set(names[:4]))

    def test_empty_bar_reply_does_not_rebuild_or_reload(self):
        calls = self.run_plugin('yabai_workspace_main', '''
yabai() { echo '[{"id":1,"index":1,"display":1}]'; }
sketchybar() {
  if [ "$1" != --query ]; then printf '%s\\n' "$*" >> "$MOCK_LOG"; fi
}
''')
        self.assertEqual(calls, '')


if __name__ == '__main__':
    unittest.main()
