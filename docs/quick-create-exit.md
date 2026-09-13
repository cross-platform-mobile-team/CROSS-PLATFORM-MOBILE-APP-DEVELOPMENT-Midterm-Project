# Quick-create exit protection

2026-09-12, implemented after UI-spacing commit 4913c2d. User authorized
stepwise implementation, verification and publication to main-test.

## B1 slice and contract

TaskScreen exposes an exitActions builder with an asynchronous confirmExit
callback. AccountGateway's offline Return to sign in and Exit sample sandbox
buttons await it before removing the workspace. Ordinary actions stay separate.

- Empty/whitespace-only title with pristine metadata exits without a prompt.
- Nonempty title or changed metadata, including invalid raw dates, prompts
  Continue editing / Discard and leave. Confirmation dismissal means keep.
- No save is triggered by either exit decision. Kept drafts retain their fields;
  discarded drafts disappear with the old workspace and do not reappear later.
- In-flight repository work blocks exit with an explanatory message. Saving
  successfully resets the metadata dirty flag along with the existing form.
- Duplicate exit requests cannot open multiple confirmations. Async callbacks
  check mounted before removing a workspace. Credentials are not stored.

Only these two explicit destructive workspace switches are guarded. Account
settings push preserves the underlying workspace, so it does not ask to discard.
Account revocation/sign-out still clears the account normally; this change must
not block security invalidation or transfer drafts to another user. Browser-tab
close, process kill, system back/app exit and session recovery are not claimed.

## Verification design

Eight independent widget cases use fresh repositories and a no-network API
client: keep/discard, blank exit and metadata-only invalid-date exit in both
modes; a completer-controlled save verifies exit blocking and clean exit after
successful save. A new independent Windows case uses only the dedicated
`taskflow.integration.quick-create-exit.v1` preference key, removes it before
and after the test, and compares the saved record before/after discard and
workspace re-entry. No general preferences clear is permitted. Re-entry is not
a process restart. The local native total is now 11 across five invocations.

The eighth widget case protects metadata across an unrelated search rebuild.
Review found mutable draftDetails was reused as the form's initial baseline.
Editing metadata, searching, changing metadata and reverting that last edit
could clear dirty state even though the draft was not empty. The form revision
now always starts from empty metadata; the fields retain their own draft state.
rebuild-reproduction.txt captures the genuine pre-fix failure. rebuild-before.txt
is an earlier non-triggering test attempt, not a failure. Final coverage includes
the corrected regression; earlier 91-case logs precede this fix.

The first targeted attempt failed to compile because a fixture reused the fake
repository's gate field name. widget.txt preserves it. The renamed fixture
passed seven cases in widget-rerun.txt; this is a fixture correction, not a
fabricated product-defect experiment. Final commands/results are in the manifest.

The first independent native regression suite passed but discovery took
unusually long (the next case started at 01:31 after discovery at 00:05).
The final run of the same unchanged scenario ends at 00:13 after the metadata
baseline correction. Keep both logs; app source differs, so this is not a
controlled timing comparison. Do not infer a root cause or general stability
rate from either run. No timeout increase was made.

The final windows_workflow_test invocation later stalled in its metadata case
without an assertion result. At 20:56:53 local time its test-owned Debug process
10316 was responsive but the last progress marker remained 00:06 (last log write
20:54:36). Only that exact repository Debug process was stopped; the runner then
returned exit 1. windows_workflow_test-final.txt preserves the interrupted run.
workflow-rerun.txt is a separate rerun with unchanged source, not a relabelled
PASS. Root cause remains unconfirmed; --timeout 90s was not treated as proof of
a wall-clock process bound. No timeout increase or user-process cleanup occurred.

## Remaining work

B2 collapsed-field validation, visible invalid-field focus and boundary review
are next. The new native case is verified locally on Windows only; current CI
includes its widget counterparts through flutter test but does not invoke this
new native file. No Android/manual Narrator/OS-exit claim, no report work.
