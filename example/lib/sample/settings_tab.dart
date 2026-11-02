import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

import '../gallery/scheme_scope.dart';
import 'sample_data.dart';
import 'sample_state.dart';
import 'wallet_shell.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SampleWalletScope.of(context);
    final scheme = SchemeScope.of(context);
    return Column(children: [
      const SampleHeader(title: 'Settings'),
      Expanded(
        child: ListView(
          padding: EdgeInsets.only(bottom: context.cds.space(4)),
          children: [
            const CdsSectionHeader(title: 'Appearance'),
            CdsBox(
              paddingX: 3,
              child: CdsSegmentedControl<CdsColorSchemePreference>(
                block: true,
                value: scheme.scheme,
                onChange: scheme.onChange,
                options: const [
                  CdsSegmentedControlOption(value: CdsColorSchemePreference.system, label: 'System'),
                  CdsSegmentedControlOption(value: CdsColorSchemePreference.light, label: 'Light'),
                  CdsSegmentedControlOption(value: CdsColorSchemePreference.dark, label: 'Dark'),
                ],
              ),
            ),
            const CdsSectionHeader(title: 'Privacy and alerts'),
            CdsBox(
              paddingX: 3,
              child: CdsVStack(gap: 2, children: [
                CdsSwitch(label: 'Hide balances', checked: state.hideBalances, onChange: (v) => state.update(() => state.hideBalances = v)),
                CdsSwitch(label: 'Price alerts', checked: state.priceAlerts, onChange: (v) => state.update(() => state.priceAlerts = v)),
                CdsSelect<String>(
                  label: 'Display currency',
                  helperText: 'Sample setting. Values stay in USD in this demo.',
                  value: state.currency,
                  onChange: (v) => state.update(() => state.currency = v ?? 'USD'),
                  options: const [
                    CdsSelectOption(value: 'USD', label: 'US dollar'),
                    CdsSelectOption(value: 'EUR', label: 'Euro'),
                    CdsSelectOption(value: 'IDR', label: 'Indonesian rupiah'),
                  ],
                ),
              ]),
            ),
            const CdsSectionHeader(title: 'Simulate data state', description: 'See the loading, empty and error screens on Home and Activity.'),
            CdsBox(
              paddingX: 3,
              child: CdsRadioGroup<SampleDataState>(
                value: state.dataState,
                onChange: (v) => state.setDataState(v),
                options: const [
                  CdsControlOption(value: SampleDataState.live, label: 'Loaded'),
                  CdsControlOption(value: SampleDataState.loading, label: 'Loading'),
                  CdsControlOption(value: SampleDataState.empty, label: 'Empty'),
                  CdsControlOption(value: SampleDataState.error, label: 'Error'),
                ],
              ),
            ),
            const CdsSectionHeader(title: 'About'),
            CdsListCell(
              spacingVariant: CdsCellSpacingVariant.condensed,
              media: const CdsCellMedia.icon(CdsIconName.document),
              title: 'Open source licenses',
              description: 'cds_flutter, CDS (Apache-2.0), Inter and Source Code Pro (OFL)',
              accessory: CdsCellAccessoryType.arrow,
              onPress: () => showLicensePage(context: context, applicationName: 'cds_flutter sample'),
            ),
          ],
        ),
      ),
    ]);
  }
}
