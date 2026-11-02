import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _tooltip({bool visible = true, CdsPlacement placement = CdsPlacement.top}) => CdsTooltip(
      content: 'Network fees go to validators.',
      visible: visible,
      placement: placement,
      child: CdsIconButton(CdsIconName.info, semanticLabel: 'About fees', onPress: () {}),
    );

void main() {
  testWidgets('long-press opens above the anchor; tap outside closes', (tester) async {
    await pumpCds(tester, _tooltip());
    expect(find.text('Network fees go to validators.'), findsNothing);
    await tester.longPress(find.byType(CdsIconButton));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.text('Network fees go to validators.')).dy,
      lessThan(tester.getTopLeft(find.byType(CdsIconButton)).dy),
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsNothing);
  });

  testWidgets('closes after the touch display duration', (tester) async {
    await pumpCds(tester, _tooltip());
    await tester.longPress(find.byType(CdsIconButton));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsNothing);
  });

  testWidgets('hover opens and leaving closes; Escape closes', (tester) async {
    await pumpCds(tester, _tooltip(placement: CdsPlacement.bottom));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(CdsIconButton)));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Network fees go to validators.')).dy,
      greaterThan(tester.getBottomLeft(find.byType(CdsIconButton)).dy),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsNothing);
    await mouse.moveTo(const Offset(1, 1));
    await mouse.moveTo(tester.getCenter(find.byType(CdsIconButton)));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsOneWidget);
    await mouse.moveTo(const Offset(1, 1));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsNothing);
  });

  testWidgets('keyboard focus opens it', (tester) async {
    await pumpCds(tester, _tooltip());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsOneWidget);
  });

  testWidgets('exposes the text as the trigger tooltip', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _tooltip());
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.tooltip == 'Network fees go to validators.'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('visible false suppresses it', (tester) async {
    await pumpCds(tester, _tooltip(visible: false));
    await tester.longPress(find.byType(CdsIconButton));
    await tester.pumpAndSettle();
    expect(find.text('Network fees go to validators.'), findsNothing);
  });

  testWidgets('renders on the inverted scheme', (tester) async {
    await pumpCds(tester, _tooltip());
    await tester.longPress(find.byType(CdsIconButton));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.text('Network fees go to validators.'));
    expect(ctx.cds.isDark, isTrue);
  });
}
