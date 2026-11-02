import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'test_images.dart';

void main() {
  group('CdsAvatar', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every size and shape in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Wrap(children: [
            for (final size in CdsAvatarSize.values)
              for (final shape in CdsAvatarShape.values) CdsAvatar(name: 'Ada', size: size, shape: shape),
            const CdsAvatar(),
            CdsAvatar(image: transparentImage()),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('uses the theme avatar size', (tester) async {
      await pumpCds(tester, const CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl));
      expect(tester.getSize(find.byType(CdsAvatar)), const Size(48, 48));
      await pumpCds(tester, const CdsAvatar(name: 'Ada', dangerouslySetSize: 70));
      expect(tester.getSize(find.byType(CdsAvatar)), const Size(70, 70));
    });

    testWidgets('shows the uppercase first letter when there is no image', (tester) async {
      await pumpCds(tester, const CdsAvatar(name: 'satoshi'));
      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('letter contrasts with the tile', (tester) async {
      await pumpCds(tester, const CdsAvatar(name: 'Ada', colorScheme: CdsHue.yellow));
      final text = tester.widget<Text>(find.text('A'));
      final tile = CdsThemeData.light.spectrum.of(CdsHue.yellow, 60);
      final fg = text.style!.color!;
      final other = fg == const Color(0xFFFFFFFF) ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
      expect(CdsColorUtils.contrastRatio(fg, tile), greaterThanOrEqualTo(CdsColorUtils.contrastRatio(other, tile)));
    });

    testWidgets('falls back to the letter when the image fails', (tester) async {
      await pumpCds(tester, CdsAvatar(image: brokenImage(), name: 'Ada'), settle: false);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('exposes semanticLabel as an image', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsAvatar(name: 'Ada', semanticLabel: 'Ada Lovelace'));
      expect(tester.getSemantics(find.bySemanticsLabel('Ada Lovelace')), matchesSemantics(label: 'Ada Lovelace', isImage: true));
      handle.dispose();
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, const CdsAvatar(name: 'Ada', size: CdsAvatarSize.s), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('CdsAvatarButton', () {
    testWidgets('fires onPress and exposes a button label', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpCds(tester, CdsAvatarButton(name: 'Ada', semanticLabel: 'Open profile', onPress: () => taps++));
      await tester.tap(find.byType(CdsAvatarButton));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Open profile')),
        containsSemantics(label: 'Open profile', isButton: true, hasTapAction: true, isEnabled: true),
      );
      handle.dispose();
    });

    testWidgets('is 56px, or 40px when compact, with a 44px minimum hit area', (tester) async {
      await pumpCds(tester, CdsAvatarButton(name: 'Ada', semanticLabel: 'Profile', onPress: () {}));
      expect(tester.getSize(find.byType(CdsAvatar)), const Size(56, 56));
      await pumpCds(tester, CdsAvatarButton(name: 'Ada', compact: true, semanticLabel: 'Profile', onPress: () {}));
      expect(tester.getSize(find.byType(CdsAvatar)), const Size(40, 40));
      expect(tester.getSize(find.byType(CdsAvatarButton)).width, greaterThanOrEqualTo(44));
    });

    testWidgets('does not fire when disabled', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsAvatarButton(name: 'Ada', semanticLabel: 'Profile', disabled: true, onPress: () => taps++));
      await tester.tap(find.byType(CdsAvatarButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('activates from the keyboard', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsAvatarButton(name: 'Ada', semanticLabel: 'Profile', onPress: () => taps++));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });
}
