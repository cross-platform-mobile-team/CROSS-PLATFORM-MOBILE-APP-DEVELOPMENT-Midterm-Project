# Automation audit and publication — 22 September 2026

The user authorized finishing or improving automation, fixing detected defects,
and publishing verified changes to main-test. This includes the previously
local color/motion UI. No claim of universal bug freedom or a guaranteed grade.

## Acceptance plan

1. Review existing unit, widget, golden, native and browser scope against Topic 4.
2. Extend motion regressions for parent rebuild/draft identity and runtime
   reduced-motion preference changes, without weakening existing assertions.
3. Run format, analyze, full Flutter coverage, API and script contracts; rerun
   Edge in isolated sessions and native workflows. Preserve unsuccessful logs.
4. Review source/evidence/ignore rules, commit and push main-test without force;
   compare local and remote SHA. Distinguish hosted CI from local results.

## Scope boundaries

The core testing levels and intentional-defect experiment already exist.
Passing the selected scenarios is not proof that every possible input or device
is correct. iOS requires macOS/Xcode and remains unverified on this Windows-only
host. Manual Narrator, physical devices and frame-time profiling are separate
acceptance activities, not inferred from automated semantics or build success.

Results are indexed in evidence/automation-audit-20260922/README.md.

## Findings and resolution

Two accessibility regressions were found in the UI refresh: decorative Focus
merged labels, and keyed task reordering left Web semantics order/positions
stale relative to the canvas. Keep includeSemantics:false on the observer,
explicit card semantics containers and ordinal sort keys. Browser tests also
now tolerate only the exact focused/unfocused title labels and wait for selected
dropdown values and the exact ordered task set. They retain all functional
assertions. Failed attempts and emulator crashes remain in the evidence index.

The post-fix Flutter suite has 110 passing cases. Final browser verification
passed four repetitions across two independent Edge sessions. Android's 15
cases passed on the existing API 36 emulator with host rendering; headless
renderer crashes were diagnosed from Windows events and are not hidden.
Windows also passed all 15 post-fix native cases. Format/analyze, 17 API cases
and Windows/Web/APK release builds passed; final APK completion was verified on
24 September. This closes the scoped local automation audit, not manual or iOS
acceptance, nor a claim that every possible bug has been excluded.

## Required automation coverage map

| Requirement | Implementation / evidence |
|---|---|
| Business rules and persistence | test/unit, task controller/metadata/CRUD/API tests |
| Validation, loading/error/empty and recovery | test/widget, independent native scenarios, Edge harness |
| Visual regressions at phone/wide sizes | 15 reviewed golden baselines, full Flutter suite |
| Create, search/AND filters/sort, edit/complete, delete/undo | independent_scenarios, persisted_scenarios, windows_workflow |
| Drafts and asynchronous save safety | quick_create_exit, pending_capture, widget draft tests |
| Genuine defect detection | intentional_defect baseline/fail/fix logs plus this audit's semantics regression |
| Native and browser execution | dated Windows/Android logs and Edge repetitions, not generated platform folders |

This map describes coverage of the specified scenario groups, not a percentage
of all possible behaviors. Manual acceptance and unsupported hardware cannot
be marked complete by adding more automated test cases.
