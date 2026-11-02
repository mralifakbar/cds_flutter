import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import '../media/test_images.dart';

const _host = SizedBox(key: Key('host'), width: 48, height: 48);

void main() {
  group('CdsDotCount', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders pinned and inline in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          const Row(mainAxisSize: MainAxisSize.min, children: [
            CdsDotCount(count: 3, child: _host),
            CdsDotCount(count: 120, overlap: CdsDotOverlap.circular, child: _host),
            CdsDotCount(count: 7),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('truncates past max', (tester) async {
      await pumpCds(tester, const CdsDotCount(count: 120));
      expect(find.text('99+'), findsOneWidget);
      await pumpCds(tester, const CdsDotCount(count: 12, max: 9));
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('is centered on the top end corner of its child', (tester) async {
      await pumpCds(tester, const CdsDotCount(count: 3, child: _host));
      final host = tester.getRect(find.byKey(const Key('host')));
      final dot = tester.getRect(find.text('3'));
      expect(dot.center.dx, moreOrLessEquals(host.right, epsilon: 0.5));
      expect(dot.center.dy, moreOrLessEquals(host.top, epsilon: 1));
    });

    testWidgets('mirrors to the top left in right-to-left', (tester) async {
      await pumpCds(tester, const CdsDotCount(count: 3, child: _host), textDirection: TextDirection.rtl);
      final host = tester.getRect(find.byKey(const Key('host')));
      expect(tester.getCenter(find.text('3')).dx, moreOrLessEquals(host.left, epsilon: 0.5));
    });

    testWidgets('fades out at 0 and back in when the count returns', (tester) async {
      Widget build(int count) => CdsDotCount(count: count, child: _host);
      await pumpCds(tester, build(5));
      await pumpCds(tester, build(0), settle: false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('5'), findsOneWidget, reason: 'keeps the last count while exiting');
      await tester.pumpAndSettle();
      expect(find.text('5'), findsNothing);
      expect(find.text('0'), findsNothing);
      await pumpCds(tester, build(2));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('changes instantly under reduced motion', (tester) async {
      await pumpCds(tester, const CdsDotCount(count: 5, child: _host), disableAnimations: true);
      await pumpCds(tester, const CdsDotCount(count: 0, child: _host), disableAnimations: true, settle: false);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('5'), findsNothing);
    });

    testWidgets('reads semanticLabel', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsDotCount(count: 3, semanticLabel: '3 unread messages'));
      expect(find.bySemanticsLabel('3 unread messages'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, const CdsDotCount(count: 120, child: _host), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('CdsDotStatusColor', () {
    testWidgets('sizes from the icon scale and uses the variant color', (tester) async {
      await pumpCds(tester, const CdsDotStatusColor(variant: CdsDotVariant.positive, size: CdsIconSize.xs));
      final box = tester.widget<Container>(find.descendant(of: find.byType(CdsDotStatusColor), matching: find.byType(Container)));
      expect((box.decoration! as BoxDecoration).color, CdsThemeData.light.color.bgPositive);
      expect(tester.getSize(find.byType(CdsDotStatusColor)), const Size(12, 12));
    });

    testWidgets('pins with circular overlap inside the corner', (tester) async {
      await pumpCds(tester, const CdsDotStatusColor(variant: CdsDotVariant.negative, pin: CdsDotPinPlacement.bottomEnd, overlap: CdsDotOverlap.circular, child: _host));
      final host = tester.getRect(find.byKey(const Key('host')));
      final dot = tester.getRect(find.byType(Container).last);
      // (48 / 2 - 16 / 2) / 2.5 = 6.4 inward from the corner.
      expect(dot.center.dx, moreOrLessEquals(host.right - 6.4, epsilon: 0.01));
      expect(dot.center.dy, moreOrLessEquals(host.bottom - 6.4, epsilon: 0.01));
    });

    testWidgets('carries a semantic label so status is not color alone', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsDotStatusColor(variant: CdsDotVariant.positive, semanticLabel: 'Online', child: _host));
      expect(find.bySemanticsLabel('Online'), findsOneWidget);
      handle.dispose();
    });

    for (final brightness in Brightness.values) {
      testWidgets('renders every variant in ${brightness.name}', (tester) async {
        await pumpCds(tester, Row(mainAxisSize: MainAxisSize.min, children: [
          for (final v in CdsDotVariant.values) CdsDotStatusColor(variant: v, pin: CdsDotPinPlacement.topStart, child: _host),
        ]), brightness: brightness);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('CdsDotSymbol', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders icon, image and custom symbols in ${brightness.name}', (tester) async {
        await pumpCds(tester, Row(mainAxisSize: MainAxisSize.min, children: [
          const CdsDotSymbol(iconName: CdsIconName.checkmark, child: _host),
          CdsDotSymbol(source: transparentImage(), pin: CdsDotPinPlacement.bottomEnd, child: _host),
          const CdsDotSymbol(symbol: SizedBox.square(dimension: 10), pin: CdsDotPinPlacement.bottomStart, child: _host),
        ]), brightness: brightness);
        expect(tester.takeException(), isNull);
        expect(find.byType(CdsRemoteImage), findsOneWidget);
      });
    }

    testWidgets('icon dot is icon size plus padding and ring', (tester) async {
      await pumpCds(tester, const CdsDotSymbol(iconName: CdsIconName.checkmark));
      expect(tester.getSize(find.byType(CdsDotSymbol)), const Size(16 + 8 + 4, 16 + 8 + 4));
    });

    testWidgets('reads semanticLabel', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsDotSymbol(iconName: CdsIconName.checkmark, semanticLabel: 'Verified', child: _host));
      expect(find.bySemanticsLabel('Verified'), findsOneWidget);
      handle.dispose();
    });
  });
}
