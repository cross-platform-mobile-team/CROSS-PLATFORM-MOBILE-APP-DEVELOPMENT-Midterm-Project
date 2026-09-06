# Remaining work

This basic project is not ready for final coursework submission.

- Notes/priority/dates/tags, filters, editing, confirmed deletion and one-level
  session undo are implemented. Dates currently use a validated text field.
- Golden/full E2E suites, accessibility audit,
  defect experiment and stability benchmarks remain.
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
