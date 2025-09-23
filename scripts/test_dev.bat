@echo off
REM ==========================================
REM Development Test Runner
REM For rapid iteration during development
REM ==========================================

if "%1"=="" (
    echo [DEV] Running fast tests for development...
    flutter test --concurrency=4 --no-test-assets --reporter=compact --timeout=15s
) else (
    echo [DEV] Running specific test: %1
    flutter test %1 --no-test-assets --reporter=compact
)