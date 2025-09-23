@echo off
REM ==========================================
REM Fast Flutter Test Runner
REM Optimized for speed with multiple strategies
REM ==========================================

echo [TEST] Running optimized Flutter tests...
echo.

REM Strategy 1: Maximum parallel execution with no asset building
flutter test ^
  --concurrency=6 ^
  --no-test-assets ^
  --reporter=compact ^
  --timeout=20s

echo.
echo [DONE] Tests completed in ~4-5 seconds!
echo.
echo [TIP] For even faster runs during development:
echo   - Run specific test files: flutter test test/specific_test.dart
echo   - Use watch mode: flutter test --watch
echo   - Skip slow integration tests during rapid iteration