import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  late List<String> log;
  Widget menu() => CdsContextMenu(
        actions: [
          CdsContextMenuAction(label: 'Copy address', icon: CdsIconName.copy, onPress: () => log.add('copy')),
          CdsContextMenuAction(label: 'Remove', icon: CdsIconName.trashCan, destructive: true, onPress: () => log.add('remove')),
        ],
        child: const SizedBox(width: 200, height: 60, child: CdsText('Sample data: 0x12ab')),
      );

  setUp(() => log = []);

  testWidgets('long-press opens at the press point; an action runs and closes', (tester) async {
    await pumpCds(tester, menu());
    await tester.longPress(find.text('Sample data: 0x12ab'));
    await tester.pumpAndSettle();
    expect(find.text('Copy address'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(log, ['remove']);
    expect(find.text('Copy address'), findsNothing);
  });

  testWidgets('right-click opens; tap outside closes', (tester) async {
    await pumpCds(tester, menu());
    await tester.tap(find.text('Sample data: 0x12ab'), buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    expect(find.text('Copy address'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Copy address'), findsNothing);
  });

  testWidgets('Escape closes', (tester) async {
    await pumpCds(tester, menu());
    await tester.longPress(find.text('Sample data: 0x12ab'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Copy address'), findsNothing);
  });

  testWidgets('destructive actions use the negative color', (tester) async {
    await pumpCds(tester, menu());
    await tester.longPress(find.text('Sample data: 0x12ab'));
    await tester.pumpAndSettle();
    expect(tester.widget<CdsText>(find.widgetWithText(CdsText, 'Remove')).color, CdsColor.fgNegative);
  });
}
