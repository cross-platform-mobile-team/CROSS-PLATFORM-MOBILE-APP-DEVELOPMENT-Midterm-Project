# UI refresh - engineering notes, 2026-09-11

User-requested interface redesign. This is not report preparation. No backend
contract, stored data, dependency, credential policy or search rule changed.

## Design and implementation

- `lib/core/theme/app_theme.dart`: shared indigo/ink palette, light canvas, white
  outlined surfaces, typography, 48-pixel actions, rounded inputs/dialogs and
  accessible error/helper styles. Text styles copy the platform's base styles
  so font families remain intact. No network fonts or new runtime packages.
- `ui_components.dart`: brand mark, separately exposed section headings, surface
  panels, illustrated empty/error states and responsive authentication layout.
- Task workspace: status navigation rail at widths >=1100 and normal text scale;
  compact single-column layout otherwise. Wide composer places Add beside the
  title. Existing search/filter/sort, metadata, undo and retry labels remain.
  Sidebar status selection preserves the other current filters and never writes
  tasks. Priority uses text plus color; completion remains a real checkbox.
- Authentication: split desktop introduction/form, single form panel on smaller
  screens or large text. Sign-in/register/recovery and isolated offline/sample
  modes retain their existing behavior.
- Settings: separate profile, password, session and deletion panels. Existing
  field focus nodes, ordered traversal, live errors and credential controls stay.
- Edit/filter dialogs inherit the theme; edit content has a bounded readable
  width while remaining scrollable. Delete actions are visually distinguished.

The small coursework collection is rendered in a single scrollable column, so
grouped form/card descendants remain available consistently to semantics and
focus traversal. This eagerly lays out task cards; it is not a large-list
virtualization or performance improvement. Large datasets would require a
separate measured lazy-list/pagination design. No performance claim is made.

## Test and visual review

Two new widget cases cover desktop status filtering without storage mutation and
the large-text single-column fallback. Existing assertions remain, including the
four standalone loading cases and the permanent substring-search regression.
The Retry widget test now scrolls the taller error panel into view before tapping.
The account accessibility test settles the helper/error animation before checking
contrast, while still asserting keyboard focus and both validation messages.

Initial checks caught a Material ancestor issue for rail tiles, merged card
semantics, unreadable test-font fallback and an intermediate helper-text fade.
These were corrected rather than suppressing assertions. Development logs are
retained under `evidence/ui-refresh-20260911/`; they are not final passing gates.

All eight changed task screenshots were inspected: empty, populated, validation
and error at 390x960 / 1280x900. Compared the old wide populated screenshot and
its masked diff; the new rail, composer, fonts, badges, spacing and surfaces are
intentional. Existing fixtures/sizes/comparator are unchanged. Lower cards may
require scrolling, especially on phones; behavior/large-text tests cover that.

After visual review, explicitly regenerated only the task golden file. Added
and inspected sign-in goldens at 390x1100 / 1280x1000 and settings at 900x1600.
The settings screenshot uses mocked HTTP and a synthetic account/session, not a
real account. There are now 11 golden cases; no comparison tolerance introduced.
New baselines live in `test/golden/baselines/`. Generated failure images stay
ignored; a representative original and diff are retained with the evidence.

## Boundaries

See the latest evidence manifest for executed gates. Windows/Edge runs do not
prove Android, physical keyboard/IME or Narrator behavior. The local Android SDK
is still absent. Previous Android CI results belong to previous source commits;
they are not a PASS for this redesigned UI. Manual full-page assistive-technology
review, clean-machine release testing and a hosted run of this revision remain.
