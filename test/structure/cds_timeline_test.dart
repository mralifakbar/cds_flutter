import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _events = [
  CdsTimelineEvent(title: 'Order placed', timestamp: '09:41', status: CdsTimelineStatus.complete),
  CdsTimelineEvent(title: 'Processing', description: 'Usually under 5 minutes', status: CdsTimelineStatus.active),
  CdsTimelineEvent(title: 'Funds available'),
  CdsTimelineEvent(title: 'Card declined', status: CdsTimelineStatus.error, statusLabel: 'Declined'),
];

void main() {
  testWidgets('renders every event in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, const CdsTimeline(events: _events), brightness: b);
      expect(tester.takeException(), isNull);
      expect(find.text('Funds available'), findsOneWidget);
    }
  });

  testWidgets('each status has its own glyph', (tester) async {
    await pumpCds(tester, const CdsTimeline(events: _events));
    final names = tester.widgetList<CdsIcon>(find.byType(CdsIcon)).map((i) => i.name).toList();
    expect(names, [CdsIconName.circleCheckmark, CdsIconName.outline, CdsIconName.outline, CdsIconName.error]);
  });

  testWidgets('semantics label includes status text, not only color', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const CdsTimeline(events: _events));
    expect(find.bySemanticsLabel('Order placed, Complete, 09:41'), findsOneWidget);
    expect(find.bySemanticsLabel('Processing, In progress, Usually under 5 minutes'), findsOneWidget);
    expect(find.bySemanticsLabel('Funds available, Upcoming'), findsOneWidget);
    expect(find.bySemanticsLabel('Card declined, Declined'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('text scale 2.0 and RTL with media', (tester) async {
    await pumpCds(
      tester,
      SizedBox(
        width: 320,
        child: CdsTimeline(events: [
          ..._events,
          CdsTimelineEvent(
            title: 'Receipt ready',
            media: CdsButton(label: 'View receipt', size: CdsButtonSize.s, onPress: () {}),
          ),
        ]),
      ),
      textScale: 2,
      textDirection: TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
