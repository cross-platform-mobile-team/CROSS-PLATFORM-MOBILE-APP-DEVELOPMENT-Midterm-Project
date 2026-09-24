import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/core/theme/app_motion.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/workspace_components.dart';

void main() {
  testWidgets('decorative surface preserves separate message semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MotionSurface(
              child: Column(
                children: [Text('Error heading'), Text('Error message')],
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Error message')).label,
        'Error message',
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('entrance does not replay or replace draft on parent rebuild', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    Widget frame(String label) => MaterialApp(
      home: Scaffold(
        body: WorkspaceEntrance(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
        ),
      ),
    );
    await tester.pumpWidget(frame('Title'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Unsubmitted work');
    final fieldState = tester.state(find.byType(TextField));
    await tester.pumpWidget(frame('Updated title label'));
    final opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(WorkspaceEntrance),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, 1, reason: 'A rebuild must not hide the draft');
    expect(tester.state(find.byType(TextField)), same(fieldState));
    expect(controller.text, 'Unsubmitted work');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('surface responds immediately to reduced motion preference', (
    tester,
  ) async {
    Widget frame(bool reduced) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: const Scaffold(
          body: Center(
            child: MotionSurface(
              child: SizedBox(width: 200, height: 80, child: Text('Task')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(frame(false));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(MotionSurface)));
    await tester.pump();
    final surface = find.descendant(
      of: find.byType(MotionSurface),
      matching: find.byType(AnimatedContainer),
    );
    expect(
      tester.widget<AnimatedContainer>(surface).duration,
      const Duration(milliseconds: 200),
    );
    await tester.pumpWidget(frame(true));
    expect(tester.widget<AnimatedContainer>(surface).duration, Duration.zero);
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hover and focus keep the same editable draft and settle', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MotionSurface(
            child: TextField(controller: controller, focusNode: focus),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Keep my draft');
    final state = tester.state(find.byType(TextField));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(790, 590));
    await mouse.moveTo(tester.getCenter(find.byType(TextField)));
    await tester.pumpAndSettle();
    expect(controller.text, 'Keep my draft');
    expect(focus.hasFocus, isTrue);
    expect(tester.state(find.byType(TextField)), same(state));
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final reduced in [false, true]) {
    testWidgets('header progress settles with reduced motion $reduced', (
      tester,
    ) async {
      Widget frame(int completed) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: TaskHeader(total: 8, completed: completed),
            ),
          ),
        ),
      );
      await tester.pumpWidget(frame(2));
      await tester.pumpAndSettle();
      await tester.pumpWidget(frame(5));
      final progress = tester.widgetList<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      expect(progress, isNotEmpty);
      if (reduced) {
        expect(
          progress.every((widget) => widget.duration == Duration.zero),
          isTrue,
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('5/8 completed'), findsOneWidget);
      expect(find.text('3 to focus on'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
