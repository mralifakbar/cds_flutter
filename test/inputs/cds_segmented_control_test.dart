import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _options = [
  CdsSegmentedControlOption(value: 'a', label: 'One'),
  CdsSegmentedControlOption(value: 'b', label: 'Two'),
  CdsSegmentedControlOption(value: 'c', label: 'Three'),
];

class _Host extends StatefulWidget {
  const _Host({this.disabled = false, this.onChange});

  final bool disabled;
  final ValueChanged<String>? onChange;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String value = 'a';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: CdsSegmentedControl<String>(
        options: _options,
        value: value,
        block: true,
        disabled: widget.disabled,
        semanticLabel: 'Count',
        onChange: (v) {
          setState(() => value = v);
          widget.onChange?.call(v);
        },
      ),
    );
  }
}

Finder _seg(String label) =>
    find.ancestor(of: find.text(label).first, matching: find.byType(CdsPressable));

double _indicatorLeft(WidgetTester tester) {
  final positioned = tester.widgetList<Positioned>(find.descendant(
    of: find.byType(CdsSegmentedControl<String>),
    matching: find.byWidgetPredicate((w) => w is Positioned && w.width != null),
  ));
  return positioned.first.left!;
}

void main() {
  group('CdsSegmentedControl', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders text and icon options in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CdsSegmentedControl<String>(options: _options, value: 'b', onChange: (_) {}),
              CdsSegmentedControl<int>(
                value: 0,
                onChange: (_) {},
                options: const [
                  CdsSegmentedControlOption(value: 0, icon: CdsIconName.chartLine, semanticLabel: 'Line'),
                  CdsSegmentedControlOption(value: 1, icon: CdsIconName.chartBar, semanticLabel: 'Bar'),
                ],
              ),
              CdsSegmentedControl<String>(options: _options, value: 'a', disabled: true, onChange: (_) {}),
            ],
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.check), findsNothing);
      });
    }

    testWidgets('tap selects and the indicator springs to the new segment', (tester) async {
      final changes = <String>[];
      await pumpCds(tester, _Host(onChange: changes.add));
      expect(_indicatorLeft(tester), 0);
      await tester.tap(_seg('Three'));
      await tester.pump();
      expect(changes, ['c']);
      await tester.pump(const Duration(milliseconds: 50));
      final mid = _indicatorLeft(tester);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(200));
      await tester.pumpAndSettle();
      expect(_indicatorLeft(tester), moreOrLessEquals(200, epsilon: 0.5));
    });

    testWidgets('equal-width segments when not block', (tester) async {
      await pumpCds(tester, CdsSegmentedControl<String>(options: _options, value: 'a', onChange: (_) {}));
      final widths = [
        for (final label in ['One', 'Two', 'Three'])
          tester.getSize(_seg(label)).width,
      ];
      expect(widths[0], moreOrLessEquals(widths[2]));
      expect(widths[1], moreOrLessEquals(widths[2]));
    });

    testWidgets('dragging across segments selects the one under the finger', (tester) async {
      final changes = <String>[];
      await pumpCds(tester, _Host(onChange: changes.add));
      final start = tester.getCenter(_seg('One'));
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();
      expect(changes, ['b']);
      // Grabbed the highlight: it follows the finger 1:1 from where the drag
      // was recognized (after the 20px touch slop move).
      expect(_indicatorLeft(tester), moreOrLessEquals(80, epsilon: 1));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      expect(changes, ['b', 'c']);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_indicatorLeft(tester), moreOrLessEquals(200, epsilon: 0.5));
    });

    testWidgets('drag starting off the highlight selects and chases', (tester) async {
      final changes = <String>[];
      await pumpCds(tester, _Host(onChange: changes.add));
      await tester.dragFrom(tester.getCenter(_seg('Three')) - const Offset(30, 0), const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(changes.first, 'c');
      expect(_indicatorLeft(tester), moreOrLessEquals(200, epsilon: 0.5));
    });

    testWidgets('disabled ignores taps and drags', (tester) async {
      final changes = <String>[];
      await pumpCds(tester, _Host(disabled: true, onChange: changes.add));
      await tester.tap(_seg('Two'));
      await tester.drag(_seg('One'), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('arrow keys move the selection', (tester) async {
      final changes = <String>[];
      await pumpCds(tester, _Host(onChange: changes.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(changes, ['b', 'c', 'b']);
    });

    testWidgets('semantics: selected button in a mutually exclusive group', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const _Host());
      expect(
        tester.getSemantics(_seg('One')),
        containsSemantics(label: 'One', isButton: true, isSelected: true, isInMutuallyExclusiveGroup: true),
      );
      expect(
        tester.getSemantics(_seg('Two')),
        containsSemantics(label: 'Two', isSelected: false, isInMutuallyExclusiveGroup: true),
      );
      handle.dispose();
    });

    testWidgets('reduced motion moves the indicator instantly', (tester) async {
      await pumpCds(tester, const _Host(), disableAnimations: true);
      await tester.tap(_seg('Two'));
      await tester.pump();
      expect(_indicatorLeft(tester), 100);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('RTL places the first segment at the right', (tester) async {
      await pumpCds(tester, const _Host(), textDirection: TextDirection.rtl);
      expect(_indicatorLeft(tester), 200);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, CdsSegmentedControl<String>(options: _options, value: 'a', onChange: (_) {}), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
