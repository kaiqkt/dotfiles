"""Exercise real concurrent event processes and events received during a query."""
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

WRAPPER = Path(__file__).resolve().parents[1] / 'sketchybar/plugins/workspace_refresh.py'


class WorkspaceRefreshTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        plugins = self.root / 'plugins'
        plugins.mkdir()
        (plugins / 'yabai_workspace_main.sh').write_text('''#!/bin/bash
cd "$CONFIG_DIR"
mkdir running 2>/dev/null || { echo overlap >> errors; exit 1; }
echo start >> calls
cat value >> observed
sleep 0.3
rmdir running
''')
        (self.root / 'value').write_text('before\n')
        self.env = dict(os.environ, CONFIG_DIR=str(self.root),
                        XDG_CACHE_HOME=str(self.root / 'cache'))
        self.processes = []
        self.addCleanup(self.cleanup)

    def cleanup(self):
        for process in self.processes:
            if process.poll() is None:
                process.kill()
            process.wait()

    def start(self):
        process = subprocess.Popen([str(WRAPPER)], env=self.env)
        self.processes.append(process)
        return process

    def finish(self):
        for process in self.processes:
            self.assertEqual(process.wait(timeout=10), 0)
        self.assertFalse((self.root / 'errors').exists())

    def test_burst_is_coalesced_without_concurrent_workers(self):
        for _ in range(16):
            self.start()
        self.finish()
        calls = (self.root / 'calls').read_text().splitlines()
        self.assertLessEqual(len(calls), 3)
        self.assertGreaterEqual(len(calls), 1)

    def test_event_during_query_gets_a_followup_and_lock_is_reusable(self):
        self.start()
        deadline = time.monotonic() + 5
        while not (self.root / 'observed').exists():
            self.assertLess(time.monotonic(), deadline)
            time.sleep(0.01)
        (self.root / 'value').write_text('after\n')
        self.start()
        self.finish()
        self.assertEqual((self.root / 'observed').read_text(), 'before\nafter\n')
        self.start()
        self.finish()
        self.assertEqual((self.root / 'observed').read_text(), 'before\nafter\nafter\n')


if __name__ == '__main__':
    unittest.main()
