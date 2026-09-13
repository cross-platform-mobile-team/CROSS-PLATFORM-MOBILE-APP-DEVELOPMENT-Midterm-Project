# System design

## Architecture and dependency direction

TaskFlow separates presentation, application decisions and storage. The task screen renders controller state and collects user intent. TaskController coordinates validation, mutation and error reporting. TaskRepository defines the load and save boundary. Local preferences, the controlled in-memory repository and the HTTP repository satisfy the same contract. Domain records do not need to know whether a task was loaded from a browser preference store or a remote SQLite database.

This arrangement makes the test boundary explicit. A widget test can mount the real task screen and controller with a controllable repository. A persistence test can replace that repository with the real preferences implementation while retaining the same user workflow. An account integration test additionally exercises the client, HTTP transport and database. The interface reduces duplicated interaction code, but it does not make those environments equivalent: only the latter tests cross the corresponding production boundaries.

![Figure 4.1 Dependency boundaries and the three repository modes](assets/architecture.png)

The controller receives a clock and an identifier generator. Tests can therefore expect a particular record identity and creation time instead of depending on the wall clock or an unpredictable identifier. This is especially important for deterministic ordering and for checking that editing preserves identity. It also prevents an apparently successful edit from being mistaken for deletion followed by creation of a different record.

The account feature introduces a separate session lifecycle. Authentication gates entry to the remote workspace, while the offline and sample entries remain available independently. A sign-in does not migrate local records. That explicit separation avoids an ambiguous ownership decision and makes account-isolation tests meaningful: a task in one workspace must not appear merely because the same device previously opened another workspace.

## Domain model and persistence representation

A task contains an identifier, title, notes, priority, optional calendar due date, tags, completion state and creation time. Title validation trims surrounding whitespace and requires a nonempty value within the supported length. Notes have a bounded length. Tags are normalized and deduplicated; priority is a finite choice rather than unrestricted text. A due date represents a calendar date, not an instant whose displayed day should move when the time zone changes.

The distinction between calendar dates and timestamps is preserved in the API. The due date uses a validated year-month-day representation. Creation timestamps require an explicit time-zone indication and are canonicalized. Existing creation time cannot be silently rewritten during a later update. These constraints support stable order and a more useful persistence oracle than merely counting the visible rows.

Table 4.1 Main validation and ownership constraints

| Field or boundary | Constraint in the inspected implementation | Reason for testing |
| --- | --- | --- |
| Title | Trimmed, 1 to 120 characters | Reject empty and overlong records |
| Notes | At most 2000 characters | Keep client and API validation consistent |
| Tags | At most 10 input tags, each 1 to 24 characters; normalize and deduplicate | Prevent ambiguous filter behavior |
| Priority | Three supported values | Reject invalid serialized values |
| Due date | Strict calendar date or no date | Reject impossible dates and preserve the intended day |
| Task collection | At most 500 records on the server | Bound accepted snapshot size, not prove UI performance |
| Task identity | Unique within one account | Prevent duplicate records in a replacement snapshot |
| Existing creation time | Preserved across remote updates | Keep identity and ordering stable |

The backend stores a user's tasks under a composite account-and-task key. Task payloads are serialized JSON, while users, sessions, used refresh tokens and audit entries have separate relational records. This is a deliberately small coursework design. It avoids building a general query service, because the Flutter client performs discovery over its loaded collection. The trade-off is that snapshot writes become less attractive as collections and simultaneous writers grow.

![Figure 4.2 SQLite ownership and session relationships](assets/data-model.png)

Foreign-key deletion cascades keep dependent sessions, tasks and audit records associated with the owning account. A used refresh-token digest belongs to a session, allowing the service to recognize replay after token rotation. Password and token representations have different purposes: passwords use a salted password derivation function, while randomly generated session tokens are stored as digests. Neither mechanism means that the entire SQLite file is encrypted.

## Controller state and successful writes

The controller exposes tasks, busy state and an error message. Before a mutation is allowed, a load must have succeeded. A failed reload invalidates that permission. Without this rule, an empty or stale in-memory collection could replace a saved snapshot whose contents were never successfully obtained. The guard is therefore a data-integrity requirement rather than simply a loading animation decision.

Mutation methods construct the proposed next collection and await repository persistence before publishing it as the controller's successful state. If saving fails, the previous collection remains authoritative in the UI, and an explicit retry or reload can be offered. Busy state prevents a second controller operation from overlapping the first. These decisions are covered at the controller and widget boundaries, but they do not by themselves guarantee that every editable form preserves later input.

![Figure 4.3 State transitions around loading and mutation](assets/state-flow.png)

Delete and undo follow the same persistence rule. The one-level session undo retains the deleted record and restores its complete data when valid. It is not a persistent recycle bin and does not promise recovery after closing the application. Tests compare the restored record, including metadata and identity, and verify that an unrelated record has not changed. Such assertions address accidental partial reconstruction more directly than a snackbar-only assertion.

## Remote concurrency and uncertain outcomes

The HTTP repository loads both the task snapshot and its revision. A subsequent write supplies that revision. The server begins an immediate SQLite transaction, compares the expected revision, replaces only the owning user's collection, increments the revision and commits. A stale writer receives a conflict instead of overwriting changes based on an older snapshot. SQLite documents transactions and immediate transaction behavior; the account scoping and revision protocol are TaskFlow's own application design (SQLite, n.d.).

The client treats a failed remote write as an uncertain outcome. A connection failure can occur after the server commits but before the response reaches the client. Retrying the same assumed revision without reloading would be unsafe. The repository therefore invalidates its locally remembered revision after a write failure and requires a fresh load. This does not implement automatic conflict merging; it prioritizes avoiding an unexamined overwrite.

Whole-snapshot replacement is easy to reason about for the small test dataset and makes rollback assertions straightforward. Its cost is repeated transfer of records that did not change, and a broad conflict boundary when different clients edit different tasks. Per-task endpoints also exist on the server, but the inspected Flutter repository uses the snapshot route. A future change to per-record synchronization would require a new contract and tests for partial success, deletion conflicts and reconciliation rather than merely substituting an endpoint URL.

## Session security and operational limits

The service uses random access and refresh tokens, stores their digests, rotates refresh tokens and can revoke sessions. Access lifetime is 15 minutes and session lifetime is seven days in the inspected configuration. A maximum of ten sessions per account bounds retained active sessions. Refresh-token reuse revokes the affected session family. Recovery codes are shown to the account owner and are not a substitute for email verification or an external identity provider.

The Flutter client keeps tokens in memory. Restarting the application therefore requires sign-in. A refresh request is shared when several requests need renewal, and generation checks stop an older asynchronous result from modifying a newer session. Wrong-current-password responses are distinguished from an expired authentication token. These are specific race and error-classification controls, not a claim of comprehensive security certification.

The backend uses salted scrypt hashes and bounded concurrent derivation work. Request size and request rates are bounded. Browser-origin restrictions do not replace server authorization. Non-loopback clients require HTTPS. These controls have not undergone an independent security assessment or sustained-load study.
