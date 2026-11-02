import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _frame(Widget child) => SizedBox(width: 390, child: SingleChildScrollView(child: child));

void main() {
  group('CdsContentCell', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every variant in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _frame(Column(mainAxisSize: MainAxisSize.min, children: [
            for (final v in CdsCellSpacingVariant.values)
              CdsContentCell(
                spacingVariant: v,
                media: const CdsIcon(CdsIconName.bell),
                title: 'Price alert',
                subtitle: 'Sample data',
                meta: '2m ago',
                description: 'Bitcoin rose above your alert price of 60,000 USD.',
                accessory: CdsCellAccessoryType.arrow,
                onPress: () {},
              ),
          ])),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('2m ago'), findsNWidgets(3));
      });
    }

    testWidgets('description wraps without a line limit', (tester) async {
      await pumpCds(tester, _frame(const CdsContentCell(title: 'T', description: 'A long description that keeps going and going so it needs several lines to fit in the cell.')));
      final text = tester.widget<Text>(find.textContaining('A long description'));
      expect(text.maxLines, isNull);
    });

    testWidgets('fires onPress and shows selection', (tester) async {
      var taps = 0;
      await pumpCds(tester, _frame(CdsContentCell(title: 'Choose', selected: true, onPress: () => taps++)));
      await tester.tap(find.text('Choose'));
      expect(taps, 1);
      expect(tester.widget<CdsCellAccessory>(find.byType(CdsCellAccessory)).type, CdsCellAccessoryType.selected);
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, _frame(const CdsContentCell(title: 'Price alert', meta: '2m ago', description: 'Sample data')), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
