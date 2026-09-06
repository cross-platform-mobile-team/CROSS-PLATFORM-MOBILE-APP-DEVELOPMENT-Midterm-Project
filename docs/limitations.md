# Remaining work

This basic project is not ready for final coursework submission.

- Notes/priority/dates/tags and filters remain planned. Title editing, confirmed
  deletion and one-level session undo are implemented.
- Golden/full E2E suites, accessibility audit,
  defect experiment and stability benchmarks remain.
- Windows release was built/launched, and one real-storage integration workflow
  passed. The extended test covers create/edit/complete/delete/undo and remounts
  the app with a fresh repository; it does not test an
  OS reboot or process restart. Android remains unverified due to missing SDK.
- No CI execution, APK, report, video or clean-machine reproduction claim.
- Local preferences have no backup/migration/multi-tab coordination. Invalid
  JSON is preserved and surfaced as an error rather than replaced silently.
- Retry reloads saved tasks; submit again to retry a failed write.
- Official report template, instructor and team details are required later.
