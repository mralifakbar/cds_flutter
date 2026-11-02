import 'package:cds_flutter/cds_flutter.dart';
// The cards, media and display barrels are exported from cds_flutter.dart once the maintainer adds them.
import 'package:flutter/widgets.dart';

import '../demo.dart';
import 'sample_art.dart';

/// Content, data, messaging, media and asset cards. All copy and numbers are sample data.
final CdsDemoCategory cardsCategory = CdsDemoCategory(
  title: 'Cards',
  description: 'Content, data, messaging, nudge, upsell, media and asset cards, pressable and dismissible.',
  icon: CdsIconName.card,
  demos: [
    CdsDemo(
      title: 'CdsContentCard',
      description: 'Header, body and footer, every media placement, and a pressable card with inner actions.',
      docPath: 'doc/components/CdsContentCard.md',
      builder: (_) => const _ContentCardDemo(),
    ),
    CdsDemo(
      title: 'CdsDataCard',
      description: 'Progress visualizations in vertical and horizontal layouts.',
      docPath: 'doc/components/CdsDataCard.md',
      builder: (_) => const _DataCardDemo(),
    ),
    CdsDemo(
      title: 'CdsMessagingCard',
      description: 'Upsell and nudge cards with tags, actions, media and a working dismiss.',
      docPath: 'doc/components/CdsMessagingCard.md',
      builder: (_) => const _MessagingCardDemo(),
    ),
    CdsDemo(
      title: 'CdsNudgeCard',
      description: 'The older nudge card, with media on either side.',
      docPath: 'doc/components/CdsNudgeCard.md',
      builder: (_) => const _NudgeCardDemo(),
    ),
    CdsDemo(
      title: 'CdsUpsellCard',
      description: 'The older upsell card with end-anchored media.',
      docPath: 'doc/components/CdsUpsellCard.md',
      builder: (_) => const _UpsellCardDemo(),
    ),
    CdsDemo(
      title: 'CdsMediaCard',
      description: 'Half text, half media, with media at either end.',
      docPath: 'doc/components/CdsMediaCard.md',
      builder: (_) => const _MediaCardDemo(),
    ),
    CdsDemo(
      title: 'CdsContainedAssetCard',
      description: 'Small and large asset tiles.',
      docPath: 'doc/components/CdsContainedAssetCard.md',
      builder: (_) => const _ContainedAssetCardDemo(),
    ),
    CdsDemo(
      title: 'CdsFloatingAssetCard',
      description: 'Media in its own tile with text underneath.',
      docPath: 'doc/components/CdsFloatingAssetCard.md',
      builder: (_) => const _FloatingAssetCardDemo(),
    ),
  ],
);

const _sample = 'Sample data';

Widget _art(ImageProvider source) =>
    CdsRemoteImage(source: source, width: double.infinity, height: double.infinity, shape: CdsShape.rectangle);

class _ContentCardDemo extends StatelessWidget {
  const _ContentCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Pressable with inner actions',
        caption: 'Pressing the card and pressing its buttons are separate actions.',
        child: CdsContentCard(
          background: CdsColor.bgAlternate,
          onPress: () {},
          semanticLabel: 'Read: Network activity rose this week',
          children: [
            CdsContentCardHeader(
              thumbnail: const CdsAvatar(name: 'Market', colorScheme: CdsHue.indigo),
              title: 'Market update',
              subtitle: 'News',
              actions: CdsIconButton(CdsIconName.more, semanticLabel: 'More options', transparent: true, onPress: () {}),
            ),
            CdsContentCardBody(
              title: 'Network activity rose this week',
              description: 'Sample data. Daily transactions climbed for the third week in a row.',
              media: CdsRemoteImage(source: SampleArt.blue, width: double.infinity, aspectRatio: 16 / 9, shape: CdsShape.rectangle),
            ),
            CdsContentCardFooter(children: [
              const CdsText.label2(_sample, color: CdsColor.fgMuted),
              CdsButton(label: 'Share', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, startIcon: CdsIconName.share, onPress: () {}),
            ]),
          ],
        ),
      ),
      for (final placement in [CdsContentCardMediaPlacement.start, CdsContentCardMediaPlacement.end, CdsContentCardMediaPlacement.bottom])
        DemoSection(
          title: 'Media at ${placement.name}',
          child: CdsContentCard(
            bordered: true,
            children: [
              CdsContentCardBody(
                title: 'Staking rewards now arrive weekly',
                descriptionNode: const CdsHStack(gap: 0.5, wrap: true, children: [
                  CdsText.label2(r'$3,081.01', color: CdsColor.fgMuted),
                  CdsText.label2('+6.37%', color: CdsColor.fgPositive),
                ]),
                media: placement == CdsContentCardMediaPlacement.bottom
                    ? CdsRemoteImage(source: SampleArt.green, width: double.infinity, aspectRatio: 2, shape: CdsShape.rectangle)
                    : _art(SampleArt.green),
                mediaPlacement: placement,
              ),
            ],
          ),
        ),
    ]);
  }
}

