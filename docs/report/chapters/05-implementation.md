# Implementation and platform behavior

## Responsive workspace and interaction design

The current interface uses a desktop-first workspace without removing the compact layout. A wide window places navigation beside the task canvas. The canvas groups progress, quick capture, search, discovery controls and task content. At smaller widths the layout adapts rather than retaining a desktop sidebar that would leave too little room for titles and form fields. Status and priority remain textually identifiable instead of being communicated by color alone.

The visual system combines violet, mint and peach accents with readable surfaces and explicit status text. The October audit makes compact capture and active filters clearer, adds removable conditions and separates search reset from filter reset. Figure 5.1 shows the current controlled wide fixture. Visual changes alone do not establish runtime speed; the profile experiment in Chapter 6 measures the separate transition to lazy list construction.

![Figure 5.1 Wide TaskFlow layout from the controlled golden fixture](assets/ui-wide.png)

Figure 5.1 is a test-rendered fixture, not a photograph of a deployed production system. Its value is the inspectable arrangement and the maintained visual baseline. Runtime behavior requires the integration and browser evidence discussed later. The interface exposes a completion summary and navigation counts derived from task state, so a completion action has more than one observable effect that can be asserted.

![Figure 5.2 Compact TaskFlow fixture at 390 by 844 logical pixels from the October audit](assets/ui-phone.png)

Figure 5.2 shows the compact layout with quick capture, search, status selection and visible task metadata. This deterministic golden render uses synthetic records and an injected clock; it is not an Android device capture. The partially visible second card indicates scrollable content rather than a requirement to fit every record on one screen.

## Capture and edit forms

Quick capture accepts a title and optional task metadata. The Enter action provides a keyboard path in addition to the visible add control. Date and priority affordances keep frequent metadata close to capture, while additional details remain available. Required-field errors are shown in the form rather than only in a transient message. Validation tests check unsuccessful submission and correction, not just the presence of a validator function in source code.

The edit dialog retains a draft until a successful save. Dirty-state protection applies to explicit cancellation, Escape and back navigation, including raw date text that does not yet parse into a valid date. The pending-save state also constrains exit actions. Separate tests protect the distinction between a changed parsed value and invalid raw input; otherwise a user could type an invalid date and lose it because the form incorrectly considered itself unchanged.

Quick-create workspace exits likewise check whether a draft should be discarded. Each asynchronous save captures its submitted title and metadata. Completion resets the form only when its current draft still matches that submission; newer input is retained for the next task. Four controlled widget cases verify this behavior at compact and wide sizes for successful and unsuccessful writes, including duplicate-submit prevention and the subsequent save. These protections concern explicit workspace transitions. They do not establish a general operating-system-close, browser-refresh or crash-recovery guarantee.

## Discovery and stable results

Search normalizes input and performs substring matching. The intentional-defect experiment deliberately violates that rule with prefix-only matching. Filters combine, so a result must satisfy the selected conditions rather than satisfying any single one. Sorting is stable and deterministic. Together these requirements enable exact list assertions: the test can compare the expected task set and order rather than accepting any nonempty result.

Search has a keyboard shortcut, and filter and sort controls retain meaningful labels. Clearing discovery conditions returns the user to an understandable state. A no-match result is distinct from an empty repository: the first invites changing the search or filters, while the second invites creating a task. Tests should preserve this distinction because showing the wrong empty state can hide a still-active filter and make a saved record appear lost.

## Loading and recoverable failures

The loading state is not verified by waiting for an arbitrary delay and hoping the repository remains busy. A test-controlled completion gate holds the operation open. The test can then inspect disabled actions, the progress indication and draft state before releasing the operation. A separate failure path verifies the readable error and an explicit recovery action. This pattern makes intermediate UI states testable even when normal local storage is fast.

Save failures are tested independently from initial-load failures. They have different data risks: a failed initial load must not permit replacement of unknown data, while a failed save must preserve the previously accepted collection and useful draft input. Remote write failures also require revision recovery. A generic error screen alone would not establish these invariants, so the assertions inspect both visible state and repository results.

![Figure 5.3 Retained edit draft and latest saved version in the controlled recovery fixture](assets/ui-edit-recovery.png)

Figure 5.3 makes the recovery decision visible: the form retains the user's draft while an expandable section shows the latest saved version. Applying the draft is an explicit action. This golden fixture illustrates presentation; the controlled recovery tests verify that reload does not write, server completion status is preserved and a lost replacement response does not create a duplicate.

## Account workflows and backend integration

The account gateway supports registration, sign-in and recovery. Signed-in settings expose profile, password, session and account-deletion actions. A task repository is scoped to the current account session. The application does not reuse a successful response from an older account generation to populate a later account's workspace. Backend tests exercise account isolation and concurrent writers, while the native online workflow crosses the actual HTTP and SQLite boundary.

The local server is started with the repository's PowerShell helper. The isolated online test uses synthetic accounts and a dedicated test database. Such accounts must not be created against a production service. The default loopback endpoint is suitable for the local development arrangement but is not a public deployment address. A physical Android device would require reachable networking and a suitable HTTPS backend for account-mode validation.

Node's SQLite module provides the database interface used by the server. The local runtime is Node 22.14.0; current online documentation may describe later versions, so runtime claims in this report are tied to the recorded environment rather than inferred from the newest documentation (Node.js, n.d.). No npm runtime dependency is required for the inspected backend. This reduces setup components but does not remove the need to monitor the runtime or assess deployment security.

## Platform and accessibility boundaries

Windows and Android each supply 15 native case executions, including controlled repositories, real preferences, draft protection and an isolated API/SQLite workflow. The local Android 16/API 36 emulator also passed release APK installation, cold launch and an offline task check after force-stop and relaunch. Edge supplies retained browser interactions through a controlled harness and a separate account-lifecycle test. These results do not establish physical Android device testing. The iOS runner is scaffolded but build and execution remain unverified because this Windows host has no Mac/Xcode toolchain.

The Android environment keeps the SDK, AVD, Gradle and Pub caches on drive D. The online emulator test reaches the host API through 10.0.2.2. Debug network policy permits HTTP only for that address and loopback hosts; release policy is unchanged. Release builds use normal dependency refresh after integration testing so the generated plugin registry matches the target. The coursework APK uses debug signing, not production signing.

Automated accessibility checks cover selected semantics, target-size and contrast conditions, form traversal and enlarged text. Flutter's accessibility testing documentation describes programmatic guidelines that assist such checks (Flutter, n.d.-g). The full manual screen-reader and page-wide keyboard protocol remains unexecuted in the retained status. A meaningful semantics tree is a necessary part of access, but it does not prove the quality of a complete spoken interaction.

Logical viewport overrides verify layout at specified sizes, not physical resizing or rotation. Native suites register an injected text-input channel; they do not validate a real Windows or Android IME. These input checks remain part of manual acceptance.
