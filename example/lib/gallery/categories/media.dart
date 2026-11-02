import 'package:cds_flutter/cds_flutter.dart';
// The media barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/widgets.dart';

import '../demo.dart';
import 'sample_art.dart';

/// Avatars, remote images and cell media. Names and images are sample data.
final CdsDemoCategory mediaCategory = CdsDemoCategory(
  title: 'Media',
  description: 'Avatars, remote images with loading and error fallbacks, image groups and cell media.',
  icon: CdsIconName.image,
  demos: [
    CdsDemo(
      title: 'CdsAvatar',
      description: 'Pictures, letter tiles in every color, sizes, shapes and the error fallback.',
      docPath: 'doc/components/CdsAvatar.md',
      builder: (_) => const _AvatarDemo(),
    ),
    CdsDemo(
      title: 'CdsAvatarButton',
      description: 'A pressable avatar for opening a profile, regular and compact.',
      docPath: 'doc/components/CdsAvatarButton.md',
      builder: (_) => const _AvatarButtonDemo(),
    ),
    CdsDemo(
      title: 'CdsRemoteImage',
      description: 'Every CDS shape, aspect ratios, dark mode enhancements, missing and broken images.',
      docPath: 'doc/components/CdsRemoteImage.md',
      builder: (_) => const _RemoteImageDemo(),
    ),
    CdsDemo(
      title: 'CdsRemoteImageGroup',
      description: 'Overlapping images that collapse into a +N bubble.',
      docPath: 'doc/components/CdsRemoteImageGroup.md',
      builder: (_) => const _RemoteImageGroupDemo(),
    ),
    CdsDemo(
      title: 'CdsCellMedia',
      description: 'Icon, asset, avatar, image and pictogram media sized for cells.',
      docPath: 'doc/components/CdsCellMedia.md',
      builder: (_) => const _CellMediaDemo(),
    ),
  ],
);

const _sample = 'Sample data';

class _AvatarDemo extends StatelessWidget {
  const _AvatarDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Sizes',
        caption: 's 16, m 24, l 32, xl 40, xxl 48, xxxl 56',
        child: CdsHStack(gap: 1.5, wrap: true, children: [
          for (final size in CdsAvatarSize.values) CdsAvatar(name: 'Ada', size: size),
        ]),
      ),
      DemoSection(
        title: 'Letter tile colors',
        caption: _sample,
        child: CdsHStack(gap: 1, wrap: true, children: [
          for (final hue in CdsHue.values) CdsAvatar(name: hue.name, colorScheme: hue, size: CdsAvatarSize.xl),
        ]),
      ),
      DemoSection(
        title: 'Shapes',
        child: CdsHStack(gap: 2, children: [
          CdsAvatar(image: SampleArt.blue, size: CdsAvatarSize.xxl),
          CdsAvatar(image: SampleArt.green, size: CdsAvatarSize.xxl, shape: CdsAvatarShape.square),
          CdsAvatar(image: SampleArt.sunset, size: CdsAvatarSize.xxl, shape: CdsAvatarShape.hexagon),
          const CdsAvatar(name: 'Grace', size: CdsAvatarSize.xxl, shape: CdsAvatarShape.square, colorScheme: CdsHue.teal),
        ]),
      ),
      DemoSection(
        title: 'Fallbacks',
        caption: 'A broken image with a name shows the letter; with neither, a silhouette.',
        child: CdsHStack(gap: 2, children: [
          CdsAvatar(image: SampleArt.broken, name: 'Linus', size: CdsAvatarSize.xxl),
          const CdsAvatar(size: CdsAvatarSize.xxl),
          CdsAvatar(image: SampleArt.blue, size: CdsAvatarSize.xxl, borderColor: CdsColor.bgPrimary),
        ]),
      ),
    ]);
  }
}

class _AvatarButtonDemo extends StatelessWidget {
  const _AvatarButtonDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Regular and compact',
      caption: _sample,
      child: CdsHStack(gap: 2, children: [
        CdsAvatarButton(name: 'Ada', colorScheme: CdsHue.purple, semanticLabel: 'Open profile', onPress: () {}),
        CdsAvatarButton(image: SampleArt.blue, compact: true, semanticLabel: 'Switch account', onPress: () {}),
        const CdsAvatarButton(name: 'Off', semanticLabel: 'Profile unavailable', disabled: true),
      ]),
    );
  }
}

