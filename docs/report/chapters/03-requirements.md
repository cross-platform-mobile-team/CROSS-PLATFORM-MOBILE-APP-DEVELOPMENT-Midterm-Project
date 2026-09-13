# Requirements and risk analysis

## Actors and workspace modes

TaskFlow has three user-facing workspace modes. An offline user manages tasks stored on the current device. A sample user explores temporary seeded tasks that are discarded on exit. An account user manages server-backed records belonging to the authenticated account. These modes share the task interface but differ in persistence, recovery and privacy boundaries. There is no background transfer from offline storage to the account backend.

The sample mode is an important part of reproducible demonstration. A presenter can search, edit and delete synthetic tasks without changing saved coursework data or creating a server account. Re-entering the sample recreates its known state. The interface must communicate that this is a session-only workspace; presenting it as synchronized or permanently saved would be a UX defect even if every button worked correctly.

The backend actor is the authenticated account, not an arbitrary user identifier supplied in a task request. Ownership is derived from the session. A request that knows another account's task ID must still be unable to read or change that account's record. This requirement is tested separately from the visible task-management flow because it is fundamentally an authorization property.

## Functional requirements and acceptance conditions

A valid task title is required and is normalized before persistence. Optional details include notes, a priority chosen from low, medium and high, a calendar date and normalized tags. Creation must produce exactly one stored record with stable identity; editing must preserve identity and creation time. Marking completion changes the task state without discarding its other fields. Deletion asks for confirmation, and undo restores the most recent deleted record during the current session.

Search normalizes surrounding whitespace and case. It examines title, notes and tags, while the exact-tag filter compares normalized tag values. Status, priority, due-date and tag filters combine rather than replace each other. Sorting must be deterministic, including ties. Clearing filters must reset both the visible query and filter state. Table 3.1 links these requirements to observable checks rather than to the presence of a screen or source file.

Table 3.1 Functional acceptance matrix

| Feature | Observable acceptance condition | Main evidence |
| --- | --- | --- |
| Create | One valid record appears and survives remount | Persisted create scenario |
| Validate | Readable error and corrected successful save | Widget and native validation |
| Discover | Exact matching set and deterministic order | Independent discovery scenario |
| Edit and complete | Updated fields and unaffected metadata survive | Persisted edit scenario |
| Delete and undo | Confirmation and full-record restoration | Native workflow |
| Recover | Failure is visible and retry retains relevant draft | Controlled repository tests |
| Isolate accounts | One account cannot access another's tasks | API and online workflow |
| Preserve visual usability | Compact, wide and enlarged text remain usable | Layout and golden tests |

## Nonfunctional requirements

Responsiveness is represented by observable intermediate states, not by an unmeasured performance claim. Repository work must not make the interface silently appear successful. The screen displays loading, disables duplicate mutations and offers a clear recovery action after failure. Selected loading tests validate their asserted scenarios, not every possible asynchronous interaction.

Accessibility requirements include readable labels, semantic headings, usable targets, keyboard interaction and layouts that tolerate enlarged text. The desktop search shortcut must actually focus the input. Status and priority must have text meaning rather than color alone. Automated checks can detect several violations, but a passing guideline test does not establish complete WCAG conformance or successful use with a particular screen reader.

Reproducibility requires a known initial state, retained dependency lockfile, documented platform configuration, synthetic test data and evidence that can be mapped to a command and environment. A generated Android folder is insufficient platform evidence. A release executable without its required neighboring Windows files is also insufficient distribution evidence. These requirements shape the documentation and artifact strategy as much as the application code.

## Risk priorities

The highest data-integrity risks are overwriting an unknown snapshot, replaying an uncertain remote save, crossing account boundaries and discarding a user's unsaved changes. Visual polish has value, but it does not compensate for these failures. A second priority is interaction ambiguity: duplicate submissions, hidden validation, unreachable controls, inaccessible labels and unclear workspace persistence. A third is evidence ambiguity, such as attributing a historical CI result to newer source or confusing remount with process restart.

Table 3.2 records the risk-oriented reasoning behind the test design. Severity here is a project triage judgment, not a formal security certification. It guides the order of further investigation and does not imply that all possible risks have been enumerated.

Table 3.2 Risk controls and remaining evidence gaps

| Risk | Implemented control | Remaining boundary |
| --- | --- | --- |
| Unknown local snapshot overwritten | Successful load required before mutation | External storage corruption recovery |
| Timed-out remote save replayed | Revision invalidated until reload | Manual conflict resolution |
| Cross-account record access | Session-derived owner and scoped SQL | Independent security assessment |
| Accidental workspace exit | Explicit draft-discard confirmation | OS close and browser reload |
| Visual regression | Reviewed goldens and large-text tests | Full manual assistive-technology use |
| Misleading platform claim | Dated platform evidence with exact scope | Clean-device release installation |

## Investigation boundaries

The project deliberately excludes collaboration, chat, real-time synchronization, social features and automated offline migration. The backend is a local development service with account functionality; there is no claimed SMTP service, email verification or multi-factor authentication. The report also does not equate a memory-only token policy with complete endpoint or operating-system security.

This bounded scope is suitable for the selected testing topic because it provides enough interactions to expose realistic defects without requiring unrelated infrastructure. The acceptance criterion is explanatory and reproducible evidence about those interactions. Adding a new feature is justified only when it addresses a specific requirement or uncovers a testing mechanism that the existing demonstration cannot show.
