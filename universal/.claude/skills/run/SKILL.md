---
name: run
description: Launch, connect to, and drive the Universal Flutter app via the Dart MCP server — navigate screens, take screenshots, and check for runtime errors to confirm a UI or behavior change actually works. Use when asked to run, launch, or screenshot the app, or to verify a change in the running app.
---

# Run — Universal (Flutter, Dart MCP)

Drives a live instance of the app through the `dart` MCP server's tools rather than adb or manual taps. Everything below runs from the `universal/` directory.

## 1. Load the Dart MCP tools

They're deferred at session start, so nothing below is callable yet. Load them once:

`ToolSearch: select:mcp__dart__dtd,mcp__dart__widget_inspector,mcp__dart__flutter_driver_command,mcp__dart__hot_reload,mcp__dart__hot_restart,mcp__dart__get_runtime_errors`

Done when all six come back as callable.

## 2. Analyze before touching a device

Run `flutter analyze` from `universal/`. A compile error here is a clear, fast signal — the same error surfacing later as an opaque DTD failure is not. Clean (or only pre-existing, unrelated warnings) → continue. Errors → stop and report them; nothing below will work until they're fixed.

## 3. Find a live instance, or start one

Call `dtd listDtdUris`. An entry whose workspace root is under `universal/universal` is this app already running — `dtd connect` to it and skip to step 4.

None found:

- Check `flutter devices` for a connected Android emulator. Its id (`emulator-XXXX`) is assigned fresh each time one launches, so read it from this output rather than assuming a fixed value. Missing → try `flutter emulators --launch <id>`, then recheck `flutter devices` for the id it was just given. Still missing → stop and ask for the emulator to be started by hand. (On this WSL2 setup the AVD lives on the Windows side; `flutter emulators` has no sources to launch from here, so failure at this step is expected, not a bug to chase.)
- From `universal/`, launch in the background so the call returns immediately: `nohup flutter run -d <device-id> -t lib/driver_main.dart > <scratchpad>/flutter_run.log 2>&1 &`. Always target `lib/driver_main.dart`, never `lib/main.dart` — only the driver entrypoint calls `enableFlutterDriverExtension()`, and every `flutter_driver_command` call below depends on that extension being registered.
- Poll `dtd listDtdUris` until the new instance appears, then `dtd connect` to it.

## 4. Get to a known, current state

Prefer `hot_reload`; escalate to `hot_restart` when a reload doesn't seem to have taken effect (e.g. a `const`/global value changed) or the app needs to be back at a known screen rather than wherever a reused instance was left. Use judgment on when — this isn't a fixed cadence.

## 5. Drive and verify

Before any `flutter_driver_command` that needs a finder (`tap`, `scroll`, `enter_text`, `waitFor`, ...), call `widget_inspector get_widget_tree` (`summaryOnly: true`) first and select against what's actually in the tree — text, tooltip, or type as shown. Never guess a selector.

Use `screenshot` to confirm visually, and `get_runtime_errors` to catch exceptions a screenshot won't show — reach for it wherever it makes sense given what you just did, not on a fixed schedule.

Done when the change you were asked about is confirmed working, or you've found and can report a concrete problem.

## 6. Leave it running

Don't stop or detach the `flutter run` process when finished. The next run of this skill reuses it via step 3's `dtd listDtdUris` check instead of relaunching from scratch.
