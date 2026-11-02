import 'package:cds_flutter/cds_flutter.dart';
// The cells, media and display barrels are exported from cds_flutter.dart once the maintainer adds them.
import 'package:flutter/widgets.dart';

import '../demo.dart';
import 'sample_art.dart';

/// List and content cells. Assets, balances and messages are sample data.
final CdsDemoCategory cellsCategory = CdsDemoCategory(
  title: 'Cells',
  description: 'List cells, content cells, selection, helper text, and loading, empty and error lists.',
  icon: CdsIconName.list,
  demos: [
    CdsDemo(
      title: 'CdsListCell',
      description: 'Media, title stack, detail, accessories and the three spacing variants.',
      docPath: 'doc/components/CdsListCell.md',
      builder: (_) => const _ListCellDemo(),
    ),
    CdsDemo(
      title: 'CdsListCell selection',
      description: 'A single-select list driven by value and onChange.',
      docPath: 'doc/components/CdsListCell.md',
      builder: (_) => const _SelectionDemo(),
    ),
    CdsDemo(
      title: 'CdsListCellFallback',
      description: 'A list that moves through loading, loaded, empty and error states.',
      docPath: 'doc/components/CdsListCellFallback.md',
      builder: (_) => const _ListStatesDemo(),
    ),
    CdsDemo(
      title: 'CdsContentCell',
      description: 'Notifications with meta text and wrapping descriptions.',
      docPath: 'doc/components/CdsContentCell.md',
      builder: (_) => const _ContentCellDemo(),
    ),
  ],
);

const _assets = [
  ('Bitcoin', 'BTC', r'$64,201.10', '+2.4%', CdsCellDetailVariant.positive),
  ('Ethereum', 'ETH', r'$3,081.01', '-1.2%', CdsCellDetailVariant.negative),
  ('USD Coin', 'USDC', r'$1.00', '0.0%', CdsCellDetailVariant.foregroundMuted),
];

class _ListCellDemo extends StatelessWidget {
  const _ListCellDemo();

  @override
  Widget build(BuildContext context) {
    final art = [SampleArt.blue, SampleArt.green, SampleArt.sunset];
    return CdsVStack(gap: 4, children: [
      DemoSection(
        title: 'Condensed asset list',
        caption: 'Sample data',
        child: CdsVStack(children: [
          for (var i = 0; i < _assets.length; i++)
            CdsListCell(
              spacingVariant: CdsCellSpacingVariant.condensed,
              media: CdsCellMedia.asset(source: art[i]),
              title: _assets[i].$1,
              description: _assets[i].$2,
              detail: _assets[i].$3,
              subdetail: _assets[i].$4,
              variant: _assets[i].$5,
              accessory: CdsCellAccessoryType.arrow,
              onPress: () {},
            ),
        ]),
      ),
      DemoSection(
        title: 'Spacing variants',
        caption: 'normal and compact are the CDS default but deprecated; prefer condensed.',
        child: CdsVStack(children: [
          for (final v in CdsCellSpacingVariant.values)
            CdsListCell(
              spacingVariant: v,
              media: const CdsCellMedia.icon(CdsIconName.wallet),
              title: v.name,
              detail: r'$12,345.00',
              accessory: CdsCellAccessoryType.arrow,
              onPress: () {},
            ),
        ]),
      ),
      DemoSection(
        title: 'Subtitle, end content and helper text',
        child: CdsVStack(children: [
          CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            media: const CdsCellMedia.icon(CdsIconName.bank),
            title: 'Checking account',
            subtitle: 'Deposits available in 1 to 2 days',
            description: 'Ending in 42',
            end: const CdsTag('Primary', colorScheme: CdsTagColorScheme.blue),
            helperText: const CdsCellHelperText('Verification pending', variant: CdsCellHelperTextVariant.warning),
          ),
          const CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            media: CdsCellMedia.icon(CdsIconName.creditCard),
            title: 'Debit card',
            description: 'Ending in 7781',
            accessory: CdsCellAccessoryType.more,
            helperText: CdsCellHelperText('Card expired. Add a new card to keep buying.', variant: CdsCellHelperTextVariant.error),
          ),
          const CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            title: 'A long asset name that will not fit next to its balance',
            detail: r'$1,234,567.89',
            priority: {CdsCellPriority.end},
            disableMultilineTitle: true,
            helperText: CdsCellHelperText('priority: end keeps the balance whole'),
          ),
          const CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            title: 'Disabled row',
            description: 'Not available in your region',
            disabled: true,
            onPress: null,
          ),
        ]),
      ),
    ]);
  }
}

