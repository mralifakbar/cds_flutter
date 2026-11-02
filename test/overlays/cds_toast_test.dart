import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _button(String label, void Function(BuildContext) onPress) =>
    Builder(builder: (context) => CdsButton(label: label, onPress: () => onPress(context)));

void main() {
  test('duration follows CDS: 5s, +2s with action, +300ms per 10 chars past 50', () {
    expect(cdsToastDuration('Saved'), const Duration(seconds: 5));
    expect(cdsToastDuration('Saved', hasAction: true), const Duration(seconds: 7));
    expect(cdsToastDuration('x' * 70), const Duration(milliseconds: 5600));
  });

  testWidgets('shows above the bottom edge and hides after its duration', (tester) async {
    await pumpCds(tester, _button('Copy', (c) => showCdsToast(c, 'Address copied')));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Address copied'), findsOneWidget);
    expect(tester.getBottomLeft(find.text('Address copied')).dy, greaterThan(400));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Address copied'), findsNothing);
  });

  testWidgets('queues toasts one at a time', (tester) async {
    await pumpCds(
      tester,
      _button('Send', (c) {
        showCdsToast(c, 'First toast', duration: const Duration(seconds: 1));
        showCdsToast(c, 'Second toast', duration: const Duration(seconds: 5));
      }),
    );
    await tester.tap(find.text('Send'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('First toast'), findsOneWidget);
    expect(find.text('Second toast'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.text('First toast'), findsNothing);
    expect(find.text('Second toast'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Second toast'), findsNothing);
  });

  testWidgets('timer pauses while the toast is touched', (tester) async {
    await pumpCds(tester, _button('Copy', (c) => showCdsToast(c, 'Held toast', duration: const Duration(seconds: 1))));
    await tester.tap(find.text('Copy'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final gesture = await tester.startGesture(tester.getCenter(find.text('Held toast')));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Held toast'), findsOneWidget);
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Held toast'), findsNothing);
  });

  testWidgets('swipe down with velocity dismisses; a small slow drag springs back', (tester) async {
    var hidden = 0;
    await pumpCds(tester, _button('Copy', (c) => showCdsToast(c, 'Swipe me', onDidHide: () => hidden++)));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    final rest = tester.getTopLeft(find.text('Swipe me')).dy;
    await tester.timedDrag(find.text('Swipe me'), const Offset(0, 12), const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Swipe me')).dy, moreOrLessEquals(rest, epsilon: 0.5));
    await tester.fling(find.text('Swipe me'), const Offset(0, 60), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Swipe me'), findsNothing);
    expect(hidden, 1);
  });

  testWidgets('horizontal swipe dismisses', (tester) async {
    await pumpCds(tester, _button('Copy', (c) => showCdsToast(c, 'Swipe sideways')));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    await tester.fling(find.text('Swipe sideways'), const Offset(200, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Swipe sideways'), findsNothing);
  });

  testWidgets('action runs and hides the toast', (tester) async {
    var undone = 0;
    await pumpCds(
      tester,
      _button('Send', (c) => showCdsToast(c, 'Sent 25 USDC', action: CdsToastAction(label: 'Undo', onPress: () => undone++))),
    );
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.text('Sent 25 USDC'), findsNothing);
  });

  testWidgets('announces to screen readers and is a live region', (tester) async {
    final handle = tester.ensureSemantics();
    final announcements = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (message) async {
      announcements.add(message);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));
    await pumpCds(tester, _button('Copy', (c) => showCdsToast(c, 'Address copied')));
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(announcements.toString(), contains('Address copied'));
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.liveRegion == true), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    handle.dispose();
  });

  testWidgets('CdsToastHost places toasts with a custom offset', (tester) async {
    await pumpCds(
      tester,
      CdsToastHost(
        bottomOffset: 100,
        child: Center(child: _button('Copy', (c) => showCdsToast(c, 'Hosted toast'))),
      ),
      center: false,
    );
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Hosted toast'), findsOneWidget);
    CdsToastHost.of(tester.element(find.text('Copy'))).clearQueue();
    await tester.pumpAndSettle();
    expect(find.text('Hosted toast'), findsNothing);
  });

  testWidgets('reduced motion, dark mode and text scale 2.0', (tester) async {
    await pumpCds(
      tester,
      _button('Copy', (c) => showCdsToast(c, 'A longer message that wraps onto more than one line at large text sizes')),
      disableAnimations: true,
      brightness: Brightness.dark,
      textScale: 2,
    );
    await tester.tap(find.text('Copy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.textContaining('A longer message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
