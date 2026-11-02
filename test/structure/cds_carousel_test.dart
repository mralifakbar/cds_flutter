import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

List<Widget> _cards(int n) => [
      for (var i = 0; i < n; i++)
        SizedBox(key: ValueKey('card$i'), height: 120, child: CdsText('Card $i')),
    ];

double _x(WidgetTester tester, int i) => tester.getTopLeft(find.byKey(ValueKey('card$i'))).dx;

Future<void> _focusTrack(WidgetTester tester) async {
  final focus = tester.widget<Focus>(
    find.byWidgetPredicate((w) => w is Focus && w.focusNode?.debugLabel == 'CdsCarousel'),
  );
  focus.focusNode!.requestFocus();
  await tester.pump();
}

void main() {
  testWidgets('renders title, navigation and one dot per page in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, CdsCarousel(title: 'Explore', children: _cards(4)), brightness: b);
      expect(tester.takeException(), isNull);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Go to page')), findsNWidgets(4));
    }
  });

  testWidgets('next and previous buttons page and report changes', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(onChangePage: pages.add, children: _cards(3)));
    final left0 = _x(tester, 0);
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pumpAndSettle();
    expect(pages, [1]);
    expect(_x(tester, 1), moreOrLessEquals(left0, epsilon: 0.5));

    await tester.tap(find.bySemanticsLabel('Previous page'));
    await tester.pumpAndSettle();
    expect(pages, [1, 0]);

    // Previous is disabled on the first page.
    await tester.tap(find.bySemanticsLabel('Previous page'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(pages, [1, 0]);
  });

  testWidgets('pagination dots jump to a page', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(onChangePage: pages.add, children: _cards(4)));
    await tester.tap(find.bySemanticsLabel('Go to page 3'));
    await tester.pumpAndSettle();
    expect(pages, [2]);
  });

  testWidgets('a short slow drag springs back; a flick snaps to the next page', (tester) async {
    final pages = <int>[];
    var dragEvents = 0;
    await pumpCds(
      tester,
      CdsCarousel(
        onChangePage: pages.add,
        onDragStart: () => dragEvents++,
        onDragEnd: () => dragEvents++,
        children: _cards(3),
      ),
    );
    final start = _x(tester, 0);
    await tester.timedDrag(find.text('Card 0'), const Offset(-60, 0), const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(pages, isEmpty);
    expect(_x(tester, 0), moreOrLessEquals(start, epsilon: 0.5));
    expect(dragEvents, 2);

    await tester.fling(find.text('Card 0'), const Offset(-80, 0), 1500);
    await tester.pumpAndSettle();
    expect(pages, [1]);
  });

  testWidgets('drag follows the finger 1:1 and resists past the first page', (tester) async {
    await pumpCds(tester, CdsCarousel(children: _cards(3)));
    final start = _x(tester, 0);
    final gesture = await tester.startGesture(tester.getCenter(find.text('Card 0')));
    // The first move clears the touch slop.
    await gesture.moveBy(const Offset(-20, 0));
    await gesture.moveBy(const Offset(-50, 0));
    await tester.pump();
    final moved = start - _x(tester, 0);
    expect(moved, greaterThan(40));
    expect(moved, lessThanOrEqualTo(70.5));
    await gesture.moveBy(const Offset(170, 0));
    await tester.pump();
    final overshoot = _x(tester, 0) - start;
    expect(overshoot, greaterThan(0));
    expect(overshoot, lessThan(100));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_x(tester, 0), moreOrLessEquals(start, epsilon: 0.5));
  });

  testWidgets('a hard flick in page mode moves one page at a time', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(onChangePage: pages.add, children: _cards(6)));
    await tester.fling(find.text('Card 0'), const Offset(-200, 0), 8000);
    await tester.pumpAndSettle();
    expect(pages, [1]);
  });

  testWidgets('item mode computes one page per item until the rest fit', (tester) async {
    final controller = CdsCarouselController();
    await pumpCds(
      tester,
      CdsCarousel(itemWidth: 300, snapMode: CdsCarouselSnapMode.item, controller: controller, children: _cards(6)),
    );
    // 800px test viewport, 300px items, 8px gap: 6 items end at 1840. Item 4
    // is the first that can start a page showing every remaining item, so
    // pages start at items 0 to 4.
    expect(controller.totalPages, 5);
    controller.goToPage(2);
    await tester.pumpAndSettle();
    expect(controller.activePageIndex, 2);
    controller.dispose();
  });

  testWidgets('keyboard arrows page when focused, mirrored in RTL', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(onChangePage: pages.add, children: _cards(3)));
    await _focusTrack(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(pages, [1, 0]);

    pages.clear();
    await pumpCds(tester, CdsCarousel(key: const Key('rtl'), onChangePage: pages.add, children: _cards(3)),
        textDirection: TextDirection.rtl);
    await _focusTrack(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(pages, [1]);
  });

  testWidgets('autoplay is off by default', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(onChangePage: pages.add, children: _cards(3)));
    await tester.pump(const Duration(seconds: 7));
    expect(pages, isEmpty);
    expect(find.bySemanticsLabel('Pause Carousel'), findsNothing);
  });

  testWidgets('autoplay advances, then stops for good after the user drags', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(autoplay: true, onChangePage: pages.add, children: _cards(3)));
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();
    expect(pages, [1]);
    expect(find.bySemanticsLabel('Pause Carousel'), findsOneWidget);

    await tester.timedDrag(find.text('Card 1'), const Offset(-10, 0), const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Play Carousel'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    expect(pages, [1]);

    await tester.tap(find.bySemanticsLabel('Play Carousel'));
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();
    expect(pages, [1, 2]);

    // Wraps to the first page after the last.
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();
    expect(pages, [1, 2, 0]);
    await tester.tap(find.bySemanticsLabel('Pause Carousel'));
    await tester.pump();
  });

  testWidgets('autoplay never runs under reduced motion', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(autoplay: true, onChangePage: pages.add, children: _cards(3)),
        disableAnimations: true);
    await tester.pump(const Duration(seconds: 7));
    expect(pages, isEmpty);
    expect(find.bySemanticsLabel('Play Carousel'), findsNothing);
  });

  testWidgets('reduced motion: buttons jump without animating', (tester) async {
    await pumpCds(tester, CdsCarousel(children: _cards(3)), disableAnimations: true);
    final start = _x(tester, 0);
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(_x(tester, 1), moreOrLessEquals(start, epsilon: 0.5));
  });

  testWidgets('semantics: label, page value and scroll actions', (tester) async {
    final handle = tester.ensureSemantics();
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(title: 'Explore', onChangePage: pages.add, children: _cards(3)));
    final node = tester.getSemantics(find.bySemanticsLabel('Explore').last);
    expect(node.value, 'Page 1 of 3');
    expect(node.getSemanticsData().hasAction(SemanticsAction.scrollLeft), isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.scrollRight), isFalse);
    node.owner!.performAction(node.id, SemanticsAction.scrollLeft);
    await tester.pumpAndSettle();
    expect(pages, [1]);
    handle.dispose();
  });

  testWidgets('hidden navigation and pagination, text scale 2.0', (tester) async {
    await pumpCds(
      tester,
      CdsCarousel(title: 'Recommended for you this week', hideNavigation: true, hidePagination: true, children: _cards(2)),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Next page'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Go to page')), findsNothing);
  });

  testWidgets('drag none ignores drags', (tester) async {
    final pages = <int>[];
    await pumpCds(tester, CdsCarousel(drag: CdsCarouselDrag.none, onChangePage: pages.add, children: _cards(3)));
    await tester.fling(find.text('Card 0'), const Offset(-200, 0), 2000);
    await tester.pumpAndSettle();
    expect(pages, isEmpty);
  });
}
