import 'package:cds_flutter/cds_flutter.dart';
// The data display and media barrels are exported from cds_flutter.dart once the maintainer adds them.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Data tables. Every asset, price and transaction is sample data.
final CdsDemoCategory tableCategory = CdsDemoCategory(
  title: 'Tables',
  description: 'Data tables with sorting, pressable rows, horizontal scrolling, and loading, empty and error states.',
  icon: CdsIconName.grid,
  demos: [
    CdsDemo(
      title: 'CdsTable',
      description: 'Sortable columns, pressable rows, a caption and a totals footer.',
      docPath: 'doc/components/CdsTable.md',
      builder: (_) => const _SortableTableDemo(),
    ),
    CdsDemo(
      title: 'CdsTable variants',
      description: 'Standard, ruled and graph lines, compact and bordered.',
      docPath: 'doc/components/CdsTable.md',
      builder: (_) => const _VariantsDemo(),
    ),
    CdsDemo(
      title: 'CdsTable wide content',
      description: 'A table wider than the screen scrolls horizontally; a fixed layout truncates instead.',
      docPath: 'doc/components/CdsTable.md',
      builder: (_) => const _WideTableDemo(),
    ),
    CdsDemo(
      title: 'CdsTableCellFallback',
      description: 'A table that moves through loading, loaded, empty and error states.',
      docPath: 'doc/components/CdsTableCellFallback.md',
      builder: (_) => const _TableStatesDemo(),
    ),
  ],
);

typedef _Asset = ({String name, String symbol, double price, double change});

const List<_Asset> _assets = [
  (name: 'Bitcoin', symbol: 'BTC', price: 64201.10, change: 2.4),
  (name: 'Ethereum', symbol: 'ETH', price: 3081.01, change: -1.2),
  (name: 'Solana', symbol: 'SOL', price: 142.55, change: 5.8),
  (name: 'USD Coin', symbol: 'USDC', price: 1.00, change: 0),
];

String _usd(double v) {
  final whole = v.truncate().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  final cents = ((v - v.truncate()) * 100).round().toString().padLeft(2, '0');
  return '\$$whole.$cents';
}

String _pct(double v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)}%';

CdsColor _changeColor(double v) => v > 0 ? CdsColor.fgPositive : (v < 0 ? CdsColor.fgNegative : CdsColor.fgMuted);

class _SortableTableDemo extends StatefulWidget {
  const _SortableTableDemo();

  @override
  State<_SortableTableDemo> createState() => _SortableTableDemoState();
}

class _SortableTableDemoState extends State<_SortableTableDemo> {
  String _sortBy = 'price';
  CdsTableSortDirection _direction = CdsTableSortDirection.descending;
  String? _opened;

  void _sort(String key) => setState(() {
        if (_sortBy == key) {
          _direction = _direction == CdsTableSortDirection.ascending
              ? CdsTableSortDirection.descending
              : CdsTableSortDirection.ascending;
        } else {
          _sortBy = key;
          _direction = CdsTableSortDirection.descending;
        }
      });

  CdsTableSortDirection _dirFor(String key) => _sortBy == key ? _direction : CdsTableSortDirection.none;

  @override
  Widget build(BuildContext context) {
    final rows = [..._assets]..sort((a, b) {
        final cmp = switch (_sortBy) {
          'name' => a.name.compareTo(b.name),
          'change' => a.change.compareTo(b.change),
          _ => a.price.compareTo(b.price),
        };
        return _direction == CdsTableSortDirection.ascending ? cmp : -cmp;
      });
    final total = _assets.fold(0.0, (sum, a) => sum + a.price);

    return CdsVStack(gap: 2, children: [
      CdsTable(
        variant: CdsTableVariant.ruled,
        bordered: true,
        semanticLabel: 'Sample prices',
        children: [
          const CdsTableCaption('Prices'),
          CdsTableHeader(children: [
            CdsTableRow(children: [
              CdsTableCell(title: 'Asset', sortDirection: _dirFor('name'), onPress: () => _sort('name')),
              CdsTableCell(title: 'Price', alignItems: CrossAxisAlignment.end, sortDirection: _dirFor('price'), onPress: () => _sort('price')),
              CdsTableCell(title: 'Change', alignItems: CrossAxisAlignment.end, sortDirection: _dirFor('change'), onPress: () => _sort('change')),
            ]),
          ]),
          CdsTableBody(children: [
            for (final a in rows)
              CdsTableRow(
                onPress: () => setState(() => _opened = a.name),
                semanticLabel: 'Open ${a.name}',
                children: [
                  CdsTableCell(title: a.name, subtitle: a.symbol, start: const CdsCellMedia.icon(CdsIconName.wallet)),
                  CdsTableCell(title: _usd(a.price), alignItems: CrossAxisAlignment.end),
                  CdsTableCell(title: _pct(a.change), color: _changeColor(a.change), alignItems: CrossAxisAlignment.end),
                ],
              ),
          ]),
          CdsTableFooter(children: [
            CdsTableRow(children: [
              const CdsTableCell(title: 'Sum of prices'),
              CdsTableCell(title: _usd(total), alignItems: CrossAxisAlignment.end),
              const CdsTableCell(title: ''),
            ]),
          ]),
        ],
      ),
      CdsText.label2(_opened == null ? 'Sample data. Press a row.' : 'Sample data. Opened $_opened.', color: CdsColor.fgMuted),
    ]);
  }
}

class _VariantsDemo extends StatelessWidget {
  const _VariantsDemo();

