import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

import 'asset_page.dart';
import 'flows.dart';
import 'sample_data.dart';
import 'sample_state.dart';
import 'wallet_shell.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SampleWalletScope.of(context);
    return Column(children: [
      SampleHeader(title: 'Sample wallet', onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).maybePop() : null),
      Expanded(
        child: CdsRefreshControl(
          onRefresh: state.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: context.cds.space(4)),
            children: [
              const _Balance(),
              const _Actions(),
              const CdsSectionHeader(title: 'Assets'),
              _AssetList(state: state),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _Balance extends StatelessWidget {
  const _Balance();

  @override
  Widget build(BuildContext context) {
    final state = SampleWalletScope.of(context);
    final balance = sampleBalance(epoch: state.epoch);
    final series = {
      for (final p in SamplePeriod.values)
        p: _portfolioSeries(p, state.epoch),
    };
    return CdsVStack(
      paddingTop: 1,
      gap: 1,
      children: [
        CdsBox(
          paddingX: 3,
          child: CdsVStack(gap: 0.5, children: [
            const CdsText.label2('Total balance', color: CdsColor.fgMuted),
            if (state.hideBalances)
              const CdsText.display3('Hidden', semanticsLabel: 'Balance hidden')
            else
              CdsRollingNumber(value: balance, format: const CdsNumberFormat.currency(), font: CdsFont.display3),
          ]),
        ),
        CdsSparklineInteractive<SamplePeriod>(
          data: series,
          periods: [for (final p in SamplePeriod.values) CdsSparklinePeriod(label: p.label, value: p)],
          defaultPeriod: SamplePeriod.day,
          formatDate: (date, period) => period == SamplePeriod.day
              ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
              : '${date.day}/${date.month}',
          formatHoverPrice: formatUsd,
          formatMinMaxLabel: formatUsd,
          height: 200,
        ),
      ],
    );
  }

  List<CdsChartDataPoint> _portfolioSeries(SamplePeriod period, int epoch) {
    final parts = [for (final a in sampleAssets) sampleSeries(a, period, epoch: epoch)];
    return [
      for (var i = 0; i < parts.first.length; i++)
        CdsChartDataPoint(
          value: [for (var j = 0; j < sampleAssets.length; j++) parts[j][i].value * sampleAssets[j].holding].reduce((a, b) => a + b),
          date: parts.first[i].date,
        ),
    ];
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return CdsBox(
      paddingX: 3,
      paddingY: 2,
      child: Row(children: [
        Expanded(child: CdsButton(label: 'Buy', block: true, size: CdsButtonSize.m, onPress: () => openBuyFlow(context))),
        SizedBox(width: context.cds.space(1)),
        Expanded(child: CdsButton(label: 'Send', block: true, size: CdsButtonSize.m, variant: CdsButtonVariant.secondary, onPress: () => openSendFlow(context))),
        SizedBox(width: context.cds.space(1)),
        Expanded(child: CdsButton(label: 'Receive', block: true, size: CdsButtonSize.m, variant: CdsButtonVariant.secondary, onPress: () => openReceiveFlow(context))),
      ]),
    );
  }
}

class _AssetList extends StatelessWidget {
  const _AssetList({required this.state});

  final SampleWalletState state;

  @override
  Widget build(BuildContext context) {
    switch (state.dataState) {
      case SampleDataState.loading:
        return Column(children: [
          for (var i = 0; i < 4; i++)
            CdsListCellFallback(title: true, description: true, detail: true, subdetail: true, media: CdsCellMediaType.avatar, rectWidthVariant: i),
        ]);
      case SampleDataState.empty:
        return CdsBox(
          paddingY: 3,
          child: CdsEmptyState(
            icon: CdsIconName.wallet,
            title: 'No assets yet',
            description: 'Crypto you buy or receive shows up here.',
            primaryAction: 'Buy crypto',
            onPrimaryActionPress: () => openBuyFlow(context),
          ),
        );
      case SampleDataState.error:
        return CdsBox(
          paddingY: 3,
          child: CdsEmptyState(
            variant: CdsEmptyStateVariant.error,
            icon: CdsIconName.warning,
            title: "Couldn't load your assets",
            description: 'Check your connection, then try again.',
            primaryAction: 'Try again',
            onPrimaryActionPress: () => state.setDataState(SampleDataState.live),
          ),
        );
      case SampleDataState.live:
        return Column(children: [
          for (final asset in sampleAssets)
            Builder(builder: (context) {
              final price = samplePrice(asset, epoch: state.epoch);
              final change = sampleChange(asset, epoch: state.epoch);
              return CdsListCell(
                spacingVariant: CdsCellSpacingVariant.condensed,
                media: CdsAvatar(name: asset.name, colorScheme: asset.hue),
                title: asset.name,
                description: '${formatAmount(asset.holding)} ${asset.symbol}',
                detail: state.hideBalances ? 'Hidden' : formatUsd(asset.holding * price),
                subdetail: formatPercent(change),
                variant: change >= 0 ? CdsCellDetailVariant.positive : CdsCellDetailVariant.negative,
                accessory: CdsCellAccessoryType.arrow,
                onPress: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => SampleWalletScope(state: state, child: CdsToastHost(child: AssetPage(asset: asset))),
                )),
              );
            }),
        ]);
    }
  }
}
