import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _bar({Widget? start, Widget? end, Widget? bottom, String title = 'Profile'}) => CdsTopNavBar(
      start: start,
      end: end,
      bottom: bottom,
      child: CdsNavigationTitle(title),
    );

final _back = CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: () {});

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _bar(start: _back), brightness: b, center: false);
      expect(find.text('Profile'), findsOneWidget);
    }
  });

  testWidgets('keeps the title centered when only start is set', (tester) async {
    await pumpCds(tester, _bar(start: _back), center: false);
    final bar = tester.getRect(find.byType(CdsTopNavBar));
    expect(tester.getCenter(find.text('Profile')).dx, closeTo(bar.center.dx, 0.5));
  });

  testWidgets('long titles ellipsize instead of overlapping actions', (tester) async {
    await pumpCds(
      tester,
      _bar(
        start: _back,
        end: CdsNavBarIconButton(CdsIconName.settings, semanticLabel: 'Settings', onPress: () {}),
        title: 'A very long navigation title that cannot possibly fit on one line',
      ),
      center: false,
    );
    expect(tester.takeException(), isNull);
    final title = tester.getRect(find.byType(CdsNavigationTitle));
    final back = tester.getRect(find.byType(CdsNavBarIconButton).first);
    final settings = tester.getRect(find.byType(CdsNavBarIconButton).last);
    expect(title.left, greaterThanOrEqualTo(back.right));
    expect(title.right, lessThanOrEqualTo(settings.left));
  });

  testWidgets('start and end sit on mirrored sides in RTL', (tester) async {
    await pumpCds(
      tester,
      _bar(start: _back, end: CdsNavBarIconButton(CdsIconName.settings, semanticLabel: 'Settings', onPress: () {})),
      textDirection: TextDirection.rtl,
      center: false,
    );
    final back = tester.getCenter(find.bySemanticsLabel('Back'));
    final settings = tester.getCenter(find.bySemanticsLabel('Settings'));
    expect(back.dx, greaterThan(settings.dx));
  });

  testWidgets('applies the top safe area', (tester) async {
    await pumpCds(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: const EdgeInsets.only(top: 47)),
          child: Align(alignment: Alignment.topCenter, child: _bar()),
        ),
      ),
      center: false,
    );
    expect(tester.getTopLeft(find.text('Profile')).dy, greaterThan(47 + 16 - 1));
  });

  testWidgets('removing start collapses the slot with animation', (tester) async {
    await pumpCds(tester, _bar(start: _back), center: false);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    await pumpCds(tester, _bar(), center: false, settle: false);
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(CdsNavBarIconButton), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CdsNavBarIconButton), findsNothing);
  });

  testWidgets('renders the bottom slot', (tester) async {
    await pumpCds(tester, _bar(bottom: const Text('Tabs here')), center: false);
    expect(find.text('Tabs here'), findsOneWidget);
  });

  testWidgets('title is a header; bar is labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _bar(start: _back), center: false);
    expect(tester.getSemantics(find.text('Profile')).getSemanticsData().flagsCollection.isHeader, isTrue);
    expect(find.bySemanticsLabel('main navigation'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await pumpCds(tester, _bar(start: _back), textScale: 2, center: false);
    expect(tester.takeException(), isNull);
  });

  group('CdsNavBarIconButton', () {
    testWidgets('fires onPress, has a 44px target and a label', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpCds(tester, CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () => taps++));
      await tester.tap(find.byType(CdsNavBarIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.getSize(find.byType(CdsPressable)), const Size(44, 44));
      expect(
        tester.getSemantics(find.byType(CdsNavBarIconButton)),
        matchesSemantics(label: 'Close', isButton: true, hasTapAction: true, hasEnabledState: true, isEnabled: true, isFocusable: true, hasFocusAction: true),
      );
      handle.dispose();
    });

    testWidgets('disabled does not fire', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', disabled: true, onPress: () => taps++));
      await tester.tap(find.byType(CdsNavBarIconButton));
      await tester.pumpAndSettle();
      expect(taps, 0);
    });
  });
}
