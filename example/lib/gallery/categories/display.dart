import 'package:cds_flutter/cds_flutter.dart';
// The display and media barrels are exported from cds_flutter.dart once the maintainer adds them.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Tags, links, dots, code snippets and keycaps. Counts and labels are sample data.
final CdsDemoCategory displayCategory = CdsDemoCategory(
  title: 'Display',
  description: 'Tags, links, notification and status dots, code snippets and keyboard shortcuts.',
  icon: CdsIconName.tag,
  demos: [
    CdsDemo(
      title: 'CdsTag',
      description: 'Informational and promotional tags in every color and emphasis.',
      docPath: 'doc/components/CdsTag.md',
      builder: (_) => const _TagDemo(),
    ),
    CdsDemo(
      title: 'CdsLink',
      description: 'Standalone and inline links with pressed feedback and link semantics.',
      docPath: 'doc/components/CdsLink.md',
      builder: (_) => const _LinkDemo(),
    ),
    CdsDemo(
      title: 'CdsDotCount',
      description: 'A count badge that animates in and out as the count changes.',
      docPath: 'doc/components/CdsDotCount.md',
      builder: (_) => const _DotCountDemo(),
    ),
    CdsDemo(
      title: 'CdsDotStatusColor',
      description: 'Status dots pinned to avatars, always paired with a label.',
      docPath: 'doc/components/CdsDotStatusColor.md',
      builder: (_) => const _DotStatusDemo(),
    ),
    CdsDemo(
      title: 'CdsDotSymbol',
      description: 'Icon and image badges pinned to a corner.',
      docPath: 'doc/components/CdsDotSymbol.md',
      builder: (_) => const _DotSymbolDemo(),
    ),
    CdsDemo(
      title: 'CdsCodeSnippet',
      description: 'Monospaced text with a copy button and a confirmation state.',
      docPath: 'doc/components/CdsCodeSnippet.md',
      builder: (_) => const _CodeSnippetDemo(),
    ),
    CdsDemo(
      title: 'CdsKbd',
      description: 'Keyboard shortcuts drawn as keycaps.',
      docPath: 'doc/components/CdsKbd.md',
      builder: (_) => const _KbdDemo(),
    ),
  ],
);

class _TagDemo extends StatelessWidget {
  const _TagDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      for (final intent in CdsTagIntent.values)
        for (final emphasis in CdsTagEmphasis.values)
          DemoSection(
            title: '${intent.name}, ${emphasis.name} emphasis',
            child: CdsHStack(gap: 1, wrap: true, children: [
              for (final scheme in CdsTagColorScheme.values)
                CdsTag(scheme.name, intent: intent, emphasis: emphasis, colorScheme: scheme),
            ]),
          ),
      const DemoSection(
        title: 'With icons and truncation',
        child: CdsHStack(gap: 1, wrap: true, children: [
          CdsTag('Verified', colorScheme: CdsTagColorScheme.green, startIcon: CdsIconName.circleCheckmark, startIconActive: true),
          CdsTag('Pending', colorScheme: CdsTagColorScheme.yellow, startIcon: CdsIconName.clock),
          CdsTag('A label too long for its tag', colorScheme: CdsTagColorScheme.gray, maxWidth: 140),
        ]),
      ),
    ]);
  }
}

class _LinkDemo extends StatelessWidget {
  const _LinkDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Standalone',
        caption: 'Press and hold to see the pressed state.',
        child: CdsVStack(gap: 0, alignItems: CrossAxisAlignment.start, children: [
          CdsLink('View all assets', font: CdsFont.headline, onPress: () {}),
          CdsLink('Fee schedule', font: CdsFont.label1, onPress: () {}),
          CdsLink('Transaction ID 0x8a3f', font: CdsFont.label2, mono: true, onPress: () {}),
        ]),
      ),
      DemoSection(
        title: 'Inline',
        child: CdsText.rich(TextSpan(children: [
          const TextSpan(text: 'By continuing you accept the '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: CdsLink('user agreement', inline: true, font: CdsFont.body, onPress: () {}),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: CdsLink('privacy policy', inline: true, font: CdsFont.body, onPress: () {}),
          ),
          const TextSpan(text: '.'),
        ])),
      ),
    ]);
  }
}

class _DotCountDemo extends StatefulWidget {
  const _DotCountDemo();

