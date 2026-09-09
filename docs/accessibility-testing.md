# Accessibility verification

This document separates automated checks from manual assistive-technology
evidence. Passing widget guidelines does not establish WCAG conformance or prove
that a screen reader works correctly on every supported platform.

## Automated coverage - 2026-09-09

The account entry screens already cover invalid login, registration and recovery
forms, a keyboard transition from email to password, and registration at 200%
text. `test/widget/account_settings_accessibility_test.dart` now extends that
coverage to the signed-in account settings screen.

The new checks use a synthetic signed-in account and an in-memory HTTP mock. They
verify:

- semantic headings for the account, Profile, Password and security, and Active
  sessions;
- inline profile/password validation and an announced account-deletion error;
- focus returning to the first invalid field;
- Tab from display name to Save profile, then to current password;
- the current-password Next action moving to the new-password field;
- the new-password Done action validating without sending an invalid request;
- labeled controls, Android-sized tap targets and text contrast; and
- scrollability, error visibility and absence of overflow at 200% text on a
  390 x 900 logical-pixel surface.

Account settings uses explicit ordered traversal inside the profile and password
form groups. It also supplies native autofill hints and IME Next/Done actions.
This preserves normal document order for the dynamic session list while making
the critical credential sequence deterministic.

Reproduce from the repository root:

```powershell
& 'C:\Users\LENOVO\flutter-sdk\bin\flutter.bat' test `
  test/widget/account_settings_accessibility_test.dart --reporter expanded
```

Raw output is indexed in `docs/evidence/manifest.md`.

## Manual keyboard and screen-reader protocol

Status: **NOT RUN**. A team member must perform this protocol and capture the
actual outcome; do not convert this checklist into a PASS without observation.

Use a clean synthetic account and avoid showing its recovery code, password or
tokens in recordings.

1. Record Windows, Edge, Flutter and screen-reader versions.
2. Launch the default Web build in Edge at 1280 x 900 and zoom/text scaling at
   100%. Repeat the critical form pass at 200%.
3. Enable Narrator, then navigate from the address bar into the Flutter app.
4. On sign in, registration and recovery, verify that headings, field labels,
   password visibility control, helper text, validation errors and busy state are
   announced once and in a useful order.
5. Sign in and open Account settings. Traverse only with Tab/Shift+Tab. Expected
   high-level order is Display name -> Save profile -> Current password -> New
   password -> Change password -> dynamic session actions -> Sign out -> Sign out
   all sessions -> Delete my account. Record any browser or embedded suffix-icon
   stops rather than hiding them.
6. Submit each form empty. Verify focus returns to the first invalid field and the
   corresponding error is announced. Trigger account deletion without a password
   and verify the same behavior.
7. Open the deletion confirmation using keyboard activation. Verify focus is
   trapped in the dialog, its title/body are announced, Escape/Cancel is safe, and
   focus returns to Delete my account after cancellation.
8. At 390 x 844 and 1280 x 900 browser viewports, verify no content is clipped and
   every action remains reachable at 200% text. Check visible focus indicators and
   contrast in both normal and error states.
9. Stop Narrator and save a short result table with PASS/FAIL per step, observed
   focus sequence, defects, screenshots/video timestamps and retest evidence.

Manual screen-reader behavior, physical keyboard/IME behavior, complete page-wide
focus order and other assistive technologies remain unverified until this protocol
is executed on the claimed release build.
