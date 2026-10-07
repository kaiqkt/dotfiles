"""Exercise shell helpers against disposable Git repositories and fake tools."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ShellHelperTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.directory = Path(self.tmp.name)
        self.env = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1',
                        GIT_AUTHOR_NAME='Test', GIT_AUTHOR_EMAIL='test@example.invalid',
                        GIT_COMMITTER_NAME='Test', GIT_COMMITTER_EMAIL='test@example.invalid')
        self.repo = self.directory / 'repo'
        self.git('init', '-b', 'main', str(self.repo), cwd=self.directory)
        (self.repo / 'tracked.txt').write_text('initial\n')
        self.git('add', '.')
        self.git('commit', '-m', 'initial')

    def git(self, *args, cwd=None):
        return subprocess.run(['git', *args], cwd=cwd or self.repo, env=self.env,
                              capture_output=True, text=True, check=True).stdout.strip()

    def zsh(self, code, cwd=None):
        return subprocess.run(['zsh', '-f', '-c', code], cwd=cwd or self.repo,
                              env=self.env, capture_output=True, text=True)

    def worktree_code(self, code):
        return 'compdef() { :; }; docker() { :; }; source "$1"; ' + code

    def worktree(self, code, cwd):
        return subprocess.run(['zsh', '-f', '-c', self.worktree_code(code), '_',
                               str(ROOT / 'zsh/config/worktrees.sh')], cwd=cwd,
                              env=self.env, capture_output=True, text=True)

    def bare_project(self):
        project = self.directory / 'project'
        project.mkdir()
        self.git('clone', '--bare', str(self.repo), str(project / '.bare'))
        return project

    def test_prompt_counts_real_staged_unstaged_and_untracked_changes(self):
        (self.repo / 'staged.txt').write_text('new')
        self.git('add', 'staged.txt')
        (self.repo / 'tracked.txt').write_text('changed')
        (self.repo / 'untracked.txt').write_text('new')
        result = self.zsh(f'source "{ROOT}/zsh/user/prompt.sh"; _prompt_async_worker')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.split('\t')[0], 'main +1 !1 ?1')

    def test_prompt_counts_ahead_and_behind(self):
        initial = self.git('rev-parse', 'HEAD')
        tree = self.git('rev-parse', 'HEAD^{tree}')
        upstream = self.git('commit-tree', tree, '-p', initial, '-m', 'upstream')
        self.git('update-ref', 'refs/remotes/origin/main', upstream)
        self.git('config', 'remote.origin.url', str(self.repo))
        self.git('config', 'remote.origin.fetch', '+refs/heads/*:refs/remotes/origin/*')
        self.git('branch', '--set-upstream-to=origin/main', 'main')
        self.git('commit', '--allow-empty', '-m', 'local')
        result = self.zsh(f'source "{ROOT}/zsh/user/prompt.sh"; _prompt_async_worker')
        self.assertEqual(result.stdout.split('\t')[0], 'main ⇡1 ⇣1')

    def test_worktree_create_uses_main_and_unique_ports(self):
        project = self.bare_project()
        result = self.worktree('wt:create feature', project)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((project / 'feature/.git').is_file())
        first = (project / 'feature/.env').read_text()
        result = self.worktree('wt:create second', project)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('APP_PORT=3000', first)
        self.assertIn('APP_PORT=3001', (project / 'second/.env').read_text())

    def test_worktree_refuses_dirty_removal_and_force_removes_it(self):
        project = self.bare_project()
        self.git('-C', str(project / '.bare'), 'worktree', 'add', '-b', 'feature',
                 str(project / 'feature'), 'main')
        important = project / 'feature/unsaved.txt'
        important.write_text('keep this')
        result = self.worktree('_wt:destroy "$PWD/feature" feature false', project)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(important.read_text(), 'keep this')
        result = self.worktree('wt:remove feature --force', project)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((project / 'feature').exists())
        self.assertNotIn('feature', self.git('-C', str(project / '.bare'), 'branch'))

    def test_worktree_init_does_not_continue_after_failed_clone(self):
        result = self.worktree('wt:init /nonexistent/dotfiles-test-remote failed', self.directory)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.directory / 'failed/.bare').exists())

    def test_git_multi_reports_invalid_arguments_and_accepts_help(self):
        for args, expected in [(('--help',), 0), (('--bogus',), 2), (('-u',), 2)]:
            result = subprocess.run([str(ROOT / 'scripts/git-multi'), *args],
                                    cwd=self.repo, env=self.env, capture_output=True)
            self.assertEqual(result.returncode, expected)

    def test_git_multi_infers_origin_without_git_suffix(self):
        self.git('remote', 'add', 'origin', 'https://github.com/example/repository')
        result = subprocess.run([str(ROOT / 'scripts/git-multi'), '-u', 'example'],
                                cwd=self.repo, env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git('remote', 'get-url', 'origin'),
                         'git@codeberg.org:example/repository.git')
        self.assertEqual(len(self.git('config', '--get-all', 'remote.origin.pushurl').splitlines()), 2)

    def test_fuzzy_edit_preserves_spaces_and_shell_ifs(self):
        result = self.zsh(f'''
source "{ROOT}/zsh/config/fzf.sh"
fd() {{ printf '%s\\n' 'a file.txt' 'another file.txt'; }}
fzf() {{ cat; }}
test_editor() {{ printf '<%s>' "$@"; }}
EDITOR=test_editor
original_ifs=$IFS
fe ''
[[ $IFS == $original_ifs ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, '<a file.txt><another file.txt>')

    def test_pane_switch_keeps_multi_digit_pane_ids(self):
        tools = self.directory / 'tools'
        tools.mkdir()
        calls = self.directory / 'calls.jsonl'
        mock = tools / 'tmux'
        mock.write_text('''#!/usr/bin/env python3
import json, os, sys
with open(os.environ['TEST_CALLS'], 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1] == 'list-panes':
    print('%1 1:1 - current')
    print('%12 1:10 - /path-with-dashes nvim')
elif sys.argv[1] == 'display-message':
    print('%1')
''')
        mock.chmod(0o755)
        fzf = tools / 'fzf'
        fzf.write_text('#!/bin/sh\ncat\n')
        fzf.chmod(0o755)
        env = dict(self.env, PATH=str(tools) + ':' + self.env['PATH'], TEST_CALLS=str(calls))
        result = subprocess.run([str(ROOT / 'tmux/scripts/fzf-switch-pane.sh')],
                                cwd=self.directory, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        commands = [json.loads(line) for line in calls.read_text().splitlines()]
        self.assertIn(['select-pane', '-t', '%12'], commands)
        self.assertIn(['select-window', '-t', '%12'], commands)

    def test_popup_result_preserves_path_and_targets_calling_pane(self):
        tools = self.directory / 'bin'
        tools.mkdir()
        calls = self.directory / 'calls.jsonl'
        tmux = tools / 'tmux'
        tmux.write_text('''#!/usr/bin/env python3
import json, os, sys
with open(os.environ['TEST_CALLS'], 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1] == 'display-message':
    print('@7' if sys.argv[-1] == '#{window_id}' else '%4')
''')
        tmux.chmod(0o755)
        child = tools / 'select-file'
        child.write_text('''#!/usr/bin/env python3
import os
with open(os.environ['TMUX_FZF_RESULT_FILE'], 'wb') as f:
    f.write(os.environ['TEST_FILENAME'].encode() + b'\\0')
''')
        child.chmod(0o755)
        filename = "space ' quote; $(touch unexpected).txt"
        editor = tools / 'editor'
        editor.write_text('''#!/usr/bin/env python3
import json, os, sys
with open(os.environ['TEST_EDITOR_ARGS'], 'w') as f:
    json.dump(sys.argv[1:], f)
''')
        editor.chmod(0o755)
        env = dict(self.env, PATH=str(tools) + ':' + self.env['PATH'], TMUX_PANE='%4',
                   TMPDIR=str(self.directory), TEST_CALLS=str(calls), TEST_FILENAME=filename,
                   EDITOR=str(editor), TEST_EDITOR_ARGS=str(self.directory / 'editor.json'))
        result = subprocess.run([str(ROOT / 'tmux/scripts/fzf-popup.sh'), str(child)],
                                cwd=self.directory, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        commands = [json.loads(line) for line in calls.read_text().splitlines()]
        send = next(c for c in commands if c[:4] == ['send-keys', '-t', '%4', '-l'])
        subprocess.run(['zsh', '-f', '-c', send[-1]], cwd=self.directory, env=env, check=True)
        self.assertEqual(json.loads((self.directory / 'editor.json').read_text()),
                         [str(self.directory.resolve() / filename)])
        self.assertFalse((self.directory / 'unexpected').exists())
        self.assertEqual(list(self.directory.glob('tmux-fzf.*')), [])
        self.assertTrue(any(c[:3] == ['set', '-t', '@7'] for c in commands))


if __name__ == '__main__':
    unittest.main()
