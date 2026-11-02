import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  late List<String> clipboard;

  setUp(() {
    clipboard = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('CdsCodeSnippet', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          const SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, children: [
            CdsCodeSnippet('flutter pub add cds_flutter'),
            CdsCodeSnippet('0x0000000000000000000000000000000000000000', title: 'Address', wrap: true),
            CdsCodeSnippet('no button', showCopyButton: false),
          ])),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('copies to the clipboard and confirms, then resets', (tester) async {
      var copies = 0;
      await pumpCds(tester, SizedBox(width: 320, child: CdsCodeSnippet('dart run', onCopy: () => copies++)));
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(clipboard, ['dart run']);
      expect(copies, 1);
      expect(find.text('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('the button is labelled and announces the confirmation', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const SizedBox(width: 320, child: CdsCodeSnippet('x', title: 'Install command')));
      expect(tester.getSemantics(find.bySemanticsLabel('Copy Install command')), containsSemantics(isButton: true, hasTapAction: true));
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('long lines scroll unless wrap is set', (tester) async {
      const long = 'a very long single line of code that cannot possibly fit inside the snippet box';
      await pumpCds(tester, const SizedBox(width: 240, child: CdsCodeSnippet(long)));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await pumpCds(tester, const SizedBox(width: 240, child: CdsCodeSnippet(long, wrap: true)));
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the monospace family', (tester) async {
      await pumpCds(tester, const SizedBox(width: 320, child: CdsCodeSnippet('mono')));
      expect(tester.widget<Text>(find.text('mono')).style!.fontFamily, contains('SourceCodePro'));
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, const SizedBox(width: 320, child: CdsCodeSnippet('flutter pub add cds_flutter', title: 'Install')), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
