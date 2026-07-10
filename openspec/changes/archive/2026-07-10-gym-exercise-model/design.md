## Context

Issue #95 is the first slice of the Phase 3 gym epic (#16): a bare `Exercise` data model, no storage/UI/backend sync. The existing `universal/lib/models/checklist.dart` is the only precedent for a Flutter model in this codebase, and it uses name-as-identity — fine there because nothing outside a `Checklist` ever references a `ChecklistItem`. `Exercise` is different: CONTEXT.md's `Exercise Entry` and `Planned Exercise` both reference an `Exercise`, and an Exercise's name is expected to be correctable later (typo fixes). That distinction was worked out in a grilling session and recorded as ADR-0015.

## Goals / Non-Goals

**Goals:**
- Define `Exercise`'s shape (`id`, `name`) and serialization, matching `ChecklistItem`'s style (immutable, `copyWith`, `toJson`/`fromJson`).
- Encode id-as-identity at the API level, not just as a documentation convention.

**Non-Goals:**
- id generation (client UUID vs. server-assigned) — deferred to a future storage/catalog issue, blocked on #16's offline-vs-local-first decision.
- Name uniqueness enforcement, reuse-by-name matching, reject-on-rename-collision — real domain rules (now in CONTEXT.md) but they require a container/service to enforce, which doesn't exist yet. `ChecklistItem` follows the same split: `Checklist.addItem` dedups, `ChecklistItem` itself doesn't.
- `==`/`hashCode` override — no dedup/Set usage exists in this issue's scope; premature.

## Decisions

**`id` is a required, caller-supplied constructor parameter.** The model does not generate its own id. Alternative considered: generate a UUID internally (e.g. via a `uuid` package, which isn't currently a dependency). Rejected because generation timing/scheme is a storage-layer decision that depends on the still-open offline-vs-local-first question in #16 — baking a scheme in now risks rework.

**`copyWith` does not accept an `id` parameter.** Only `name` can be overridden. This makes "id never changes after construction" a property of the type signature, not just a convention — a caller cannot accidentally reassign identity through `copyWith`, unlike `ChecklistItem.copyWith`, which exposes every field. Changing an Exercise's id (if ever needed) requires constructing a new instance explicitly.

**No validation in the constructor.** `name` is accepted as-is, including empty strings — mirrors `ChecklistItem`, which also does no validation (trimming/dedup happens one layer up, in `Checklist.addItem`). Validation belongs to whatever future storage/catalog layer creates Exercises from user input.

**`fromJson` throws on missing fields rather than defaulting.** Matches `ChecklistItem.fromJson`'s existing behavior (`as String` casts throw on null/missing keys) — no new error-handling pattern introduced.

## Risks / Trade-offs

- **[Risk]** Excluding `id` from `copyWith` could be seen as inconsistent with `ChecklistItem`'s pattern by a future reader. → **Mitigation**: ADR-0015 and this design doc record the rationale explicitly.
- **[Risk]** Deferring id generation means `Exercise` can't be constructed end-to-end (no storage layer exists yet to call the constructor with a real id) — this issue only ships the model + unit tests, which construct `Exercise` directly with test-supplied ids. → **Mitigation**: acceptable per issue #95's explicit scope; the storage/catalog issue picks this up next.

## Open Questions

- id type/generation scheme (String UUID vs. server-assigned) — resolved when the storage/catalog issue is proposed, after #16's offline-vs-local-first decision lands.
