# Research: AI-assisted UX/UI design workflows for Flutter

Resolves the research ticket behind GitHub issue #143. Feeds into the follow-up decision ticket, issue #144 ("which workflow should we actually use"), which this document does not attempt to answer for.

**Scope.** Universal's output is Flutter widget code (Dart), not HTML/React. Every claim below is checked against a primary source — an official skill file, official Anthropic docs, or a project's own repo/API docs — and cited with a path or URL. No secondary "best AI design tools" write-ups were used.

---

## 1. What's already installed in this repo, and how is it meant to be invoked?

Three of Matt Pocock's skills are already vendored at `.agents/skills/{prototype,grilling,domain-modeling}/SKILL.md`, and `wayfinder` (`.agents/skills/wayfinder/SKILL.md`) governs how they get invoked as ticket types on a decision map.

- **`grilling`** (`.agents/skills/grilling/SKILL.md`) — a pure conversational protocol: interview the user one question at a time, walking the decision tree, giving a recommended answer per question, never acting until the user confirms shared understanding. No design-specific content; it's a generic "sharpen a plan through dialogue" tool. Directly usable for UX flow/IA questions — "should the edit-set screen be a bottom sheet or a full route", "does this delete need a confirm step" — but only as a discussion protocol, not something that produces an artifact.
- **`domain-modeling`** (`.agents/skills/domain-modeling/SKILL.md`) — actively maintains `CONTEXT.md` and `docs/adr/`: challenges vocabulary against the glossary, sharpens fuzzy terms, cross-references code against stated behavior, writes ADRs only when a decision is hard-to-reverse, surprising, and a real trade-off. This is IA/vocabulary work adjacent to UX (getting navigation and entity names precise) but is not a visual or interaction-flow tool by itself.
- **`prototype`** (`.agents/skills/prototype/SKILL.md`, with branches `LOGIC.md` and `UI.md`) — the one built specifically to raise the fidelity of a design discussion via a cheap, throwaway, concrete artifact. See §2 for how its UI branch would need to be adapted for Flutter.
- **`wayfinder`** (`.agents/skills/wayfinder/SKILL.md`) treats `prototype` as one of four ticket types (`research`, `prototype`, `grilling`, `task`). Its own description of the type: "Raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to — an outline, a rough take, a stub, or UI/logic code via the /prototype skill... Use when 'how should it look' or 'how should it behave' is the key question." (`.agents/skills/wayfinder/SKILL.md:78`). It's explicitly marked **HITL** (human-in-the-loop) — "a HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it" (`wayfinder/SKILL.md:75`). So on a wayfinder map, "what should the Active Workout screen look like" is chartered as a `prototype` ticket, claimed by a session, resolved by literally running `/prototype`, and the resolution comment records which variant won and why — the variant set itself lives on a throwaway branch per the prototype skill's own capture step.

**Bottom line:** the map already answers "how would we structure the *process* of getting to a validated UX/UI direction" — `grilling`/`domain-modeling` for flow and IA questions, `prototype` for "how should it look/behave" questions, wired into wayfinder's ticket-and-map bookkeeping. What's *not* answered by anything installed here is "what visual/aesthetic judgment or tooling fills in the UI branch of `/prototype` for a Flutter app, and specifically for staying within Material 3." That's the open question §3–§5 investigate.

---

## 2. How would `/prototype` concretely work for a Flutter UI/UX question?

Read literally, `.agents/skills/prototype/UI.md` is written for a web/React project: variants switch via a `?variant=` **URL search param**, `router.replace`/`navigate`, arrow-key handling that must avoid stealing focus from an `<input>`, and a floating bar gated by `process.env.NODE_ENV !== 'production'` (`UI.md:20, 87-90`). None of those mechanisms exist in a Flutter mobile app in the form the skill describes — there is no address bar, and go_router's query params exist but aren't how a user "reloads" a running mobile app mid-session. This is exactly the kind of "web-first design tool assumption" the ticket asked to flag: **the skill's structure (N variants, structurally different, switchable, judged against real app chrome) transfers; its plumbing does not.**

Concretely, for a Flutter UI prototype ticket in this repo, the adaptation would be:

