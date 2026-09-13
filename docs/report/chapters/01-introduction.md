# Introduction

## Problem and motivation

Task management becomes difficult when an application must preserve records, validate metadata, recover from failed writes and remain usable across screen sizes. A successful tap does not prove that a task was saved; a correct screenshot does not prove that search returns the right records. These differences motivate testing at several boundaries rather than treating one framework as a complete quality strategy.

This report addresses Topic 4, UI Automation Testing in Flutter: Implementing End-to-End Testing, for Cross-Platform Mobile App Development, course 503107. The demonstration application is TaskFlow, a Flutter task manager developed as a testing case study. Its offline mode uses local preferences, its sample mode is temporary, and its account mode communicates with a Node.js and SQLite backend. The backend is included because it exposes realistic failure and concurrency conditions, not because the report attempts to become a general backend-development survey.

The September 2026 desktop refactor illustrates this problem: widget and golden checks passed after intentional visual updates, while Edge automation still required correction because its readiness and focused-input assumptions described the previous interface.

## Objectives and research questions

The objectives are to explain deterministic Flutter testing mechanisms, apply them to meaningful workflows and interpret the resulting evidence. The explanation covers finders, frame scheduling, dependency injection and the distinction between controlled fakes and real persistence.

Four questions organize the study. RQ1 asks which risks are best addressed by unit, widget, golden, native integration and browser tests in this application. RQ2 asks whether a meaningful automated workflow can detect a deliberate semantic defect that does not prevent compilation. RQ3 asks how isolation, explicit completion gates and observable-state assertions affect reproducibility. RQ4 asks what can legitimately be concluded from local test results, limited repetition experiments and historical hosted Android evidence.

The contribution is an inspectable case study, not a new testing algorithm. It connects implementation decisions to tests for persistence, drafts, account isolation and visual change control.

## Scope and evaluation boundary

The application supports creating, editing, completing, searching, filtering, sorting and deleting tasks. Records contain a title, optional notes, priority, due date and normalized tags. Deletion has a one-level undo during the current session. Account workflows cover registration, sign-in, profile changes, recovery codes, password changes, session revocation and account deletion. Offline data is not silently uploaded when a user signs in.

Implementation claims describe inspected code; measured claims describe retained runs. Proposed improvements and missing evidence are labelled separately. A runnable backend, for example, does not establish production readiness or sustained-load capacity.

The evaluated source is baseline commit 39dd199 on branch main-test plus the verified draft-consistency update in the working tree. The review reran the Flutter and backend suites and a Windows draft-exit workflow. Historical Windows, Edge and Android results retain their original dates and revisions. This manuscript describes the corrected implementation and completed experiments within their stated verification boundaries.

## Research and evidence method

The technical explanation combines official framework documentation with a source-level examination of TaskFlow. Documentation establishes API behavior; project code establishes how that behavior is used here. Tests establish only the observations asserted under their recorded conditions. The study therefore avoids inferring a real Android run from a golden test configured with an Android rendering variant, or inferring an operating-system restart from a widget remount.

Evidence was collected through deterministic fixtures, standard runner output, controlled failure injection and separate platform invocations. The intentional search experiment preserves baseline, failing and corrected outputs. The timing experiment reports whole-command durations for unequal selected suites and explicitly includes native compilation and launch overhead. Browser results preserve unsuccessful attempts instead of replacing them with the final successful rerun.

## Report organization

Chapter 2 explains the test mechanisms and compares the approaches used in the project. Chapter 3 translates product requirements into risks and observable acceptance conditions. Chapter 4 describes the architecture, data model and security boundaries. Chapter 5 connects those designs to implementation and platform behavior. Chapter 6 presents the test design, experimental results, audit findings and threats to validity. Chapter 7 concludes with the supported findings and prioritized remaining work. The appendices provide a compact reproduction guide and an evidence index rather than reproducing long raw logs.
