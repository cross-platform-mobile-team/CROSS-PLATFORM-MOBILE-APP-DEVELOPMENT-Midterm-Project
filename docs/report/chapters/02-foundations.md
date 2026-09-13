# Testing foundations and comparative analysis

## Different tests answer different questions

Flutter distinguishes unit tests, widget tests and integration tests by the boundary under examination. Its testing overview recommends combining many focused tests with sufficient integration coverage of important use cases, while recognizing differences in dependencies, speed and maintenance (Flutter, n.d.-a). TaskFlow adds golden comparisons as a visual oracle and browser automation as an external check of the Web interface. These mechanisms overlap in coverage but are not interchangeable.

A unit test of TaskFilters can construct records directly and check the exact output order. It does not need a rendered search box or a device. A widget test can type a query into TaskScreen and check the resulting task widgets. This verifies the connection between an input event, controller filtering and the displayed list, while still allowing a fake repository. A native integration workflow uses an actual Windows application process and, in the persistence suites, the preference plugin. Its additional value is crossing those platform and storage boundaries, not merely executing a longer sequence of taps.

Figure 2.1 summarizes the evidence layers used in TaskFlow. The shape is a design principle rather than a measured ratio: inexpensive, focused checks should localize most rule failures, while selected workflows cover interactions that lower layers cannot establish. Golden and browser tests complement this structure rather than replacing its foundation.

![Figure 2.1 Testing layers and their TaskFlow evidence boundaries](assets/testing-layers.png)

## Binding and frame scheduling

A Flutter widget test requires a binding that coordinates the framework, rendered tree and test actions. The fixture mounts the app with pumpWidget, supplies dependencies and advances frames deliberately. The official pump API documents an important distinction: advancing time in a fake-async test environment differs from delaying a live test for the same duration (Flutter, n.d.-b). Therefore, a duration used in a widget fixture must not automatically be interpreted as a user-perceived delay on a device.

In TaskFlow, an asynchronous repository operation changes controller state before it produces a result. The controller sets busy, clears an earlier error and notifies listeners. The screen can now display loading and disable mutation actions while the repository future remains incomplete. When the future completes, the controller publishes either the confirmed task list or an error. A test that asserts only the final list can miss a broken intermediate state, such as an Add button remaining active and allowing duplicate work.

The loading tests use a Completer to keep the operation pending. They pump the initial frame, inspect the loading state, release the gate and only then settle the interface. This makes the relevant state observable without assuming a particular processor speed. A fixed sleep would instead mix the repository contract with host scheduling: it might be unnecessarily slow on one machine and too short on another.

## Settling and bounded waiting

pumpAndSettle repeatedly pumps frames until no frame remains scheduled, with a timeout. Its documentation warns that an indeterminate animation can prevent settling and recommends understanding the number of frames required by the interaction (Flutter, n.d.-c). TaskFlow has exactly this risk while an unresolved repository gate keeps a progress indicator active. Calling settle before completing the gate would wait for a condition that the test itself prevents.

The practical rule is to choose the wait from the expected state transition. During a controlled pending operation, pump enough to observe the frame and assert the disabled action. After completing a deterministic gate, settle the resulting short transition. In an external browser, wait for a visible message, task or verified focused input. During native application startup, retain build and connection logs because a timeout may occur before any business assertion runs.

The project also demonstrates the limitation of a timeout value. An earlier combined native invocation could not establish the next debug connection, while a separate unchanged invocation passed. Other retained native runs stalled during a workflow and required a standalone rerun. These observations do not identify a root cause. Increasing the timeout until a test passes would obscure whether the problem is application behavior, driver connectivity or the host environment.

## Finders and meaningful assertions

Finders connect a test action to a specific target. A key is useful when several controls have similar text, while a visible label helps express user intent. Flutter's byKey finder skips offstage widgets by default, which matters for hidden detail forms and inactive routes (Flutter, n.d.-d). A test that deliberately includes offstage elements needs a reason; otherwise it may interact with content the user cannot currently reach.

TaskFlow uses stable keys for metadata fields and visible text for actions such as Add task, Save changes and Retry. Task assertions are scoped to CheckboxListTile rather than the entire tree. Without that scope, a search test could succeed because the query text remained in the input field even though the expected task had disappeared. The permanent substring-search regression test checks the task row itself and also excludes an unrelated record.

