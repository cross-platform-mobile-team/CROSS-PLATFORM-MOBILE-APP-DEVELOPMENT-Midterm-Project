# TaskFlow midterm report

## Review edition 21 October 2026

Use `output/pdf/taskflow-report.docx` and its matching export
`output/pdf/taskflow-report-word.pdf` for the current student review. They have
47 physical pages and 35 main-content pages (physical 7–41), including the three
new October evidence figures added on 21 October. The October refresh
uses reviewed source a153046 and the dated UI/UX and Android evidence packages:
133 Flutter cases, 17 API cases and 15 native scenarios per platform, with the
Windows final-fix boundary stated in the manuscript. No new app test run is
claimed by this documentation update.

The outdated LaTeX export was removed from `output/pdf`; use the Word file and
its matching PDF for submission. LaTeX sources remain available for optional
local compilation, and its generated PDF is ignored. The retained faculty reference at
`build/report-template/reference.docx` is absent on this host, so this refresh
preserves the existing Word template layout directly. A full builder run still
requires the original reference with the expected hash; do not bypass that check.

Video script: `docs/presentation/KICH-BAN-VIDEO-DEMO.md`. Repository cleanup
record: `docs/history/engineering-notes.md#github-cleanup-review`. Publication of the current report and
cleanup was authorized on 21 October; student verification remains required
before coursework submission.

English manuscript for Topic 4, using the supplied TDTU cover/logo and body
formatting conventions. AI-assisted text requires student review. The user
confirmed current permission to use AI. The manuscript now describes the verified
draft-consistency update; see DEFERRED_REVIEW.md for the resolved review record.
Historical experimental evidence remains intact.

## Deliverables

- output/pdf/taskflow-report.docx: editable template-derived Word edition.
- output/pdf/taskflow-report-word.pdf: matching Word export.
- docs/report/latex/taskflow-report.tex and assets: self-contained LaTeX source.
- chapters, references.md and appendices.md: shared manuscript content.

The optional LaTeX renderer has different pagination. Do not substitute its PDF
for the matching Word export when identical Word/PDF pagination is required.
Submission date and actual contributions have not been supplied. Neither is invented.

## Rebuild

Use the bundled document Python runtime with python-docx and Pillow:
`python scripts/build-report.py`. This requires the retained read-only template
at build/report-template/reference.docx; scripts/inspect-report-template.ps1
creates it from the user's original Word file. Its SHA-256 is checked by the builder.

To refresh only LaTeX, use `python scripts/build-report.py --latex-only`.
This reads the shared manuscript and retained images without needing the Word
template or changing the reviewed Word/PDF pair. Repeating it is deterministic.
The current source compiled successfully with the desktop editor on 21 October.

Run `./scripts/render-report.ps1` with Microsoft Word available to refresh fields
and export the matching PDF. The packaged LibreOffice renderer was attempted but
is unavailable on this host; Word export plus PDFium is the inspection fallback.

Compile latex/taskflow-report.tex with XeLaTeX or Tectonic, from its containing
directory. Times New Roman and Arial must be legally installed. Fonts are not
redistributed. When those fonts are absent, the source falls back to TeX Gyre
Termes/Heros for preview; verify the faculty-required fonts before submission.
The original university logo is retained from the provided template
solely for this coursework; no broader redistribution licence is claimed.

Optional portable Tectonic 0.17.0 can be kept under ignored build/tectonic/runtime.
Its official release archive SHA-256 is:
f61ce51f0b0ade1015b7de7ef368541c5424e9756ecbd0d7af97d6d48030845f.
Compilation downloads TeX support data, not manuscript uploads. No global install.

Reviewed application baseline: a153046. The manuscript records the October
133 Flutter, 17 API and 15 native scenarios per platform, with the Windows
final-fix boundary stated in Chapter 1. Android release install/launch/restart
evidence is from 11 October. iOS remains NOT RUN. Earlier browser/CI experiments
retain their original identities. Duplicate log payloads resolve through
docs/evidence/aliases.json; no distinct failed outcome was removed.
This report is not a certification that the application is defect-free.
