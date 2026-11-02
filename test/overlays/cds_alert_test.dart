import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _launcher({
  required ValueChanged<bool?> onResult,
  VoidCallback? onPreferred,
  VoidCallback? onDismiss,
  Axis actionLayout = Axis.horizontal,
  CdsButtonVariant variant = CdsButtonVariant.negative,
}) {
  return Builder(
    builder: (context) => CdsButton(
      label: 'Remove wallet',
      onPress: () async {
        onResult(await showCdsAlert(
          context,
          title: 'Remove wallet?',
          body: 'You can add it again with your recovery phrase.',
          preferredActionLabel: 'Remove',
          preferredActionVariant: variant,
          onPreferredActionPress: onPreferred,
          dismissActionLabel: 'Cancel',
          onDismissActionPress: onDismiss,
          actionLayout: actionLayout,
        ));
      },
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget w, {double textScale = 1, Brightness brightness = Brightness.light}) async {
  await pumpCds(tester, w, textScale: textScale, brightness: brightness);
  await tester.tap(find.text('Remove wallet'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('preferred action runs its callback and returns true', (tester) async {
    bool? result;
    var pressed = 0;
    await _open(tester, _launcher(onResult: (r) => result = r, onPreferred: () => pressed++));
    expect(find.text('Remove wallet?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(pressed, 1);
    expect(result, isTrue);
    expect(find.text('Remove wallet?'), findsNothing);
  });

  testWidgets('dismiss action returns false', (tester) async {
    bool? result;
    var dismissed = 0;
    await _open(tester, _launcher(onResult: (r) => result = r, onDismiss: () => dismissed++));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    expect(result, isFalse);
  });

  testWidgets('scrim tap does not close, Escape returns null', (tester) async {
    bool? result = true;
    await _open(tester, _launcher(onResult: (r) => result = r));
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Remove wallet?'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Remove wallet?'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('negative variant styles the preferred action', (tester) async {
    await _open(tester, _launcher(onResult: (_) {}));
    final button = tester.widget<CdsButton>(find.widgetWithText(CdsButton, 'Remove'));
    expect(button.variant, CdsButtonVariant.negative);
  });

  testWidgets('vertical layout stacks preferred above dismiss', (tester) async {
    await _open(tester, _launcher(onResult: (_) {}, actionLayout: Axis.vertical));
    expect(tester.getTopLeft(find.text('Remove')).dy, lessThan(tester.getTopLeft(find.text('Cancel')).dy));
  });

  testWidgets('title is a header and the route is named', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester, _launcher(onResult: (_) {}));
    expect(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.namesRoute == true && w.properties.label == 'Remove wallet?'),
      findsOneWidget,
    );
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.header == true), findsWidgets);
    handle.dispose();
  });

  testWidgets('dark mode and text scale 2.0 render without errors', (tester) async {
    await _open(tester, _launcher(onResult: (_) {}), brightness: Brightness.dark, textScale: 2);
    expect(tester.takeException(), isNull);
  });

  test('rejects variants other than primary and negative', () {
    expect(
      () => CdsAlert(
        title: 't',
        body: 'b',
        preferredActionLabel: 'p',
        preferredActionVariant: CdsButtonVariant.secondary,
      ),
      throwsAssertionError,
    );
  });
}
