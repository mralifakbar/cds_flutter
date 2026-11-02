import 'package:cds_flutter/cds_flutter.dart';
// The select barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Selects, comboboxes and select chips. All options are sample data.
final CdsDemoCategory selectCategory = CdsDemoCategory(
  title: 'Select',
  description: 'Single and multiple choice, with search and as filter chips.',
  icon: CdsIconName.filter,
  demos: [
    CdsDemo(
      title: 'CdsSelect',
      description: 'Opens a tray on phones and a menu on wide screens. Single and multiple choice.',
      docPath: 'doc/components/CdsSelect.md',
      builder: (_) => const _SelectDemo(),
    ),
    CdsDemo(
      title: 'CdsCombobox',
      description: 'A select with a search field for long lists.',
      docPath: 'doc/components/CdsCombobox.md',
      builder: (_) => const _ComboboxDemo(),
    ),
    CdsDemo(
      title: 'CdsSelectChip',
      description: 'Chip-shaped selects for filter bars.',
      docPath: 'doc/components/CdsSelectChip.md',
      builder: (_) => const _SelectChipDemo(),
    ),
  ],
);

const _networks = [
  CdsSelectOption(value: 'eth', label: 'Ethereum', description: 'Sample data: fee about 0.80 USD'),
  CdsSelectOption(value: 'base', label: 'Base', description: 'Sample data: fee about 0.01 USD'),
  CdsSelectOption(value: 'sol', label: 'Solana', description: 'Sample data: fee about 0.01 USD'),
  CdsSelectOption(value: 'btc', label: 'Bitcoin', description: 'Not supported for USDC', disabled: true),
];

class _SelectDemo extends StatefulWidget {
  const _SelectDemo();

  @override
  State<_SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<_SelectDemo> {
  String? _network;
  List<String> _alerts = const ['eth'];

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Network for USDC',
        child: CdsVStack(gap: 3, children: [
          CdsSelect<String>(
            label: 'Network',
            placeholder: 'Choose a network',
            helperText: _network == null ? 'Choose a network to send USDC' : null,
            variant: _network == null ? CdsSelectVariant.negative : null,
            value: _network,
            onChange: (v) => setState(() => _network = v),
            options: _networks,
          ),
          CdsSelect<String>.multi(
            label: 'Price alerts',
            placeholder: 'Choose networks',
            value: _alerts,
            onChange: (v) => setState(() => _alerts = v),
            options: _networks,
          ),
          const CdsSelect<String>(
            label: 'Network (disabled)',
            placeholder: 'Choose a network',
            disabled: true,
            value: null,
            onChange: null,
            options: _networks,
          ),
        ]),
      );
}

const _countries = [
  CdsSelectOption(value: 'au', label: 'Australia'),
  CdsSelectOption(value: 'br', label: 'Brazil'),
  CdsSelectOption(value: 'ca', label: 'Canada'),
  CdsSelectOption(value: 'de', label: 'Germany'),
  CdsSelectOption(value: 'fr', label: 'France'),
  CdsSelectOption(value: 'in', label: 'India'),
  CdsSelectOption(value: 'jp', label: 'Japan'),
  CdsSelectOption(value: 'mx', label: 'Mexico'),
  CdsSelectOption(value: 'gb', label: 'United Kingdom'),
  CdsSelectOption(value: 'us', label: 'United States'),
];

class _ComboboxDemo extends StatefulWidget {
  const _ComboboxDemo();

  @override
  State<_ComboboxDemo> createState() => _ComboboxDemoState();
}

class _ComboboxDemoState extends State<_ComboboxDemo> {
  String? _country;
  List<String> _shipping = const [];

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Country of residence',
        child: CdsVStack(gap: 3, children: [
          CdsCombobox<String>(
            label: 'Country',
            placeholder: 'Search countries',
            value: _country,
            onChange: (v) => setState(() => _country = v),
            options: _countries,
          ),
          CdsCombobox<String>.multi(
            label: 'Tax residencies',
            placeholder: 'Search countries',
            value: _shipping,
            onChange: (v) => setState(() => _shipping = v),
            options: _countries,
          ),
        ]),
      );
}

class _SelectChipDemo extends StatefulWidget {
  const _SelectChipDemo();

  @override
  State<_SelectChipDemo> createState() => _SelectChipDemoState();
}

class _SelectChipDemoState extends State<_SelectChipDemo> {
  String? _sort;
  List<String> _types = const [];

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Market filters',
        caption: 'A chip inverts while it holds a value.',
        child: CdsHStack(wrap: true, gap: 1, children: [
          CdsSelectChip<String>(
            placeholder: 'Sort',
            value: _sort,
            onChange: (v) => setState(() => _sort = v),
            options: const [
              CdsSelectOption(value: 'gainers', label: 'Top gainers'),
              CdsSelectOption(value: 'losers', label: 'Top losers'),
              CdsSelectOption(value: 'volume', label: 'Trading volume'),
            ],
          ),
          CdsSelectChip<String>.multi(
            placeholder: 'Asset type',
            value: _types,
            onChange: (v) => setState(() => _types = v),
            options: const [
              CdsSelectOption(value: 'coin', label: 'Coins'),
              CdsSelectOption(value: 'stable', label: 'Stablecoins'),
              CdsSelectOption(value: 'token', label: 'Tokens'),
            ],
          ),
        ]),
      );
}
