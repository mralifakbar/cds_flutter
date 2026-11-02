import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final values = ['BTC', 'ETH', 'SOL'];

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      for (final v in values) CdsInputChip(label: v, onPress: () => setState(() => values.remove(v))),
    ]);
  }
}

void main() {
  group('CdsInputChip', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(tester, const _Host(), brightness: brightness);
        expect(tester.takeException(), isNull);
        expect(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.close), findsNWidgets(3));
      });
    }

    testWidgets('pressing removes the value', (tester) async {
      await pumpCds(tester, const _Host());
      await tester.tap(find.text('ETH'));
      await tester.pumpAndSettle();
      expect(find.text('ETH'), findsNothing);
      expect(find.text('BTC'), findsOneWidget);
    });

    testWidgets('is active (inverted) by default', (tester) async {
      await pumpCds(tester, CdsInputChip(label: 'BTC', onPress: () {}));
      final box = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).first;
      expect((box.decoration! as BoxDecoration).color, CdsThemeData.dark.color.bgSecondary);
    });

    testWidgets('semantics: "Remove <label>" button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsInputChip(label: 'BTC', onPress: () {}));
      expect(tester.getSemantics(find.byType(CdsPressable)), containsSemantics(label: 'Remove BTC', isButton: true));
      handle.dispose();
    });

    testWidgets('keyboard: Space removes', (tester) async {
      await pumpCds(tester, const _Host());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('BTC'), findsNothing);
    });

    testWidgets('disabled does not remove', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsInputChip(label: 'BTC', disabled: true, onPress: () => taps++));
      await tester.tap(find.text('BTC'));
      expect(taps, 0);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, const _Host(), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
