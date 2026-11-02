import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('Tab cycles inside the trap and Escape calls onEscPress', (tester) async {
    var escapes = 0;
    final inside = [FocusNode(), FocusNode()];
    final outside = FocusNode();
    addTearDown(() {
      for (final n in [...inside, outside]) {
        n.dispose();
      }
    });
    await pumpCds(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CdsButton(label: 'Outside', focusNode: outside, onPress: () {}),
          CdsFocusTrap(
            onEscPress: () => escapes++,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CdsButton(label: 'First', focusNode: inside[0], onPress: () {}),
                CdsButton(label: 'Second', focusNode: inside[1], onPress: () {}),
              ],
            ),
          ),
        ],
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(outside.hasFocus, isFalse);
      expect(inside.any((n) => n.hasFocus), isTrue);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(escapes, 1);
  });

  testWidgets('restores focus to the previously focused widget on unmount', (tester) async {
    final trigger = FocusNode();
    addTearDown(trigger.dispose);
    var show = false;
    late StateSetter setOuter;
    await pumpCds(
      tester,
      StatefulBuilder(builder: (context, setState) {
        setOuter = setState;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CdsButton(label: 'Trigger', focusNode: trigger, onPress: () {}),
            if (show) CdsFocusTrap(child: CdsButton(label: 'Inside', onPress: () {})),
          ],
        );
      }),
    );
    trigger.requestFocus();
    await tester.pump();
    setOuter(() => show = true);
    await tester.pumpAndSettle();
    expect(trigger.hasFocus, isFalse);
    setOuter(() => show = false);
    await tester.pumpAndSettle();
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('disableFocusTrap lets Tab leave', (tester) async {
    final outside = FocusNode();
    addTearDown(outside.dispose);
    await pumpCds(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CdsFocusTrap(disableFocusTrap: true, child: CdsButton(label: 'Inside', onPress: () {})),
          CdsButton(label: 'Outside', focusNode: outside, onPress: () {}),
        ],
      ),
    );
    var reached = false;
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      reached = reached || outside.hasFocus;
    }
    expect(reached, isTrue);
  });
}
