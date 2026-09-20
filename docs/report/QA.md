# Report verification

## Refresh 19 September 2026

Shared source and both editions now distinguish baseline 06d3790 plus the local
snapshot-budget change, 104 Flutter / 17 API cases and 15 Windows reruns.
Historical Android, Edge and timing experiments retain original dates.
Word: 43 physical pages, 31 main pages (7-37). LaTeX: 42 physical pages,
29 main pages (8-36). Both remain within the 20-35 main-page range.

Rebuilt with the bundled Python runtime and retained template contract;
reference SHA-256 remains B2E75BBBAB293CEC424726B20DC6880D4A83BC22B5F8A10F4D2B4FD68EDEFB6D.
Packaged render_docx failed because soffice.exe is unavailable. Word COM
refreshed fields/TOC and exported the matching PDF; PDFium rendered every page.
LaTeX compiled with existing Tectonic; font-path/underfull warnings remain,
without an overfull warning. Every changed page image was inspected; unchanged
pages were compared by SHA-256 against the previously reviewed renders.
The first Word pass had an unnecessary continuation page; shortened prose
restored the 43-page layout without shrinking text or removing qualifications.
QA renders: ignored build/report-qa/risk-closure-20260919/final-word and
final-latex. Raw compile/renderer diagnostics are in the risk-closure evidence.

Report completion does not certify manual accessibility or clean-machine setup.
The previous dated verification below remains historical.

## Latest refresh 15 September 2026

This documentation-only update synchronizes README and both report editions to
implementation 3e4f733. No application source, test evidence or golden changed.
The evaluation now distinguishes 100 Flutter/14 API cases, 15 Windows native
cases on 14 September and 15 Android cases on 15 September. iOS stays NOT RUN.

- Word and matching PDF: 43 physical pages, 31 main-content pages (7-37).
- LaTeX PDF: 42 physical pages, 29 main-content pages (8-36).
- Both remain within the required 20-35 main-content pages.
- Word fields and contents refreshed; Tectonic compilation PASS. Retained
  font-path warnings and one underfull box are not hidden; no overfull box reported.
- Canonical render attempted and failed for missing soffice.exe. Word export
  and PDFium rendered all pages to build/report-qa/review-20260915/.
- Changed Word and LaTeX pages were visually inspected; unchanged pages were
  compared with the previously reviewed v8 PNGs. A nearly empty LaTeX overflow
  page was removed by shortening repeated input-limit prose, without reducing font.
- Final reference entries now link to 3e4f733; historical experiment numbers
  and retrieval dates were preserved. No new test or hosted CI run is claimed.
- No commit/push in this documentation update; publication requires user request.

The sections below describe earlier editions.

## Generated editions

- LaTeX PDF: 41 physical pages; main chapters 1–28 (physical 8–35).
- Word and matching PDF: 43 physical pages; main chapters 1–31 (physical 7–37).
- Seven chapters, five numbered figures, eight numbered tables, references and
  three appendices. Both main-content counts satisfy the supplied 20–35 range.
- Word fields refreshed using Microsoft Word before PDF export.
- University logo bytes compared with retained template and preserved.
- Tectonic 0.17.0 compilation succeeded. Windows font-path warnings remain;
  fonts must be available on another build host. No overfull text boxes reported.

## Visual checks

All Word PDF pages reviewed as rendered PNGs. LaTeX pages reviewed, then diagram
labels adjusted to remain inside boxes; changed pages rechecked. Tables repeat
headers across page breaks. Some chapter ends have deliberate whitespace because
each chapter starts on a new page. No blank filler pages added.
The canonical document renderer was attempted but failed because soffice.exe is
unavailable. Word PDF export plus PDFium rendering was used, not a claimed
LibreOffice pass. Generated QA images remain under ignored build/report-qa.

## Scope

The draft-consistency fix and four permanent regressions are included in this
update. No commit or push. The resolved review retains the original evidence.
Version v8 rerendered all pages; 11 changed Word pages and 8 changed LaTeX pages
were visually checked. Other page PNG hashes match the previously reviewed v7.
Pagination remains 43/41 pages, with 31/28 main-content pages respectively.
Canonical rendering again reports missing soffice.exe; Word/PDFium fallback used.
The report is for student verification, not an unconditional submission approval.
