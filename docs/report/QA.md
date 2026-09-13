# Report verification

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
