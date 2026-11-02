import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsKbd', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders keycaps in ${brightness.name}', (tester) async {
        await pumpCds(tester, const CdsKbd(['⌘', 'Shift', 'K']), brightness: brightness);
        expect(tester.takeException(), isNull);
        expect(find.text('Shift'), findsOneWidget);
      });
    }

    testWidgets('speaks symbols by name', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsKbd(['⌘', 'K']));
      expect(find.bySemanticsLabel('Command K'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keycaps are at least 24px', (tester) async {
      await pumpCds(tester, const CdsKbd(['K']));
      final size = tester.getSize(find.byType(CdsKbd));
      expect(size.width, greaterThanOrEqualTo(24));
      expect(size.height, greaterThanOrEqualTo(24));
    });

    testWidgets('wraps instead of overflowing at text scale 2', (tester) async {
      await pumpCds(tester, const SizedBox(width: 120, child: CdsKbd(['Ctrl', 'Shift', 'Alt', 'Delete'])), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
