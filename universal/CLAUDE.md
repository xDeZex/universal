# Flutter App Guidelines

## Commands

```bash
flutter test       # must pass before any work is considered done
flutter analyze    # fix warnings before committing
```

After making a UI-affecting change, run the app on the emulator and check
how it actually looks — use the `/run-universal` skill (at the repo
root's `.claude/skills/run-universal/`) to build, launch, and drive it
via `adb`, and take a screenshot to confirm.

## Architecture

```
lib/        # App source — see lib/CLAUDE.md
test/       # Flutter tests (mirrors lib/ structure)
android/    # Android platform code
```

## Environment

- No auto hot-reload; user triggers manually
