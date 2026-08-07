# Improvement Kata — universal

## Challenge

AI-assisted coding is working well in this repo when implementation follows red/green TDD per acceptance criterion, changed lines land with 100% diff coverage (global coverage never drops below 95%), each ticket is scoped to fit one fresh context window (~150k tokens), and every code-review finding gets fixed before the loop closes.

## Harness

- **Local git hooks** (`.githooks/`, active via `core.hooksPath`):
  - `pre-commit` — blocks direct commits to `main`; blocks staged Dart/Go files growing past 300 lines; for staged Flutter files, runs `flutter test`/`flutter analyze` and a coverage gate (95% global via a custom script, 100% on changed lines via `diff-cover`) before allowing the commit.
  - `commit-msg` — enforces Conventional Commits format or a `[temporary]` tag.
  - `pre-push` — rejects pushing `[temporary]` commits anywhere but a squashed PR branch.
- **CI** (`ci-universal.yml`, GitHub Actions): re-runs `flutter test` and `flutter analyze` on push/PR, builds the APK, cuts a release. Does **not** re-check coverage — a bypassed or unconfigured local hook has no upstream catch.
- **Workflow convention** (not tool-enforced): app work follows the `implement-ticket` skill — TDD per acceptance criterion, checkpoint commits, a `code-review` loop until clean, then squash — invoked by habit, not gated by any hook or CI check.
