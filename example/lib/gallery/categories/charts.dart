import 'dart:math' as math;

import 'package:cds_flutter/cds_flutter.dart';
// The charts and numbers barrels are exported from cds_flutter.dart once the maintainer adds them.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Chart and number demos. Every series is generated sample data.
final CdsDemoCategory chartsCategory = CdsDemoCategory(
  title: 'Charts',
  description: 'Sparklines, line, area and bar charts, scrubbing, period selection and rolling numbers.',
  icon: CdsIconName.chartLine,
  demos: [
    CdsDemo(
      title: 'CdsSparklineInteractive',
      description: 'Period tabs switch datasets; scrubbing updates the header with the value and date.',
      docPath: 'doc/components/CdsSparklineInteractive.md',
      builder: (_) => const _SparklineInteractiveDemo(),
    ),
    CdsDemo(
      title: 'CdsSparklineInteractiveHeader',
      description: 'Label, tabular price and change line that updates while scrubbing.',
      docPath: 'doc/components/CdsSparklineInteractiveHeader.md',
      builder: (_) => const _SparklineInteractiveDemo(),
    ),
    CdsDemo(
      title: 'CdsSparkline',
      description: 'Small trend lines for list rows, with optional area fills.',
      docPath: 'doc/components/CdsSparkline.md',
      builder: (_) => const _SparklineDemo(),
    ),
    CdsDemo(
      title: 'CdsSparklineGradient',
      description: 'A sparkline whose stroke darkens from left to right in light mode.',
      docPath: 'doc/components/CdsSparklineGradient.md',
      builder: (_) => const _SparklineGradientDemo(),
    ),
    CdsDemo(
      title: 'CdsLineChart',
      description: 'Line chart with a period selector, scrubber and live value readout.',
      docPath: 'doc/components/CdsLineChart.md',
      builder: (_) => const _LineChartDemo(),
    ),
    CdsDemo(
      title: 'CdsAreaChart',
      description: 'Stacked areas with outlines and a legend.',
      docPath: 'doc/components/CdsAreaChart.md',
      builder: (_) => const _AreaChartDemo(),
    ),
    CdsDemo(
      title: 'CdsBarChart',
      description: 'Grouped or stacked bars with category labels.',
      docPath: 'doc/components/CdsBarChart.md',
      builder: (_) => const _BarChartDemo(),
    ),
    CdsDemo(
      title: 'CdsPercentageBarChart',
      description: 'Part-to-whole segments with gaps and rounded ends.',
      docPath: 'doc/components/CdsPercentageBarChart.md',
      builder: (_) => const _PercentageBarDemo(),
    ),
    CdsDemo(
      title: 'CdsCartesianChart',
      description: 'Bars, a line, a reference line and a point composed in one frame.',
      docPath: 'doc/components/CdsCartesianChart.md',
      builder: (_) => const _CartesianDemo(),
    ),
    CdsDemo(
      title: 'CdsXAxis',
      description: 'Tick labels, grid lines, tick marks and an axis title.',
      docPath: 'doc/components/CdsXAxis.md',
      builder: (_) => const _AxesDemo(),
    ),
    CdsDemo(
      title: 'CdsYAxis',
      description: 'Value ticks with a formatter and grid lines.',
      docPath: 'doc/components/CdsYAxis.md',
      builder: (_) => const _AxesDemo(),
    ),
    CdsDemo(
      title: 'CdsReferenceLine',
      description: 'Horizontal and vertical markers with labels.',
      docPath: 'doc/components/CdsReferenceLine.md',
      builder: (_) => const _CartesianDemo(),
    ),
    CdsDemo(
      title: 'CdsPoint',
      description: 'Labeled markers at data coordinates.',
      docPath: 'doc/components/CdsPoint.md',
      builder: (_) => const _CartesianDemo(),
    ),
    CdsDemo(
      title: 'CdsScrubber',
      description: 'Beacons with series labels that follow the scrubbed position.',
      docPath: 'doc/components/CdsScrubber.md',
      builder: (_) => const _ScrubberDemo(),
    ),
    CdsDemo(
      title: 'CdsLegend',
      description: 'Series names with their colors and shapes.',
      docPath: 'doc/components/CdsLegend.md',
      builder: (_) => const _AreaChartDemo(),
    ),
    CdsDemo(
      title: 'CdsPeriodSelector',
      description: 'Period tabs with a sliding pill and a live tab.',
      docPath: 'doc/components/CdsPeriodSelector.md',
      builder: (_) => const _PeriodSelectorDemo(),
    ),
    CdsDemo(
      title: 'CdsRollingNumber',
      description: 'Digits roll from the old value to the new one, with a color pulse on change.',
      docPath: 'doc/components/CdsRollingNumber.md',
      builder: (_) => const _RollingNumberDemo(),
    ),
  ],
);

