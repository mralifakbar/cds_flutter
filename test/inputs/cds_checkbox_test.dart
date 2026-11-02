import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Toggle extends StatefulWidget {
  const _Toggle();

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool checked = false;

  @override
  Widget build(BuildContext context) =>
      CdsCheckbox(label: 'Accept', checked: checked, onChange: (v) => setState(() => checked = v));
}

void main() {
  group('CdsCheckbox', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders all states in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CdsCheckbox(label: 'Off', onChange: (_) {}),
              CdsCheckbox(label: 'On', checked: true, onChange: (_) {}),
              CdsCheckbox(label: 'Mixed', indeterminate: true, onChange: (_) {}),
              const CdsCheckbox(label: 'Disabled', checked: true, disabled: true),
              const CdsCheckbox(label: 'Read only', checked: true, readOnly: true),
              CdsCheckbox(semanticLabel: 'No label', onChange: (_) {}),
            ],
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tap calls onChange with the next value', (tester) async {
      final calls = <bool>[];
      await pumpCds(tester, CdsCheckbox(label: 'A', onChange: calls.add));
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(calls, [true]);

      await pumpCds(tester, CdsCheckbox(label: 'A', checked: true, onChange: calls.add));
      await tester.tap(find.text('A'));
      expect(calls, [true, false]);
    });

    testWidgets('indeterminate tap reports checked', (tester) async {
      bool? next;
      await pumpCds(tester, CdsCheckbox(label: 'I', indeterminate: true, onChange: (v) => next = v));
      await tester.tap(find.text('I'));
      expect(next, isTrue);
      expect(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.minus), findsOneWidget);
    });

    testWidgets('does not fire when disabled or read only', (tester) async {
      var calls = 0;
      await pumpCds(
        tester,
        Column(mainAxisSize: MainAxisSize.min, children: [
          CdsCheckbox(label: 'D', disabled: true, onChange: (_) => calls++),
          CdsCheckbox(label: 'R', readOnly: true, onChange: (_) => calls++),
        ]),
      );
      await tester.tap(find.text('D'));
      await tester.tap(find.text('R'));
      expect(calls, 0);
    });

    testWidgets('reflects the checked value it is given', (tester) async {
      await pumpCds(tester, const _Toggle());
      final glyph = find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.checkmark);
      Opacity opacity() => tester.widget<Opacity>(find.ancestor(of: glyph, matching: find.byType(Opacity)).first);
      expect(opacity().opacity, 0);
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      expect(opacity().opacity, 1);
    });

    testWidgets('check animation can reverse mid-flight', (tester) async {
      await pumpCds(tester, const _Toggle());
      final glyph = find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.checkmark);
      double opacity() =>
          tester.widget<Opacity>(find.ancestor(of: glyph, matching: find.byType(Opacity)).first).opacity;
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final mid = opacity();
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(opacity(), lessThanOrEqualTo(mid));
      await tester.pumpAndSettle();
      expect(opacity(), 0);
    });

    testWidgets('semantics: checked, mixed, label, enabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        Column(mainAxisSize: MainAxisSize.min, children: [
          CdsCheckbox(label: 'Checked', checked: true, onChange: (_) {}),
          CdsCheckbox(label: 'Mixed', indeterminate: true, onChange: (_) {}),
          const CdsCheckbox(label: 'Off', disabled: true),
        ]),
      );
      expect(
        tester.getSemantics(find.text('Checked')),
        containsSemantics(label: 'Checked', isChecked: true, hasCheckedState: true, isEnabled: true, hasTapAction: true),
      );
      expect(tester.getSemantics(find.text('Mixed')), containsSemantics(isCheckStateMixed: true, isChecked: false));
      expect(tester.getSemantics(find.text('Off')), containsSemantics(isEnabled: false, hasTapAction: false));
      handle.dispose();
    });

    testWidgets('semanticLabel replaces the visible label for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsCheckbox(label: 'Visible', semanticLabel: 'Spoken', onChange: (_) {}));
      expect(find.bySemanticsLabel('Spoken'), findsOneWidget);
      expect(find.bySemanticsLabel('Visible'), findsNothing);
      handle.dispose();
    });

    testWidgets('keyboard: Tab focuses, Space toggles', (tester) async {
      final calls = <bool>[];
      await pumpCds(tester, CdsCheckbox(label: 'K', onChange: calls.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(calls, [true]);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('hit area is at least 44px', (tester) async {
      await pumpCds(tester, CdsCheckbox(semanticLabel: 'Small', onChange: (_) {}));
      final size = tester.getSize(find.byType(CdsPressable));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('reduced motion applies the checked state immediately', (tester) async {
      await pumpCds(tester, const _Toggle(), disableAnimations: true);
      await tester.tap(find.text('Accept'));
      await tester.pump();
      final glyph = find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.checkmark);
      expect(tester.widget<Opacity>(find.ancestor(of: glyph, matching: find.byType(Opacity)).first).opacity, 1);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('text scale 2.0 with a long label does not overflow', (tester) async {
      await pumpCds(
        tester,
        SizedBox(
          width: 300,
          child: CdsCheckbox(
            label: 'I agree to the terms of service and acknowledge the privacy notice for this account',
            onChange: (_) {},
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
