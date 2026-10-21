# Report verification

## Publication and LaTeX repair 21 October 2026

User authorized publication under the configured Long-D176 identity. The current
LaTeX source now supports font fallback for preview and regenerates with
`python scripts/build-report.py --latex-only` without the absent Word reference.
The desktop compiler returned success for the current source. Regeneration is
deterministic; image assets are checked before output. Word/PDF remain the
reviewed matching pair with 47 physical and 35 main-content pages.

[Publication checks](../evidence/publication-20261021/README.md) record fresh
format/analyze PASS, 133 Flutter cases and 17 API cases PASS. Exact duplicate
evidence copies resolve through aliases.json; distinct raw payloads are intact.
The earlier failed compilation and no-publication notes below remain historical.

## October figure update 21 October 2026

Added Figures 5.2 (390×844 compact golden fixture), 5.3 (retained-draft recovery
golden fixture) and 6.1 (API 36 emulator release restart capture). Source images
are copied without pixel modification from the checked-in October baselines and
Android evidence. All figures have captions, source context and explanatory text.
The controlled fixtures are explicitly distinguished from emulator screenshots.

Word and matching PDF: 47 physical pages, 35 main-content pages (physical 7–41).
References start on physical page 42. TOC and list of figures refreshed by Word;
all pages rendered with PDFium, review sheets inspected and new figures checked
in full-page images. The recovery image was enlarged to improve label legibility.
Images retain their aspect ratios, remain with captions, and fit page boundaries.
Builder and LaTeX source constrain portrait figure dimensions for future rebuilds.
The historical LaTeX PDF remains excluded from the current review deliverables.
`git diff --check` passes; no application code, baseline or raw evidence changed.
No commit or push.

## Review refresh 21 October 2026

- Original brief read from `C:/Users/Nguyen Long/Downloads/503107-Essay-V2 (1).pdf`.
- Current report source identity: a153046; results trace to the October UI/UX and
  Android follow-up packages. Historical experiments retain original dates.
- Existing faculty Word layout and cover preserved; absent retained reference
  template prevents a full `build-report.py` rebuild on this host.
- Word COM refreshed fields/TOC and exported the matching PDF: 44 physical pages,
  32 main-content pages (physical 7–38); references begin at physical page 39.
- Canonical `render_docx.py` attempted; missing bundled soffice.exe prevents it.
  Microsoft Word export plus bundled PDFium rendered all 44 pages. Review sheets
  cover every page; detailed images cover changed results/profile/conclusion and
  appendix pages. Removed a nearly empty conclusion overflow page by shortening
  prose, without reducing font size. Updated current UI fixture and evidence rows.
- `git diff --check` PASS. Application source/tests, golden baselines and original
  logs unchanged. No application suite rerun, coverage percentage or new CI claim.
- LaTeX source updated; its older PDF is explicitly excluded from current review.
  Built-in compiler attempt returned `compile-failed: Compilation timed out`.
  Current Word and matching PDF are the deliverables for review.
- No commit/push/deletion. Git identity remains Long-D176 with the configured
  student email; report coauthors remain both team members.

The dated sections below are historical verification records.

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
