# TaskFlow midterm report

English manuscript for Topic 4, using the supplied TDTU cover/logo and body
formatting conventions. AI-assisted text requires student review. The user
confirmed current permission to use AI. The manuscript now describes the verified
draft-consistency update; see DEFERRED_REVIEW.md for the resolved review record.
Historical experimental evidence remains intact.

## Deliverables

- output/pdf/taskflow-report.pdf: compiled LaTeX edition.
- output/pdf/taskflow-report.docx: editable template-derived Word edition.
- output/pdf/taskflow-report-word.pdf: matching Word export.
- docs/report/latex/taskflow-report.tex and assets: self-contained LaTeX source.
- chapters, references.md and appendices.md: shared manuscript content.

The two renderers have different pagination. Do not substitute the LaTeX PDF
for the matching Word export when identical Word/PDF pagination is required.
Submission date and actual contributions have not been supplied. Neither is invented.

## Rebuild

Use the bundled document Python runtime with python-docx and Pillow:
`python scripts/build-report.py`. This requires the retained read-only template
at build/report-template/reference.docx; scripts/inspect-report-template.ps1
creates it from the user's original Word file. Its SHA-256 is checked by the builder.

Run `./scripts/render-report.ps1` with Microsoft Word available to refresh fields
and export the matching PDF. The packaged LibreOffice renderer was attempted but
is unavailable on this host; Word export plus PDFium is the inspection fallback.

Compile latex/taskflow-report.tex with XeLaTeX or Tectonic, from its containing
directory. Times New Roman and Arial must be legally installed. Fonts are not
redistributed. The original university logo is retained from the provided template
solely for this coursework; no broader redistribution licence is claimed.

Local Tectonic 0.17.0 is under ignored build/tectonic/runtime. It was obtained from
the official GitHub release; archive SHA-256:
f61ce51f0b0ade1015b7de7ef368541c5424e9756ecbd0d7af97d6d48030845f.
Compilation downloads TeX support data, not manuscript uploads. No global install.

Source baseline: 3e4f733. The manuscript includes the 14-15 September platform
audit: 100 Flutter, 14 API, 15 Windows and 15 Android native cases, plus Android
release install/launch/process-restart persistence. iOS remains NOT RUN.
Earlier browser/CI experiments retain their original identities.
This report is not a certification that the application is defect-free.
