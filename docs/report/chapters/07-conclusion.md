# Conclusion

## Findings

TaskFlow answers RQ1 through risk-based test allocation. Unit tests isolate rules, widget tests expose interaction states, goldens protect reviewed visuals, and native or browser workflows cross additional runtime boundaries. No single level replaces the others.

For RQ2, the permanent search regression detected the temporary prefix-only defect and passed after correction. Retained patches and outputs support this narrow, reproducible result, not a general detection probability.

For RQ3, isolated fixtures, injected dependencies and completion gates make pending, failed and committed states inspectable. The study demonstrates their use without claiming a measured reduction in flakiness.

For RQ4, October evidence records 133 Flutter cases, 17 API cases and 15 native scenarios per platform, with the Windows revision boundary stated in Chapter 1. Android release restart persistence was verified on the emulator. Windows profile results support lazy construction within the single-host experiment. Basic TalkBack compatibility was observed; a full screen-reader audit, iOS and physical-device HTTPS remain unverified.

## Prioritized continuation

The project should complete its ongoing engineering review, execute the documented manual accessibility and clean-environment checks, and refresh platform evidence after relevant code changes. These actions address remaining evidence gaps without expanding the midterm into unrelated product features.

Submission requires team verification, a usable English video and confirmed contributions. Each member must explain the workflow assertions, execution boundaries and remaining uncertainty.