- **Sub-shape A (adjustment to an existing page) still applies and is still preferred** — the skill's own guidance to prefer variants "butting up against the rest of the app" (`UI.md:16`) maps cleanly: build the 2–3 variants as sibling widgets inside the real route (e.g. `ActiveWorkoutScreen`), with real data, not an isolated demo screen.
- **The URL-param switcher becomes a local, in-memory switcher.** A `StatefulWidget` (or a Riverpod/Provider `int variantIndex`, matching whatever state approach the app already uses) with a small floating `Row` of buttons/labels ("A · B · C") replaces the URL bar; tapping cycles `variantIndex`. Gate it with `kDebugMode` (Flutter's own build-mode constant) instead of `process.env.NODE_ENV`, satisfying the same "never ship the switcher to production" rule (`UI.md:90`) with the Flutter-native equivalent.
- **"The user flips between variants in the browser" becomes "the user flips between variants on the emulator."** This is where `run-universal` (see §5) fills the gap the skill assumes a browser fills: `driver.sh launch` → `driver.sh tap` the switcher → `driver.sh ss out.png` for each variant, so either the human or Claude itself can see all three variants rendered before the human picks. The skill's hand-off step ("Surface the URL... the user will flip through whenever they get to it", `UI.md:96`) becomes "surface the screenshots, or hand the human a running emulator with the switcher visible."
- **Capture-and-cleanup is unchanged** — fold the winning variant into the real widget tree, drop the rest onto the throwaway branch, exactly as `SKILL.md`'s step 6 and `UI.md`'s step 6 already describe; nothing about that mechanic is web-specific.

`LOGIC.md`, by contrast, needs **no adaptation** for this repo: it asks for "whatever the project uses" as the language for a small TUI over a pure reducer/state machine (`LOGIC.md:20-22`), and Dart runs standalone via `dart run some_prototype.dart` without pulling in Flutter widgets at all. For a state-model question — e.g. "does editing a Set's weight mid-workout correctly propagate to the summary totals" — this branch is usable as-written today.

---

## 3. Is there an official Anthropic design/frontend skill? Does it target Flutter?

Yes — confirmed via `npx skills find design --owner anthropics` (the Skills CLI) and by reading the source directly from `github.com/anthropics/skills`.

**`anthropics/skills` → `skills/frontend-design/SKILL.md`** (fetched via `gh api repos/anthropics/skills/contents/skills/frontend-design/SKILL.md`). Its description: "Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults." Key content:

- Frames the work as "the design lead at a small studio," producing a "compact token system" — 4–6 named hex colors, 2+ named typefaces by role, an ASCII-wireframed layout concept, and one "signature" element — reviewed once for genericness before code is written.
- Names the three visual ruts it's explicitly trying to steer Claude away from: warm-cream-serif-terracotta, near-black-with-one-bright-accent, and broadsheet-hairline-zero-radius — "AI-generated design right now clusters around" these regardless of subject.
- Its execution guidance is **CSS-specific**: "be careful of structuring your CSS selector specificities... classes can cancel each other out (especially with a type-based selector like `.section` and an element-based selector like `.cta`)," and its verification step is "take screenshots if your environment supports it" of a rendered web page.
- **No mention of Flutter, Dart, widgets, or any component/theming system anywhere in the skill.** It is a general aesthetic-judgment framework (how to pick a non-generic palette/type/layout and self-critique it) wrapped in web-specific execution mechanics.

**Verdict:** the *aesthetic-judgment scaffold* (token system: 4–6 named colors + type roles + layout concept + one signature element, reviewed against a checklist of generic AI defaults before coding) is framework-agnostic and directly portable to a Flutter `ThemeData`/`ColorScheme` — but the skill as written does not know that, and its concrete execution advice (CSS specificity, browser screenshots) does not fire for Dart/Flutter. It would need a Flutter-specific rewrite of the "build" step, not a rewrite of the judgment framework.

Also checked via the same GitHub source browse: **`skills/theme-factory`** turned out to be a false lead for this question — its description is "Toolkit for styling artifacts with a theme... slides, docs, reportings, HTML landing pages" (`skills/theme-factory/SKILL.md`), i.e. it hands Claude 10 pre-baked color/font themes to apply to *documents and slide decks* it generates as Claude-authored artifacts, not to an existing app's component library. Irrelevant here. **`skills/canvas-design`** is also a false lead — static `.png`/`.pdf` poster/art generation, explicitly "never copying existing artists' work," nothing about UI or components.

### Other reputable owners found via the Skills CLI

`npx skills find "UI design"` and `npx skills find react --owner vercel-labs` surfaced:

- **`vercel-labs/agent-skills@web-design-guidelines`** — confirmed by reading `skills/web-design-guidelines/SKILL.md`: it fetches `https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md` and audits **existing code files** against it, reporting `file:line` violations. Explicitly a **code review** tool for HTML/CSS/React, not a generation tool, and its rule source is web-interface-specific (the guidelines file itself is a web accessibility/UX checklist). **Web-only; not usable against Dart/Flutter source as-is** — there's nothing to fetch-and-apply that understands Flutter widget trees.
- **`vercel-labs/agent-skills@vercel-react-best-practices`**, **`vercel-react-view-transitions`** — React/Next.js-specific by name and content; not applicable.
- **`vercel-labs/agent-skills@vercel-react-native-skills`** exists (the repo does have a `react-native-skills` directory) — the closest thing to "mobile" in that family, but it's React Native (JS/TS), not Flutter/Dart; still not directly usable here, though conceptually the nearest of the vercel skills to Universal's mobile-app shape.
- **`nextlevelbuilder/ui-ux-pro-max-skill`** family (`ckm:design-system`, `ckm:design`, `ckm:ui-styling`, `ckm:brand`, `ckm:banner-design`) — a third-party, non-Anthropic, non-Vercel skill pack with high install counts (~32K+ each per the CLI's own numbers). Not read in depth: it isn't a first-party or already-vetted-in-this-session owner, and the research ground rules call for primary/reputable sources — flagging its existence for #144 to optionally follow up on, not vouching for its content.

### Is there a Flutter-specific design/UX skill anywhere?

Checked directly, not inferred: **`flutter/skills`** (the Flutter team's own official skills repo, confirmed via its own README: "Agent skills for Flutter, maintained by the Flutter team") lists exactly ten skills — `flutter-add-integration-test`, `flutter-add-widget-preview`, `flutter-add-widget-test`, `flutter-apply-architecture-best-practices`, `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-implement-json-serialization`, `flutter-setup-declarative-routing`, `flutter-setup-localization`, `flutter-use-http-package` (`gh api repos/flutter/skills/contents/skills`). None address visual/aesthetic design, palette, typography, or Material theming — they're architecture/testing/data-plumbing skills. `flutter-build-responsive-layout` and `flutter-fix-layout-issues` are layout-mechanics tools (fixing overflow errors, adapting to screen size), not aesthetic-direction tools.

Also checked **`dart-lang/skills`** (referenced from the `flutter/skills` README as the complementary Dart-task pack): its `skills/` directory holds twelve skills, all testing/tooling (`dart-add-unit-test`, `dart-build-cli-app`, `dart-fix-runtime-errors`, `dart-generate-test-mocks`, `dart-run-static-analysis`, `dart-use-pattern-matching`, etc.) — nothing design-related.

**Conclusion for #144: no reputable owner currently ships a Flutter-aware visual-design or Material-3-aware theming skill.** The nearest first-party asset is `anthropics/skills@frontend-design`'s aesthetic-judgment framework, which would need its build/verify steps re-targeted from CSS+browser to `ThemeData`+emulator to be usable here at all.

---

## 4. What does Flutter itself already give you for staying inside Material 3, independent of any AI skill?

Grounding claim, checked against Flutter's own API docs (`api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html`) rather than a tutorial: `ColorScheme.fromSeed` "generates a ColorScheme derived from the given seedColor... designed to work well together and meet contrast requirements for accessibility in the Material 3 Design system," producing the full tonal palette (including M3-specific roles like `surfaceContainer`, `surfaceContainerHigh`, etc. per `docs.flutter.dev/release/breaking-changes/new-color-scheme-roles`) from one seed color. This is the existing, non-AI baseline mechanism this repo already has available for "generate a palette that's still valid Material 3" — any AI-assisted palette workflow for Universal is really just "help pick a good seed color and confirm the generated roles read well," not "invent a bespoke palette by hand," if it's going to honor the "don't depart from M3" constraint from the ticket. None of the design skills surveyed in §3 mention `ColorScheme.fromSeed` or Material 3 tonal roles at all — they'd need to be told about this constraint explicitly, since their default behavior (e.g. `frontend-design`'s "take one real aesthetic risk," picking arbitrary hex values) would happily depart from M3 if not reined in.

---

## 5. How does Claude Code itself recommend the "see your own output" loop, and what's the Flutter equivalent?

Primary source: `code.claude.com/docs/en/best-practices`, section **"Give Claude a way to verify its work"**:

> "Give Claude a check it can run: tests, a build, a screenshot to compare. It's the difference between a session you watch and one you walk away from... The check is anything that returns a signal Claude can read in the conversation: a test suite, a build exit code, a linter, a script that diffs output against a fixture, or a browser screenshot compared against a design."

Its own before/after table gives the concrete UI pattern: go from *"make the dashboard look better"* to *"[paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them."* The same page names three ways to gate on the check (single-prompt, a `/goal` condition re-checked every turn, or a deterministic Stop hook) — i.e. Anthropic's own recommended loop is generic ("any check that returns pass/fail"), and *screenshot-diffing* is just the instance of that pattern for visual work, not a separate mechanism.

The **browser-specific instrument** for that pattern is `code.claude.com/docs/en/chrome` (Claude Code's Chrome extension integration): it explicitly names "**Design verification**: build a UI from a Figma mock, then open it in the browser to verify it matches" as one of its capabilities, and gives read-only browser calls (`read_page`, `get_page_text`, `find`, screenshot) that run without a permission prompt versus state-changing calls (clicks, typing, navigation) that do. This is the mechanism secondary sources describe as "give the model eyes" — but per Anthropic's own docs it is Chrome/Edge-only and explicitly **not supported in WSL**, and has no Android/mobile-emulator equivalent in the product.

**`anthropics/skills@webapp-testing`** (`skills/webapp-testing/SKILL.md`) is the packaged, scriptable version of the same idea for local web apps: a decision tree ("is the server running? → `scripts/with_server.py` manages lifecycle → write a Playwright script"), a "reconnaissance-then-action" pattern (screenshot + DOM inspection before writing selectors), and an explicit pitfall list (wait for `networkidle` before inspecting). Structurally, this is the same shape as this repo's own `.claude/skills/run-universal/SKILL.md`: a driver script (`driver.sh` wrapping `adb`, vs. `with_server.py` wrapping a dev server + Playwright) that gives Claude launch → interact → screenshot → verify, one command at a time, without a human at the keyboard.

**Flutter has no browser, so `run-universal` is already this repo's version of that instrument** — confirmed by reading `.claude/skills/run-universal/SKILL.md` directly:

- `driver.sh launch` foregrounds the app (⇄ Playwright's `page.goto`)
- `driver.sh ss out.png` screenshots at native 1080×2400 resolution, no scaling to account for (⇄ `page.screenshot()`)
- `driver.sh tap`/`text`/`key`/`swipe` drive interaction (⇄ Playwright's click/type/press)
- `driver.sh dump` gets a `uiautomator` XML tree of the current screen — the closest Flutter-emulator analogue to reading the DOM for selectors
- adb calls are synchronous, so — unlike Playwright, which needs `wait_for_load_state('networkidle')` — no explicit wait step is documented as a pitfall here; the skill's own "Gotchas" section instead calls out reinstall-kills-hot-reload and the Gboard-toolbar-obscures-screenshot issues as the Flutter-specific equivalents of Playwright's networkidle trap.

**So the mapping the ticket asked about is exact:** Anthropic's own recommended loop is "give Claude a check it can run — for visual work, a screenshot to compare against a target," instrumented on the web via the Chrome extension or the `webapp-testing` skill's Playwright wrapper, and this repo already has the Flutter-side instrument for the identical loop (`run-universal`'s `driver.sh`). Nothing needs to be built to run this loop today — it needs to be *invoked* as part of whatever workflow #144 picks: build a variant, `driver.sh ss`, compare against the design brief or a pasted mock, iterate, exactly per the best-practices page's own before/after example.

---

## 6. UX (flow/IA) vs. UI (visual) — which tool for which?

| Question shape | Tool(s) found | Primary source |
|---|---|---|
| "Does this navigation/flow make sense?" | `grilling` (dialogue) + `domain-modeling` (vocabulary/IA precision) + `prototype`/LOGIC.md if it's really a state-model question ("can the user even reach this state") | `.agents/skills/{grilling,domain-modeling}/SKILL.md`, `.agents/skills/prototype/LOGIC.md` |
| "What should this screen look like?" | `prototype`/UI.md (needs the Flutter adaptation in §2) + `frontend-design`'s aesthetic-judgment scaffold (needs re-targeting off CSS, per §3) + `ColorScheme.fromSeed` as the M3 guardrail (§4) | `.agents/skills/prototype/UI.md`, `anthropics/skills/skills/frontend-design/SKILL.md`, `api.flutter.dev` |
| "Does the built result actually match what we wanted?" | `run-universal`'s `driver.sh` screenshot loop, used per the "give Claude a check it can run" pattern | `.claude/skills/run-universal/SKILL.md`, `code.claude.com/docs/en/best-practices` |
| "Does this UI code follow good web-interface conventions?" | Not applicable here — `web-design-guidelines` is a web-code linter with no Flutter analogue found | `vercel-labs/agent-skills/skills/web-design-guidelines/SKILL.md` |

None of the tools surveyed do *navigation/IA reasoning* as a first-class, structured activity beyond plain conversation (`grilling`) — there's no AI-assisted flow-diagramming or IA-validation tool among the sources checked here. If #144 wants something more structured than conversation for flow/IA, that's an open gap, not something this research found and is withholding.

---

## If you had to pick one workflow today

**Not a decision — a starting point for #144 to weigh, argue with, or discard.**

For a concrete Universal UI question (e.g. "the Active Workout screen's set-editing flow feels clunky"):

1. **Frame the question with `grilling`** first, one question at a time, to pin down what "clunky" actually means (too many taps? unclear affordance? wrong information hierarchy?) before generating anything — this is free and prevents prototyping the wrong thing.
2. **If the answer is about flow/state** ("can I actually reach the delete-confirm state I want"), drop into `prototype`/LOGIC.md as-is — no adaptation needed, it's a Dart script.
3. **If the answer is about visual/interaction design**, run `prototype`/UI.md with the Flutter adaptation from §2: 2–3 structurally different variants as sibling widgets on the real route, switched by a `kDebugMode`-gated in-app switcher (not a URL param), each one held to the M3 guardrail from §4 (derive palette from `ColorScheme.fromSeed`, don't hand-pick arbitrary hex values even if a design-judgment skill suggests it) and — where a fresh visual "shake up the defaults" pass is wanted rather than a variant comparison — borrowed judgment from `frontend-design`'s token-system framing (name 2+ type roles, one signature element, self-critique against generic-AI-defaults) adapted for `ThemeData` instead of CSS.
4. **Verify with `run-universal`**: `driver.sh launch` → `driver.sh ss` each variant → compare screenshots against the stated brief, per Anthropic's own "give Claude a check it can run" pattern — this closes the loop the same way Claude in Chrome closes it for web work, using the instrument this repo already has.
5. **Capture the decision** per `prototype/SKILL.md`'s own step 6: fold the winner into the real widget tree, park the rest on a throwaway branch, and if the resolution reveals a genuinely hard-to-reverse, surprising, trade-off-driven decision (e.g. "we're standardizing on bottom sheets for all destructive edits"), let `domain-modeling` write it up as an ADR.

What #144 still needs to decide and this research doesn't presume: whether it's worth writing a small project-local Flutter variant of `frontend-design` (or just carrying its judgment framework by reference each time), whether `grilling` alone is enough for IA/flow work or a more structured method is worth adopting, and whether the `nextlevelbuilder/ui-ux-pro-max-skill` family (flagged but not vetted in §3) is worth a closer look.
