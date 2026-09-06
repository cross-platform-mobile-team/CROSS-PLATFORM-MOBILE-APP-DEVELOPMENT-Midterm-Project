# Implementation milestones

Current request: continue necessary work, update AGENTS.md and push to main/test.
The full coursework specification remains the roadmap, not a claim of completion.

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
