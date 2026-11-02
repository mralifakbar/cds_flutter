import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const double _width = 350;

Finder get _handle =>
    find.descendant(of: find.byType(CdsSlideButton), matching: find.byType(GestureDetector)).first;

double _handleWidth(WidgetTester tester) => tester.getSize(_handle).width;

Widget _button({
  bool checked = false,
  List<String>? log,
  bool disabled = false,
  bool autoComplete = false,
  CdsSlideButtonSize? size,
}) {
  return SizedBox(
    width: _width,
    child: CdsSlideButton(
      checked: checked,
      disabled: disabled,
      size: size,
      autoCompleteSlideOnThresholdMet: autoComplete,
      uncheckedLabel: 'Slide to send',
      checkedLabel: 'Sending',
      endCheckedNode: const SizedBox.square(dimension: 24),
      onChange: (v) => log?.add('change:$v'),
      onSlideStart: () => log?.add('start'),
      onSlideCancel: () => log?.add('cancel'),
      onSlideComplete: () => log?.add('complete'),
      onSlideEnd: () => log?.add('end'),
    ),
  );
}

void main() {
  group('CdsSlideButton', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every variant and size in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          SizedBox(
            width: _width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final v in CdsSlideButtonVariant.values)
                  for (final s in CdsSlideButtonSize.values)
                    CdsSlideButton(checked: false, variant: v, size: s, uncheckedLabel: 'Slide to buy'),
                const CdsSlideButton(checked: false, disabled: true, uncheckedLabel: 'Disabled'),
              ],
            ),
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('sizes match CDS heights', (tester) async {
      for (final (size, height) in [(CdsSlideButtonSize.s, 40.0), (CdsSlideButtonSize.m, 48.0), (CdsSlideButtonSize.l, 56.0)]) {
        await pumpCds(tester, _button(size: size));
        expect(tester.getSize(find.byType(CdsSlideButton)).height, height);
        expect(_handleWidth(tester), height);
      }
      await pumpCds(tester, const SizedBox(width: _width, child: CdsSlideButton(checked: false, compact: true)));
      expect(tester.getSize(find.byType(CdsSlideButton)).height, 40);
    });

    testWidgets('dragging past the threshold commits with CDS callback order', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log));
      await tester.drag(_handle, const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(log, ['start', 'change:true', 'complete', 'end']);
      expect(_handleWidth(tester), closeTo(_width, 0.5));
    });

    testWidgets('a short slow drag springs back and cancels', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log));
      await tester.timedDrag(_handle, const Offset(60, 0), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(log, ['start', 'cancel', 'end']);
      expect(_handleWidth(tester), closeTo(56, 0.5));
    });

    testWidgets('a fast flick commits from below the threshold', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log));
      await tester.fling(_handle, const Offset(100, 0), 1500);
      await tester.pumpAndSettle();
      expect(log, contains('change:true'));
    });

    testWidgets('the handle follows the finger 1:1 and rubberbands past the end', (tester) async {
      await pumpCds(tester, _button());
      final gesture = await tester.startGesture(tester.getCenter(_handle));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();
      expect(_handleWidth(tester), closeTo(56 + 100, 0.5));
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      final stretched = _handleWidth(tester);
      expect(stretched, greaterThan(_width));
      expect(stretched, lessThan(56 + 500.0));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('autoCompleteSlideOnThresholdMet commits before release', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log, autoComplete: true));
      final gesture = await tester.startGesture(tester.getCenter(_handle));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(250, 0));
      await tester.pump();
      expect(log, ['start', 'change:true', 'complete', 'end']);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(log.length, 4);
    });

    testWidgets('disabled ignores drags', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log, disabled: true));
      await tester.drag(_handle, const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(log, isEmpty);
      expect(_handleWidth(tester), 56);
    });

    testWidgets('checked ignores drags and fills the track', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log, checked: true));
      expect(_handleWidth(tester), _width);
      await tester.drag(_handle, const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(log, isEmpty);
    });

    testWidgets('changing checked from outside springs the handle', (tester) async {
      await pumpCds(tester, _button());
      await tester.pumpWidget(cdsHarness(_button(checked: true)));
      await tester.pump(const Duration(milliseconds: 50));
      final mid = _handleWidth(tester);
      expect(mid, greaterThan(56));
      expect(mid, lessThan(_width));
      await tester.pumpAndSettle();
      expect(_handleWidth(tester), closeTo(_width, 0.5));
      await tester.pumpWidget(cdsHarness(_button()));
      await tester.pumpAndSettle();
      expect(_handleWidth(tester), closeTo(56, 0.5));
    });

    testWidgets('RTL slides toward the start-to-end direction (leftward)', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log), textDirection: TextDirection.rtl);
      await tester.drag(_handle, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(log, contains('change:true'));
    });

    testWidgets('semantics: button labeled with the current label; tap completes', (tester) async {
      final handle = tester.ensureSemantics();
      final log = <String>[];
      await pumpCds(tester, _button(log: log));
      expect(
        tester.getSemantics(find.byType(CdsSlideButton)),
        containsSemantics(label: 'Slide to send', isButton: true, hasTapAction: true, isEnabled: true),
      );
      tester.semantics.tap(find.semantics.byLabel('Slide to send'));
      await tester.pumpAndSettle();
      expect(log, ['change:true', 'complete', 'end']);
      await pumpCds(tester, _button(checked: true));
      expect(
        tester.getSemantics(find.byType(CdsSlideButton)),
        containsSemantics(label: 'Sending', hasTapAction: false),
      );
      handle.dispose();
    });

    testWidgets('keyboard: Tab focuses, Enter completes', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _button(log: log));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(log, ['change:true', 'complete', 'end']);
    });

    testWidgets('reduced motion jumps to the new state', (tester) async {
      await pumpCds(tester, _button(), disableAnimations: true);
      await tester.pumpWidget(cdsHarness(_button(checked: true), disableAnimations: true));
      await tester.pump();
      expect(_handleWidth(tester), _width);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('default checked spinner holds still under reduced motion', (tester) async {
      await pumpCds(
        tester,
        const SizedBox(width: _width, child: CdsSlideButton(checked: true, checkedLabel: 'Sending')),
        disableAnimations: true,
      );
      expect(find.byType(CdsProgressCircle), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('text scale 2.0 grows the control without overflow', (tester) async {
      await pumpCds(tester, _button(), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(CdsSlideButton)).height, greaterThanOrEqualTo(56));
    });
  });
}
