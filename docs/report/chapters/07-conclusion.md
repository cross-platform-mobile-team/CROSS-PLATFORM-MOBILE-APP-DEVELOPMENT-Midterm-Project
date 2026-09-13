# Conclusion

## Findings

TaskFlow answers RQ1 through risk-based test allocation. Unit tests isolate rules, widget tests expose interaction states, goldens protect reviewed visuals, and native or browser workflows cross additional runtime boundaries. No single level replaces the others.

For RQ2, the permanent search regression detected the temporary prefix-only defect and passed after correction. Retained patches and outputs support this narrow, reproducible result, not a general detection probability.

For RQ3, isolated fixtures, injected dependencies and completion gates make pending, failed and committed states inspectable. The study demonstrates their use without claiming a measured reduction in flakiness.

For RQ4, results remain tied to their platforms and revisions. The selected existing suites passed, but these results do not establish absence of defects.

## Prioritized continuation

The project should complete its ongoing engineering review, execute the documented manual accessibility and clean-environment checks, and refresh platform evidence after relevant code changes. These actions address remaining evidence gaps without expanding the midterm into unrelated product features.

Final submission requires student verification and presentation materials. The demonstration should explain each workflow's assertions, execution boundary and remaining uncertainty, using the retained success and failure records.
