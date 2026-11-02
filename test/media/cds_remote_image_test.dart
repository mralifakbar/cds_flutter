import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'test_images.dart';

void main() {
  group('CdsRemoteImage', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every shape in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Wrap(children: [
            for (final shape in CdsShape.values) CdsRemoteImage(source: transparentImage(), shape: shape, borderColor: CdsColor.bgLine),
            const CdsRemoteImage(),
            CdsRemoteImage(source: transparentImage(), darkModeEnhancementsApplied: true),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('defaults to the m avatar size', (tester) async {
      await pumpCds(tester, const CdsRemoteImage());
      expect(tester.getSize(find.byType(CdsRemoteImage)), const Size(24, 24));
    });

    testWidgets('width and aspectRatio derive the height', (tester) async {
      await pumpCds(tester, const CdsRemoteImage(width: 160, aspectRatio: 16 / 9));
      expect(tester.getSize(find.byType(CdsRemoteImage)), const Size(160, 90));
    });

    testWidgets('fills the width when width is infinite', (tester) async {
      await pumpCds(tester, const SizedBox(width: 300, child: CdsRemoteImage(width: double.infinity, aspectRatio: 2)));
      expect(tester.getSize(find.byType(CdsRemoteImage)), const Size(300, 150));
    });

    testWidgets('shows a custom fallback when the image fails', (tester) async {
      await pumpCds(tester, CdsRemoteImage(source: brokenImage(), fallback: const Text('No image')), settle: false);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
      expect(find.text('No image'), findsOneWidget);
    });

    testWidgets('is hidden from screen readers unless labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, Column(mainAxisSize: MainAxisSize.min, children: [
        const CdsRemoteImage(),
        CdsRemoteImage(source: transparentImage(), semanticLabel: 'Bitcoin logo'),
      ]));
      expect(find.bySemanticsLabel('Bitcoin logo'), findsOneWidget);
      expect(tester.getSemantics(find.bySemanticsLabel('Bitcoin logo')), matchesSemantics(label: 'Bitcoin logo', isImage: true));
      handle.dispose();
    });
  });

  group('CdsRemoteImageGroup', () {
    testWidgets('collapses children past max into +N', (tester) async {
      await pumpCds(tester, const CdsRemoteImageGroup(max: 2, children: [CdsRemoteImage(), CdsRemoteImage(), CdsRemoteImage(), CdsRemoteImage()]));
      expect(find.text('+2'), findsOneWidget);
      expect(find.byType(CdsRemoteImage), findsNWidgets(2));
    });

    testWidgets('sizes children and overlaps them by 8px at 40px and below', (tester) async {
      await pumpCds(tester, const CdsRemoteImageGroup(size: CdsAvatarSize.xl, children: [CdsRemoteImage(), CdsRemoteImage(), CdsRemoteImage()]));
      expect(tester.getSize(find.byType(CdsRemoteImage).first), const Size(40, 40));
      expect(tester.getSize(find.byType(CdsRemoteImageGroup)).width, 40 + 32 + 32);
    });

    testWidgets('overlaps by 16px above 40px and adds rings', (tester) async {
      await pumpCds(tester, const CdsRemoteImageGroup(size: CdsAvatarSize.xxl, borderWidth: 200, children: [CdsRemoteImage(), CdsRemoteImage()]));
      expect(tester.getSize(find.byType(CdsRemoteImageGroup)).width, 52 + 36);
    });

    testWidgets('reads semanticLabel instead of each image', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsRemoteImageGroup(max: 1, semanticLabel: 'Bitcoin and 1 more', children: [CdsRemoteImage(), CdsRemoteImage()]));
      expect(find.bySemanticsLabel('Bitcoin and 1 more'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('lays out right to left', (tester) async {
      await pumpCds(tester, const CdsRemoteImageGroup(children: [CdsRemoteImage(key: Key('a')), CdsRemoteImage(key: Key('b'))]), textDirection: TextDirection.rtl);
      expect(tester.getTopLeft(find.byKey(const Key('a'))).dx, greaterThan(tester.getTopLeft(find.byKey(const Key('b'))).dx));
    });
  });

  group('CdsCellMedia', () {
    testWidgets('icons and assets sit in 32px, images and pictograms in 48px', (tester) async {
      await pumpCds(tester, Column(mainAxisSize: MainAxisSize.min, children: [
        const CdsCellMedia.icon(CdsIconName.wallet, key: Key('icon')),
        CdsCellMedia.asset(source: transparentImage(), key: const Key('asset')),
        CdsCellMedia.avatar(source: transparentImage(), key: const Key('avatar')),
        CdsCellMedia.image(source: transparentImage(), key: const Key('image')),
        const CdsCellMedia.pictogram(SizedBox.square(dimension: 48), key: Key('pictogram')),
      ]));
      expect(tester.getSize(find.byKey(const Key('icon'))), const Size(32, 32));
      expect(tester.getSize(find.byKey(const Key('asset'))), const Size(32, 32));
      expect(tester.getSize(find.byKey(const Key('avatar'))), const Size(32, 32));
      expect(tester.getSize(find.byKey(const Key('image'))), const Size(48, 48));
      expect(tester.getSize(find.byKey(const Key('pictogram'))), const Size(48, 48));
    });

    testWidgets('labels pictograms for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsCellMedia.pictogram(SizedBox.square(dimension: 48), semanticLabel: 'Shield'));
      expect(find.bySemanticsLabel('Shield'), findsOneWidget);
      handle.dispose();
    });
  });
}