  Widget _table(CdsTableVariant variant, {bool compact = false, bool bordered = false}) => CdsTable(
        variant: variant,
        compact: compact,
        bordered: bordered,
        children: [
          CdsTableHeader(children: [
            CdsTableRow(children: const [CdsTableCell(title: 'Asset'), CdsTableCell(title: 'Price', alignItems: CrossAxisAlignment.end)]),
          ]),
          CdsTableBody(children: [
            for (final a in _assets.take(3))
              CdsTableRow(children: [CdsTableCell(title: a.name), CdsTableCell(title: _usd(a.price), alignItems: CrossAxisAlignment.end)]),
          ]),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(title: 'standard', caption: 'Sample data', child: _table(CdsTableVariant.standard)),
      DemoSection(title: 'ruled', child: _table(CdsTableVariant.ruled)),
      DemoSection(title: 'graph, bordered', child: _table(CdsTableVariant.graph, bordered: true)),
      DemoSection(title: 'ruled, compact', child: _table(CdsTableVariant.ruled, compact: true)),
    ]);
  }
}

class _WideTableDemo extends StatelessWidget {
  const _WideTableDemo();

  static const _columns = ['Date', 'Type', 'Asset', 'Amount', 'Fee', 'Status', 'Network'];
  static const _rows = [
    ['Oct 2', 'Buy', 'Bitcoin', '0.0150 BTC', r'$1.99', 'Completed', 'Bitcoin'],
    ['Oct 1', 'Send', 'USD Coin', '250.00 USDC', r'$0.00', 'Pending', 'Layer 2'],
    ['Sep 28', 'Sell', 'Ethereum', '0.4000 ETH', r'$2.49', 'Completed', 'Ethereum'],
  ];

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Auto layout scrolls',
        caption: 'Sample data. Drag sideways to see every column.',
        child: CdsTable(
          variant: CdsTableVariant.ruled,
          bordered: true,
          children: [
            CdsTableHeader(children: [CdsTableRow(children: [for (final c in _columns) CdsTableCell(title: c)])]),
            CdsTableBody(children: [
              for (final r in _rows) CdsTableRow(children: [for (final v in r) CdsTableCell(title: v)]),
            ]),
          ],
        ),
      ),
      DemoSection(
        title: 'Fixed layout truncates',
        child: CdsTable(
          variant: CdsTableVariant.ruled,
          bordered: true,
          tableLayout: CdsTableLayout.fixed,
          compact: true,
          children: [
            CdsTableHeader(children: [
              CdsTableRow(children: [for (final c in _columns.take(4)) CdsTableCell(title: c, overflow: TextOverflow.ellipsis)]),
            ]),
            CdsTableBody(children: [
              for (final r in _rows)
                CdsTableRow(children: [for (final v in r.take(4)) CdsTableCell(title: v, overflow: TextOverflow.ellipsis)]),
            ]),
          ],
        ),
      ),
    ]);
  }
}

enum _TableState { loading, loaded, empty, error }

class _TableStatesDemo extends StatefulWidget {
  const _TableStatesDemo();

  @override
  State<_TableStatesDemo> createState() => _TableStatesDemoState();
}

class _TableStatesDemoState extends State<_TableStatesDemo> {
  _TableState _state = _TableState.loading;

  List<CdsTableRow> _rows() => switch (_state) {
        _TableState.loading => [
            for (var i = 0; i < 4; i++)
              CdsTableRow(children: [
                CdsTableCellFallback(title: true, subtitle: true, start: CdsCellMediaType.icon, rectWidthVariant: i),
                CdsTableCellFallback(title: true, titleWidth: 72, rectWidthVariant: i + 2),
              ]),
          ],
        _TableState.loaded => [
            for (final a in _assets)
              CdsTableRow(children: [
                CdsTableCell(title: a.name, subtitle: a.symbol, start: const CdsCellMedia.icon(CdsIconName.wallet)),
                CdsTableCell(title: _usd(a.price), alignItems: CrossAxisAlignment.end),
              ]),
          ],
        _TableState.empty => [
            CdsTableRow(children: const [
              CdsTableCell(title: 'No holdings yet', subtitle: 'Buy or receive crypto to see it here.'),
            ]),
          ],
        _TableState.error => [
            CdsTableRow(children: [
              const CdsTableCell(
                title: 'Could not load holdings',
                subtitle: 'Check your connection, then try again.',
                start: CdsIcon(CdsIconName.error, size: CdsIconSize.s, color: CdsColor.fgNegative),
              ),
              CdsTableCell(
                alignItems: CrossAxisAlignment.end,
                child: CdsButton(label: 'Retry', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _state = _TableState.loading)),
              ),
            ]),
          ],
      };

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 2, children: [
      CdsHStack(gap: 1, wrap: true, children: [
        for (final s in _TableState.values)
          CdsButton(
            label: s.name,
            size: CdsButtonSize.xs,
            variant: s == _state ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
            onPress: () => setState(() => _state = s),
          ),
      ]),
      CdsTable(
        variant: CdsTableVariant.ruled,
        bordered: true,
        semanticLabel: 'Sample holdings',
        children: [
          CdsTableHeader(children: [
            CdsTableRow(children: const [CdsTableCell(title: 'Asset'), CdsTableCell(title: 'Price', alignItems: CrossAxisAlignment.end)]),
          ]),
          CdsTableBody(children: _rows()),
        ],
      ),
      const CdsText.label2('Sample data', color: CdsColor.fgMuted),
    ]);
  }
}
