# Git Worktrees (`wt:*`)

Shell helpers in `zsh/config/worktrees.sh` for managing git worktrees off a bare repo.

## Layout

```
ProjectName/
  .bare/          # bare clone (git internals)
  branch-name/    # worktree (folder usually matches branch name)
```

Most commands must run from the project root (the dir containing `.bare/`).
`wt:list`, `wt:info`, `wt:update` and `wt:config` also work from inside any worktree.

## Commands

| Command                                  | Description                                                                          |
| ---------------------------------------- | ------------------------------------------------------------------------------------ |
| `wt:init <remote-url> [folder]`          | Clone repo as bare into `<folder>/.bare` and `cd` into it                            |
| `wt:add <branch>`                        | Check out existing remote branch as worktree                                         |
| `wt:create <branch> [base]`              | Create new branch + worktree from `base` (arg > `wt:config defaultBase` > `master`)  |
| `wt:list`                                | List worktree branch names, one per line                                             |
| `wt:info`                                | Table: git dirty, docker status, ports, hash, last commit, ahead/behind master       |
| `wt:update`                              | `git fetch --all --prune` into `.bare`                                               |
| `wt:rename <old> <new>`                  | Rename worktree directory + branch (fixes submodule paths)                           |
| `wt:remove <branch-or-path> [--force]`   | Stop containers, remove worktree, prune refs, delete branch (confirms unless force)  |
| `wt:cleanup`                             | Interactive per-row prompt — `y` delete, `f` force-delete, anything else skip        |
| `wt:config [<key> [<value>\|--unset]]`   | Read/write `wt.*` config on the bare repo                                            |
| `wt:help`                                | Show full inline help                                                                |

## Post-create automation

After `wt:add` and `wt:create`, the new worktree gets:

1. Submodules initialised (`git submodule update --init --recursive`)
2. `.env` written with unique `APP_PORT` / `DB_PORT` / `REDIS_PORT` — offsets pick the first triplet not used by any sibling worktree. Defaults read from `.env.example` (fallback 3000/3306/6379).
3. `./.wt-postcreate` executed if present and executable — bootstrap secrets, copy templates, run installers.

### `.wt-postcreate` example (Rails master.key)

```bash
#!/usr/bin/env bash
set -euo pipefail
key="${WT_MASTER_KEY_DEMOSYSTEM:-}"
if [[ -n "$key" && -d config ]]; then
  if [[ ! -f config/master.key || "$(<config/master.key)" != "$key" ]]; then
    printf '%s' "$key" > config/master.key
    chmod 600 config/master.key
  fi
fi
```

Keep secrets out of the script — read them from env vars (`WT_<PURPOSE>_<PROJECT>` convention).

## Config keys

| Key           | Effect                                                                |
| ------------- | --------------------------------------------------------------------- |
| `defaultBase` | Branch used as base by `wt:create` when no base argument is given     |

```bash
wt:config defaultBase sprint_ee    # set
wt:config defaultBase              # read
wt:config                          # list all wt.* keys
wt:config defaultBase --unset      # clear
```
