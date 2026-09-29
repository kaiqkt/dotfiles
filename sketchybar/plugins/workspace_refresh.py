#!/usr/bin/python3
"""Coalesce workspace events and serialize refreshes with a kernel-owned lock."""
import fcntl
import os
from pathlib import Path
import signal
import subprocess
import time


def main():
    cache = Path(os.environ.get('XDG_CACHE_HOME', Path.home() / '.cache'))
    state = cache / 'sketchybar' / 'workspaces'
    state.mkdir(parents=True, exist_ok=True)
    pending = state / 'pending'
    pending.touch()
    worker = Path(os.environ['CONFIG_DIR']) / 'plugins/yabai_workspace_main.sh'
    with (state / 'lock').open('a') as lock:
        while True:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return
            # Events in this interval are covered by the upcoming fresh query.
            time.sleep(0.2)
            pending.unlink(missing_ok=True)
            process = subprocess.Popen(['bash', str(worker)], start_new_session=True)
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
            finally:
                fcntl.flock(lock, fcntl.LOCK_UN)
            # Check after unlocking: an arrival either owns the lock itself or
            # leaves a pending marker for us. Events during a query aren't lost.
            if not pending.exists():
                return


if __name__ == '__main__':
    main()
