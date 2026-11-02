import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'sized_harness.dart';

Widget _modalLauncher() => Builder(
      builder: (context) => CdsButton(
        label: 'Verify identity',
        onPress: () => showCdsFullscreenModal<void>(
          context,
          accessibilityLabel: 'Verify your identity',
          builder: (context) => const CdsFullscreenModal(
            title: 'Verify your identity',
            primaryContent: CdsText('Have your ID ready.'),
            secondaryContent: CdsText('Sample data: about 3 minutes'),
            showSecondaryContentDivider: true,
          ),
        ),
      ),
    );

Widget _alertLauncher(ValueChanged<bool?> onResult) => Builder(
      builder: (context) => CdsButton(
        label: 'Retry transfer',
        onPress: () async => onResult(await showCdsFullscreenAlert(
          context,
          title: 'Transfer failed',
          body: 'Your bank declined the transfer.',
          preferredActionLabel: 'Try again',
          dismissActionLabel: 'Close alert',
        )),
      ),
    );

void main() {
  testWidgets('fullscreen modal opens, rises in and closes from the header', (tester) async {
    await pumpCds(tester, _modalLauncher());
    await tester.tap(find.text('Verify identity'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byWidgetPredicate((w) => w is Transform && w.transform.getTranslation().y > 0), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Verify your identity'), findsOneWidget);
    expect(find.text('Sample data: about 3 minutes'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Verify your identity'), findsNothing);
  });

  testWidgets('secondary content sits beside primary on wide screens', (tester) async {
    await pumpCdsSized(tester, _modalLauncher(), const Size(1300, 900));
    await tester.tap(find.text('Verify identity'));
    await tester.pumpAndSettle();
    final primary = tester.getTopLeft(find.text('Have your ID ready.'));
    final secondary = tester.getTopLeft(find.text('Sample data: about 3 minutes'));
    expect(secondary.dx, greaterThan(primary.dx));
  });

  testWidgets('Escape closes the fullscreen modal', (tester) async {
    await pumpCds(tester, _modalLauncher());
    await tester.tap(find.text('Verify identity'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Verify your identity'), findsNothing);
  });

  testWidgets('fullscreen alert returns the chosen action', (tester) async {
    bool? result;
    await pumpCds(tester, _alertLauncher((r) => result = r));
    await tester.tap(find.text('Retry transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Transfer failed'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Try again')).dy, lessThan(tester.getTopLeft(find.text('Close alert')).dy));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('Retry transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('layout renders custom content at text scale 2.0', (tester) async {
    await pumpCds(
      tester,
      Builder(
        builder: (context) => CdsButton(
          label: 'Open layout',
          onPress: () => showCdsFullscreenModal<void>(
            context,
            builder: (context) => const CdsFullscreenModalLayout(child: CdsText('Custom flow')),
          ),
        ),
      ),
      textScale: 2,
    );
    await tester.tap(find.text('Open layout'));
    await tester.pumpAndSettle();
    expect(find.text('Custom flow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion only fades', (tester) async {
    await pumpCds(tester, _modalLauncher(), disableAnimations: true);
    await tester.tap(find.text('Verify identity'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byWidgetPredicate((w) => w is Transform && w.transform.getTranslation().y > 0), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