class _DataCardDemo extends StatelessWidget {
  const _DataCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 3, children: [
      const DemoSection(
        title: 'Vertical',
        caption: _sample,
        child: CdsDataCard(
          title: 'Emergency fund',
          subtitle: r'$450 of $1,000',
          thumbnail: CdsCellMedia.icon(CdsIconName.wallet),
          titleAccessory: CdsTag('On track', colorScheme: CdsTagColorScheme.green),
          child: CdsProgressCircle(progress: 0.45, size: 48),
        ),
      ),
      DemoSection(
        title: 'Horizontal, pressable',
        child: CdsDataCard(
          layout: CdsDataCardLayout.horizontal,
          title: 'Weekly limit',
          subtitle: r'$7,000 of $10,000 used',
          onPress: () {},
          child: const CdsProgressCircle(progress: 0.7, size: 64, showLabel: true),
        ),
      ),
    ]);
  }
}

class _MessagingCardDemo extends StatefulWidget {
  const _MessagingCardDemo();

  @override
  State<_MessagingCardDemo> createState() => _MessagingCardDemoState();
}

class _MessagingCardDemoState extends State<_MessagingCardDemo> {
  final Set<int> _dismissed = {};

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      CdsMessagingCard(
        type: CdsMessagingCardType.upsell,
        tag: 'New',
        title: 'Earn rewards on USDC',
        description: 'Sample data. Rates vary and can change.',
        action: 'Start earning',
        onActionButtonPress: () {},
        onDismissButtonPress: () => setState(() => _dismissed.add(0)),
        media: CdsRemoteImage(source: SampleArt.sunset, width: 120, height: 140, shape: CdsShape.rectangle),
      ),
      CdsMessagingCard(
        type: CdsMessagingCardType.nudge,
        title: 'Turn on price alerts',
        description: 'Get notified when Bitcoin moves 5% in a day.',
        action: 'Set up alerts',
        onActionButtonPress: () {},
        onDismissButtonPress: () => setState(() => _dismissed.add(1)),
        media: const CdsIcon(CdsIconName.bell, size: CdsIconSize.l, color: CdsColor.fgPrimary),
      ),
      CdsMessagingCard(
        type: CdsMessagingCardType.nudge,
        mediaPlacement: CdsMessagingCardMediaPlacement.start,
        title: 'Secure your account',
        description: 'Add a passkey for faster, safer sign-in.',
        onPress: () {},
        onDismissButtonPress: () => setState(() => _dismissed.add(2)),
        media: const CdsIcon(CdsIconName.shield, size: CdsIconSize.l, color: CdsColor.fgPrimary),
      ),
    ];
    return CdsVStack(gap: 2, children: [
      const CdsText.label2('$_sample. Dismiss a card to remove it.', color: CdsColor.fgMuted),
      for (var i = 0; i < cards.length; i++)
        if (!_dismissed.contains(i)) cards[i],
      if (_dismissed.isNotEmpty)
        CdsButton(
          label: 'Restore cards',
          size: CdsButtonSize.s,
          variant: CdsButtonVariant.secondary,
          onPress: () => setState(_dismissed.clear),
        ),
    ]);
  }
}

