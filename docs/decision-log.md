# Bootstrap decisions

- Constructor injection and Flutter ChangeNotifier suit this single feature.
- shared_preferences 2.5.5 was resolved by pub. The downloaded package README and
  BSD license were inspected on 2026-09-05. The Flutter-maintained plugin supports
  Android/Web/Windows; the SDK has no uniform persistence API across these targets.
  Async API avoids the legacy process-local cache. This is small non-critical
  data; preferences do not guarantee disk durability. Reconsider a database later.
- Persist before publishing new state; failed writes preserve the prior list.
- Sort newest first and use ID ascending for ties; inject clock/ID in tests.
- Keep Flutter 3.47.1 fixed for a reproducible baseline.

- Metadata uses optional top-level JSON keys in the existing storage format, so
  legacy tasks receive defaults without destructive migration. Tags are immutable.
- Calendar dates serialize as YYYY-MM-DD (no UTC conversion). Overdue excludes
  completed tasks. Other due filters combine with the selected status via AND.
- Keep quick creation compact with optional details; share metadata form fields
  between creation and editing. No additional dependencies were introduced.
