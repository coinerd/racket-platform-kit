# Pi coding-agent adapter (optional)

The canonical instructions are **tool-independent** and live in top-level `AGENTS.md`. No Pi-specific runtime APIs or profiles are assumed here.

1. Inspect the locally installed `pi --version` and `pi --help`; verify the active executable, not an older `start.sh` wrapper.
2. Determine whether the installed Pi version automatically reads `AGENTS.md`. If not, explicitly give the agent `AGENTS.md` as its task context.
3. Prefer repository-local configuration. Do **not** overwrite `~/.pi/`, global model settings, existing extensions/skills, or credentials.
4. Reuse only the agent runner's documented worktree/session facilities; shell `git worktree` is the portable fallback.
5. Do not install, generate or assume custom Pi extensions just to implement workflows already covered by this repository's documents.
6. Keep each session's initial context small: AGENTS + relevant task + public contract + only relevant source files. Load the full 1,894-line manual when facing an abstraction tradeoff, not automatically on every trivial edit.
7. Check model/tool availability at runtime; never hard-code an unverified model ID or Pi CLI flag into installation scripts.

The user’s original abstraction manual is preserved in `docs/reference/` so agents can read it selectively without repeatedly injecting the entire guide into every coding turn.
