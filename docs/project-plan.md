# Implementation milestones

Current request (2026-09-07): add independent native E2E discovery/recovery and
compact/wide validation scenarios, verify them and the existing quality gates,
update README/AGENTS and publish the backend plus this increment on `main-test`.
Acceptance: fresh state per scenario, exact filtered order, observable loading,
failed writes retain drafts/data, and explicit Retry recovers without duplication.
The full coursework specification remains the roadmap, not a claim of completion.

Acceptance verified: 4 independent native cases pass; format/analyze, 49 Flutter
tests (plain and coverage), 14 API tests, 2 native preference workflows, 1 native
online workflow and Windows/Web release builds pass. Android remains NOT RUN.
Evidence: docs/evidence/manifest.md. Next: independent edit/delete workflows,
browser evidence, stable demo-data entry, accessibility and repeated-run studies.

1. Verify SDK and repository. Preserve existing instructions.
2. Implement a first slice: validated title, local persistence, list, completion,
   search, loading and recoverable errors. Use repository injection and a clock/ID seam.
3. Verify domain/controller/widget behavior, analyze and build Web.
4. Commit the bootstrap and push to the user's repository.
5. Continue the testing case study, platform evidence, report and presentation.

Data model for bootstrap: immutable ID, title, createdAt and completed status.
Storage writes must succeed before publishing new state. Failed loads retain stored
data; retries read again. Test fakes isolate storage and can fail the next operation.

2026-09-06 milestone: title editing, delete confirmation and one-level session undo.
Acceptance: validation and write-failure recovery, preserved task fields, no concurrent
mutations, phone/wide widget flows and a persisted native Windows workflow.

2026-09-06 metadata milestone: notes (2000 characters), priority, calendar date,
normalized tags (10 x 24 characters), combined filters, deterministic sorting and
legacy JSON defaults. Acceptance includes validation, immutable tags, date boundaries,
preservation through edit/toggle/undo, phone/wide forms and native persistence.

2026-09-06 verification milestone: eight reviewed golden baselines, four automated
accessibility guideline states, keyboard/text-scale checks, stronger error text,
and controlled substring-search defect with genuine baseline/fail/fix-pass logs.
Acceptance: no golden updates in normal tests, corrected production search,
39 local tests and two Windows workflows passing; format/analyze and release builds.

Next: independently reset native scenarios (especially search/filter/sort and
failure/retry), browser automation, manual accessibility, demo seed entry point,
timing/stability methodology and pinned CI. Then clean-machine reproduction and
research/report/video/oral materials after official/team information is supplied.

2026-09-07 backend milestone: local Node/SQLite API; registration, opaque rotating
sessions, recovery codes, profile/password/account actions; isolated task CRUD,
discovery, statistics, revision-checked snapshots; Flutter gateway and remote
repository. API reference, backup utility and setup scripts included. Acceptance:
API/client tests and real Windows online workflow demonstrate ownership and stale
write rejection while old offline tests/goldens continue to pass. See backend-plan.md
and the latest evidence manifest for the exact current checks and limitations.
