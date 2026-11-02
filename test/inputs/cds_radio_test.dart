import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsRadio', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Column(mainAxisSize: MainAxisSize.min, children: [
            CdsRadio(label: 'Off', onChange: (_) {}),
            CdsRadio(label: 'On', checked: true, onChange: (_) {}),
            const CdsRadio(label: 'Disabled', checked: true, disabled: true),
            CdsRadio(label: 'Custom', checked: true, controlColor: CdsColor.bgPositive, dotSize: 8, onChange: (_) {}),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tap calls onChange with !checked', (tester) async {
      final calls = <bool>[];
      await pumpCds(tester, CdsRadio(label: 'R', onChange: calls.add));
      await tester.tap(find.text('R'));
      expect(calls, [true]);
    });

    testWidgets('disabled radio does not fire', (tester) async {
      var calls = 0;
      await pumpCds(tester, CdsRadio(label: 'R', disabled: true, onChange: (_) => calls++));
      await tester.tap(find.text('R'));
      expect(calls, 0);
    });

    testWidgets('semantics: checked and in a mutually exclusive group', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsRadio(label: 'Bank', checked: true, onChange: (_) {}));
      expect(
        tester.getSemantics(find.text('Bank')),
        containsSemantics(label: 'Bank', isChecked: true, isInMutuallyExclusiveGroup: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('keyboard Enter activates', (tester) async {
      final calls = <bool>[];
      await pumpCds(tester, CdsRadio(label: 'R', onChange: calls.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, [true]);
    });

    testWidgets('reduced motion and text scale 2.0', (tester) async {
      await pumpCds(tester, CdsRadio(label: 'A long radio label that wraps', checked: true, onChange: (_) {}),
          disableAnimations: true, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
