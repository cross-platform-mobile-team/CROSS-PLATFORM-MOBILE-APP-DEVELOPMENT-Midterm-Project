# Color and motion UI refresh

User request: a more colorful, modern interface with smooth transitions.
Baseline b4479e3; implementation only, no push or report changes authorized.

## Plan and acceptance

1. Add shared iris/mint/peach surfaces and bounded motion tokens with no package.
2. Refresh sidebar, greeting/progress, quick capture, cards and shared panels.
   Keep existing visible labels, keys, keyboard actions and repository contracts.
3. Test reduced motion, finite settling, hover/focus, draft retention and compact
   layouts. Run the full suite; inspect intentional golden differences before
   accepting replacement baselines. Never hide a functional failure with them.
4. Build native and Web outputs and retain actual verification results.

No continuous decorative animations, blur filters, timers, automatic focus
changes or duplicated outgoing forms. Reduced-motion users get immediate state
changes. Color supplements status/priority text rather than replacing it.
Animation duration is a design choice, not measured frame-rate improvement.

## Implemented design

- Iris canvas, lavender/mint sidebar, iris-to-peach greeting, gradient mark.
- Completion/focus pills and a finite 360ms progress transition.
- A single 320ms fade/8px entrance for the greeting; ordinary rebuilds keep it.
- 200ms surface border/shadow hover and keyboard-focus feedback. No scaling of
  editable content and no added keyboard traversal stop.
- Rose high-priority, blue low-priority, warm normal and mint completed cards;
  existing labels and completed strikethrough remain the semantic indicators.
- Shared surfaces bring the same treatment to account and error panels.

## Review and regression work

Initial behavior checks exposed a Flutter assertion: decorated task tiles had
no local Material for ink. Added transparent Material inside the surface.
Visual review then caught content clipped by rounded corners because padding
was outside that Material. Padding now belongs inside it. Original outputs are
retained rather than relabelled as passing runs.

The phone CRUD test initially tapped an offscreen Edit action after the taller
greeting. It now scrolls that existing control into view before tapping, without
weakening its invalid-save/retry/delete/undo assertions. All 92 unit/widget cases
passed. Fifteen golden differences were reviewed before explicit regeneration;
the final full coverage invocation passed 107 cases. No baseline was changed to
hide a behavioral failure. Golden fixtures are synthetic, not physical-device
or manual screen-reader evidence.

Raw results: docs/evidence/color-motion-20260921. Report editions remain a dated
record of the previous implementation; they were not regenerated for this UI.

Native persisted scenarios exposed an old Card-type ancestor finder after the
surface refactor. It now scopes actions through the stable task-card key while
still finding the visible task title. Full-record persistence, unrelated-task,
cancel and undo assertions are unchanged; the original failed run is retained.

22 September continuation completed the pending gates: final format/analyze,
15 Windows native cases, 17 API cases and Windows/Web/Android release builds
PASS. Web was rebuilt with bundled resources; its earlier incomplete attempt
remains recorded. No new Edge/Android interaction or frame-time measurement
was performed. The changes remain local and the report remains untouched.