const _sampleCaption = 'Sample data';

/// A deterministic random walk so every run shows the same sample series.
List<double> _walk(int seed, int count, {double start = 100, double volatility = 0.03}) {
  final random = math.Random(seed);
  var value = start;
  return [for (var i = 0; i < count; i++) value = math.max(1, value * (1 + (random.nextDouble() - 0.5) * volatility))];
}

String _money(double v) {
  final fixed = v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '\$$whole.${parts[1]}';
}

const _periodTabs = [
  CdsPeriodSelectorTab(id: '1H', label: '1H'),
  CdsPeriodSelectorTab(id: '1D', label: '1D'),
  CdsPeriodSelectorTab(id: '1W', label: '1W'),
  CdsPeriodSelectorTab(id: '1M', label: '1M'),
  CdsPeriodSelectorTab(id: '1Y', label: '1Y'),
];

final Map<String, List<double>> _periodSeries = {
  '1H': _walk(1, 60, start: 1180, volatility: 0.004),
  '1D': _walk(2, 96, start: 1150, volatility: 0.01),
  '1W': _walk(3, 84, start: 1100, volatility: 0.02),
  '1M': _walk(4, 120, start: 980, volatility: 0.03),
  '1Y': _walk(5, 52, start: 700, volatility: 0.08),
};

const Map<String, Duration> _periodStep = {
  '1H': Duration(minutes: 1),
  '1D': Duration(minutes: 15),
  '1W': Duration(hours: 2),
  '1M': Duration(hours: 6),
  '1Y': Duration(days: 7),
};

final DateTime _sampleEnd = DateTime(2025, 6, 30, 16);

List<CdsChartDataPoint> _timed(String period) {
  final values = _periodSeries[period]!;
  final step = _periodStep[period]!;
  return [
    for (var i = 0; i < values.length; i++)
      CdsChartDataPoint(value: values[i], date: _sampleEnd.subtract(step * (values.length - 1 - i))),
  ];
}

String _formatDate(DateTime d, String period) {
  String two(int v) => v.toString().padLeft(2, '0');
  return switch (period) {
    '1H' || '1D' => '${two(d.hour)}:${two(d.minute)}',
    '1W' || '1M' => '${d.month}/${d.day}',
    _ => '${d.month}/${d.year % 100}',
  };
}

CdsSparklineInteractiveSubHead _change(List<double> values, String accessory) {
  final delta = values.last - values.first;
  final up = delta >= 0;
  return CdsSparklineInteractiveSubHead(
    percent: '${(delta.abs() / values.first * 100).toStringAsFixed(2)}%',
    priceChange: _money(delta.abs()),
    sign: up ? CdsSparklineInteractiveHeaderSignVariant.positive : CdsSparklineInteractiveHeaderSignVariant.negative,
    variant: up ? CdsSparklineInteractiveHeaderVariant.positive : CdsSparklineInteractiveHeaderVariant.negative,
    accessoryText: accessory,
  );
}

class _SparklineInteractiveDemo extends StatefulWidget {
  const _SparklineInteractiveDemo();

  @override
  State<_SparklineInteractiveDemo> createState() => _SparklineInteractiveDemoState();
}

class _SparklineInteractiveDemoState extends State<_SparklineInteractiveDemo> {
  final _header = CdsSparklineInteractiveHeaderController();
  late final Map<String, List<CdsChartDataPoint>> _data = {for (final t in _periodTabs) t.id: _timed(t.id)};
  String _period = '1D';

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = _periodSeries[_period]!;
    return DemoSection(
      title: 'Sample asset price',
      caption: '$_sampleCaption. Drag across the chart to read values.',
      child: CdsSparklineInteractive<String>(
        data: _data,
        periods: [for (final t in _periodTabs) CdsSparklinePeriod(label: t.label, value: t.id)],
        defaultPeriod: '1D',
        gutter: 0,
        strokeColor: values.last >= values.first ? CdsColor.fgPositive : CdsColor.fgNegative,
        formatDate: _formatDate,
        formatHoverDate: _formatDate,
        formatHoverPrice: _money,
        formatMinMaxLabel: _money,
        onPeriodChanged: (p) => setState(() => _period = p),
        onScrub: (p) => _header.update(
          title: _money(p.point.value),
          subHead: _change([values.first, p.point.value], _formatDate(p.point.date, p.period)),
        ),
        onScrubEnd: _header.reset,
        headerNode: CdsSparklineInteractiveHeader(
          controller: _header,
          defaultLabel: 'Sample asset',
          defaultTitle: _money(values.last),
          defaultSubHead: _change(values, cdsPeriodLabelMap[_period] ?? _period),
        ),
      ),
    );
  }
}

