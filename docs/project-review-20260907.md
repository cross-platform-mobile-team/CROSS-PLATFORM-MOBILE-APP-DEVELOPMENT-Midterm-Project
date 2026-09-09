# Project review and next increment - 2026-09-07

Agent-assisted engineering review for student verification. Baseline: 62190d8 on
main-test, clean working tree before this increment. This is a functional/scope
review, not a penetration test, line-by-line security certification or final
coursework assessment. Generated build caches and binary assets are not treated
as application source; accepted golden images remain unchanged.

## Current system and evidence boundaries

| Area | Implementation/evidence | Remaining boundary |
|---|---|---|
| Flutter task flow | Immutable task/metadata, repository abstraction, controller writes before state publication, form/filter/dialog UI | Small collection, one-level session undo; no automatic conflict merge |
| Offline storage | SharedPreferencesAsync JSON, separately injected keys in native tests | No encrypted database, cross-process transaction or local backup service |
| Accounts/client | Account gateway, memory-only tokens, serialized refresh, remote revision invalidation after failed writes | Re-login after restart; no silent offline upload |
| Backend | Node HTTP, SQLite transactions, ownership, scrypt, rotating sessions, recovery, validation, backup, OpenAPI | Single process, no public deployment/SMTP/MFA/operational security audit |
| Unit/widget/golden | 49 cases with 8 controlled baselines; permanent substring-search regression | Account accessibility/manual screen-reader coverage still incomplete |
| Native E2E before this change | Two combined real-preference workflows, four fake-repository scenarios, one real API workflow | Independent create/edit/delete persistence scenarios were missing |
| Platform configuration | Windows runner, Web entry/manifest, Android runner and Internet permission | Android SDK absent; release signing still uses template debug configuration, not store-ready |
| Evidence and delivery | Raw logs, authentic fail/fix patches, reproducible run/backup scripts, local Release artifact | No online browser E2E, clean-machine install, CI or repeated-run study claim |
| Coursework | Prompt, requirements traceability, test matrix and architecture notes | Official metadata/templates, researched report, video, oral material and verified contributions remain |

Environment was rechecked with flutter --version, dart --version, flutter doctor -v
and flutter devices: Flutter 3.47.1, Dart 3.13.1, Windows 10.0.26200.9168,
Chrome 149.0.7827.201, Edge 152.0.4191.66. Windows C++ toolchain is usable; SDK PATH
warnings and absent Android SDK remain. No tooling was installed or SDK modified.

## Implemented next step

Added integration_test/persisted_scenarios_test.dart with three independent cases:

1. Fresh empty native storage -> valid create -> saved record -> fresh repository
   and UI remount show the same complete record.
2. Fixed seeded record -> edit title/notes -> complete -> fresh repository/remount;
   compare the full expected record so identity, creation time, priority, date and
   tags cannot silently disappear.
3. Target plus unaffected record -> cancel delete (no data change) -> confirm delete
   (only target removed) -> undo (full target restored once) -> remount. Check the
   unaffected record before/after and preserve the target's completed state.

Only three dedicated keys under taskflow.integration.persisted.* are removed
before/after tests. Production taskflow.tasks.v1 and other application preferences
are untouched. Each case supplies its own initial state and does not rely on any
other test. Helpers interact through visible controls and existing bounded settling.

These tests use actual native preference I/O, not the controlled in-memory fake.
Repository recreation and widget remount are not a process restart or OS reboot.
The test input channel is registered; physical keyboard/IME behavior is not claimed.
The seven required workflow categories now have independently reset coverage
across the persisted and controlled suites, but not on every claimed platform.
That distinction prevents declaring the whole project ready for submission.

## Next priorities

1. Web/Edge online workflow evidence with isolated test data, then a stable demo
   data entry point that cannot overwrite real tasks implicitly.
2. Manual keyboard/focus/screen-reader checks plus account form accessibility.
3. Repeated-run experiment and pinned CI; report raw outcomes, not inferred rates.
4. Clean-machine setup/release launch and authorized Android tooling if required.
5. Research/report/video/oral materials after official template/team details.

Exact PASS/FAIL/NOT RUN gates are indexed in evidence/manifest.md. Source and test
changes in this increment are local; previous Git publication is not standing
authorization to push subsequent changes.

Observed runner limitation: passing two integration files in one Flutter invocation
completed the first suite (2 cases), then failed to obtain a debug connection for
the second app. The second suite passed alone (4 cases) without source changes.
No app assertion failed in that combined run; the underlying launch failure has
not been proven. Preserve the failed output and use separate suite invocations;
do not increase timeouts or describe this as a measured stability result.