  @override
  State<_DotCountDemo> createState() => _DotCountDemoState();
}

class _DotCountDemoState extends State<_DotCountDemo> {
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Pinned to a button',
        caption: 'Sample data. Set the count to 0 to watch the badge leave.',
        child: CdsVStack(gap: 2, alignItems: CrossAxisAlignment.start, children: [
          CdsDotCount(
            count: _count,
            semanticLabel: '$_count unread notifications',
            child: CdsIconButton(CdsIconName.bell, semanticLabel: 'Notifications', onPress: () {}),
          ),
          CdsHStack(gap: 1, wrap: true, children: [
            CdsButton(label: 'Add', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _count++)),
            CdsButton(label: 'Add 50', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _count += 50)),
            CdsButton(label: 'Clear', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _count = 0)),
          ]),
        ]),
      ),
      const DemoSection(
        title: 'On an avatar and inline',
        child: CdsHStack(gap: 4, children: [
          CdsDotCount(count: 120, overlap: CdsDotOverlap.circular, child: CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl)),
          CdsDotCount(count: 7),
        ]),
      ),
    ]);
  }
}

class _DotStatusDemo extends StatelessWidget {
  const _DotStatusDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Variants',
      caption: 'Sample data. The visible label carries the status for people who cannot see the color.',
      child: CdsVStack(gap: 2, alignItems: CrossAxisAlignment.start, children: [
        for (final (variant, label) in const [
          (CdsDotVariant.positive, 'Online'),
          (CdsDotVariant.warning, 'Away'),
          (CdsDotVariant.negative, 'Offline'),
          (CdsDotVariant.primary, 'In a call'),
          (CdsDotVariant.foregroundMuted, 'Unknown'),
        ])
          CdsHStack(gap: 2, children: [
            CdsDotStatusColor(
              variant: variant,
              pin: CdsDotPinPlacement.bottomEnd,
              overlap: CdsDotOverlap.circular,
              semanticLabel: label,
              child: CdsAvatar(name: label, size: CdsAvatarSize.xxl, colorScheme: CdsHue.gray),
            ),
            ExcludeSemantics(child: CdsText.body(label)),
          ]),
      ]),
    );
  }
}

class _DotSymbolDemo extends StatelessWidget {
  const _DotSymbolDemo();

  @override
  Widget build(BuildContext context) {
    return const DemoSection(
      title: 'Icon badges',
      caption: 'Sample data',
      child: CdsHStack(gap: 4, children: [
        CdsDotSymbol(
          iconName: CdsIconName.checkmark,
          pin: CdsDotPinPlacement.bottomEnd,
          overlap: CdsDotOverlap.circular,
          semanticLabel: 'Verified',
          child: CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl),
        ),
        CdsDotSymbol(
          iconName: CdsIconName.lightningBolt,
          size: CdsIconSize.xs,
          background: CdsColor.bgPositive,
          pin: CdsDotPinPlacement.topEnd,
          semanticLabel: 'Instant',
          child: CdsRemoteImage(size: CdsAvatarSize.xxl, shape: CdsShape.squircle),
        ),
      ]),
    );
  }
}

class _CodeSnippetDemo extends StatelessWidget {
  const _CodeSnippetDemo();

  @override
  Widget build(BuildContext context) {
    return const CdsVStack(gap: 3, children: [
      DemoSection(title: 'Command', child: CdsCodeSnippet('flutter pub add cds_flutter', title: 'Install')),
      DemoSection(
        title: 'Wrapped address',
        caption: 'Sample data',
        child: CdsCodeSnippet('0x52908400098527886E0F7030069857D2E4169EE7', title: 'Deposit address', wrap: true),
      ),
      DemoSection(
        title: 'Multi-line code',
        child: CdsCodeSnippet("CdsTag('New', intent: CdsTagIntent.promotional)\nCdsTag('Pending', colorScheme: CdsTagColorScheme.yellow)"),
      ),
    ]);
  }
}

class _KbdDemo extends StatelessWidget {
  const _KbdDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 2, children: [
      for (final (label, keys) in const [
        ('Search', ['⌘', 'K']),
        ('Command palette', ['Ctrl', 'Shift', 'P']),
        ('Close', ['Esc']),
        ('Next result', ['↓']),
      ])
        CdsHStack(gap: 2, children: [Expanded(child: CdsText.body(label)), CdsKbd(keys)]),
    ]);
  }
}
