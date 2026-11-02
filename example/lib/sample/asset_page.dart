import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

import 'flows.dart';
import 'sample_data.dart';
import 'sample_state.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({super.key, required this.asset});

  final SampleAsset asset;

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  bool _watching = false;

  @override
  Widget build(BuildContext context) {
    final state = SampleWalletScope.of(context);
    final asset = widget.asset;
    final price = samplePrice(asset, epoch: state.epoch);
    final change = sampleChange(asset, epoch: state.epoch);
    return CdsScaffold(
      header: CdsTopNavBar(
        start: CdsNavBarIconButton(CdsIconName.backArrow, semanticLabel: 'Back', onPress: () => Navigator.of(context).pop()),
        end: CdsNavBarIconButton(
          CdsIconName.star,
          semanticLabel: _watching ? 'Remove from watchlist' : 'Add to watchlist',
          active: _watching,
          onPress: () {
            setState(() => _watching = !_watching);
            showCdsToast(context, _watching ? '${asset.name} added to watchlist' : '${asset.name} removed from watchlist');
          },
        ),
        child: CdsNavigationTitle(asset.name),
      ),
      footer: CdsStickyFooter(
        child: CdsButton(label: 'Buy ${asset.name}', block: true, onPress: () => openBuyFlow(context, asset: asset)),
      ),
      body: CdsVStack(
        paddingTop: 2,
        gap: 3,
        children: [
          CdsBox(
            paddingX: 3,
            child: CdsVStack(gap: 0.5, children: [
              const CdsTag('Sample data', colorScheme: CdsTagColorScheme.yellow),
              CdsRollingNumber(value: price, format: const CdsNumberFormat.currency(), font: CdsFont.title1),
              CdsText.label1(
                '${formatPercent(change)} today',
                color: change >= 0 ? CdsColor.fgPositive : CdsColor.fgNegative,
              ),
            ]),
          ),
          CdsSparklineInteractive<SamplePeriod>(
            data: {for (final p in SamplePeriod.values) p: sampleSeries(asset, p, epoch: state.epoch)},
            periods: [for (final p in SamplePeriod.values) CdsSparklinePeriod(label: p.label, value: p)],
            defaultPeriod: SamplePeriod.week,
            strokeColor: change >= 0 ? CdsColor.fgPositive : CdsColor.fgNegative,
            formatDate: (date, period) => '${date.day}/${date.month}',
            formatHoverPrice: formatUsd,
            formatMinMaxLabel: formatUsd,
            height: 240,
          ),
          const CdsSectionHeader(title: 'Your balance'),
          CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            media: CdsAvatar(name: asset.name, colorScheme: asset.hue),
            title: '${formatAmount(asset.holding)} ${asset.symbol}',
            description: 'Available to send',
            detail: formatUsd(asset.holding * price),
          ),
          CdsBox(
            paddingX: 3,
            child: CdsBanner(
              variant: CdsBannerVariant.informational,
              startIcon: CdsIconName.info,
              title: 'Sample screen',
              description: 'Prices, balances and charts here are generated for the demo and change when you pull to refresh on Home.',
            ),
          ),
        ],
      ),
    );
  }
}
