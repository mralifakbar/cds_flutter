import 'package:cds_flutter/cds_flutter.dart';
// The feedback barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Banners, loading placeholders, progress and spinners. All copy and numbers
/// are sample data.
final CdsDemoCategory feedbackCategory = CdsDemoCategory(
  title: 'Feedback',
  description: 'Banners, skeleton placeholders, progress bars and spinners.',
  icon: CdsIconName.megaphone,
  demos: [
    CdsDemo(
      title: 'CdsBanner',
      description: 'Every variant and style, with actions and a working dismiss.',
      docPath: 'doc/components/CdsBanner.md',
      builder: (_) => const _BannerDemo(),
    ),
    CdsDemo(
      title: 'CdsFallback',
      description: 'Skeleton shapes. Static by default; the shimmer runs only while loading.',
      docPath: 'doc/components/CdsFallback.md',
      builder: (_) => const _FallbackDemo(),
    ),
    CdsDemo(
      title: 'CdsProgressBar',
      description: 'Bars that animate from their current value, with fixed and floating labels.',
      docPath: 'doc/components/CdsProgressBar.md',
      builder: (_) => const _ProgressDemo(),
    ),
    CdsDemo(
      title: 'CdsSpinner',
      description: 'Indeterminate loading in two sizes.',
      docPath: 'doc/components/CdsSpinner.md',
      builder: (_) => const _SpinnerDemo(),
    ),
  ],
);

class _BannerDemo extends StatefulWidget {
  const _BannerDemo();

  @override
  State<_BannerDemo> createState() => _BannerDemoState();
}

class _BannerDemoState extends State<_BannerDemo> {
  int _key = 0;
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    Widget action(String label) => CdsButton(
          label: label,
          size: CdsButtonSize.xs,
          transparent: true,
          flush: CdsFlush.start,
          onPress: () {},
        );
    return DemoSection(
      title: 'Banners',
      caption: 'Sample data',
      child: CdsVStack(gap: 2, children: [
        CdsBanner(
          key: ValueKey(_key),
          variant: CdsBannerVariant.warning,
          startIcon: CdsIconName.warning,
          startIconAccessibilityLabel: 'Warning',
          title: 'Verify your identity',
          description: 'Sending is paused until you finish verification.',
          primaryAction: action('Verify now'),
          showDismiss: true,
          onClose: () => setState(() => _dismissed = true),
        ),
        if (_dismissed)
          CdsButton(
            label: 'Show the warning again',
            variant: CdsButtonVariant.secondary,
            onPress: () => setState(() {
              _dismissed = false;
              _key++;
            }),
          ),
        CdsBanner(
          variant: CdsBannerVariant.error,
          startIcon: CdsIconName.error,
          startIconAccessibilityLabel: 'Error',
          title: 'Card declined',
          description: 'Your bank declined the payment. Add another card to buy Bitcoin.',
          primaryAction: action('Add a card'),
          secondaryAction: action('Contact support'),
        ),
        const CdsBanner(
          variant: CdsBannerVariant.informational,
          startIcon: CdsIconName.info,
          description: 'Ethereum transfers may be slower than usual.',
          label: 'Updated 4 min ago',
          styleVariant: CdsBannerStyleVariant.inline,
        ),
        const CdsBanner(
          variant: CdsBannerVariant.promotional,
          startIcon: CdsIconName.megaphone,
          title: 'Recurring buys are here',
          description: 'Buy a fixed amount every week.',
          styleVariant: CdsBannerStyleVariant.global,
        ),
      ]),
    );
  }
}

class _FallbackDemo extends StatefulWidget {
  const _FallbackDemo();

  @override
  State<_FallbackDemo> createState() => _FallbackDemoState();
}

class _FallbackDemoState extends State<_FallbackDemo> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Asset row placeholder',
        caption: 'Toggle loading to swap in sample content.',
        child: CdsVStack(gap: 2, alignItems: CrossAxisAlignment.start, children: [
          CdsButton(
            label: _loading ? 'Show content' : 'Show loading',
            variant: CdsButtonVariant.secondary,
            onPress: () => setState(() => _loading = !_loading),
          ),
          if (_loading)
            const CdsHStack(gap: 2, children: [
              CdsFallback(width: 40, height: 40, shape: CdsFallbackShape.circle, shimmer: true),
              CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
                CdsFallback(width: 140, height: 16, rectWidthVariant: 0, shimmer: true, accessibilityLabel: null),
                CdsFallback(width: 90, height: 12, rectWidthVariant: 3, shimmer: true, accessibilityLabel: null),
              ]),
            ])
          else
            const CdsHStack(gap: 2, children: [
              CdsBox(width: 40, height: 40, background: CdsColor.bgSecondary, borderRadius: 1000),
              CdsVStack(gap: 0.5, alignItems: CrossAxisAlignment.start, children: [
                CdsText.headline('Bitcoin'),
                CdsText.label2('Sample data: 0.0421 BTC', color: CdsColor.fgMuted),
              ]),
            ]),
          const CdsHStack(gap: 1, children: [
            CdsFallback(width: 48, height: 48, shape: CdsFallbackShape.square),
            CdsFallback(width: 48, height: 48, shape: CdsFallbackShape.squircle),
            CdsFallback(width: 48, height: 48, shape: CdsFallbackShape.circle),
          ]),
        ]),
      );
}

class _ProgressDemo extends StatefulWidget {
  const _ProgressDemo();

  @override
  State<_ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<_ProgressDemo> {
  double _progress = 0.3;

  void _step(double delta) => setState(() => _progress = (_progress + delta).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).roundToDouble();
    return DemoSection(
      title: 'Progress',
      caption: 'Sample data. Tap quickly: each change starts from where the bar is.',
      child: CdsVStack(gap: 3, children: [
        CdsHStack(gap: 1, children: [
          CdsButton(label: 'Less', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => _step(-0.2)),
          CdsButton(label: 'More', size: CdsButtonSize.s, onPress: () => _step(0.2)),
        ]),
        CdsProgressBar(progress: _progress, accessibilityLabel: 'Upload progress'),
        CdsProgressBar(progress: _progress, weight: CdsProgressWeight.heavy, color: CdsColor.bgPositive),
        CdsProgressBarWithFixedLabels(
          progress: _progress,
          startLabel: CdsProgressBarLabel(percent),
          endLabel: const CdsProgressBarLabel(100),
        ),
        CdsProgressBarWithFixedLabels(
          progress: _progress,
          labelPlacement: CdsProgressLabelPlacement.below,
          startLabel: CdsProgressBarLabel(percent, render: (v, _) => CdsText.label2('${v.round()} of 100 USDC saved')),
        ),
        CdsProgressBarWithFloatLabel(progress: _progress, label: CdsProgressBarLabel(percent)),
      ]),
    );
  }
}

class _SpinnerDemo extends StatelessWidget {
  const _SpinnerDemo();

  @override
  Widget build(BuildContext context) => const DemoSection(
        title: 'Spinners',
        child: CdsHStack(gap: 3, children: [
          CdsSpinner(),
          CdsSpinner(size: CdsSpinnerSize.large),
          CdsSpinner(color: CdsColor.fgMuted),
        ]),
      );
}
