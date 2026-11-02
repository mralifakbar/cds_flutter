import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _sheetKey = Key('tray-content');

Widget _launcher({List<double>? snapPoints, bool scrollable = false, ValueChanged<Object?>? onResult}) {
  return Builder(
    builder: (context) => CdsButton(
      label: 'Open tray',
      onPress: () async {
        final result = await showCdsTray<Object>(
          context,
          builder: (context) => CdsTray(
            title: 'Choose an asset',
            snapPoints: snapPoints,
            child: scrollable
                ? ListView(
                    key: _sheetKey,
                    children: [for (var i = 0; i < 40; i++) SizedBox(height: 48, child: CdsText('Row $i'))],
                  )
                : const SizedBox(key: _sheetKey, height: 300, child: CdsText('Sample data')),
          ),
        );
        onResult?.call(result);
      },
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget launcher) async {
  await pumpCds(tester, launcher);
  await tester.tap(find.text('Open tray'));
  await tester.pumpAndSettle();
}

double _top(WidgetTester tester) => tester.getTopLeft(find.byKey(_sheetKey)).dy;

void main() {
  testWidgets('opens and settles', (tester) async {
    await _open(tester, _launcher());
    expect(find.text('Choose an asset'), findsOneWidget);
    expect(_top(tester), lessThan(600));
  });

  testWidgets('slow partial drag returns to open', (tester) async {
    await _open(tester, _launcher());
    final rest = _top(tester);
    await tester.timedDrag(find.byKey(_sheetKey), const Offset(0, 80), const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(_top(tester), moreOrLessEquals(rest, epsilon: 0.5));
    expect(find.text('Choose an asset'), findsOneWidget);
  });

  testWidgets('fast fling from a small offset dismisses', (tester) async {
    Object? result = 'unset';
    await _open(tester, _launcher(onResult: (r) => result = r));
    await tester.fling(find.byKey(_sheetKey), const Offset(0, 60), 2500);
    await tester.pumpAndSettle();
    expect(find.text('Choose an asset'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('drag above max rubberbands', (tester) async {
    await _open(tester, _launcher());
    final rest = _top(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(_sheetKey)));
    await gesture.moveBy(const Offset(0, -20));
    await gesture.moveBy(const Offset(0, -180));
    await tester.pump();
    final moved = rest - _top(tester);
    expect(moved, greaterThan(0));
    expect(moved, lessThan(200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_top(tester), moreOrLessEquals(rest, epsilon: 0.5));
  });

  testWidgets('grab mid-dismiss continues from current position', (tester) async {
    await _open(tester, _launcher());
    final rest = _top(tester);
    await tester.fling(find.byKey(_sheetKey), const Offset(0, 60), 2500);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final before = _top(tester);
    expect(before, greaterThan(rest));
    final gesture = await tester.startGesture(Offset(195, before + 10));
    await tester.pump(const Duration(milliseconds: 16));
    expect(_top(tester), moreOrLessEquals(before, epsilon: 1));
    await gesture.moveBy(const Offset(0, -30));
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Choose an asset'), findsOneWidget);
    expect(_top(tester), moreOrLessEquals(rest, epsilon: 0.5));
  });

  testWidgets('Navigator.pop animates the tray out along its entry path', (tester) async {
    await _open(tester, _launcher());
    final rest = _top(tester);
    Navigator.of(tester.element(find.byKey(_sheetKey))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byKey(_sheetKey), findsOneWidget);
    expect(_top(tester), greaterThan(rest));
    await tester.pumpAndSettle();
    expect(find.byKey(_sheetKey), findsNothing);
  });

  testWidgets('scrim tap and Escape close; CdsTray.close returns a result', (tester) async {
    await _open(tester, _launcher());
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    expect(find.byKey(_sheetKey), findsNothing);

    await tester.tap(find.text('Open tray'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(_sheetKey), findsNothing);

    Object? result;
    await pumpCds(
      tester,
      Builder(
        builder: (context) => CdsButton(
          label: 'Pick',
          onPress: () async {
            result = await showCdsTray<String>(
              context,
              builder: (context) => CdsTray(
                child: Builder(
                  builder: (context) => CdsButton(label: 'Bitcoin', onPress: () => CdsTray.close(context, 'BTC')),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bitcoin'));
    await tester.pumpAndSettle();
    expect(result, 'BTC');
  });

  testWidgets('scrim dims in proportion to the tray position', (tester) async {
    await _open(tester, _launcher());
    double scrimOpacity() => tester.widget<CdsOverlay>(find.byType(CdsOverlay)).opacity;
    expect(scrimOpacity(), moreOrLessEquals(1));
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(_sheetKey)));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    expect(scrimOpacity(), lessThan(1));
    expect(scrimOpacity(), greaterThan(0.4));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('snap points: fling up expands, fling down collapses', (tester) async {
    await _open(tester, _launcher(snapPoints: const [0.4, 0.8], scrollable: true));
    final low = _top(tester);
    await tester.fling(find.text('Choose an asset'), const Offset(0, -120), 1500);
    await tester.pumpAndSettle();
    final high = _top(tester);
    expect(high, lessThan(low - 100));
    await tester.timedDrag(find.text('Choose an asset'), const Offset(0, 60), const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(_top(tester), moreOrLessEquals(high, epsilon: 0.5));
  });

  testWidgets('pulling down at the top of scrolling content moves the tray', (tester) async {
    await _open(tester, _launcher(scrollable: true));
    final rest = _top(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.text('Row 2')));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    expect(_top(tester), greaterThan(rest + 40));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_top(tester), moreOrLessEquals(rest, epsilon: 0.5));

    // Content that has scrolled keeps scrolling instead of moving the tray.
    await tester.drag(find.text('Row 5'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_top(tester), moreOrLessEquals(rest, epsilon: 0.5));
    await tester.drag(find.byKey(_sheetKey), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(_top(tester), moreOrLessEquals(rest, epsilon: 0.5));
  });

  testWidgets('fling down on scrolling content at the top dismisses', (tester) async {
    await _open(tester, _launcher(scrollable: true));
    await tester.fling(find.text('Row 1'), const Offset(0, 80), 2500);
    await tester.pumpAndSettle();
    expect(find.byKey(_sheetKey), findsNothing);
  });

  testWidgets('handle bar is a labeled dismiss button', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester, _launcher());
    expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
    final node = tester.getSemantics(find.bySemanticsLabel('Dismiss'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('preventDismissGestures keeps the tray open', (tester) async {
    await pumpCds(
      tester,
      Builder(
        builder: (context) => CdsButton(
          label: 'Open tray',
          onPress: () => showCdsTray<void>(
            context,
            builder: (context) => const CdsTray(
              preventDismissGestures: true,
              child: SizedBox(key: _sheetKey, height: 200),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open tray'));
    await tester.pumpAndSettle();
    await tester.fling(find.byKey(_sheetKey), const Offset(0, 80), 2500);
    await tester.pumpAndSettle();
    expect(find.byKey(_sheetKey), findsOneWidget);
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();
    expect(find.byKey(_sheetKey), findsOneWidget);
  });

  testWidgets('declarative tray calls onCloseComplete', (tester) async {
    var closed = 0;
    await pumpCds(
      tester,
      CdsTray(onCloseComplete: () => closed++, child: const SizedBox(key: _sheetKey, height: 200)),
      center: false,
    );
    expect(find.byKey(_sheetKey), findsOneWidget);
    await tester.fling(find.byKey(_sheetKey), const Offset(0, 80), 2500);
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('reduced motion fades instead of sliding', (tester) async {
    await pumpCds(tester, _launcher(), disableAnimations: true);
    await tester.tap(find.text('Open tray'));
    await tester.pump();
    await tester.pump();
    final opening = _top(tester);
    await tester.pumpAndSettle();
    expect(_top(tester), opening);
  });

  testWidgets('dark mode and text scale 2.0', (tester) async {
    await pumpCds(tester, _launcher(), brightness: Brightness.dark, textScale: 2);
    await tester.tap(find.text('Open tray'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('CdsTray.close works from the context of the widget that builds the tray', (tester) async {
    String? result;
    await pumpCds(tester, Builder(builder: (context) => CdsButton(label: 'Open', onPress: () async {
          result = await showCdsTray<String>(context, builder: (_) => const _BuildsTray());
        })));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(result, 'done');
    expect(find.byType(CdsTray), findsNothing);
  });
}

class _BuildsTray extends StatelessWidget {
  const _BuildsTray();

  // `context` here sits above CdsTray, the common State/StatelessWidget pattern.
  @override
  Widget build(BuildContext context) => CdsTray(
        title: 'Tray',
        child: CdsButton(label: 'Close', onPress: () => CdsTray.close(context, 'done')),
      );
}
