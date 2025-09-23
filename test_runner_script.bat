@echo off
REM Fast Flutter test runner script
echo Running Flutter tests with optimizations...

REM Run tests with optimizations
flutter test ^
  --concurrency=6 ^
  --no-test-assets ^
  --reporter=compact ^
  --timeout=30s

echo.
echo Tests completed!