class _SparklineDemo extends StatelessWidget {
  const _SparklineDemo();

  @override
  Widget build(BuildContext context) {
    Widget row(String name, int seed) {
      final values = _walk(seed, 48);
      final up = values.last >= values.first;
      return CdsHStack(
        gap: 2,
        alignItems: CrossAxisAlignment.center,
        children: [
          Expanded(child: CdsText.headline(name)),
          CdsSparkline(data: values, width: 64, height: 20, color: up ? CdsColor.fgPositive : CdsColor.fgNegative),
          SizedBox(width: 72, child: CdsText.label2(_money(values.last), tabularNumbers: true, align: TextAlign.end)),
        ],
      );
    }

    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'List rows',
          caption: _sampleCaption,
          child: CdsVStack(
            gap: 2,
            children: [row('Sample asset A', 11), row('Sample asset B', 12), row('Sample asset C', 13)],
          ),
        ),
        DemoSection(
          title: 'Fill types',
          caption: _sampleCaption,
          child: CdsVStack(
            gap: 2,
            children: [
              for (final type in CdsSparklineFillType.values)
                CdsSparkline(data: _walk(21, 60), height: 64, fill: true, fillType: type, color: CdsColor.fgPrimary),
            ],
          ),
        ),
      ],
    );
  }
}

class _SparklineGradientDemo extends StatelessWidget {
  const _SparklineGradientDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Gradient stroke',
      caption: _sampleCaption,
      child: CdsSparklineGradient(data: _walk(31, 60), height: 80, fill: true, color: CdsColor.fgPositive),
    );
  }
}

class _LineChartDemo extends StatefulWidget {
  const _LineChartDemo();

  @override
  State<_LineChartDemo> createState() => _LineChartDemoState();
}

class _LineChartDemoState extends State<_LineChartDemo> {
  String _period = '1W';
  int? _index;

  @override
  Widget build(BuildContext context) {
    final values = _periodSeries[_period]!;
    final points = _timed(_period);
    final shown = _index == null ? values.last : values[_index!];
    final label = _index == null ? 'Latest' : _formatDate(points[_index!].date, _period);
    return DemoSection(
      title: 'Price over time',
      caption: '$_sampleCaption. Switch periods or drag to scrub.',
      child: CdsVStack(
        gap: 1,
        children: [
          CdsText.label2(label, color: CdsColor.fgMuted),
          CdsText.title2(_money(shown), tabularNumbers: true),
          CdsLineChart(
            height: 220,
            showArea: true,
            enableScrubbing: true,
            onScrubberPositionChange: (i) => setState(() => _index = i),
            series: [
              CdsLineSeries(
                id: 'price',
                label: 'Sample asset',
                data: values,
                color: values.last >= values.first ? CdsColor.fgPositive : CdsColor.fgNegative,
              ),
            ],
            getScrubberAccessibilityLabel: (i) => '${_formatDate(points[i].date, _period)}, ${_money(values[i])}',
            children: const [CdsScrubber(hideBeaconLabels: true)],
          ),
          CdsPeriodSelector(
            tabs: _periodTabs,
            activeTab: _period,
            onChange: (p) => setState(() {
              _period = p;
              _index = null;
            }),
          ),
        ],
      ),
    );
  }
}

class _AreaChartDemo extends StatelessWidget {
  const _AreaChartDemo();

  @override
  Widget build(BuildContext context) {
    final spectrum = context.cds.spectrum;
    return DemoSection(
      title: 'Stacked allocation',
      caption: _sampleCaption,
      child: CdsAreaChart(
        height: 220,
        stacked: true,
        showLines: true,
        type: CdsChartAreaType.gradient,
        curve: CdsChartCurve.monotone,
        legend: const CdsLegend(),
        series: [
          CdsAreaSeries(
            id: 'a',
            label: 'Series A',
            data: _walk(41, 24, start: 40),
            dangerouslySetColor: spectrum.of(CdsHue.blue, 60),
          ),
          CdsAreaSeries(
            id: 'b',
            label: 'Series B',
            data: _walk(42, 24, start: 30),
            dangerouslySetColor: spectrum.of(CdsHue.teal, 50),
          ),
          CdsAreaSeries(
            id: 'c',
            label: 'Series C',
            data: _walk(43, 24, start: 20),
            dangerouslySetColor: spectrum.of(CdsHue.purple, 50),
          ),
        ],
      ),
    );
  }
}

