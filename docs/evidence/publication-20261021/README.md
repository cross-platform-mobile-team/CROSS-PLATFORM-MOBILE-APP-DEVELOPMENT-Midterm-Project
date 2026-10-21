# Report publication checks 21 October 2026

Scope: refreshed report, current UI figures, video script, repository cleanup,
exact duplicate evidence consolidation and a reproducible LaTeX-only builder.
Application source and test baselines are unchanged from a153046. The checks
below are fresh local runs on the documentation working tree before commit;
they do not replace the dated October native evidence.

Environment: Windows host, Flutter 3.47.0 / Dart 3.13.0, bundled Node 24.19.0.
The API runtime here differs from the historical Node 22.14.0 environment.

| Check | Outcome | Raw output |
| --- | --- | --- |
| Dart format over lib, test, integration_test and test_driver | PASS, 70 files, zero changed | [format](dart-format.txt) |
| Flutter analyze | PASS, no issues | [analysis](flutter-analyze.txt) |
| Flutter test with coverage | PASS, 133 cases | [Flutter output](flutter-test.txt) |
| Node API test | PASS, 17 cases | [API output](api-test.txt) |
| LaTeX source regeneration and Python syntax | PASS, deterministic LaTeX-only output | [verification](verification.json) |
| Desktop editor LaTeX compilation | PASS | Tool diagnostic confirmed successful compilation of the current source |
| Evidence and links | PASS, all 662 pre-cleanup non-Markdown payloads resolve by SHA-256; 133 links valid | [verification](verification.json) |
| Windows/Android native and release rebuild | NOT RUN in this documentation increment | Existing dated records remain separate |
| Hosted CI for this commit | Not claimed by these local checks | Inspect GitHub Actions after push |

Commands from the repository root, using the installed SDK and bundled runtimes:

```powershell
& 'C:/Users/Nguyen Long/develop/flutter/bin/dart.bat' format --output=none --set-exit-if-changed lib test integration_test test_driver
& 'C:/Users/Nguyen Long/develop/flutter/bin/flutter.bat' analyze
& 'C:/Users/Nguyen Long/develop/flutter/bin/flutter.bat' test --coverage
& 'C:/Users/Nguyen Long/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node.exe' --test --test-concurrency=1 backend/test/api.test.js
& 'C:/Users/Nguyen Long/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/build-report.py --latex-only
```

The LaTeX-only command does not require the missing faculty Word reference and
does not alter the reviewed Word/PDF pair. The Word pair has 47 physical pages,
35 main-content pages and three additional October evidence figures. LaTeX and
Word may paginate differently; the old exported LaTeX PDF was removed.

Thirty-five byte-identical copies were consolidated, saving 210,385 bytes.
[Alias metadata](../aliases.json) retains original names, canonical paths,
sizes and hashes. Original event identity and outcome remain separate from
payload identity; identical outputs do not establish independent repetitions.
No distinct failing output or intentional-defect stage was discarded.
AI-assistance disclosures and team-review requirements remain in the project.
