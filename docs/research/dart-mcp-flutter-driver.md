# Research: Dart MCP Server, DTD, `flutter_driver`, and Widget Inspector

This document is primary-source research only — it contains no skill instructions. It exists to
underpin a future Claude Code skill that teaches an agent to drive a running Flutter app for UI
verification using the "dart" MCP server's tools. Every claim below is followed by an inline link
to the primary source it came from (official docs, official GitHub repos/source, or the MCP
tool's own schema as exposed in this environment). Where no primary source could be found, that is
stated explicitly rather than filled in from memory or secondary write-ups (blogs, Stack Overflow,
tutorials).

## Topic 1: The Dart MCP Server

- The official, canonical docs page is `dart.dev/tools/mcp-server`, which 301-redirects to
  `docs.flutter.dev/ai/mcp-server` — this is the current home of the documentation ([dart.dev/tools/mcp-server](https://dart.dev/tools/mcp-server), redirects to [docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)).
- The page states: "The Dart and Flutter MCP server exposes Dart and Flutter development tool
  actions to compatible AI-assistant clients" and that the server is bundled with, and run via, the
  `dart mcp-server` command, requiring **Dart 3.9 or later** ([docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)).
- The server's implementation source lives in the `dart-lang/ai` GitHub repo, at
  `pkgs/dart_mcp_server`, linked directly from the official docs page ([docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server); [github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)).
- `dart_mcp_server` is distinct from `pub.dev/packages/dart_mcp`: `dart_mcp` (published by
  `labs.dart.dev`, currently v0.5.2, BSD-3-Clause) is described as "a package for making MCP
  servers and clients" — i.e. a *protocol library*, not the bundled server itself. Its repository
  is `github.com/dart-lang/ai/tree/main/pkgs/dart_mcp` ([pub.dev/packages/dart_mcp](https://pub.dev/packages/dart_mcp)). `dart_mcp_server` is the concrete server built on top of that
  library, and the Dart SDK's `dart mcp-server` command runs it — the official docs note the
  package can also be run standalone via `dart pub global activate -s git
  https://github.com/dart-lang/ai.git --git-path pkgs/dart_mcp_server/` for development ([docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)).
- Setup: the server communicates over stdio; a compliant MCP client must support **Tools** and
  **Resources**, and it is recommended (not required, with a `--force-roots-fallback` flag as a
  fallback) that the client also support **Roots** ([docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)). The docs give concrete
  per-client configuration snippets (Antigravity, Gemini CLI, Cursor, GitHub Copilot/VS Code via
  Dart Code extension ≥3.116, Claude Code via `claude mcp add --transport stdio dart -- dart
  mcp-server`, Codex CLI, OpenCode) ([docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)).
- Full documented tool list from the `dart_mcp_server` README (`github.com/dart-lang/ai`,
  `pkgs/dart_mcp_server/README.md`), reproduced with enabled/disabled-by-default status: `analyze_files`,
  `create_project` (disabled), `dart_fix` (disabled), `dart_format` (disabled), `dtd`,
  `flutter_driver_command`, `get_active_location` (disabled), `get_app_logs` (disabled),
  `get_runtime_errors`, `hot_reload`, `hot_restart`, `launch_app` (disabled), `list_devices`
  (disabled), `list_running_apps` (disabled), `lsp`, `pub`, `pub_dev_search`, `read_package_uris`,
  `rip_grep_packages`, `roots`, `run_tests` (disabled), `stop_app` (disabled), `vm_service`,
  `widget_inspector` ([github.com/dart-lang/ai/blob/main/pkgs/dart_mcp_server/README.md](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/README.md)).
- `dtd` tool: per its own schema, as exposed in this environment — "Manage live app connections to
  Dart and Flutter apps using the Dart Tooling Daemon (DTD). Start by using the `listDtdUris`
  command to find available DTD URIs, followed by the `connect` command with the desired URI to
  connect to. Apps from a given DTD instance are automatically connected to, and you can use the
  `listConnectedApps` command to see the list of connected apps. If you see DTD instances with a
  working dir that looks like a home directory, these are likely connected to an IDE and you
  should connect to those to find IDE launched apps." (Dart MCP server tool schema, as exposed in
  this environment.) This matches the README's documented workflow of `listDtdUris` → `connect` →
  `listConnectedApps` ([github.com/dart-lang/ai/blob/main/pkgs/dart_mcp_server/README.md](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/README.md)).
- `widget_inspector` tool: per its own schema — "Interact with the Flutter widget inspector in the
  active Flutter application. Requires an active DTD connection." Commands: `get_widget_tree`,
  `get_selected_widget`, `set_widget_selection_mode`, with a `summaryOnly` option on
  `get_widget_tree` that, if true, "only widgets created by user code are returned." (Dart MCP
  server tool schema, as exposed in this environment.)
- `flutter_driver_command` tool: per its own schema — "Run a flutter driver command," with the
  description explicitly instructing: "To specify a widget to interact with, you must first use
  the 'widget_inspector' tool (with 'get_widget_tree' command) to get the widget tree of the
  current page so that you can see the available widgets. Do not guess at how to select widgets,
  use the real text, tooltips, and widget types that you see present in the tree." This is the
  server's own documented ordering guidance: **call `widget_inspector` (`get_widget_tree`) before
  `flutter_driver_command`** when selecting widgets. (Dart MCP server tool schema, as exposed in
  this environment.) Supported commands include `get_health`, `enter_text`,
  `send_text_input_action`, `get_text`, `scroll`, `scrollIntoView`, `set_frame_sync`,
  `set_semantics`, `set_text_entry_emulation`, `tap`, `waitFor`, `waitForAbsent`,
  `waitForTappable`, `get_offset`, `get_diagnostics_tree`, `screenshot`.
- Prerequisites for `flutter_driver_command` to work: the server's own source
  (`pkgs/dart_mcp_server/lib/src/mixins/dtd.dart`) implements this tool by calling
  `vmService.callServiceExtension('ext.flutter.driver', isolateId: ..., args: request.arguments)`
  — i.e. it invokes the `ext.flutter.driver` VM service extension directly over the VM
  service/DTD connection, not by shelling out to any `flutter drive` CLI process. When that
  extension is not registered, the tool returns this hard-coded error message (found in the same
  source file): *"The flutter driver extension is not enabled. You need to import
  'package:flutter_driver/driver_extension.dart' and then add a call to
  `enableFlutterDriverExtension();` before calling `runApp` to use this tool. It is recommended
  that you create a separate entrypoint file like `driver_main.dart` to do this."* ([github.com/dart-lang/ai, pkgs/dart_mcp_server/lib/src/mixins/dtd.dart](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/lib/src/mixins/dtd.dart)).
  This **confirms empirically-observed setup is also what the tool's own source/error message
  documents** — the official README prose itself, however, does **not** separately spell out this
  prerequisite (it is not in the README's tool table or setup section; it only surfaces at
  runtime via this error string) ([github.com/dart-lang/ai/blob/main/pkgs/dart_mcp_server/README.md](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/README.md)).
- A first-party GitHub issue (`dart-lang/sdk#62265`, filed against the Dart SDK repo, which is
  where `dart mcp-server` bugs are tracked) documents that, as of Dart SDK 3.10.4 stable /
  3.11.0-200.1 beta and Flutter 3.38.5 stable on macOS, Flutter Driver **finder-based** commands
  (`tap`, `waitFor`, `get_text` when using `ByText`/`ByType`/`ByValueKey` finders) fail with a
  `type 'int' is not a subtype of type 'String?'` type-cast error at
  `dart_mcp_server/src/mixins/dtd.dart:187`, while `get_health` and `screenshot` work correctly.
  The issue explicitly notes reproduction requires the app to be started with
  `enableFlutterDriverExtension()`, and a fix PR (#331) was in progress at time of writing ([github.com/dart-lang/sdk/issues/62265](https://github.com/dart-lang/sdk/issues/62265)).
- Workflow/lifecycle guidance from the README: Flutter apps auto-register with DTD when run in
  debug/profile mode "unless `--no-dds` is passed"; pure Dart apps require the `--observe` flag to
  start DTD registration; and it's recommended to "Always pass the `--print-dtd` flag to `dart` or
  `flutter` when spawning an application" so the exact DTD URI is known up front rather than
  needing to enumerate all running instances via `listDtdUris` ([github.com/dart-lang/ai/blob/main/pkgs/dart_mcp_server/README.md](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/README.md)).
- No official documentation was found describing a strict "one DTD per workspace" invariant as a
  hard rule; the README frames it descriptively (IDEs start one DTD per workspace that persists for
  the IDE session; command-line-run apps get a DTD started by the DevTools server owned by the
  `dart`/`flutter` CLI runner) rather than asserting a single-instance guarantee ([dart.dev / DTD search result, see Topic 2](https://dart.googlesource.com/sdk/+/refs/tags/3.6.0-108.0.dev/pkg/dtd_impl/README.md)).

## Topic 2: Dart Tooling Daemon (DTD)

- DTD's protocol-level documentation lives in the Dart SDK source tree, not on a dedicated
  `dart.dev` narrative page: `pkg/dtd_impl/README.md` and `pkg/dtd_impl/dtd_protocol.md`, browsable
  via `dart.googlesource.com` (the Dart SDK's canonical Git host) ([dart.googlesource.com/sdk/+/refs/tags/3.5.0-264.0.dev/pkg/dtd_impl/README.md](https://dart.googlesource.com/sdk/+/refs/tags/3.5.0-264.0.dev/pkg/dtd_impl/README.md); [dart.googlesource.com/sdk/+/refs/tags/3.6.0-108.0.dev/pkg/dtd_impl/dtd_protocol.md](https://dart.googlesource.com/sdk/+/refs/tags/3.6.0-108.0.dev/pkg/dtd_impl/dtd_protocol.md)).
- DTD is described as "a long-running process meant to facilitate communication between Dart tools
  and minimal file system access for a Dart development workspace" ([dart.googlesource.com/sdk/.../pkg/dtd_impl/README.md](https://dart.googlesource.com/sdk/+/refs/tags/3.5.0-264.0.dev/pkg/dtd_impl/README.md)).
- Lifecycle: "When writing or running a Dart or Flutter application in an IDE, the Dart Tooling
  Daemon is started by the IDE and persists over the life of the IDE's workspace. When running a
  Dart or Flutter application from the command line, the Dart Tooling Daemon is started by the
  DevTools server, which is owned by the Dart or Flutter command line runner, and will persist for
  the life of the application's run process" ([dart.googlesource.com/sdk/.../pkg/dtd_impl/README.md](https://dart.googlesource.com/sdk/+/refs/tags/3.5.0-264.0.dev/pkg/dtd_impl/README.md)). This directly implies that an IDE-run app and a
  manually `flutter run`-launched app are on **different DTD instances**, matching the dart MCP
  server's `dtd` tool guidance to check working-directory hints when choosing which `listDtdUris`
  result to `connect` to (see Topic 1).
  Protocol: DTD speaks JSON-RPC 2.0 ([dart.googlesource.com/sdk/.../pkg/dtd_impl/dtd_protocol.md](https://dart.googlesource.com/sdk/+/refs/tags/3.6.0-108.0.dev/pkg/dtd_impl/dtd_protocol.md)).
- Client interaction model per the protocol doc: clients can subscribe to named streams (receiving
  broadcast events other clients post) and/or register themselves as the handler for a named
  service method; only one client may hold a given service-name registration at a time, freed up
  again on disconnect ([dart.googlesource.com/sdk/.../pkg/dtd_impl/dtd_protocol.md](https://dart.googlesource.com/sdk/+/refs/tags/3.6.0-108.0.dev/pkg/dtd_impl/dtd_protocol.md)). A built-in `FileSystem` service
  provides read/write/list operations constrained to configured IDE workspace roots, authenticated
  via a secret exchanged when the daemon starts and `setIDEWorkspaceRoots` is called ([dart.googlesource.com/sdk/.../pkg/dtd_impl/dtd_protocol.md](https://dart.googlesource.com/sdk/+/refs/tags/3.6.0-108.0.dev/pkg/dtd_impl/dtd_protocol.md)).
- There is an official Dart package, `dtd` on pub.dev, for connecting to a running instance
  programmatically: `DartToolingDaemon.connect(uri)` ([pub.dev/packages/dtd](https://pub.dev/packages/dtd)).
- Discovering/connecting to a running instance's URI: both the `dart` and `flutter` CLIs support a
  `--print-dtd` flag that prints the DTD WebSocket URI (e.g. `ws://127.0.0.1:62925/`) to stdout
  when the process starts, which is the officially documented mechanism for a tool that spawns the
  app itself to obtain the URI directly rather than having to enumerate/guess among multiple
  running DTD instances. For pure Dart CLI apps, `--observe` must also be passed (both flags go
  before the script path, e.g. `dart --observe --print-dtd bin/main.dart`) since Dart apps don't
  start DTD registration by default the way Flutter apps do ([github.com/dart-lang/ai/blob/main/pkgs/dart_mcp_server/README.md](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/README.md), corroborated by first-party issue [flutter/flutter#176310](https://github.com/flutter/flutter/issues/176310) discussing `--print-dtd` behavior in combination with `--machine`).
- A first-party (though open, unresolved) Flutter SDK issue requests a dedicated `--dtd-uri` flag
  for `flutter run` so IDEs/tools can pass an *existing* DTD URI in and avoid spawning a second,
  disconnected DTD instance — this indicates the "one DTD instance can end up per invocation"
  problem is a live, acknowledged concern within the Flutter team as of this writing, not yet
  fully solved ([github.com/flutter/flutter/issues/177329](https://github.com/flutter/flutter/issues/177329)).

## Topic 3: `flutter_driver` package

- `flutter_driver` is **not published as a standalone entry on pub.dev** — fetching
  `pub.dev/packages/flutter_driver` issues an HTTP 303 redirect straight to
  `api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html`, confirming it is shipped
  and versioned only as part of the Flutter SDK/framework source tree, not as an independently
  publishable package (verified by direct fetch: `pub.dev/packages/flutter_driver` → 303 → `api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html`).
- Its source lives at `github.com/flutter/flutter/tree/master/packages/flutter_driver`, containing
  `lib/`, `test/`, `test_driver/`, `test_fixes/`, `pubspec.yaml`, `analysis_options.yaml`, and
  `dart_test.yaml` — **there is no `README.md` file in this directory** (confirmed via directory
  listing) ([github.com/flutter/flutter/tree/master/packages/flutter_driver](https://github.com/flutter/flutter/tree/master/packages/flutter_driver)).
- `pubspec.yaml` describes it as: `description: Integration and performance test API for Flutter
  applications`, `homepage: https://flutter.dev`, requiring Dart SDK `^3.11.0-0` or later; no
  `discontinued`/deprecated marker is present in the pubspec itself ([github.com/flutter/flutter/blob/master/packages/flutter_driver/pubspec.yaml](https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_driver/pubspec.yaml)).
- The library-level doc comment in `lib/flutter_driver.dart` describes its purpose: "Provides API
  to test Flutter applications that run on real devices and emulators," running "in a separate
  process from the test itself," positioning it alongside Selenium WebDriver (web), Protractor
  (Angular), Espresso (Android), and Earl Grey (iOS) as Flutter's equivalent. **No `@Deprecated`
  annotation or deprecation notice appears in this file** ([github.com/flutter/flutter/blob/master/packages/flutter_driver/lib/flutter_driver.dart](https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_driver/lib/flutter_driver.dart)).
- **Deprecation status — the decision-relevant finding**: Flutter has an official, first-party
  migration guide, "Migrating from flutter_driver," at
  `docs.flutter.dev/release/breaking-changes/flutter-driver-migration`. Its opening line: "This
  page describes how to migrate an existing project using `flutter_driver` to the
  `integration_test` package, in order to run integration tests." The guide gives side-by-side API
  mappings (`driver.tap()` → `tester.tap(); tester.pumpAndSettle()`; `driver.waitFor(finder)` →
  `expect(finder, findsOneWidget)`; `driver.scroll(...)` → `tester.scrollUntilVisible(...)`) and a
  `pubspec.yaml` setup snippet adding `integration_test` as an SDK dev dependency, with tests
  living under `integration_test/<name>_test.dart` ([docs.flutter.dev/release/breaking-changes/flutter-driver-migration](https://docs.flutter.dev/release/breaking-changes/flutter-driver-migration)). Notably, this specific page's own text does
  **not** contain an explicit sentence stating "flutter_driver is deprecated" — it is framed
  descriptively as a migration path, not a deprecation notice, when read in isolation.
- The explicit, first-party confirmation of intent to deprecate is a **Flutter-team-filed GitHub
  tracking issue**, `flutter/flutter#139249`, titled "Expand deprecation policy to
  package:flutter_driver." Its body states this is "the tracking issue for the proposal to expand
  the deprecation policy to package:flutter_driver," following successful adoption of the same
  policy for `flutter` and `flutter_test`, "with flutter_driver being next." It lists concrete
  planned steps (adding `dart fix` support to `flutter_driver`, a communication/feedback period,
  enforcing deprecation-notice formatting, updating policy docs) and names specific
  long-deprecated methods (some dating to Flutter 1.9/2.1) that would become eligible for removal
  once the policy is applied ([github.com/flutter/flutter/issues/139249](https://github.com/flutter/flutter/issues/139249)). This is a **proposal/tracking issue about applying the
  deprecation *policy* (formal `@Deprecated` annotations + removal timeline) to the package**,
  not a blanket "the package is gone" statement — i.e., primary-source evidence supports "the
  Flutter team intends to formally deprecate `flutter_driver` piece by piece and steers new/migrated
  test code toward `integration_test`," but does **not** support "the `flutter_driver` package has
  already been fully deprecated or removed" as of this research.
- The officially-recommended replacement, `integration_test`, is a `flutter.dev`-published,
  verified-publisher package. Its pub.dev page states it enables "self-driving testing of Flutter
  code on devices and emulators" and adapts `flutter_test` results into a format compatible with
  `flutter drive`. Its own pub.dev listing carries a **discontinued** notice: "This package has
  been moved to the Flutter SDK. Starting with Flutter 2.0, it should be included as a dev
  dependency directly from the SDK" — i.e. it is not itself abandoned, it simply moved from a
  standalone pub.dev package into the SDK, the same way `flutter_driver` lives in-SDK ([pub.dev/packages/integration_test](https://pub.dev/packages/integration_test)).
  The current official testing docs (`docs.flutter.dev/testing/overview` and
  `docs.flutter.dev/testing/integration-tests`) describe `integration_test` as the SDK-bundled
  package for integration tests and note the caveat that it "can't interact with native platform
  UI, such as permission dialogs, notifications, or platform views," for which they point to the
  third-party `patrol` package as an alternative — **neither of these two current docs pages
  mentions `flutter_driver` by name at all** as of this research (verified by direct fetch of both
  pages) ([docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview); [docs.flutter.dev/testing/integration-tests](https://docs.flutter.dev/testing/integration-tests)).
- **Does the Dart MCP server's `flutter_driver_command` tool actually use `flutter_driver` (the
  package/protocol), or `integration_test`?** Definitively the former. The tool's own name and
  description say "Run a flutter driver command" (Dart MCP server tool schema, as exposed in this
  environment), and the server's implementation
  (`pkgs/dart_mcp_server/lib/src/mixins/dtd.dart`) calls the VM service extension
  `ext.flutter.driver` directly — this is the exact extension name registered by
  `enableFlutterDriverExtension()` from `package:flutter_driver/driver_extension.dart` (see next
  bullet), not anything from `integration_test` ([github.com/dart-lang/ai, pkgs/dart_mcp_server/lib/src/mixins/dtd.dart](https://raw.githubusercontent.com/dart-lang/ai/main/pkgs/dart_mcp_server/lib/src/mixins/dtd.dart)). So the MCP server's live-app-driving tool is built
  squarely on the package the Flutter team is steering test-authors away from for *authored,
  checked-in* tests — an interesting tension worth flagging to whoever builds the downstream skill.
- `enableFlutterDriverExtension()` (`package:flutter_driver/driver_extension.dart`, re-exported
  from the `flutter_driver_extension` library) officially: "Enables Flutter Driver VM service
  extension," described as "required for tests that use `package:flutter_driver`" to drive the app
  from a separate process; must be called "prior to running your application, e.g. before you call
  `runApp`." Its signature is `void enableFlutterDriverExtension({DataHandler? handler, bool
  silenceErrors = false, bool enableTextEntryEmulation = true, List<FinderExtension>? finders,
  List<CommandExtension>? commands})`. The doc comment also notes it "changes the behavior of the
  framework in several ways — including keyboard interaction and text editing," and that
  `enableTextEntryEmulation: false` is available for real-keyboard testing at the cost of breaking
  `FlutterDriver.enterText` ([github.com/flutter/flutter, packages/flutter_driver/lib/src/extension/extension.dart](https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_driver/lib/src/extension/extension.dart)). **No `@Deprecated` annotation is present on this
  function** in the current source ([same source](https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_driver/lib/src/extension/extension.dart)).
- The top-level `driver_extension.dart` entrypoint file shows the canonical usage pattern
  officially documented in its example: call `enableFlutterDriverExtension()` as the first
  statement in `main()`, before `runApp(...)` ([github.com/flutter/flutter/blob/master/packages/flutter_driver/lib/driver_extension.dart](https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_driver/lib/driver_extension.dart)) — this matches this project's empirically-derived
  setup (a dedicated entrypoint calling `enableFlutterDriverExtension()`, plus a `flutter_driver`
  dev dependency so that import resolves).
- **Debug-only / release-build caveats**: No explicit, first-party statement was found in the
  `flutter_driver` source files fetched (`extension.dart`, `driver_extension.dart`,
  `flutter_driver.dart`) saying "do not ship this in release builds" in so many words. This is
  flagged as a gap below (see Open questions) rather than asserted from general Flutter knowledge
  about debug-only VM service extensions.

## Topic 4: Widget inspector / DevTools service extensions

- `WidgetInspectorService` is documented on api.flutter.dev as a **mixin** (not a plain class) in
  the `widgets` library, "whose methods are appropriate to invoke from debugging tools using the VM
  service protocol to evaluate Dart expressions of the form
  `WidgetInspectorService.instance.methodName(arg1, arg2, ...)`," with all string-returning methods
  returning JSON ([api.flutter.dev/flutter/widgets/WidgetInspectorService-mixin.html](https://api.flutter.dev/flutter/widgets/WidgetInspectorService-mixin.html)).
- Key documented members: a static `instance` property exposing the current service instance; a
  `selection` property tracking the object(s) currently selected, "used by both GUI tools such as
  the Flutter IntelliJ Plugin and the WidgetInspector displayed on the device"; an `isSelectMode`
  property; `registerServiceExtension`, which registers a method under the full name
  `ext.flutter.inspector.<name>`; and `toObject`, which resolves a reference id back to the
  underlying Dart object ([api.flutter.dev/flutter/widgets/WidgetInspectorService-mixin.html](https://api.flutter.dev/flutter/widgets/WidgetInspectorService-mixin.html)). This confirms the dart MCP server's
  `widget_inspector` tool (which calls `set_widget_selection_mode`, `get_selected_widget`,
  `get_widget_tree`) is a thin wrapper over this same `ext.flutter.inspector.*` VM service extension
  surface.
- Official DevTools documentation for the inspector UI itself is at
  `docs.flutter.dev/tools/devtools/inspector`. It describes the inspector as visualizing the
  widget hierarchy, and documents "Show implementation widgets": by default only widgets created in
  the project's own root directory are shown in the tree; toggling this setting reveals framework
  ("implementation") widgets too — directly analogous to the `summaryOnly` parameter on the dart
  MCP server's `widget_inspector` `get_widget_tree` command (`summaryOnly: true` → only
  user/project-created widgets) ([docs.flutter.dev/tools/devtools/inspector](https://docs.flutter.dev/tools/devtools/inspector)).
- Documented mechanism: the inspector "connects to the running app via the Dart VM Service,"
  relies on **widget-creation tracking**, which is on by default for `flutter run` and can be
  disabled with `--no-track-widget-creation`; this tracking is what lets the displayed widget tree
  mirror the app's source structure and accurately report source locations, at the cost of
  preventing some `const` widget instances from being considered identical in debug builds ([docs.flutter.dev/tools/devtools/inspector](https://docs.flutter.dev/tools/devtools/inspector)).
- Documented limitation most relevant to this skill: inspector functionality is described as
  primarily available in **debug mode**; the page states release-mode apps have reduced/no
  inspection capability "due to reduced debug information, optimized code stripping, and
  performance constraints" ([docs.flutter.dev/tools/devtools/inspector](https://docs.flutter.dev/tools/devtools/inspector)). Combined with `flutter_driver`'s own VM-service-extension
  mechanism (also debug/profile-oriented), this reinforces that both `widget_inspector` and
  `flutter_driver_command` in the dart MCP server are tools for **debug (or at least
  debug/profile, non-release) builds only**.
- A separate, explicitly **legacy/deprecated** DevTools inspector page exists,
  `docs.flutter.dev/tools/devtools/legacy-inspector`, and the current inspector page's settings
  dialog includes a "Use legacy inspector" toggle described as falling back to "a deprecated
  inspector version" ([docs.flutter.dev/tools/devtools/inspector](https://docs.flutter.dev/tools/devtools/inspector)) — noted here in case a future skill needs to
  distinguish "legacy DevTools inspector UI" (deprecated) from the underlying
  `WidgetInspectorService`/`ext.flutter.inspector.*` extension surface (not deprecated, and what
  the dart MCP server's `widget_inspector` tool actually uses).

## Open questions / gaps

- **No primary source found** for an explicit, first-party statement that
  `enableFlutterDriverExtension()` or the `ext.flutter.driver` VM service extension must never be
  compiled into release builds. The `flutter_driver` source files fetched (`extension.dart`,
  `driver_extension.dart`, top-level `flutter_driver.dart`) contain no such explicit caveat in
  their doc comments. (General Flutter knowledge suggests VM service extensions are a
  debug/profile-mode concept, but that claim is not backed by a specific quoted primary source
  found during this research and should not be asserted as officially documented without further
  digging, e.g. into `docs.flutter.dev` build-mode docs.)
- **No primary source found** stating flat-out "`flutter_driver` is deprecated" in present tense
  from an official docs page (as opposed to a migration guide framed neutrally, or a GitHub
  tracking issue about *future* deprecation-policy rollout). The strongest primary evidence is the
  combination of (a) the existence of the official migration guide and (b) the Flutter-team-filed
  tracking issue `flutter/flutter#139249` proposing to extend the formal deprecation policy to the
  package. Whether that policy rollout has since completed (i.e., whether `flutter_driver` APIs
  now carry actual `@Deprecated` annotations) was not verified beyond the two source files spot-checked
  in Topic 3, which had none.
- **No dedicated `dart.dev` narrative/tutorial page for the Dart Tooling Daemon** was found (only
  the SDK-source-tree `README.md`/`dtd_protocol.md` on `dart.googlesource.com`, and the `dtd`
  package on pub.dev). It's possible a friendlier `dart.dev/tools/...` overview page exists but was
  not surfaced by search; only the source-tree docs and the MCP server's own README could be
  confirmed.
- **Could not fetch a rendered version of `api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html`** — WebFetch repeatedly returned only a stub redirect link (`[New URL](../flutter_driver/)`) rather than page content, likely because the page is client-rendered. The equivalent information (library doc comment) was instead sourced directly from the underlying Dart source file on GitHub, which is the origin of that generated page's content, so the claim is still primary-sourced, just via source instead of the rendered HTML.
- Did not find an official statement on whether the dart MCP server assumes **exactly one** DTD
  instance is active per workspace at a time, versus gracefully supporting many; the `dtd` tool's
  own guidance ("if you see DTD instances with a working dir that looks like a home directory,
  these are likely connected to an IDE") implies the server is designed to cope with multiple
  simultaneous DTD instances and pick the right one heuristically, but no doc explicitly states an
  upper bound or a recommended "always exactly one" pattern.
- The `dart_mcp` (protocol library) and `dart_mcp_server` (bundled server) relationship was
  confirmed via docs and repo structure, but the precise mechanism by which the `dart` SDK CLI's
  `mcp-server` subcommand invokes/vendors `pkgs/dart_mcp_server` (e.g., whether it's compiled into
  the `dart` binary at SDK build time, or shells out to a separately-fetched package) was not
  independently verified against the `dart-lang/sdk` repo's own build scripts — this is asserted
  only at the level the official docs describe it (a bundled command; version-gated behind Dart
  3.9+).
