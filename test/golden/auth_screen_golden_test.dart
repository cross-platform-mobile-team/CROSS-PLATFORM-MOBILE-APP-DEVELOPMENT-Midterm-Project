import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/account/presentation/auth_screen.dart';

import '../support/visual_fixture.dart';

void main() {
  setUpAll(loadVisualFonts);
  for (final size in [const Size(390, 1100), const Size(1280, 1000)]) {
    final name = size.width < 960 ? 'phone-sign-in' : 'wide-sign-in';
    testWidgets('golden $name', (tester) async {
      configureViewport(tester, size);
      await tester.pumpWidget(
        TaskFlowApp(
          home: AuthScreen(
            authenticate: (_, _, _) async {},
            recover: (_, _, _) async {},
            offline: () {},
            samples: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('baselines/$name.png'),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}
