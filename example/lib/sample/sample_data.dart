import 'dart:math' as math;

import 'package:cds_flutter/cds_flutter.dart';

/// Everything on the sample wallet screens is generated here. None of it is a
/// real price, balance or transaction, and the UI labels it "Sample data".
class SampleAsset {
  const SampleAsset({required this.symbol, required this.name, required this.hue, required this.holding, required this.basePrice, required this.seed});

  final String symbol;
  final String name;
  final CdsHue hue;
  final double holding;
  final double basePrice;
  final int seed;
}

const sampleAssets = [
  SampleAsset(symbol: 'BTC', name: 'Bitcoin', hue: CdsHue.orange, holding: 0.042, basePrice: 64000, seed: 1),
  SampleAsset(symbol: 'ETH', name: 'Ethereum', hue: CdsHue.indigo, holding: 1.35, basePrice: 3100, seed: 2),
  SampleAsset(symbol: 'SOL', name: 'Solana', hue: CdsHue.purple, holding: 18, basePrice: 145, seed: 3),
  SampleAsset(symbol: 'USDC', name: 'USD Coin', hue: CdsHue.blue, holding: 420, basePrice: 1, seed: 4),
];

enum SamplePeriod { day, week, month, year }

extension SamplePeriodLabel on SamplePeriod {
  String get label => switch (this) {
        SamplePeriod.day => '1D',
        SamplePeriod.week => '1W',
        SamplePeriod.month => '1M',
        SamplePeriod.year => '1Y',
      };

  Duration get step => switch (this) {
        SamplePeriod.day => const Duration(minutes: 30),
        SamplePeriod.week => const Duration(hours: 4),
        SamplePeriod.month => const Duration(days: 1),
        SamplePeriod.year => const Duration(days: 7),
      };
}

/// A deterministic random walk so screenshots and tests are stable. [epoch]
/// changes on pull-to-refresh to produce a slightly different sample.
List<CdsChartDataPoint> sampleSeries(SampleAsset asset, SamplePeriod period, {int epoch = 0}) {
  final random = math.Random(asset.seed * 97 + period.index * 13 + epoch);
  final volatility = asset.symbol == 'USDC' ? 0.0005 : 0.02;
  final end = DateTime(2026, 11, 2, 15);
  var value = asset.basePrice * (1 + (random.nextDouble() - 0.5) * 0.1);
  final points = <CdsChartDataPoint>[];
  for (var i = 47; i >= 0; i--) {
    value *= 1 + (random.nextDouble() - 0.48) * volatility;
    points.add(CdsChartDataPoint(value: value, date: end.subtract(period.step * i)));
  }
  return points;
}

double samplePrice(SampleAsset asset, {int epoch = 0}) => sampleSeries(asset, SamplePeriod.day, epoch: epoch).last.value;

double sampleChange(SampleAsset asset, {int epoch = 0}) {
  final s = sampleSeries(asset, SamplePeriod.day, epoch: epoch);
  return (s.last.value - s.first.value) / s.first.value;
}

double sampleBalance({int epoch = 0}) =>
    sampleAssets.fold(0, (sum, a) => sum + a.holding * samplePrice(a, epoch: epoch));

String formatUsd(double v) {
  final fixed = v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '\$$whole.${parts[1]}';
}

/// Crypto amounts without trailing zeros: 50 not 50.0, 0.25 not 0.250.
String formatAmount(double v) {
  final s = v.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '');
  return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
}

String formatPercent(double v) => '${v >= 0 ? '+' : ''}${(v * 100).toStringAsFixed(2)}%';

enum SampleTxStatus { completed, pending, failed }

class SampleTransaction {
  const SampleTransaction({required this.title, required this.asset, required this.amount, required this.date, required this.status, required this.incoming});

  final String title;
  final SampleAsset asset;
  final double amount;
  final String date;
  final SampleTxStatus status;
  final bool incoming;
}

final sampleTransactions = [
  SampleTransaction(title: 'Bought Bitcoin', asset: sampleAssets[0], amount: 0.01, date: 'Today, 09:12', status: SampleTxStatus.completed, incoming: true),
  SampleTransaction(title: 'Sent USD Coin', asset: sampleAssets[3], amount: 50, date: 'Today, 08:40', status: SampleTxStatus.pending, incoming: false),
  SampleTransaction(title: 'Received Ethereum', asset: sampleAssets[1], amount: 0.25, date: 'Yesterday', status: SampleTxStatus.completed, incoming: true),
  SampleTransaction(title: 'Sent Solana', asset: sampleAssets[2], amount: 3, date: 'Oct 29', status: SampleTxStatus.failed, incoming: false),
  SampleTransaction(title: 'Bought Ethereum', asset: sampleAssets[1], amount: 0.4, date: 'Oct 21', status: SampleTxStatus.completed, incoming: true),
];

/// Lets the settings tab force a data state so loading, empty and error
/// screens can be inspected.
enum SampleDataState { live, loading, empty, error }
