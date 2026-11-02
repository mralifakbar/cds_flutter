import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _media = CdsIcon(CdsIconName.crypto);

EdgeInsetsGeometry _padding(WidgetTester tester) => tester
    .widget<Padding>(find.descendant(of: find.byType(CdsMediaChip), matching: find.byType(Padding)).first)
    .padding;

void main() {
  group('cdsMediaChipSpacing', () {
    test('matches getMediaChipSpacingProps', () {
      expect(cdsMediaChipSpacing(start: false, label: true, end: false), (paddingStart: 2.0, paddingEnd: 2.0, paddingY: 1.0, gap: 1.0));
      expect(cdsMediaChipSpacing(start: true, label: false, end: false), (paddingStart: 1.0, paddingEnd: 1.0, paddingY: 1.0, gap: 1.0));
      expect(cdsMediaChipSpacing(start: true, label: true, end: false), (paddingStart: 1.0, paddingEnd: 2.0, paddingY: 1.0, gap: 0.75));
      expect(cdsMediaChipSpacing(start: true, label: true, end: false, size: CdsChipSize.xs),
          (paddingStart: 1.0, paddingEnd: 1.5, paddingY: 0.75, gap: 0.75));
      expect(cdsMediaChipSpacing(start: false, label: true, end: true), (paddingStart: 2.0, paddingEnd: 1.5, paddingY: 1.0, gap: 0.75));
      expect(cdsMediaChipSpacing(start: true, label: false, end: true), (paddingStart: 1.0, paddingEnd: 1.5, paddingY: 1.0, gap: 0.75));
      expect(cdsMediaChipSpacing(start: true, label: true, end: true), (paddingStart: 1.0, paddingEnd: 1.5, paddingY: 1.0, gap: 0.75));
    });
  });

  group('CdsMediaChip', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Wrap(children: [
            CdsMediaChip(label: 'Bitcoin', start: _media, onPress: () {}),
            const CdsMediaChip(start: _media),
            CdsMediaChip(label: 'Active', start: _media, active: true, onPress: () {}),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tightens start padding around media', (tester) async {
      await pumpCds(tester, const CdsMediaChip(label: 'Bitcoin', start: _media));
      expect(_padding(tester), const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 8));
    });

    testWidgets('onPress fires', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsMediaChip(label: 'ETH', start: _media, onPress: () => taps++));
      await tester.tap(find.text('ETH'));
      expect(taps, 1);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, CdsMediaChip(label: 'Bitcoin', start: _media, onPress: () {}), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
