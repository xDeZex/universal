@echo off
REM ==========================================
REM Watch Mode Test Runner
REM Automatically runs tests when files change
REM ==========================================

echo [WATCH] Starting test watcher...
echo [INFO] Tests will run automatically when files change
echo [INFO] Press Ctrl+C to stop watching
echo.

flutter test --watch --concurrency=4 --no-test-assets --reporter=compact