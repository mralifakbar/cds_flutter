import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'sized_harness.dart';

Widget _launcher({
  bool disableOverlayPress = false,
  bool shouldCloseOnEscPress = true,
  bool hideCloseButton = false,
  ValueChanged<bool?>? onResult,
}) {
  return Builder(
    builder: (context) => CdsButton(
      label: 'Review transfer',
      onPress: () async {
        final result = await showCdsModal<bool>(
          context,
          accessibilityLabel: 'Send USDC',
          disableOverlayPress: disableOverlayPress,
          shouldCloseOnEscPress: shouldCloseOnEscPress,
          builder: (context) => CdsModal(
            hideCloseButton: hideCloseButton,
            children: [
              const CdsModalHeader(title: 'Send USDC'),
              const CdsModalBody(child: CdsText('Sample data: 25 USDC to 0x12ab')),
              CdsModalFooter(
                primaryAction: CdsButton(label: 'Send', onPress: () => Navigator.pop(context, true)),
                secondaryAction: CdsButton(
                  label: 'Cancel',
                  variant: CdsButtonVariant.secondary,
                  onPress: () => Navigator.pop(context, false),
                ),
              ),
            ],
          ),
        );
        onResult?.call(result);
      },
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget launcher, {bool disableAnimations = false, Brightness brightness = Brightness.light, double textScale = 1}) async {
  await pumpCds(tester, launcher, disableAnimations: disableAnimations, brightness: brightness, textScale: textScale);
  await tester.tap(find.text('Review transfer'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await _open(tester, _launcher(), brightness: b);
      expect(find.text('Send USDC'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('footer actions pop with a result', (tester) async {
    bool? result;
    await _open(tester, _launcher(onResult: (r) => result = r));
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.text('Send USDC'), findsNothing);
  });

  testWidgets('close button closes', (tester) async {
    bool? result = true;
    await _open(tester, _launcher(onResult: (r) => result = r));
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Send USDC'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('hideCloseButton removes the close button', (tester) async {
    await _open(tester, _launcher(hideCloseButton: true));
    expect(find.bySemanticsLabel('Close'), findsNothing);
  });

  testWidgets('Escape closes unless disabled', (tester) async {
    await _open(tester, _launcher());
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Send USDC'), findsNothing);

    await _open(tester, _launcher(shouldCloseOnEscPress: false));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Send USDC'), findsOneWidget);
  });

  testWidgets('scrim tap closes a wide modal unless disabled', (tester) async {
    await pumpCdsSized(tester, _launcher(), const Size(1200, 900));
    await tester.tap(find.text('Review transfer'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Send USDC'), findsNothing);

    await pumpCdsSized(tester, _launcher(disableOverlayPress: true), const Size(1200, 900));
    await tester.tap(find.text('Review transfer'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Send USDC'), findsOneWidget);
  });

  testWidgets('wide screens get a 612px card, narrow screens fill', (tester) async {
    await pumpCdsSized(tester, _launcher(), const Size(1200, 900));
    await tester.tap(find.text('Review transfer'));
    await tester.pumpAndSettle();
    final card = tester.getSize(find.ancestor(of: find.text('Send USDC'), matching: find.byType(ClipRRect)).first);
    expect(card.width, 612);

    tester.view.physicalSize = const Size(390, 844);
    await _open(tester, _launcher());
    final full = tester.getSize(find.ancestor(of: find.text('Send USDC'), matching: find.byType(ClipRRect)).first);
    expect(full.width, 390);
  });

  testWidgets('route semantics scope and name the dialog', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester, _launcher());
    expect(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.scopesRoute == true && w.properties.label == 'Send USDC'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('focus is trapped inside and restored on close', (tester) async {
    await pumpCds(tester, _launcher());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final trigger = FocusManager.instance.primaryFocus;
    expect(trigger, isNotNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Send USDC'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ctx = FocusManager.instance.primaryFocus?.context;
      expect(ctx, isNotNull);
      expect(find.descendant(of: find.byType(CdsModal), matching: find.byWidget(ctx!.widget)).evaluate().isNotEmpty || ctx.findAncestorWidgetOfExactType<CdsModal>() != null, isTrue);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, trigger);
  });

  testWidgets('reduced motion fades without scaling and settles quickly', (tester) async {
    await pumpCds(tester, _launcher(), disableAnimations: true);
    await tester.tap(find.text('Review transfer'));
    await tester.pump();
    expect(find.byType(ScaleTransition), findsNothing);
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.text('Send USDC'), findsOneWidget);
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await _open(tester, _launcher(), textScale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical footer puts the primary action first', (tester) async {
    await pumpCds(
      tester,
      CdsModalFooter(
        direction: Axis.vertical,
        primaryAction: CdsButton(label: 'Confirm', onPress: () {}),
        secondaryAction: CdsButton(label: 'Back', onPress: () {}),
      ),
    );
    expect(tester.getTopLeft(find.text('Confirm')).dy, lessThan(tester.getTopLeft(find.text('Back')).dy));
  });

  testWidgets('header back button fires', (tester) async {
    var back = 0;
    await pumpCds(tester, CdsModalHeader(title: 'Step 2', onBackButtonClick: () => back++));
    await tester.tap(find.bySemanticsLabel('Back'));
    expect(back, 1);
  });
}