class _SelectionDemo extends StatefulWidget {
  const _SelectionDemo();

  @override
  State<_SelectionDemo> createState() => _SelectionDemoState();
}

class _SelectionDemoState extends State<_SelectionDemo> {
  String _value = 'USD';

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Local currency',
      caption: 'Unselected rows keep the checkmark space so titles align.',
      child: CdsVStack(children: [
        for (final (code, name) in const [('USD', 'US dollar'), ('EUR', 'Euro'), ('GBP', 'British pound')])
          CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            title: code,
            description: name,
            selected: _value == code,
            accessory: CdsCellAccessoryType.unselected,
            onPress: () => setState(() => _value = code),
          ),
      ]),
    );
  }
}

enum _ListState { loading, loaded, empty, error }

class _ListStatesDemo extends StatefulWidget {
  const _ListStatesDemo();

  @override
  State<_ListStatesDemo> createState() => _ListStatesDemoState();
}

class _ListStatesDemoState extends State<_ListStatesDemo> {
  _ListState _state = _ListState.loading;

  Widget _body() => switch (_state) {
        _ListState.loading => CdsVStack(children: [
            for (var i = 0; i < 3; i++)
              CdsListCellFallback(
                spacingVariant: CdsCellSpacingVariant.condensed,
                title: true,
                description: true,
                detail: true,
                subdetail: true,
                media: CdsCellMediaType.asset,
                rectWidthVariant: i,
              ),
          ]),
        _ListState.loaded => CdsVStack(children: [
            for (final a in _assets)
              CdsListCell(
                spacingVariant: CdsCellSpacingVariant.condensed,
                media: const CdsCellMedia.icon(CdsIconName.wallet),
                title: a.$1,
                description: a.$2,
                detail: a.$3,
                subdetail: a.$4,
                variant: a.$5,
              ),
          ]),
        _ListState.empty => const CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            media: CdsCellMedia.icon(CdsIconName.wallet, color: CdsColor.fgMuted),
            title: 'No assets yet',
            description: 'Buy or receive crypto to see it here.',
            multiline: true,
          ),
        _ListState.error => CdsListCell(
            spacingVariant: CdsCellSpacingVariant.condensed,
            media: const CdsCellMedia.icon(CdsIconName.error, color: CdsColor.fgNegative),
            title: 'Could not load assets',
            description: 'Check your connection, then try again.',
            multiline: true,
            end: CdsButton(label: 'Retry', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _state = _ListState.loading)),
          ),
      };

  @override
  Widget build(BuildContext context) {
    return CdsVStack(gap: 2, children: [
      CdsHStack(gap: 1, wrap: true, children: [
        for (final s in _ListState.values)
          CdsButton(
            label: s.name,
            size: CdsButtonSize.xs,
            variant: s == _state ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
            onPress: () => setState(() => _state = s),
          ),
      ]),
      DemoSection(title: 'Sample data', child: _body()),
    ]);
  }
}

class _ContentCellDemo extends StatelessWidget {
  const _ContentCellDemo();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Notifications',
      caption: 'Sample data',
      child: CdsVStack(children: [
        CdsContentCell(
          spacingVariant: CdsCellSpacingVariant.condensed,
          media: const CdsCellMedia.icon(CdsIconName.bell),
          title: 'Price alert',
          meta: '2m ago',
          description: 'Bitcoin rose above your alert price of 60,000 USD.',
          accessory: CdsCellAccessoryType.arrow,
          onPress: () {},
        ),
        CdsContentCell(
          media: const CdsCellMedia.icon(CdsIconName.shield),
          title: 'New sign-in',
          subtitle: 'Sample device',
          meta: '9:41',
          description: 'If this was not you, lock your account from the security settings and change your password.',
          onPress: () {},
        ),
      ]),
    );
  }
}
