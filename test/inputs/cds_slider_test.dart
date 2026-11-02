import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

// 324 wide, centered in the 800x600 test surface: the track runs from x=250 to x=550 (300px).
const double _width = 324;
const double _trackLeft = 250;
const double _trackWidth = 300;

double _x(double fraction) => _trackLeft + fraction * _trackWidth;

Finder _thumbs(Type type) =>
    find.descendant(of: find.byType(type), matching: find.byType(FocusableActionDetector));

class _SliderHost extends StatefulWidget {
  const _SliderHost({this.initial = 0.5, this.divisions, this.log});

  final double initial;
  final int? divisions;
  final List<String>? log;

  @override
  State<_SliderHost> createState() => _SliderHostState();
}

class _SliderHostState extends State<_SliderHost> {
  late double value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: CdsSlider(
        value: value,
        divisions: widget.divisions,
        semanticLabel: 'Volume',
        onChangeStart: (v) => widget.log?.add('start'),
        onChange: (v) {
          widget.log?.add('change:${v.toStringAsFixed(2)}');
          setState(() => value = v);
        },
        onChangeEnd: (v) => widget.log?.add('end:${v.toStringAsFixed(2)}'),
      ),
    );
  }
}

class _RangeHost extends StatefulWidget {
  const _RangeHost({this.log});

  final List<CdsRangeValues>? log;

  @override
  State<_RangeHost> createState() => _RangeHostState();
}

class _RangeHostState extends State<_RangeHost> {
  CdsRangeValues values = (start: 0.25, end: 0.75);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: CdsRangeSlider(
        values: values,
        startSemanticLabel: 'Minimum',
        endSemanticLabel: 'Maximum',
        onChange: (v) {
          widget.log?.add(v);
          setState(() => values = v);
        },
      ),
    );
  }
}

