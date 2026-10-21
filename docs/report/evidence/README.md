# Historical report preparation evidence

Classified as historical on 21 October 2026. Raw filenames, bytes and locations
are preserved because the report and [capture-fix record](../../evidence/capture-fix/README.md)
reference them. This classification date is not a new test execution date.

| File | Recorded purpose and boundary |
| --- | --- |
| [analyze.txt](analyze.txt) | Original static-analysis output; no issues found |
| [backend.txt](backend.txt) | Historical API run with 14 passing cases |
| [flutter.txt](flutter.txt) | Historical Flutter run with 96 passing cases |
| [pending-capture.txt](pending-capture.txt) | Original failure showing a newer draft being cleared |
| [pending_capture_test.dart.txt](pending_capture_test.dart.txt) | Probe source associated with the retained failure |

The capture finding and later correction are described in the
[resolved review record](../DEFERRED_REVIEW.md). These logs do not establish
results for the current 133-case suite. For later results and source boundaries,
use the [October UI/UX evidence](../../evidence/uiux-audit-20261011/README.md) and
[Android follow-up](../../evidence/android-loopback-20261011/README.md).
