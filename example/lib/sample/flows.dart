import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

import 'sample_data.dart';

/// Buy: pick an asset, enter an amount on the numpad, confirm.
Future<void> openBuyFlow(BuildContext context, {SampleAsset? asset}) async {
  final result = await showCdsTray<String>(context, builder: (_) => _BuyTray(initial: asset ?? sampleAssets.first));
  if (result != null && context.mounted) showCdsToast(context, result);
}

class _BuyTray extends StatefulWidget {
  const _BuyTray({required this.initial});
  final SampleAsset initial;

  @override
  State<_BuyTray> createState() => _BuyTrayState();
}

class _BuyTrayState extends State<_BuyTray> {
  late SampleAsset _asset = widget.initial;
  String _amount = '';
  bool _submitting = false;

  double get _value => double.tryParse(_amount) ?? 0;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) CdsTray.close(context, 'Sample order: ${formatUsd(_value)} of ${_asset.name}');
  }

  @override
  Widget build(BuildContext context) {
    final tooSmall = _amount.isNotEmpty && _value < 1;
    return CdsTray(
      title: 'Buy ${_asset.name}',
      footer: CdsBox(
        paddingX: 3,
        paddingBottom: 2,
        child: CdsButton(
          label: _value >= 1 ? 'Buy ${formatUsd(_value)}' : 'Enter an amount',
          block: true,
          loading: _submitting,
          onPress: _value >= 1 ? _confirm : null,
        ),
      ),
      child: CdsVStack(gap: 2, paddingX: 3, children: [
        CdsSelect<String>(
          label: 'Asset',
          value: _asset.symbol,
          onChange: (v) => setState(() => _asset = sampleAssets.firstWhere((a) => a.symbol == v)),
          options: [for (final a in sampleAssets) CdsSelectOption(value: a.symbol, label: a.name)],
        ),
        Center(
          child: CdsVStack(gap: 0.5, alignItems: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            CdsText.display3(_amount.isEmpty ? r'$0' : '\$$_amount', tabularNumbers: true, semanticsLabel: 'Amount ${_amount.isEmpty ? '0' : _amount} dollars'),
            CdsText.label2(
              tooSmall ? 'Minimum order is \$1.00' : 'Sample order, no money moves',
              color: tooSmall ? CdsColor.fgNegative : CdsColor.fgMuted,
            ),
          ]),
        ),
        CdsNumpad(
          onPress: (key) => setState(() => _amount = CdsNumpad.apply(_amount, key, maxDecimals: 2)),
          onClear: () => setState(() => _amount = ''),
        ),
      ]),
    );
  }
}

/// Send: address with inline validation, then a confirmation toast.
Future<void> openSendFlow(BuildContext context) async {
  final result = await showCdsTray<String>(context, builder: (_) => const _SendTray());
  if (result != null && context.mounted) showCdsToast(context, result);
}

class _SendTray extends StatefulWidget {
  const _SendTray();

  @override
  State<_SendTray> createState() => _SendTrayState();
}

class _SendTrayState extends State<_SendTray> {
  String _address = '';
  bool _touched = false;

  bool get _valid => RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(_address.trim());

  @override
  Widget build(BuildContext context) {
    final showError = _touched && _address.isNotEmpty && !_valid;
    return CdsTray(
      title: 'Send USD Coin',
      footer: CdsBox(
        paddingX: 3,
        paddingBottom: 2,
        child: CdsButton(label: 'Review send', block: true, onPress: _valid ? () => CdsTray.close(context, 'Sample send to ${_address.substring(0, 6)}...${_address.substring(_address.length - 4)} is ready to review') : null),
      ),
      child: CdsBox(
        paddingX: 3,
        child: CdsTextInput(
          label: 'Recipient address',
          placeholder: '0x followed by 40 characters',
          value: _address,
          onChange: (v) => setState(() => _address = v),
          onBlur: () => setState(() => _touched = true),
          variant: showError ? CdsInputVariant.negative : CdsInputVariant.foregroundMuted,
          helperText: showError ? 'That is not a valid address. It starts with 0x and has 40 more characters.' : 'Paste an Ethereum-style address. Sample only.',
        ),
      ),
    );
  }
}

/// Receive: a sample address with copy.
Future<void> openReceiveFlow(BuildContext context) {
  return showCdsTray<void>(
    context,
    builder: (context) => CdsTray(
      title: 'Receive',
      child: CdsVStack(gap: 2, paddingX: 3, paddingBottom: 3, children: const [
        CdsText.body('Share this sample address to receive crypto. It is not a real wallet.', color: CdsColor.fgMuted),
        CdsCodeSnippet('0x0000000000000000000000000000000000000000', title: 'Sample address'),
      ]),
    ),
  );
}
