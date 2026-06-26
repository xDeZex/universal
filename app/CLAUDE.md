# Flutter App Guidelines

## Commands

```bash
flutter test       # must pass before any work is considered done
flutter analyze    # fix warnings before committing
```

## Architecture

```
lib/        # App source — see lib/CLAUDE.md
test/       # Flutter tests (mirrors lib/ structure)
android/    # Android platform code
```

## Environment

- No auto hot-reload; user triggers manually
