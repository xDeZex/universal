# Flutter App Guidelines

## Workflow

App feature work does not use OpenSpec (that's for `services/`/`deploy/` — see root `CLAUDE.md`). Instead:

1. **Plan**: for work too big for one session, `wayfinder` resolves open decisions (research/prototype/grilling tickets) down to a settled destination. `to-tickets` always does the final slicing into buildable, GitHub-issue tickets with acceptance-criteria checkboxes — whether or not wayfinder was involved.
2. **Implement**: the `implement-ticket` skill takes one ticket end to end — RED/GREEN per acceptance criterion, a checkpoint commit per criterion, then a final review/fix loop via the `code-review` skill. Same branch/rebase and squash-before-PR conventions as the rest of the repo (root `AGENTS.md`).
3. **No mandatory spec file.** Tests are the spec of record for app capabilities.
4. **No standalone design step.** Small design questions get resolved inline while implementing a criterion. Only escalate to a new wayfinder ticket if the answer would change the ticket's scope or ripple into other tickets on the map.

## Commands

```bash
flutter test       # must pass before any work is considered done
flutter analyze    # fix warnings before committing
```

After making a UI-affecting change, run the app on the emulator and check
how it actually looks — use the `run` skill (`universal/.claude/skills/run/`)
to connect via the Dart MCP server, drive the app, and take a screenshot
to confirm.

## Architecture

```
lib/        # App source — see lib/CLAUDE.md
test/       # Flutter tests (mirrors lib/ structure)
android/    # Android platform code
```