void main() {
  group('CdsSlider', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          SizedBox(
            width: _width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CdsSlider(value: 0.3, onChange: (_) {}),
                CdsSlider(value: 3, min: 0, max: 10, divisions: 10, onChange: (_) {}),
                const CdsSlider(value: 0.6, onChange: null),
                CdsRangeSlider(values: (start: 0.2, end: 0.8), onChange: (_) {}),
              ],
            ),
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tap on the track reports the tapped value with start and end', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _SliderHost(log: log));
      await tester.tapAt(Offset(_x(0.75), 300));
      await tester.pumpAndSettle();
      expect(log, ['start', 'change:0.75', 'end:0.75']);
      expect(tester.getCenter(_thumbs(CdsSlider)).dx, closeTo(_x(0.75), 0.5));
    });

    testWidgets('drag follows the finger from the grab point', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _SliderHost(log: log));
      final center = tester.getCenter(_thumbs(CdsSlider));
      expect(center.dx, closeTo(_x(0.5), 0.5));
      final gesture = await tester.startGesture(center + const Offset(6, 0));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(tester.getCenter(_thumbs(CdsSlider)).dx, closeTo(_x(0.7), 0.5));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(log.first, 'start');
      expect(log.last, 'end:0.70');
    });

    testWidgets('divisions snap reported values and the thumb settles on a step', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _SliderHost(divisions: 4, log: log));
      await tester.drag(_thumbs(CdsSlider), const Offset(20, 0));
      await tester.pumpAndSettle();
      expect(log.last, 'end:0.50');
      await tester.drag(_thumbs(CdsSlider), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(log.last, 'end:0.75');
      expect(tester.getCenter(_thumbs(CdsSlider)).dx, closeTo(_x(0.75), 0.5));
    });

    testWidgets('keyboard: arrows, shift, page and home/end', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _SliderHost(divisions: 20, log: log));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(log.last, 'end:0.55');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(log.last, 'end:0.50');
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(log.last, 'end:0.60');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(log.last, 'end:0.50');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(log.last, 'end:1.00');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(log.last, 'end:0.00');
    });

    testWidgets('RTL flips horizontal arrow keys and the track', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _SliderHost(initial: 0.25, divisions: 4, log: log), textDirection: TextDirection.rtl);
      expect(tester.getCenter(_thumbs(CdsSlider)).dx, closeTo(_x(0.75), 0.5));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(log.last, 'end:0.50');
    });

    testWidgets('semantics: slider role, label, value and increase/decrease actions', (tester) async {
      final handle = tester.ensureSemantics();
      final log = <String>[];
      await pumpCds(tester, _SliderHost(divisions: 10, log: log));
      final node = tester.getSemantics(_thumbs(CdsSlider));
      expect(
        node,
        containsSemantics(
          isSlider: true,
          label: 'Volume',
          value: '50%',
          increasedValue: '60%',
          decreasedValue: '40%',
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(node.id, SemanticsAction.increase);
      await tester.pump();
      expect(log.last, 'end:0.60');
      handle.dispose();
    });

    testWidgets('formatValue drives the semantic value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        SizedBox(
          width: _width,
          child: CdsSlider(value: 40, min: 0, max: 100, onChange: (_) {}, formatValue: (v) => '\$${v.round()}'),
        ),
      );
      expect(tester.getSemantics(_thumbs(CdsSlider)), containsSemantics(value: r'$40'));
      handle.dispose();
    });

    testWidgets('disabled and null onChange ignore input', (tester) async {
      var calls = 0;
      await pumpCds(
        tester,
        SizedBox(
          width: _width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CdsSlider(value: 0.5, disabled: true, onChange: (_) => calls++),
              const CdsSlider(value: 0.5, onChange: null),
            ],
          ),
        ),
      );
      for (final s in find.byType(CdsSlider).evaluate()) {
        final box = s.renderObject! as RenderBox;
        await tester.tapAt(box.localToGlobal(Offset(_width * 0.9, box.size.height / 2)));
      }
      await tester.drag(find.byType(CdsSlider).first, const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('external value changes spring the thumb; reduced motion jumps', (tester) async {
      Widget slider(double v) =>
          SizedBox(width: _width, child: CdsSlider(value: v, onChange: (_) {}));
      await pumpCds(tester, slider(0));
      await tester.pumpWidget(cdsHarness(slider(1)));
      await tester.pump(const Duration(milliseconds: 40));
      final mid = tester.getCenter(_thumbs(CdsSlider)).dx;
      expect(mid, greaterThan(_x(0)));
      expect(mid, lessThan(_x(1)));
      await tester.pumpAndSettle();
      expect(tester.getCenter(_thumbs(CdsSlider)).dx, closeTo(_x(1), 0.5));

      await tester.pumpWidget(cdsHarness(slider(0), disableAnimations: true));
      await tester.pump();
      expect(tester.getCenter(_thumbs(CdsSlider)).dx, closeTo(_x(0), 0.01));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('text scale 2.0 renders without exceptions', (tester) async {
      await pumpCds(tester, const _SliderHost(), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('CdsRangeSlider', () {
    testWidgets('a drag moves the nearest thumb and cannot cross the other', (tester) async {
      final log = <CdsRangeValues>[];
      await pumpCds(tester, _RangeHost(log: log));
      final startThumb = tester.getCenter(_thumbs(CdsRangeSlider).first);
      expect(startThumb.dx, closeTo(_x(0.25), 0.5));
      await tester.drag(_thumbs(CdsRangeSlider).first, const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(log.last.start, closeTo(0.75, 0.001));
      expect(log.last.end, closeTo(0.75, 0.001));
      for (final v in log) {
        expect(v.start, lessThanOrEqualTo(v.end));
      }
    });

    testWidgets('a tap moves the nearest thumb', (tester) async {
      final log = <CdsRangeValues>[];
      await pumpCds(tester, _RangeHost(log: log));
      await tester.tapAt(Offset(_x(0.9), 300));
      await tester.pumpAndSettle();
      expect(log.last.start, 0.25);
      expect(log.last.end, closeTo(0.9, 0.001));
    });

    testWidgets('each thumb is focusable with its own semantics and is bounded by the other', (tester) async {
      final handle = tester.ensureSemantics();
      final log = <CdsRangeValues>[];
      await pumpCds(tester, _RangeHost(log: log));
      expect(tester.getSemantics(_thumbs(CdsRangeSlider).first), containsSemantics(isSlider: true, label: 'Minimum', value: '25%'));
      expect(tester.getSemantics(_thumbs(CdsRangeSlider).last), containsSemantics(isSlider: true, label: 'Maximum', value: '75%'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(log.last, (start: 0.75, end: 0.75));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(log.last, (start: 0.75, end: 0.75));
      handle.dispose();
    });
  });
}
