import 'dart:ui' show SemanticsAction;

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

double _scaleOf(WidgetTester tester) {
  final t = tester.widget<Transform>(find.descendant(of: find.byType(CdsPressable), matching: find.byType(Transform)).first);
  return t.transform.storage[0];
}

void main() {
  testWidgets('scales down on pointer-down and springs back on release', (tester) async {
    var presses = 0;
    await pumpCds(tester, CdsPressable(
      onPress: () => presses++,
      background: CdsColor.bgSecondary,
      child: const SizedBox(width: 100, height: 50),
    ));
    final gesture = await tester.startGesture(tester.getCenter(find.byType(CdsPressable)));
    await tester.pump(); // ticker's first frame
    await tester.pump(const Duration(milliseconds: 300));
    expect(_scaleOf(tester), closeTo(CdsMotion.pressScale, 0.002));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_scaleOf(tester), closeTo(1, 0.001));
    expect(presses, 1);
  });

  testWidgets('a quick re-press starts from the current scale, not from 1', (tester) async {
    await pumpCds(tester, CdsPressable(onPress: () {}, debounce: Duration.zero, child: const SizedBox(width: 100, height: 50)));
    final center = tester.getCenter(find.byType(CdsPressable));
    final g1 = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await g1.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final midway = _scaleOf(tester);
    expect(midway, lessThan(1));
    final g2 = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final after = _scaleOf(tester);
    expect((after - midway).abs(), lessThan(0.01), reason: 'no jump back to 1 when interrupted');
    await g2.up();
    await tester.pumpAndSettle();
  });

  testWidgets('tints the background while pressed', (tester) async {
    await pumpCds(tester, CdsPressable(onPress: () {}, background: CdsColor.bgPrimary, child: const SizedBox(width: 100, height: 50)));
    Color bg() => (tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration).color!;
    final idle = bg();
    final gesture = await tester.startGesture(tester.getCenter(find.byType(CdsPressable)));
    await tester.pump();
    expect(bg(), isNot(idle));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(bg(), idle);
  });

  testWidgets('debounces rapid double taps', (tester) async {
    var presses = 0;
    await pumpCds(tester, CdsPressable(onPress: () => presses++, child: const SizedBox(width: 100, height: 50)));
    await tester.tap(find.byType(CdsPressable));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(CdsPressable));
    await tester.pumpAndSettle();
    expect(presses, 1);
  });

  testWidgets('presses outside the debounce window both fire (test clock aware)', (tester) async {
    var presses = 0;
    await pumpCds(tester, CdsPressable(onPress: () => presses++, child: const SizedBox(width: 100, height: 50)));
    await tester.tap(find.byType(CdsPressable));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byType(CdsPressable));
    await tester.pumpAndSettle();
    expect(presses, 2);
  });

  testWidgets('icon-only controls stay focusable for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () {}));
    final node = tester.getSemantics(find.byType(CdsIconButton));
    expect(node.label, 'Close');
    expect(node.getSemanticsData().hasAction(SemanticsAction.focus), isTrue);
    handle.dispose();
  });

  testWidgets('disabled and loading block presses', (tester) async {
    var presses = 0;
    await pumpCds(tester, Column(mainAxisSize: MainAxisSize.min, children: [
      CdsPressable(key: const Key('d'), disabled: true, onPress: () => presses++, child: const SizedBox(width: 100, height: 50)),
      CdsPressable(key: const Key('l'), loading: true, onPress: () => presses++, child: const SizedBox(width: 100, height: 50)),
    ]));
    await tester.tap(find.byKey(const Key('d')));
    await tester.tap(find.byKey(const Key('l')));
    await tester.pumpAndSettle();
    expect(presses, 0);
  });

  testWidgets('keyboard focus shows a ring and Enter/Space activate', (tester) async {
    var presses = 0;
    await pumpCds(tester, CdsPressable(onPress: () => presses++, debounce: Duration.zero, child: const SizedBox(width: 100, height: 50)));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.foregroundPainter is CdsFocusRingPainter), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(presses, 2);
  });

  testWidgets('exposes button semantics with state', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, CdsPressable(onPress: () {}, semanticLabel: 'Open Bitcoin', selected: true, child: const SizedBox(width: 100, height: 50)));
    expect(
      tester.getSemantics(find.byType(CdsPressable)),
      matchesSemantics(label: 'Open Bitcoin', isButton: true, isEnabled: true, hasEnabledState: true, isSelected: true, hasSelectedState: true, hasTapAction: true, isFocusable: true, hasFocusAction: true),
    );
    handle.dispose();
  });

  testWidgets('minTapTargetSize pads small controls to 44px', (tester) async {
    await pumpCds(tester, CdsPressable(onPress: () {}, minTapTargetSize: 44, child: const SizedBox(width: 20, height: 20)));
    expect(tester.getSize(find.byType(CdsPressable)), const Size(44, 44));
  });

  testWidgets('reduced motion keeps scale at 1', (tester) async {
    await pumpCds(tester, CdsPressable(onPress: () {}, child: const SizedBox(width: 100, height: 50)), disableAnimations: true);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(CdsPressable)));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_scaleOf(tester), 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('fires haptics on commit', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
      return null;
    });
    await pumpCds(tester, CdsPressable(onPress: () {}, feedback: CdsHapticFeedback.light, child: const SizedBox(width: 100, height: 50)));
    await tester.tap(find.byType(CdsPressable));
    await tester.pumpAndSettle();
    expect(calls, ['HapticFeedbackType.lightImpact']);
  });
}
