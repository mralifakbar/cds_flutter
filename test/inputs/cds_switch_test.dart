import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Toggle extends StatefulWidget {
  const _Toggle({this.initial = false, this.accept = true});

  final bool initial;

  /// When false the parent refuses every change.
  final bool accept;

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  late bool checked = widget.initial;
  final changes = <bool>[];

  @override
  Widget build(BuildContext context) => CdsSwitch(
        label: 'Alerts',
        checked: checked,
        onChange: (v) {
          changes.add(v);
          if (widget.accept) setState(() => checked = v);
        },
      );
}

/// Thumb offset from the track's start edge, in logical px.
double _thumbLeft(WidgetTester tester) {
  final positioned = tester.widget<Positioned>(
    find.descendant(of: find.byType(CdsSwitch), matching: find.byType(Positioned)).first,
  );
  return positioned.left!;
}

Finder get _track => find.byWidgetPredicate((w) => w is GestureDetector && w.onHorizontalDragStart != null);

void main() {
  group('CdsSwitch', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders all states in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Column(mainAxisSize: MainAxisSize.min, children: [
            CdsSwitch(label: 'Off', onChange: (_) {}),
            CdsSwitch(label: 'On', checked: true, onChange: (_) {}),
            for (final v in CdsSwitchVariant.values) CdsSwitch(checked: true, variant: v, semanticLabel: v.name, onChange: (_) {}),
            const CdsSwitch(label: 'Disabled', checked: true, disabled: true),
            const CdsSwitch(label: 'Read only', readOnly: true),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tap toggles and the thumb springs to the other end', (tester) async {
      await pumpCds(tester, const _Toggle());
      expect(_thumbLeft(tester), 1);
      await tester.tap(find.text('Alerts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final mid = _thumbLeft(tester);
      expect(mid, greaterThan(1));
      expect(mid, lessThan(21));
      await tester.pumpAndSettle();
      expect(_thumbLeft(tester), closeTo(21, 0.01));
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, [true]);
    });

    testWidgets('thumb follows the finger 1:1 while dragging', (tester) async {
      await pumpCds(tester, const _Toggle());
      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(20, 0)); // past touch slop, thumb at the end
      await tester.pump();
      final start = _thumbLeft(tester);
      await gesture.moveBy(const Offset(-5, 0));
      await tester.pump();
      expect(_thumbLeft(tester) - start, closeTo(-5, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('rubberbands past the end instead of stopping dead', (tester) async {
      await pumpCds(tester, const _Toggle(initial: true));
      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      final left = _thumbLeft(tester);
      expect(left, greaterThan(21));
      expect(left, lessThan(21 + 60));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_thumbLeft(tester), closeTo(21, 0.01));
    });

    testWidgets('slow drag past the middle commits', (tester) async {
      await pumpCds(tester, const _Toggle());
      await tester.timedDrag(_track, const Offset(24, 0), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, [true]);
      expect(_thumbLeft(tester), closeTo(21, 0.01));
    });

    testWidgets('released short of the middle with no velocity, it springs back', (tester) async {
      await pumpCds(tester, const _Toggle());
      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(-16, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pump();
      expect(_thumbLeft(tester), greaterThan(1));
      await tester.pumpAndSettle();
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, isEmpty);
      expect(_thumbLeft(tester), closeTo(1, 0.01));
    });

    testWidgets('a quick flick toward on commits even when short', (tester) async {
      await pumpCds(tester, const _Toggle());
      final gesture = await tester.startGesture(tester.getCenter(_track));
      // Cross the slop away from "on", then flick back fast. The net
      // displacement is tiny, so only the velocity can carry it over.
      var time = Duration.zero;
      await gesture.moveBy(const Offset(-20, 0), timeStamp: time);
      time += const Duration(milliseconds: 150);
      await gesture.moveBy(const Offset(-1, 0), timeStamp: time);
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        time += const Duration(milliseconds: 8);
        await gesture.moveBy(const Offset(6, 0), timeStamp: time);
      }
      await tester.pump();
      expect(_thumbLeft(tester), lessThan(11));
      await gesture.up(timeStamp: time + const Duration(milliseconds: 8));
      await tester.pumpAndSettle();
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, [true]);
    });

    testWidgets('springs back when the parent refuses the change', (tester) async {
      await pumpCds(tester, const _Toggle(accept: false));
      await tester.timedDrag(_track, const Offset(24, 0), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, [true]);
      expect(_thumbLeft(tester), closeTo(1, 0.01));
    });

    testWidgets('right-to-left: on sits at the left and dragging left turns it on', (tester) async {
      await pumpCds(tester, const _Toggle(), textDirection: TextDirection.rtl);
      expect(_thumbLeft(tester), closeTo(21, 0.01));
      await tester.timedDrag(_track, const Offset(-24, 0), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, [true]);
      expect(_thumbLeft(tester), closeTo(1, 0.01));
    });

    testWidgets('disabled switch ignores taps and drags', (tester) async {
      var calls = 0;
      await pumpCds(tester, CdsSwitch(label: 'D', disabled: true, onChange: (_) => calls++));
      await tester.tap(find.text('D'));
      await tester.drag(find.byType(CdsSwitch), const Offset(30, 0));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('semantics: toggled state and label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsSwitch(label: 'Alerts', checked: true, onChange: (_) {}));
      expect(
        tester.getSemantics(find.text('Alerts')),
        containsSemantics(label: 'Alerts', isToggled: true, hasToggledState: true, isEnabled: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('keyboard: Space toggles', (tester) async {
      await pumpCds(tester, const _Toggle());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(tester.state<_ToggleState>(find.byType(_Toggle)).changes, [true]);
    });

    testWidgets('reduced motion moves the thumb without animating', (tester) async {
      await pumpCds(tester, const _Toggle(), disableAnimations: true);
      await tester.tap(find.text('Alerts'));
      await tester.pump();
      expect(_thumbLeft(tester), closeTo(21, 0.01));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(
        tester,
        SizedBox(width: 300, child: CdsSwitch(label: 'Notify me when the price of Bitcoin moves', onChange: (_) {})),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
