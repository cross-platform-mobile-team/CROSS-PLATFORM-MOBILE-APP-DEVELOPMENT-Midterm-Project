# Remaining work

This basic project is not ready for final coursework submission.

- Notes/priority/dates/tags, filters, editing, confirmed deletion and one-level
  session undo are implemented. Dates currently use a validated text field.
- Eight goldens and selected automated accessibility checks now pass; full E2E
  scenario coverage, manual accessibility and stability benchmarks remain.
- The controlled search defect is detected at widget level, with genuine
  fail/fix evidence. It is not a native E2E experiment or a flakiness benchmark.
- Golden fixtures use the Android rendering variant on a Windows test host,
  not an Android device. Raster equality is not established across host/SDK versions.
- Accessibility checks cover four visible list/form states, one focus transition
  and opening/cancelling Edit at 200% text; they are not a complete focus-order,
  screen-reader or WCAG compliance audit.
- Windows release was built/launched, and two real-storage integration workflows
  passed. Tests cover CRUD and metadata/filter interaction, then remount
  the app with a fresh repository; it does not test an
  OS reboot or process restart. Android remains unverified due to missing SDK.
- No CI execution, APK, report, video or clean-machine reproduction claim.
- Local preferences have no backup/migration/multi-tab coordination. Invalid
  JSON is preserved and surfaced as an error rather than replaced silently.
- Retry reloads saved tasks; submit again to retry a failed write.
- Native tests register Flutter's test input channel to prevent interference from
  Windows IME when injecting text. They do not establish physical-keyboard/IME
  compatibility. A separate manual keyboard/accessibility pass is still required.
- Official report template, instructor and team details are required later.