class _NudgeCardDemo extends StatelessWidget {
  const _NudgeCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 2, children: [
      CdsNudgeCard(
        title: 'Back up your wallet',
        description: 'Save your recovery phrase so you keep access.',
        action: 'Back up now',
        onActionPress: () {},
        onDismissPress: () {},
        media: const CdsIcon(CdsIconName.shield, size: CdsIconSize.l, color: CdsColor.fgPrimary),
      ),
      const CdsNudgeCard(
        mediaPosition: CdsNudgeCardMediaPosition.left,
        title: 'Recurring buys',
        description: 'Sample data. Buy a set amount every week.',
        media: CdsIcon(CdsIconName.wallet, size: CdsIconSize.l, color: CdsColor.fgPrimary),
      ),
    ]);
  }
}

class _UpsellCardDemo extends StatelessWidget {
  const _UpsellCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsUpsellCard(
      title: 'Earn rewards on USDC',
      description: 'Sample data. Rates vary.',
      action: 'Start earning',
      onActionPress: () {},
      onDismissPress: () {},
      media: CdsRemoteImage(source: SampleArt.blue, width: 96, height: 158, shape: CdsShape.rectangle),
    );
  }
}

class _MediaCardDemo extends StatelessWidget {
  const _MediaCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 2, children: [
      CdsMediaCard(
        thumbnail: CdsRemoteImage(source: SampleArt.green, size: CdsAvatarSize.xl, shape: CdsShape.circle),
        subtitle: 'Collection',
        title: 'Gradient studies',
        description: _sample,
        media: _art(SampleArt.green),
        onPress: () {},
      ),
      CdsMediaCard(
        thumbnail: const CdsAvatar(name: 'Grace', colorScheme: CdsHue.purple, size: CdsAvatarSize.xl),
        subtitle: 'Creator',
        title: 'Media at start',
        description: _sample,
        mediaPlacement: CdsMediaCardMediaPlacement.start,
        media: _art(SampleArt.sunset),
      ),
    ]);
  }
}

class _ContainedAssetCardDemo extends StatelessWidget {
  const _ContainedAssetCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 2, alignItems: CrossAxisAlignment.start, children: [
      const CdsText.label2(_sample, color: CdsColor.fgMuted),
      CdsHStack(gap: 2, wrap: true, children: [
        CdsContainedAssetCard(
          header: CdsRemoteImage(source: SampleArt.blue, size: CdsAvatarSize.xl, shape: CdsShape.circle),
          subtitle: 'BTC',
          title: r'$64,201.10',
          description: '+2.4% today',
          onPress: () {},
        ),
        CdsContainedAssetCard(
          header: CdsRemoteImage(source: SampleArt.green, size: CdsAvatarSize.xl, shape: CdsShape.circle),
          subtitle: 'ETH',
          title: r'$3,081.01',
          description: '-1.2% today',
        ),
      ]),
      CdsContainedAssetCard(
        size: CdsAssetCardSize.l,
        header: CdsRemoteImage(source: SampleArt.sunset, size: CdsAvatarSize.xl, shape: CdsShape.circle),
        subtitle: 'Collection',
        title: 'Gradient studies',
        description: '24 items',
        child: _art(SampleArt.sunset),
      ),
    ]);
  }
}

class _FloatingAssetCardDemo extends StatelessWidget {
  const _FloatingAssetCardDemo();

  @override
  Widget build(BuildContext context) {
    return CdsHStack(gap: 2, alignItems: CrossAxisAlignment.start, wrap: true, children: [
      CdsFloatingAssetCard(media: _art(SampleArt.blue), subtitle: 'Collection', title: 'Blue study', description: _sample, onPress: () {}),
      CdsFloatingAssetCard(media: _art(SampleArt.sunset), subtitle: 'Collection', title: 'Sunset study', description: _sample, onPress: () {}),
    ]);
  }
}