class _RemoteImageDemo extends StatelessWidget {
  const _RemoteImageDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Shapes',
        child: CdsHStack(gap: 2, wrap: true, children: [
          for (final shape in CdsShape.values)
            CdsVStack(gap: 0.5, alignItems: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              CdsRemoteImage(source: SampleArt.blue, shape: shape, size: CdsAvatarSize.xxxl),
              CdsText.legal(shape.name, color: CdsColor.fgMuted),
            ]),
        ]),
      ),
      DemoSection(
        title: 'Full width at 16:9',
        child: CdsRemoteImage(source: SampleArt.sunset, width: double.infinity, aspectRatio: 16 / 9, shape: CdsShape.squircle),
      ),
      DemoSection(
        title: 'Missing and broken',
        caption: 'No source shows the CDS fallback graphic; a failed load does too, or a custom fallback.',
        child: CdsHStack(gap: 2, children: [
          const CdsRemoteImage(size: CdsAvatarSize.xxxl, shape: CdsShape.squircle),
          CdsRemoteImage(source: SampleArt.broken, size: CdsAvatarSize.xxxl, shape: CdsShape.squircle),
          CdsRemoteImage(
            source: SampleArt.broken,
            size: CdsAvatarSize.xxxl,
            shape: CdsShape.circle,
            fallback: const ColoredBox(
              color: Color(0x00000000),
              child: Center(child: CdsIcon(CdsIconName.image, color: CdsColor.fgMuted)),
            ),
          ),
        ]),
      ),
      DemoSection(
        title: 'Borders and dark mode enhancements',
        child: CdsHStack(gap: 2, children: [
          CdsRemoteImage(source: SampleArt.green, size: CdsAvatarSize.xxl, shape: CdsShape.circle, borderColor: CdsColor.bgPositive),
          CdsRemoteImage(source: SampleArt.blue, size: CdsAvatarSize.xxl, shape: CdsShape.circle, darkModeEnhancementsApplied: true),
        ]),
      ),
    ]);
  }
}

class _RemoteImageGroupDemo extends StatelessWidget {
  const _RemoteImageGroupDemo();

  @override
  Widget build(BuildContext context) {
    final art = [SampleArt.blue, SampleArt.green, SampleArt.sunset, SampleArt.blue, SampleArt.green, SampleArt.sunset];
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Collapsed past max',
        caption: _sample,
        child: CdsRemoteImageGroup(
          max: 3,
          semanticLabel: '6 sample assets',
          children: [for (final a in art) CdsRemoteImage(source: a)],
        ),
      ),
      DemoSection(
        title: 'Large with rings',
        child: CdsRemoteImageGroup(
          size: CdsAvatarSize.xxl,
          borderWidth: 200,
          children: [for (final a in art.take(4)) CdsRemoteImage(source: a)],
        ),
      ),
      DemoSection(
        title: 'Squares and avatars',
        child: CdsRemoteImageGroup(
          size: CdsAvatarSize.xl,
          shape: CdsShape.square,
          children: const [
            CdsAvatar(name: 'Ada', size: CdsAvatarSize.xl, shape: CdsAvatarShape.square),
            CdsAvatar(name: 'Grace', colorScheme: CdsHue.purple, size: CdsAvatarSize.xl, shape: CdsAvatarShape.square),
            CdsAvatar(name: 'Linus', colorScheme: CdsHue.green, size: CdsAvatarSize.xl, shape: CdsAvatarShape.square),
          ],
        ),
      ),
    ]);
  }
}

class _CellMediaDemo extends StatelessWidget {
  const _CellMediaDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Every type',
      caption: '32px for icons, assets and avatars; 48px for images and pictograms.',
      child: CdsHStack(gap: 2, children: [
        const CdsCellMedia.icon(CdsIconName.wallet),
        CdsCellMedia.asset(source: SampleArt.blue),
        CdsCellMedia.avatar(source: SampleArt.green),
        CdsCellMedia.image(source: SampleArt.sunset),
        const CdsCellMedia.pictogram(CdsIcon(CdsIconName.shield, size: CdsIconSize.l, color: CdsColor.fgPrimary)),
      ]),
    );
  }
}
