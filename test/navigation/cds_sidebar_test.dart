import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _sidebar({
  bool? collapsed,
  bool autoCollapse = false,
  CdsSidebarVariant variant = CdsSidebarVariant.defaultVariant,
  ValueChanged<String>? onPress,
  ValueChanged<bool>? onOpenChange,
}) =>
    SizedBox(
      height: 600,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CdsSidebar(
            collapsed: collapsed,
            autoCollapse: autoCollapse,
            variant: variant,
            logo: const CdsText('Logo'),
            renderEnd: (c) => CdsText(c ? 'E' : 'End'),
            children: [
              CdsSidebarItem(icon: CdsIconName.home, title: 'Home', active: true, onPress: () => onPress?.call('home')),
              CdsSidebarItem(icon: CdsIconName.trading, title: 'Trade', onPress: () => onPress?.call('trade')),
              CdsSidebarMoreMenu(
                onOpenChange: onOpenChange,
                children: [
                  CdsSidebarItem(icon: CdsIconName.settings, title: 'Settings', onPress: () => onPress?.call('settings')),
                ],
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );

double _width(WidgetTester tester) => tester.getSize(find.byType(CdsSidebar)).width;

void main() {
  testWidgets('renders in light and dark, both variants', (tester) async {
    for (final b in Brightness.values) {
      for (final v in CdsSidebarVariant.values) {
        await pumpCds(tester, _sidebar(variant: v), brightness: b, center: false);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('uses CDS widths', (tester) async {
    await pumpCds(tester, _sidebar(), center: false);
    expect(_width(tester), 240);
    await pumpCds(tester, _sidebar(collapsed: true), center: false);
    expect(_width(tester), 87);
    await pumpCds(tester, _sidebar(variant: CdsSidebarVariant.condensed), center: false);
    expect(_width(tester), 88);
  });

  testWidgets('autoCollapse collapses below 768px and hides titles', (tester) async {
    await pumpCds(tester, _sidebar(autoCollapse: true), center: false);
    expect(_width(tester), 87);
    expect(find.text('Trade'), findsNothing);
    expect(find.text('E'), findsOneWidget);
  });

  testWidgets('items fire onPress and expose selected and labels', (tester) async {
    final handle = tester.ensureSemantics();
    final pressed = <String>[];
    await pumpCds(tester, _sidebar(onPress: pressed.add), center: false);
    await tester.tap(find.text('Trade'));
    await tester.pumpAndSettle();
    expect(pressed, ['trade']);
    expect(tester.getSemantics(find.text('Home')), containsSemantics(label: 'Home', isSelected: true, isButton: true));

    await pumpCds(tester, _sidebar(collapsed: true), center: false);
    expect(find.bySemanticsLabel('Trade'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('width change animates and settles', (tester) async {
    await pumpCds(tester, _sidebar(collapsed: false), center: false);
    await tester.pumpWidget(cdsHarness(_sidebar(collapsed: true), center: false));
    await tester.pump(const Duration(milliseconds: 100));
    final mid = _width(tester);
    expect(mid, inExclusiveRange(87, 240));
    await tester.pumpAndSettle();
    expect(_width(tester), 87);
  });

  testWidgets('arrow keys move focus between items', (tester) async {
    await pumpCds(tester, _sidebar(), center: false);
    Focus.of(tester.element(find.text('Home'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Trade'))).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Home'))).hasPrimaryFocus, isTrue);
  });

  testWidgets('more menu opens, reports expanded, closes on item press', (tester) async {
    final handle = tester.ensureSemantics();
    final open = <bool>[];
    final pressed = <String>[];
    await pumpCds(tester, _sidebar(onOpenChange: open.add, onPress: pressed.add), center: false);
    expect(tester.getSemantics(find.text('More')), containsSemantics(isExpanded: false));

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.getSemantics(find.text('More')), containsSemantics(isExpanded: true));
    expect(Focus.of(tester.element(find.text('Settings'))).hasPrimaryFocus, isTrue);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(pressed, ['settings']);
    expect(find.text('Settings'), findsNothing);
    expect(open, [true, false]);
    expect(Focus.of(tester.element(find.text('More'))).hasPrimaryFocus, isTrue);
    handle.dispose();
  });

  testWidgets('more menu closes on Escape and outside tap', (tester) async {
    await pumpCds(tester, _sidebar(), center: false);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);

    // CdsPressable debounces repeat presses for 500ms of wall-clock time.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 550)));
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tapAt(const Offset(380, 580));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('reduced motion opens the menu with no running tickers', (tester) async {
    await pumpCds(tester, _sidebar(), center: false, disableAnimations: true);
    await tester.tap(find.text('More'));
    await tester.pump();
    expect(find.text('Settings'), findsOneWidget);
    final fade = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('Settings'), matching: find.byType(FadeTransition)).last,
    );
    expect(fade.opacity.value, 1);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('RTL and text scale 2 do not overflow', (tester) async {
    for (final v in CdsSidebarVariant.values) {
      await pumpCds(tester, _sidebar(variant: v), center: false, textDirection: TextDirection.rtl, textScale: 2);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 550)));
    }
  });
}
