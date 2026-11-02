import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _content = Key('drawer-content');

Widget _launcher(CdsDrawerPin pin) => Builder(
      builder: (context) => CdsButton(
        label: 'Open drawer',
        onPress: () => showCdsDrawer<void>(
          context,
          accessibilityLabel: 'Filters',
          builder: (context) => CdsDrawer(pin: pin, child: const SizedBox.expand(key: _content)),
        ),
      ),
    );

Future<void> _open(WidgetTester tester, CdsDrawerPin pin, {TextDirection dir = TextDirection.ltr}) async {
  await pumpCds(tester, _launcher(pin), textDirection: dir);
  await tester.tap(find.text('Open drawer'));
  await tester.pumpAndSettle();
}

double _left(WidgetTester tester) => tester.getTopLeft(find.byKey(_content)).dx;

void main() {
  testWidgets('start drawer opens at the start edge with 85% width', (tester) async {
    await _open(tester, CdsDrawerPin.start);
    expect(_left(tester), moreOrLessEquals(0, epsilon: 0.5));
    final width = tester.getSize(find.byKey(_content)).width;
    expect(width, moreOrLessEquals(tester.getSize(find.byType(CdsDrawer)).width * 0.85, epsilon: 1));
  });

  testWidgets('slow partial drag returns, fling toward the edge dismisses', (tester) async {
    await _open(tester, CdsDrawerPin.start);
    await tester.timedDrag(find.byKey(_content), const Offset(-80, 0), const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(_left(tester), moreOrLessEquals(0, epsilon: 0.5));
    await tester.fling(find.byKey(_content), const Offset(-70, 0), 2500);
    await tester.pumpAndSettle();
    expect(find.byKey(_content), findsNothing);
  });

  testWidgets('dragging past open rubberbands', (tester) async {
    await _open(tester, CdsDrawerPin.start);
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(_content)));
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(180, 0));
    await tester.pump();
    final width = tester.getSize(find.byType(SizedBox).first);
    expect(width, isNotNull);
    final right = tester.getTopRight(find.byKey(_content)).dx;
    final drawerWidth = tester.getSize(find.byKey(_content)).width;
    expect(right - drawerWidth, lessThan(200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_left(tester), moreOrLessEquals(0, epsilon: 0.5));
  });

  testWidgets('end drawer in RTL sits on the left and dismisses leftward', (tester) async {
    await _open(tester, CdsDrawerPin.end, dir: TextDirection.rtl);
    expect(_left(tester), moreOrLessEquals(0, epsilon: 0.5));
    await tester.fling(find.byKey(_content), const Offset(-70, 0), 2500);
    await tester.pumpAndSettle();
    expect(find.byKey(_content), findsNothing);
  });

  testWidgets('top drawer slides from the top', (tester) async {
    await pumpCds(
      tester,
      Builder(
        builder: (context) => CdsButton(
          label: 'Open drawer',
          onPress: () => showCdsDrawer<void>(
            context,
            builder: (context) => const CdsDrawer(pin: CdsDrawerPin.top, child: SizedBox(key: _content, height: 200)),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(_content)).dy, moreOrLessEquals(0, epsilon: 60));
    await tester.fling(find.byKey(_content), const Offset(0, -70), 2500);
    await tester.pumpAndSettle();
    expect(find.byKey(_content), findsNothing);
  });

  testWidgets('bottom drawer shows a handle; side drawers do not', (tester) async {
    await _open(tester, CdsDrawerPin.bottom);
    expect(find.byType(CdsHandleBar), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await _open(tester, CdsDrawerPin.end);
    expect(find.byType(CdsHandleBar), findsNothing);
  });
}
