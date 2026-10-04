# RTK — compact command output

RTK is an optional CLI proxy usable by any agent with shell access.
Use explicit commands; automatic command rewriting requires a tool-specific hook.

```bash
rtk --version
rtk git status
rtk git diff
rtk gain
rtk gain --history
rtk proxy git diff  # Full output when filtering omits necessary detail
```

Run `rtk --help` to check supported commands. Use native commands when RTK is
unavailable or when exact, unfiltered output is needed. RTK does not change
the agent's permissions; obtain the same approvals as for the underlying command.
