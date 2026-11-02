import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _popover({VoidCallback? onOpen, VoidCallback? onClose, bool disabled = false, CdsPopoverController? controller}) =>
    CdsPopoverPanel(
      onOpen: onOpen,
      onClose: onClose,
      disabled: disabled,
      controller: controller,
      accessibilityLabel: 'Filters',
      builder: (context, c) => CdsButton(label: 'Filters', onPress: c.toggle),
      contentBuilder: (context, close) => Padding(
        padding: const EdgeInsets.all(16),
        child: CdsButton(label: 'Show gainers', onPress: close),
      ),
    );

void main() {
  testWidgets('opens below the trigger and closes from content', (tester) async {
    var opened = 0;
    var closed = 0;
    await pumpCds(tester, _popover(onOpen: () => opened++, onClose: () => closed++));
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Show gainers')).dy, greaterThan(tester.getBottomLeft(find.text('Filters')).dy));
    expect(opened, 1);
    await tester.tap(find.text('Show gainers'));
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsNothing);
    expect(closed, 1);
  });

  testWidgets('grows from the trigger while opening', (tester) async {
    await pumpCds(tester, _popover());
    await tester.tap(find.text('Filters'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final mid = tester.getTopLeft(find.text('Show gainers')).dy;
    await tester.pumpAndSettle();
    final rest = tester.getTopLeft(find.text('Show gainers')).dy;
    expect(mid, lessThan(rest));
  });

  testWidgets('Escape closes and returns focus to the trigger', (tester) async {
    await pumpCds(tester, _popover());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final trigger = FocusManager.instance.primaryFocus;
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsNothing);
    expect(FocusManager.instance.primaryFocus, trigger);
  });

  testWidgets('tap outside closes', (tester) async {
    await pumpCds(tester, _popover());
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsNothing);
  });

  testWidgets('flips above when there is no room below', (tester) async {
    await pumpCds(
      tester,
      Align(alignment: Alignment.bottomCenter, child: _popover()),
      center: false,
    );
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Show gainers')).dy, lessThan(tester.getTopLeft(find.text('Filters')).dy));
  });

  testWidgets('controller opens it; disabled keeps it closed', (tester) async {
    final controller = CdsPopoverController();
    addTearDown(controller.dispose);
    await pumpCds(tester, _popover(controller: controller));
    controller.open();
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsOneWidget);
    controller.close();
    await tester.pumpAndSettle();

    await pumpCds(tester, _popover(disabled: true));
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Show gainers'), findsNothing);
  });

  testWidgets('reduced motion fades without movement', (tester) async {
    await pumpCds(tester, _popover(), disableAnimations: true);
    await tester.tap(find.text('Filters'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    final mid = tester.getTopLeft(find.text('Show gainers')).dy;
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Show gainers')).dy, mid);
  });
}
