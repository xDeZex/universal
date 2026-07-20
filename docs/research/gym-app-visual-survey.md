# Research: Visual Survey of Popular Workout-Tracking Apps

This is a follow-up to
[github.com/xDeZex/universal/issues/211](https://github.com/xDeZex/universal/issues/211) (child of
the "Gym-tracking visual design spec" map, #210). The earlier research file in this repo
(`docs/research/gym-row-card-selection-input-patterns.md`) covered Material 3's *guidance* and
noted a sourcing gap: "no first-party design docs found from Strong, Hevy, or StrongLifts." This
document fills that gap differently — not with design rationale, but with a plain **visual**
description of how five popular workout-tracking apps actually look, grounded in real screenshots
pulled from each app's own App Store listing (primary source: the vendor's own marketing
screenshots, as published by them to Apple). No design philosophy, no "why," no prescriptions for
this project — that synthesis belongs to the Prototype tickets (#212, #213), not this survey.

Each screenshot below was downloaded directly from the cited `apps.apple.com` listing (the
`mzstatic.com` CDN URL is Apple's own image host for App Store assets, embedded in the listing's
HTML — not a third-party mirror or review-site capture).

---

## Strong (Strong Fitness PTE Limited)

Source: [apps.apple.com/us/app/strong-workout-tracker-gym-log/id464254577](https://apps.apple.com/us/app/strong-workout-tracker-gym-log/id464254577)

- **Palette**: light theme throughout in all four screenshots sampled — white/near-white
  background, dark gray/black text, a single blue accent for primary buttons and links, orange
  used only for a small "warm-up set" badge and a crown icon.
- **Rows/lists**: the active-workout set table is a plain row-based table with a header row (`Set
  / Previous / kg / Rep / ✓`) and thin horizontal rule lines between rows — a "baseline"
  divider-table look, not a card/gap look. Completed-set rows get a pale green full-row background
  tint (not a saturated highlight) plus a green filled circular checkmark button in the last
  column.
- **Cards**: the Profile screen uses distinct white rounded-corner cards ("Workouts Per Week",
  "Bench Press Chart") on a very light gray page background, each card separated from the next by
  visible page-background gap, not a divider.
- **Buttons/controls**: primary actions ("Finish", "Skip", "Insert") are solid blue filled
  rounded-rectangle buttons. The rest-timer control is a big circular progress ring around a
  numeric countdown, flanked by two rounded-rectangle "-30s"/"+30s" chip buttons (light gray fill,
  dark text) — a stepper realized as labeled chips rather than icon-only +/- buttons. Warm-up-set
  rows carry a small solid-orange circular "W" badge.
- **Typography**: bold dark-gray headings ("Profile", "Monday's session"), regular-weight gray
  body/secondary text, numeric values in the set table left plain (no bolding to mark them out).

## Hevy (Hevy Studios S.L.)

Source: [apps.apple.com/us/app/hevy-workout-tracker-gym-log/id1458862350](https://apps.apple.com/us/app/hevy-workout-tracker-gym-log/id1458862350)

- **Palette**: mixed — the Routines/Workout-list and Log-Workout screenshots are light (white
  background), while a separate "SLEEK DARK MODE" marketing screenshot shows a true near-black
  background with white text, confirming the app ships both themes. Brand blue is the recurring
  accent in both.
- **Rows/lists — Routines screen**: each routine ("Chest & Triceps day", "Back & Biceps") is its
  own white rounded-corner card sitting on a light gray page background, separated from its
  neighbor purely by a visible page-background gap — no divider line drawn between cards. Each
  card contains a bold title, a gray one-line exercise-list summary, and a full-width solid blue
  rounded-rectangle "Start Routine" button as its own bottom element inside the card.
  "New Routine"/"Explore" above the list are smaller light-gray filled pill buttons sitting side
  by side.
  - Utility row "New Routine" / "Explore": light-gray filled rounded-rectangle chips with a leading
    icon, side by side, not full-width.
- **Rows/lists — active workout log**: each set is a row of plain numeric cells (`kg`, `reps`) with
  a green filled checkmark button at the row end; completed rows get a solid pale-green full-row
  background (shown mid-transition/diagonal in the marketing shot, but the flat green fill per
  completed row is visible). A light gray full-width "+ Add Set" pill sits below the set rows,
  visually distinct from them (rounded pill vs. the plain rows above).
- **Rows/lists — dark-mode social feed**: a workout-summary card on black shows a thin single
  horizontal divider line separating the header (avatar/name/timestamp/title/stats) from the
  exercise-list body beneath it, and another thin divider separating the exercise list from the
  like/comment/share icon row at the bottom — i.e., dividers are used, but only to separate
  *sections within one card*, not row-to-row between independent list items.
- **Add-Exercise picker**: a plain white list of exercises (thumbnail circle + name + muscle group
  + chevron), separated by thin full-width divider lines — a conventional divided list, used here
  for a searchable picker rather than the primary tracking surface.
- **Typography**: bold black headings, medium-gray secondary text, numerals in the set table left
  plain/unbolded.

## StrongLifts 5x5 (StrongLifts)

Source: [apps.apple.com/us/app/stronglifts-5x5-workout-plan/id488580022](https://apps.apple.com/us/app/stronglifts-5x5-workout-plan/id488580022)

- **Palette**: light theme, white/near-white background, black/dark-gray text, a single red accent
  used for the wordmark, the primary "Start" button, up-arrows next to progressed lifts, and the
  active-tab indicator elsewhere.
- **Rows/lists**: no divider lines observed anywhere in the four screenshots sampled. The weekly
  plan screen stacks three independent white rounded-corner cards ("Workout A" / Monday, "Workout
  B" / Wednesday, "Workout A" / Friday) on a light gray page background, each separated from its
  neighbor by a visible gap; the current/next card additionally gets a thin red vertical accent
  bar down its left edge plus a subtle drop shadow, marking it as "selected" without touching the
  gap or drawing a line across the row.
- **Set input control — the most distinctive pattern found in this survey**: instead of a
  stepper or a numeric field, each exercise's 5 sets are shown as a horizontal row of 5 circular
  chips, each pre-filled with the target rep count ("5"); completed sets are solid red circles
  with white numerals, not-yet-done sets are pale gray-outline circles with gray numerals, and a
  trailing "+" circle (light gray, thin outline) lets you add a set. This replaces both the
  "stepper" and the "row-of-text" pattern seen in the other four apps with a **row of tappable
  status chips**.
- **Segmented control**: the Workout/Warmup switch above the set-chip rows is a pill-shaped
  two-option segmented control — a light gray track with a white rounded rectangle marking the
  active segment, matching the M3 "segmented button" shape family referenced in the earlier
  research file.
- **Progress charts** use a second pill-segmented control ("1M / 3M / ∞") in the same gray-track
  style, and a star-icon toggle button (outline vs. filled-orange) in the corner of the chart
  card.
- **Exercise-detail tabs** ("Weights / Form / Progress / History") are rendered as a wider 4-way
  pill segmented control, same gray-track/white-active-segment styling as the 2-way ones.
- **Typography**: heavy black condensed/rounded display font for marketing headlines (not part of
  the in-app UI), regular black sans-serif for actual in-app text; numerals in the plan cards are
  plain weight, right-aligned.

## JEFIT (Jefit Inc.)

Source: [apps.apple.com/us/app/jefit-workout-planner-gym-log/id449810000](https://apps.apple.com/us/app/jefit-workout-planner-gym-log/id449810000)

- **Palette**: light theme with a pale blue-gray marketing background behind the device frame in
  three of four screenshots; in-app surfaces are white with blue as the sole accent (links,
  progress lines, outlined pill buttons). A 4th screenshot (progress chart) is on plain white.
- **Rows/lists — set log table**: header row reads `Set / Lbs / Reps` in light gray; the
  currently-active/next set row is marked by a **light lavender full-row background tint** (not a
  divider, not a border) with its two numeric values additionally underlined in blue; completed
  rows above it are plain white with gray checkmarks; a "+" row below in the same lavender tint
  offers "Delete" as a right-aligned affordance. No visible ruled lines between rows — differentiation is 100% background-tint-based.
  - A separate "BodyMap" muscle-breakdown list (Upper Abs/Lower Abs/Deep Core/Obliques) also uses
    **alternating pale-gray / white row backgrounds** (zebra striping) instead of divider lines,
    each row ending in a blue circular outlined "+" icon button.
- **Cards**: the progress-chart screen ("Barbell Bench Press", "225 lb") is one large white
  rounded-corner card on a white page background, containing a headline stat, a red down-arrow
  trend glyph, a black filled pill-segmented time-range control ("14D / 1M / 3M / 6M / 12M /
  All"), a blue-outlined "1 Rep Max" pill vs. a gray-outlined "Volume" pill (two-option toggle
  rendered as two separately-shaped outline chips side by side, not a single joined segmented
  track), and a line chart; "Muscle Breakdown" below is a second, separate card with its own
  horizontal stacked-bar chart.
- **Apple Watch screens** (also shown in this listing): a rounded-rectangle numeric field
  ("15" over "LBS", "8" over "REPS") with a colored rounded-rectangle border when focused/selected
  (blue border) vs. a plain gray/white border when not, flanked by separate circular "–"/"+" icon
  buttons above the pair, and a large filled-blue pill "Log Set" button below — steppers here are
  literally circular icon buttons paired with bordered numeric display boxes, distinct from the
  phone UI's plain in-row text pattern.
- **Typography**: bold black for headline stats and titles, medium gray for secondary/meta text,
  numerals in the set table styled the same weight as surrounding text except for the
  active-row underline treatment noted above.

## Fitbod (Fitbod Inc.)

Source: [apps.apple.com/us/app/fitbod-gym-fitness-planner/id1041517543](https://apps.apple.com/us/app/fitbod-gym-fitness-planner/id1041517543)

- **Palette**: dark theme throughout all four screenshots sampled — near-black/very-dark-navy
  background, white/off-white text, a red/crimson accent for primary buttons and highlighted
  values, plus a secondary yellow/gold accent used for streak numerals and one progress bar.
- **Rows/lists — workout/plan screen**: each exercise in "Push Day" (Barbell Bench Press, Dumbbell
  Shoulder Press, Dumbbell Fly, …) is its own row with a square thumbnail photo, bold white title,
  gray meta line ("4 Sets • 7 Reps • 100 lb"), and a trailing "···" overflow-menu glyph; rows are
  separated by plain vertical spacing on the dark background — no divider line and no per-row
  card/border is visible, just gap-based separation directly on the page background. Header chips
  above the list ("45m ⌄", "Planet Fitness ⌄") are dark-gray filled rounded-pill buttons with a
  chevron.
- **Rows/lists — muscle-strength breakdown**: "Push Muscles"/"Pull Muscles"/"Leg Muscles" are three
  separate dark-gray rounded-rectangle cards stacked with a visible gap between them (gap-based,
  matching the M3 "expressive list" pattern); inside the "Push Muscles" card, however, the
  Chest/Shoulders/Triceps sub-rows *are* separated from each other by thin low-contrast horizontal
  divider lines — i.e., gaps between cards, dividers only for rows nested inside one card.
- **Set input control**: the most distinctive control in this survey — each set is a numbered
  circular badge (1–4; done sets show a green filled circle with a white checkmark, the current
  set is a white-filled circle with a black number, upcoming sets are gray-outlined circles with
  gray numbers) connected top-to-bottom by a thin vertical line, next to **two individually
  bordered rounded-rectangle text fields** side by side — one for "Reps," one for "Weight (lb)" —
  each field showing a small floating label above it only when relevant/focused. This is a third
  distinct pattern for compact numeric input: bordered free-text fields rather than +/- steppers,
  chips, or plain unstyled numbers. A red hexagonal "+ Add Set" affordance and a "Log All Sets"
  dark pill button with a separate red pill button beside it complete the row group.
- **Buttons/chips**: "Switch" (routine-swap) is a maroon/dark-red filled rounded-pill button with
  a bidirectional-arrow icon; "How-To" is an outlined-on-dark pill with a play-triangle icon;
  filter-style chips ("1:30 rest", "History", "Replace") are dark-gray filled rounded-pills with
  small leading icons, arranged in a horizontal scrolling row.
- **Typography**: bold/black-weight white headings, medium-weight gray secondary text, large bold
  numerals for headline stats (e.g., "68" strength score); condensed all-caps used for marketing
  headline text only, not in-app chrome.

---

## Cross-app observations (still purely visual, no rationale)

- **Divider-free, gap-based separation for top-level list items is the majority pattern**: Hevy
  (routines), StrongLifts (weekly plan cards), Fitbod (muscle-group cards) all separate their
  primary cards by page-background gap with no line. Where a divider *does* appear, it is almost
  always nested *inside* one card/section (Hevy's dark-mode feed card, Fitbod's per-card muscle
  sub-rows) rather than between independently-selectable top-level items — this matches, but was
  derived independently of, the M3 guidance already cited in
  `gym-row-card-selection-input-patterns.md`.
- **Four different answers to "how do you show a row is active/selected/done" were observed**,
  none of them a bare color swap on an otherwise-unchanged row: Strong (pale-green full-row tint +
  green check button), Hevy (solid green full-row fill), StrongLifts (filled numbered chip
  color-swap, not a row property at all), JEFIT (lavender full-row tint + blue-underlined values),
  Fitbod (colored circular status badge external to two bordered input fields, not a row-color
  change).
- **Four different answers to "how do you let someone adjust a number" were observed**, no two
  apps matching: Strong (chip-style "-30s"/"+30s" labeled buttons for a specific rest-timer
  control, not the main set editor), StrongLifts (row of tappable numbered status chips
  standing in for the stepper entirely), JEFIT (plain in-row numerals, no visible stepper
  chrome, with underline-on-active as the only cue; separately, bordered box + circular icon
  buttons on its Watch app), Fitbod (paired bordered rounded-rectangle text fields with floating
  labels). None of the five apps sampled used a plain unstyled "+/− text button" pair for its
  primary in-app (non-Watch) set editor.
- **Dark vs. light**: 3 of 5 apps sampled (Strong, Hevy's default, StrongLifts, JEFIT) are
  primarily light-themed in their App Store screenshots; Fitbod is dark-themed throughout; Hevy
  explicitly markets a separate true-dark theme alongside its light default.
