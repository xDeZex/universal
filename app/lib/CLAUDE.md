# Flutter Guidelines

## Commands

```bash
flutter test       # must pass before any work is considered done
flutter analyze    # fix warnings before committing
```

## Architecture

```
models/     # Data only
services/   # Business logic
screens/    # UI pages
widgets/    # Reusable UI
```

## Standards

- Material 3 design, `const` constructors, camelCase/PascalCase naming
- Provider pattern for state, auto-save with SharedPreferences
- Wrap async in try-catch, use null-safe operators