class _BarChartDemo extends StatefulWidget {
  const _BarChartDemo();

  @override
  State<_BarChartDemo> createState() => _BarChartDemoState();
}

class _BarChartDemoState extends State<_BarChartDemo> {
  bool _stacked = false;
  String _set = 'A';

  @override
  Widget build(BuildContext context) {
    final seed = _set == 'A' ? 51 : 61;
    final random = math.Random(seed);
    List<double> week() => [for (var i = 0; i < 7; i++) (random.nextInt(80) + 10).toDouble()];
    return DemoSection(
      title: 'Weekly volume',
      caption: '$_sampleCaption. Toggle stacking or switch datasets.',
      child: CdsVStack(
        gap: 2,
        children: [
          CdsBarChart(
            height: 220,
            stacked: _stacked,
            stackGap: _stacked ? 2 : 0,
            showXAxis: true,
            showYAxis: true,
            legend: const CdsLegend(),
            xAxis: const CdsAxisConfig(data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']),
            yAxisStyle: const CdsYAxis(showGrid: true),
            series: [
              CdsChartSeries(id: 'buys', label: 'Buys', data: week(), color: CdsColor.fgPositive),
              CdsChartSeries(id: 'sells', label: 'Sells', data: week(), color: CdsColor.fgNegative),
            ],
          ),
          CdsHStack(
            wrap: true,
            gap: 1,
            children: [
              CdsButton(
                label: _stacked ? 'Show grouped' : 'Show stacked',
                size: CdsButtonSize.s,
                variant: CdsButtonVariant.secondary,
                onPress: () => setState(() => _stacked = !_stacked),
              ),
              CdsButton(
                label: 'Next dataset',
                size: CdsButtonSize.s,
                variant: CdsButtonVariant.secondary,
                onPress: () => setState(() => _set = _set == 'A' ? 'B' : 'A'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PercentageBarDemo extends StatelessWidget {
  const _PercentageBarDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Order book split',
          caption: _sampleCaption,
          child: CdsPercentageBarChart(
            height: 16,
            stackGap: 2,
            borderRadius: 1000,
            legend: const CdsLegend(),
            series: [
              CdsPercentageBarSeries.single(id: 'buy', value: 62, label: 'Buy 62%', color: CdsColor.fgPositive),
              CdsPercentageBarSeries.single(id: 'sell', value: 38, label: 'Sell 38%', color: CdsColor.fgNegative),
            ],
          ),
        ),
        DemoSection(
          title: 'Quarterly mix',
          caption: _sampleCaption,
          child: const CdsPercentageBarChart(
            height: 120,
            stackGap: 2,
            showYAxis: true,
            yAxis: CdsAxisConfig(data: ['Q1', 'Q2', 'Q3'], categoryPadding: 0.45),
            yAxisStyle: CdsYAxis(position: CdsYAxisPosition.left),
            series: [
              CdsPercentageBarSeries(id: 'a', data: [40, 25, 20], label: 'A', color: CdsColor.fgPositive),
              CdsPercentageBarSeries(id: 'b', data: [35, 60, 30], label: 'B', color: CdsColor.fgWarning),
              CdsPercentageBarSeries(id: 'c', data: [25, 15, 50], label: 'C', color: CdsColor.fgMuted),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartesianDemo extends StatelessWidget {
  const _CartesianDemo();

  @override
  Widget build(BuildContext context) {
    final volume = _walk(71, 12, start: 50, volatility: 0.3);
    final price = _walk(72, 12, start: 60, volatility: 0.08);
    var high = 0;
    for (var i = 1; i < price.length; i++) {
      if (price[i] > price[high]) high = i;
    }
    return DemoSection(
      title: 'Composed chart',
      caption: _sampleCaption,
      child: CdsCartesianChart(
        height: 240,
        xAxis: const CdsAxisConfig(scaleType: CdsAxisScaleType.band, includeBaseline: true),
        yAxis: const CdsAxisConfig(includeBaseline: true),
        series: [
          CdsChartSeries(id: 'volume', label: 'Volume', data: volume, color: CdsColor.bgLineHeavy),
          CdsChartSeries(id: 'price', label: 'Price', data: price, color: CdsColor.fgPrimary),
        ],
        legend: const CdsLegend(),
        children: [
          const CdsYAxis(showGrid: true),
          const CdsBarPlot(seriesIds: ['volume']),
          const CdsLine(seriesId: 'price', curve: CdsChartCurve.monotone),
          const CdsReferenceLine(dataY: 50, label: 'Target', labelElevated: true),
          const CdsReferenceLine(dataX: 6, label: 'Event'),
          CdsPoint(dataX: high.toDouble(), dataY: price[high], label: 'High', labelPosition: CdsPointLabelPosition.top),
        ],
      ),
    );
  }
}

class _AxesDemo extends StatelessWidget {
  const _AxesDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Axes',
      caption: _sampleCaption,
      child: CdsLineChart(
        height: 240,
        showXAxis: true,
        showYAxis: true,
        points: true,
        xAxis: const CdsAxisConfig(data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']),
        xAxisStyle: const CdsXAxis(showGrid: true, showLine: true, showTickMarks: true, label: 'Month'),
        yAxisStyle: CdsYAxis(showGrid: true, tickLabelFormatter: (v) => '\$${v.toInt()}'),
        series: [CdsLineSeries(id: 'a', data: _walk(81, 6, start: 40, volatility: 0.4))],
      ),
    );
  }
}

class _ScrubberDemo extends StatelessWidget {
  const _ScrubberDemo();

  @override
  Widget build(BuildContext context) {
    final spectrum = context.cds.spectrum;
    return DemoSection(
      title: 'Two series',
      caption: '$_sampleCaption. Drag, or focus the chart and use the arrow keys.',
      child: CdsLineChart(
        height: 240,
        enableScrubbing: true,
        series: [
          CdsLineSeries(
            id: 'a',
            label: 'Series A',
            data: _walk(91, 30),
            dangerouslySetColor: spectrum.of(CdsHue.blue, 60),
          ),
          CdsLineSeries(
            id: 'b',
            label: 'Series B',
            data: _walk(92, 30),
            dangerouslySetColor: spectrum.of(CdsHue.orange, 50),
          ),
        ],
        children: [CdsScrubber(labelBuilder: (i) => 'Day ${i + 1}')],
      ),
    );
  }
}

class _PeriodSelectorDemo extends StatefulWidget {
  const _PeriodSelectorDemo();

  @override
  State<_PeriodSelectorDemo> createState() => _PeriodSelectorDemoState();
}

class _PeriodSelectorDemoState extends State<_PeriodSelectorDemo> {
  String _period = '1D';

  @override
  Widget build(BuildContext context) {
    final live = _period == 'LIVE';
    return DemoSection(
      title: 'Periods',
      caption: 'Selected: $_period',
      child: CdsPeriodSelector(
        activeBackground: live ? CdsColor.bgNegativeWash : CdsColor.bgPrimaryWash,
        activeColor: live ? CdsColor.fgNegative : CdsColor.fgPrimary,
        tabs: const [
          CdsPeriodSelectorTab(id: 'LIVE', label: 'LIVE', labelWidget: CdsLiveTabLabel(), semanticLabel: 'Live'),
          ..._periodTabs,
        ],
        activeTab: _period,
        onChange: (p) => setState(() => _period = p),
      ),
    );
  }
}

class _RollingNumberDemo extends StatefulWidget {
  const _RollingNumberDemo();

  @override
  State<_RollingNumberDemo> createState() => _RollingNumberDemoState();
}

class _RollingNumberDemoState extends State<_RollingNumberDemo> {
  static final List<double> _samples = _walk(101, 12, start: 12345.67, volatility: 0.08);
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final value = _samples[_index];
    final change = value - _samples[_index - 1];
    final up = change >= 0;
    return DemoSection(
      title: 'Rolling value',
      caption: _sampleCaption,
      child: CdsVStack(
        gap: 2,
        children: [
          CdsRollingNumber(
            value: value,
            font: CdsFont.display3,
            format: const CdsNumberFormat.currency(),
            colorPulseOnUpdate: true,
          ),
          CdsRollingNumber(
            value: change.abs(),
            color: up ? CdsColor.fgPositive : CdsColor.fgNegative,
            format: const CdsNumberFormat.currency(),
            prefix: up ? '+' : '-',
            semanticLabelPrefix: up ? 'up' : 'down',
          ),
          CdsRollingNumber(
            value: change / _samples[_index - 1],
            format: const CdsNumberFormat.percent(maximumFractionDigits: 2, minimumFractionDigits: 2),
            digitTransitionVariant: CdsDigitTransitionVariant.single,
          ),
          CdsButton(
            label: 'Next sample value',
            variant: CdsButtonVariant.secondary,
            onPress: () => setState(() => _index = _index == _samples.length - 1 ? 1 : _index + 1),
          ),
        ],
      ),
    );
  }
}
