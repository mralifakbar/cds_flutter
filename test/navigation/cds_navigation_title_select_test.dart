import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders label and caret in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, CdsNavigationTitleSelect(label: 'Main portfolio', onPress: () {}), brightness: b);
      expect(find.text('Main portfolio'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.caretDown), findsOneWidget);
    }
  });

  testWidgets('calls onPress on tap', (tester) async {
    var presses = 0;
    await pumpCds(tester, CdsNavigationTitleSelect(label: 'Main portfolio', onPress: () => presses++));
    await tester.tap(find.text('Main portfolio'));
    await tester.pumpAndSettle();
    expect(presses, 1);
  });

  testWidgets('calls onPress on Enter', (tester) async {
    var presses = 0;
    await pumpCds(tester, CdsNavigationTitleSelect(label: 'Main portfolio', onPress: () => presses++));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(presses, 1);
  });

  testWidgets('null onPress is disabled', (tester) async {
    await pumpCds(tester, const CdsNavigationTitleSelect(label: 'Main portfolio', onPress: null));
    await tester.tap(find.text('Main portfolio'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('open flips the caret and reports expanded', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, CdsNavigationTitleSelect(label: 'Main portfolio', open: true, onPress: () {}));
    expect(tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns, 0.5);
    final data = tester.getSemantics(find.text('Main portfolio')).getSemanticsData();
    expect(data.flagsCollection.isExpanded, isNotNull);
    expect(data.flagsCollection.isHeader, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('reduced motion and text scale 2.0', (tester) async {
    await pumpCds(tester, CdsNavigationTitleSelect(label: 'Main portfolio', onPress: () {}), disableAnimations: true, textScale: 2);
    await pumpCds(tester, CdsNavigationTitleSelect(label: 'Main portfolio', open: true, onPress: () {}), disableAnimations: true, textScale: 2, settle: false);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });
}
