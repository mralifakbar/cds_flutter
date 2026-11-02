import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _padded(Widget child) => Padding(padding: const EdgeInsets.all(16), child: child);

Finder get _pressedBorder =>
    find.descendant(of: find.byType(CdsRadioCell), matching: find.byType(FadeTransition)).last;

void main() {
  group('CdsRadioCell', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _padded(Column(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
            CdsRadioCell(title: 'Off', description: 'Sample data', onChange: (_) {}),
            CdsRadioCell(title: 'On', checked: true, onChange: (_) {}),
            const CdsRadioCell(title: 'Disabled', description: 'Not available', disabled: true),

          ])),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('pressing anywhere on the row calls onChange with !checked', (tester) async {
      final calls = <bool>[];
      await pumpCds(tester, _padded(CdsRadioCell(title: 'Row', description: 'Details', onChange: calls.add)));
      await tester.tap(find.text('Details'));
      expect(calls, [true]);
    });

    testWidgets('disabled and read-only rows do not fire', (tester) async {
      var calls = 0;
      await pumpCds(
        tester,
        _padded(Column(mainAxisSize: MainAxisSize.min, children: [
          CdsRadioCell(title: 'D', disabled: true, onChange: (_) => calls++),
          CdsRadioCell(title: 'R', readOnly: true, onChange: (_) => calls++),
        ])),
      );
      await tester.tap(find.text('D'));
      await tester.tap(find.text('R'));
      expect(calls, 0);
    });

    testWidgets('pressed border fades in on pointer down and out on release', (tester) async {
      await pumpCds(tester, _padded(CdsRadioCell(title: 'Press', onChange: (_) {})));
      expect(tester.widget<FadeTransition>(_pressedBorder).opacity.value, 0);
      final gesture = await tester.startGesture(tester.getCenter(find.text('Press')));
      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(_pressedBorder).opacity.value, 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(_pressedBorder).opacity.value, 0);
    });

    testWidgets('semantics: combined label, CDS hint, checked state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        _padded(Column(mainAxisSize: MainAxisSize.min, children: [
          CdsRadioCell(title: 'Title', description: 'Description', onChange: (_) {}),
          CdsRadioCell(title: 'Checked', checked: true, onChange: (_) {}),

        ])),
      );
      expect(
        tester.getSemantics(find.text('Title')),
        containsSemantics(label: 'Title, Description', hint: 'Tap to select this option', isChecked: false, hasTapAction: true),
      );
      expect(
        tester.getSemantics(find.text('Checked')),
        containsSemantics(label: 'Checked', hint: 'Tap to unselect this option', isChecked: true),
      );
      expect(tester.getSemantics(find.text('Title')), containsSemantics(isInMutuallyExclusiveGroup: true));
      handle.dispose();
    });

    testWidgets('keyboard: Tab then Space toggles', (tester) async {
      final calls = <bool>[];
      await pumpCds(tester, _padded(CdsRadioCell(title: 'K', onChange: calls.add)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(calls, [true]);
    });

    testWidgets('reduced motion: pressed border snaps', (tester) async {
      await pumpCds(tester, _padded(CdsRadioCell(title: 'Press', onChange: (_) {})), disableAnimations: true);
      final gesture = await tester.startGesture(tester.getCenter(find.text('Press')));
      await tester.pump();
      expect(tester.widget<FadeTransition>(_pressedBorder).opacity.value, 1);
      await gesture.up();
      await tester.pump();
      expect(tester.widget<FadeTransition>(_pressedBorder).opacity.value, 0);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(
        tester,
        _padded(CdsRadioCell(
          title: 'Recurring purchase every week',
          description: 'Repeat this order on the same day each week until you cancel it',
          onChange: (_) {},
        )),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
