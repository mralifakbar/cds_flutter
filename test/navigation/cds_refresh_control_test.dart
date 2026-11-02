import 'dart:async';

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _list(Future<void> Function() onRefresh, {ScrollPhysics physics = const ClampingScrollPhysics()}) => SizedBox(
      height: 600,
      child: CdsRefreshControl(
        onRefresh: onRefresh,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(parent: physics),
          children: [for (var i = 0; i < 30; i++) SizedBox(height: 48, child: CdsText('Row $i'))],
        ),
      ),
    );

Future<void> _pull(WidgetTester tester, double distance) async {
  final gesture = await tester.startGesture(tester.getCenter(find.text('Row 1')));
  for (var moved = 0.0; moved < distance; moved += 10) {
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump();
  }
  await gesture.up();
}

void main() {
  for (final physics in [const ClampingScrollPhysics(), const BouncingScrollPhysics()]) {
    final name = physics.runtimeType.toString();

    testWidgets('$name: pulling past the threshold refreshes once', (tester) async {
      var calls = 0;
      final completer = Completer<void>();
      await pumpCds(tester, _list(() {
        calls++;
        return completer.future;
      }, physics: physics));
      await _pull(tester, 200);
      await tester.pump();
      expect(calls, 1);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.bySemanticsLabel('Refreshing'), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CdsProgressCircle), findsNothing);
    });

    testWidgets('$name: a short pull springs back without refreshing', (tester) async {
      var calls = 0;
      await pumpCds(tester, _list(() async => calls++, physics: physics));
      await _pull(tester, 40);
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.byType(CdsProgressCircle), findsNothing);
    });
  }

  testWidgets('indicator follows the pull with resistance past the threshold', (tester) async {
    await pumpCds(tester, _list(() async {}));
    final gesture = await tester.startGesture(tester.getCenter(find.text('Row 1')));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    final circle = tester.widget<CdsProgressCircle>(find.byType(CdsProgressCircle));
    expect(circle.progress, greaterThan(0));
    expect(circle.progress, lessThan(1));
    final early = tester.getTopLeft(find.byType(CdsProgressCircle)).dy;
    for (var i = 0; i < 20; i++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    final late = tester.getTopLeft(find.byType(CdsProgressCircle)).dy;
    // 200px of finger travel beyond the first sample moves the indicator less than 200px.
    expect(late - early, lessThan(200));
    expect(late - early, greaterThan(20));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('scrolling down in the middle of the list does nothing', (tester) async {
    var calls = 0;
    await pumpCds(tester, _list(() async => calls++));
    await tester.drag(find.text('Row 5'), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Row 10'), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('semantics custom action triggers a refresh', (tester) async {
    final handle = tester.ensureSemantics();
    var calls = 0;
    await pumpCds(tester, _list(() async => calls++));
    final node = tester.getSemantics(find.byType(CdsRefreshControl));
    final action = CustomSemanticsAction.getIdentifier(const CustomSemanticsAction(label: 'Refresh'));
    tester.renderObject(find.byType(CdsRefreshControl)).owner!.semanticsOwner!.performAction(node.id, SemanticsAction.customAction, action);
    await tester.pumpAndSettle();
    expect(calls, 1);
    handle.dispose();
  });

  testWidgets('reduced motion settles instantly without a spring', (tester) async {
    await pumpCds(tester, _list(() async {}), disableAnimations: true);
    await _pull(tester, 200);
    await tester.pump();
    await tester.pump();
    // No spring: the indicator is gone as soon as the refresh completes.
    expect(find.byType(CdsProgressCircle), findsNothing);
  });

  testWidgets('dark, RTL and text scale 2 render without errors', (tester) async {
    await pumpCds(tester, _list(() async {}), brightness: Brightness.dark, textDirection: TextDirection.rtl, textScale: 2);
    await _pull(tester, 120);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
