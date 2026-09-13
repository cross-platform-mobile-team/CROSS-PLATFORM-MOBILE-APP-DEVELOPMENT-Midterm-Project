# Draft consistency verification — 13 September 2026

Source: 39dd199 plus the local task_screen.dart fix and pending_capture_test.dart.
The pending save owns its submitted snapshot, not newer input. An unchanged
draft is cleared only after success. Busy submissions return without validation.

Commands and results:
- flutter build web --no-pub --no-web-resources-cdn: PASS (web-build.txt);
  compilation only, not a new browser-interaction run.
- flutter test --coverage --no-pub --reporter expanded: PASS, 100 cases (flutter.txt).
- flutter analyze: PASS (analyze.txt).
- node --test backend/test/*.test.js: PASS, 14 cases (backend.txt).
- flutter test integration_test/quick_create_exit_test.dart -d windows --no-pub --reporter expanded: PASS, 1 case (windows.txt).
- dart format --output=none --set-exit-if-changed .: initial FAIL due solely to
  ignored build/report-audit/pending_capture_test.dart; formatted that diagnostic
  copy, rerun PASS (format.txt and format-rerun.txt). No golden replacements.

The original capture failure remains in docs/report/evidence/pending-capture.txt.
The manuscript describes corrected behavior, not an open issue catalogue.
Android, complete native selection, browser interaction and manual accessibility
were not rerun for this patch; historical results retain their original scope.
