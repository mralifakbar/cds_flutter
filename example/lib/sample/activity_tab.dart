import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

import 'sample_data.dart';
import 'sample_state.dart';
import 'wallet_shell.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = SampleWalletScope.of(context);
    final q = _query.trim().toLowerCase();
    final items = state.dataState == SampleDataState.empty
        ? <SampleTransaction>[]
        : sampleTransactions.where((t) => q.isEmpty || t.title.toLowerCase().contains(q) || t.asset.symbol.toLowerCase().contains(q)).toList();

    Widget body;
    if (state.dataState == SampleDataState.loading) {
      body = Column(children: [
        for (var i = 0; i < 5; i++) CdsListCellFallback(title: true, description: true, detail: true, media: CdsCellMediaType.icon, rectWidthVariant: i),
      ]);
    } else if (state.dataState == SampleDataState.error) {
      body = CdsEmptyState(
        variant: CdsEmptyStateVariant.error,
        icon: CdsIconName.warning,
        title: "Couldn't load activity",
        description: 'Check your connection, then try again.',
        primaryAction: 'Try again',
        onPrimaryActionPress: () => state.setDataState(SampleDataState.live),
      );
    } else if (items.isEmpty) {
      body = q.isEmpty
          ? const CdsEmptyState(icon: CdsIconName.transactions, title: 'No activity yet', description: 'Buys, sends and receives show up here.')
          : CdsEmptyState(
              icon: CdsIconName.search,
              title: 'Nothing matches "$_query"',
              description: 'Try an asset symbol such as BTC.',
              primaryAction: 'Clear search',
              onPrimaryActionPress: () => setState(() => _query = ''),
            );
    } else {
      body = Column(children: [
        for (final t in items)
          CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            media: CdsCellMedia.icon(t.incoming ? CdsIconName.arrowDown : CdsIconName.arrowUp),
            title: t.title,
            description: t.date,
            detail: '${t.incoming ? '+' : '-'}${formatAmount(t.amount)} ${t.asset.symbol}',
            subdetail: switch (t.status) {
              SampleTxStatus.completed => null,
              SampleTxStatus.pending => 'Pending',
              SampleTxStatus.failed => 'Failed',
            },
            variant: switch (t.status) {
              SampleTxStatus.completed => CdsCellDetailVariant.foregroundMuted,
              SampleTxStatus.pending => CdsCellDetailVariant.warning,
              SampleTxStatus.failed => CdsCellDetailVariant.negative,
            },
          ),
      ]);
    }

    return Column(children: [
      const SampleHeader(title: 'Activity'),
      CdsBox(
        paddingX: 3,
        paddingBottom: 1,
        child: CdsSearchInput(placeholder: 'Search activity', value: _query, onChange: (v) => setState(() => _query = v)),
      ),
      Expanded(child: SingleChildScrollView(child: body)),
    ]);
  }
}