Exact order is another important oracle. Checking that Alpha and Beta are both present does not establish that sorting works. The discovery scenarios compare the ordered result set after normalized search, status, priority and tag constraints have been combined. They also restore the unfiltered order through Clear filters, so a partially reset filter cannot pass by leaving an apparently plausible list.

## Fakes and dependency injection

The TaskRepository interface separates application behavior from storage. The in-memory implementation can delay or fail operations, the local implementation uses preferences, and the remote implementation exchanges revisioned snapshots with the API. Clock and ID generation are injectable in TaskController. A fixture can therefore define both temporal boundaries and stable identities instead of inheriting the machine's current date or generating unpredictable task keys.

A fake is a simplified working implementation, not a guarantee that the real dependency behaves identically. The in-memory repository is appropriate for inspecting error states because the failure can be produced at a known point. It cannot establish serialization compatibility with the preference plugin or isolation between two API accounts. Those questions require separate tests at the actual boundary. The project intentionally retains both controlled-repository scenarios and real-preference scenarios for this reason.

Test independence requires more than constructing a new screen. A repository object, storage key, unresolved future, test-input registration or viewport override can survive into another test if cleanup is incomplete. The native suites use dedicated preference keys and bounded helpers, and register and unregister the test text-input channel. They do not clear all preferences, which would risk deleting unrelated user data and weaken the precision of the test environment.

## Golden tests and visual change control

The matchesGoldenFile matcher compares rendered output against an expected image. The API supports images obtained from a finder, image object or bytes; finding the correct rendering boundary is part of fixture design (Flutter, n.d.-e). TaskFlow compares selected screens with fixed dimensions, vendored font fixtures and a controlled target-platform variant. The comparator supplies a visual difference signal, not an explanation of whether the new image is desirable.

The minimalist UI update changed background, accent, branding, capture layout and workspace navigation. Fifteen reference images were therefore intentionally reviewed and replaced. Treating every pixel difference as a defect would block a requested redesign. Automatically accepting every new image would remove the regression oracle. The required middle step is visual review: confirm that the difference corresponds to the intended change and that text, dialogs and actions remain readable.

Goldens are not sufficient accessibility evidence. A screenshot may look correct while a control has an empty accessible label. Conversely, a correctly labelled control may overflow at enlarged text. TaskFlow combines semantics checks, layout tests and visual baselines, and keeps manual screen-reader verification as a separate outstanding activity.

## Native integration and browser automation

The integration_test package lets an application-level workflow use Flutter testing APIs while running on a supported target. The official guide describes desktop, device and browser workflows, including driver-based browser setup (Flutter, n.d.-f). The local SDK rejected the specific direct Edge invocation attempted in this project. That recorded limitation must not be generalized into a claim that Flutter has no browser integration-testing route.

TaskFlow uses a compile-time-gated Web harness for deterministic browser validation, discovery and retry scenarios. It contains synthetic in-memory data and no API client. Playwright locators can use roles and accessible names and resolve their targets again for subsequent actions; its documentation also notes that role locators are not a substitute for an accessibility audit (Microsoft, n.d.). The actual-browser check complements widget testing because it observes Flutter's generated DOM semantics and browser focus behavior.

Patrol is a relevant alternative when test workflows need additional native interaction. Its documentation introduces a CLI, package integration and native setup requirements (LeanCode, n.d.). Patrol was reviewed as an alternative, not installed or benchmarked in this project. Adding another framework without a corresponding uncovered risk would increase setup and maintenance while contributing little new evidence to the current task-management scenarios.

Table 2.1 expresses the project's decision criteria. The entries are a qualitative assessment of the implemented fixtures, not measured universal rankings of frameworks.

Table 2.1 Test selection for TaskFlow risks

| Approach | Strongest local use | Important limit |
| --- | --- | --- |
| Unit | Validation and deterministic transformations | No rendered interaction |
| Widget | Form states, actions and draft preservation | Controlled environment and storage |
| Golden | Reviewed visual states at fixed sizes | Font and rendering sensitivity |
| Native integration | Plugin persistence and complete workflows | Build and driver complexity |
| Browser harness | DOM semantics and browser interaction | Synthetic repository in this harness |
| Node API tests | Authentication, isolation and revisions | No Flutter rendering |
