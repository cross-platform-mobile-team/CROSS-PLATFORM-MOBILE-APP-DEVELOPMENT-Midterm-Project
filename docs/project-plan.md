# Bootstrap plan

Current request: create a basic project and push it to the designated GitHub repository.
The full coursework specification remains the roadmap, not a claim of completion.

1. Verify SDK and repository. Preserve existing instructions.
2. Implement a first slice: validated title, local persistence, list, completion,
   search, loading and recoverable errors. Use repository injection and a clock/ID seam.
3. Verify domain/controller/widget behavior, analyze and build Web.
4. Commit the bootstrap and push to the user's repository.
5. Later: notes/priority/dates/tags, advanced filters, golden and
   native E2E suites, defect experiment, platform evidence, report and presentation.

Data model for bootstrap: immutable ID, title, createdAt and completed status.
Storage writes must succeed before publishing new state. Failed loads retain stored
data; retries read again. Test fakes isolate storage and can fail the next operation.

2026-09-06 milestone: title editing, delete confirmation and one-level session undo.
Acceptance: validation and write-failure recovery, preserved task fields, no concurrent
mutations, phone/wide widget flows and a persisted native Windows workflow.
