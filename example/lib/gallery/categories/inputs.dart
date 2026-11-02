import 'package:cds_flutter/cds_flutter.dart';
// The inputs barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/material.dart';

import '../demo.dart';

/// Input demos: text fields, selection controls, keypads, chips and gesture controls.
final CdsDemoCategory inputsCategory = CdsDemoCategory(
  title: 'Inputs',
  description: 'Text fields, checkboxes, radios, switches, chips, numpad, sliders and slide-to-confirm.',
  icon: CdsIconName.pencil,
  demos: [
    ..._textDemos,
    ..._controlsDemos,
    ..._padsDemos,
    ..._gesturesDemos,
  ],
);

final List<CdsDemo> _textDemos = [
  CdsDemo(
    title: 'CdsTextInput',
    description: 'Labeled text field with variants, slots, prefix and suffix text, and focus border.',
    docPath: 'doc/components/CdsTextInput.md',
    builder: (_) => const _TextInputDemo(),
  ),
  CdsDemo(
    title: 'CdsTextFormField',
    description: 'Text field wired into a Form: validate, save and reset.',
    docPath: 'doc/components/CdsTextFormField.md',
    builder: (_) => const _TextFormFieldDemo(),
  ),
  CdsDemo(
    title: 'CdsTextArea',
    description: 'Multiline field that grows with its content and counts characters.',
    docPath: 'doc/components/CdsTextArea.md',
    builder: (_) => const _TextAreaDemo(),
  ),
  CdsDemo(
    title: 'CdsSearchInput',
    description: 'Pill search field with back arrow on focus and a clear button.',
    docPath: 'doc/components/CdsSearchInput.md',
    builder: (_) => const _TextSearchDemo(),
  ),
  CdsDemo(
    title: 'CdsOtpInput',
    description: 'One-time code cells with paste support and an error state.',
    docPath: 'doc/components/CdsOtpInput.md',
    builder: (_) => const _TextOtpDemo(),
  ),
];

class _TextInputDemo extends StatefulWidget {
  const _TextInputDemo();

  @override
  State<_TextInputDemo> createState() => _TextInputDemoState();
}

class _TextInputDemoState extends State<_TextInputDemo> {
  String _email = '';
  String _amount = '';
  String _password = '';
  bool _hidden = true;

  bool get _emailValid => _email.contains('@') && _email.contains('.');

  @override
  Widget build(BuildContext context) {
    final emailVariant = _email.isEmpty
        ? CdsInputVariant.foregroundMuted
        : (_emailValid ? CdsInputVariant.positive : CdsInputVariant.negative);
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Validation states',
          caption: 'The variant follows what you type.',
          child: CdsTextInput(
            label: 'Email',
            placeholder: 'satoshi@example.com',
            value: _email,
            onChange: (v) => setState(() => _email = v),
            keyboardType: TextInputType.emailAddress,
            variant: emailVariant,
            helperText: _email.isEmpty
                ? 'We send receipts to this address'
                : (_emailValid ? 'Looks good' : 'Enter a valid email address'),
          ),
        ),
        DemoSection(
          title: 'Prefix and suffix',
          child: CdsTextInput(
            label: 'Amount',
            placeholder: '0.00',
            prefix: r'$',
            suffix: 'USD',
            value: _amount,
            onChange: (v) => setState(() => _amount = v),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            helperText: 'Sample data. No funds move.',
          ),
        ),
        DemoSection(
          title: 'Password with reveal',
          child: CdsTextInput(
            label: 'Password',
            value: _password,
            onChange: (v) => setState(() => _password = v),
            obscureText: _hidden,
            end: CdsInputIconButton(
              _hidden ? CdsIconName.visible : CdsIconName.invisible,
              semanticLabel: _hidden ? 'Show password' : 'Hide password',
              onPress: () => setState(() => _hidden = !_hidden),
            ),
          ),
        ),
        const DemoSection(
          title: 'Start icon',
          child: CdsTextInput(label: 'Wallet address', placeholder: '0x...', start: CdsInputIcon(CdsIconName.wallet)),
        ),
        const DemoSection(
          title: 'Label placement and size',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsTextInput(label: 'Inside label', labelVariant: CdsInputLabelVariant.inside, placeholder: 'Size l'),
              CdsTextInput(
                label: 'Inline',
                labelVariant: CdsInputLabelVariant.inside,
                size: CdsTextInputSize.m,
                placeholder: 'Size m',
              ),
              CdsTextInput(label: 'Compact', compact: true, placeholder: 'Size s'),
            ],
          ),
        ),
        const DemoSection(
          title: 'Disabled and read only',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsTextInput(label: 'Disabled', value: 'Not editable', disabled: true),
              CdsTextInput(label: 'Read only', value: 'Sample data: ID 0042', readOnly: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextFormFieldDemo extends StatefulWidget {
  const _TextFormFieldDemo();

  @override
  State<_TextFormFieldDemo> createState() => _TextFormFieldDemoState();
}

class _TextFormFieldDemoState extends State<_TextFormFieldDemo> {
  final _formKey = GlobalKey<FormState>();
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Form validation',
      caption: 'Press Save with empty fields to see errors.',
      child: Form(
        key: _formKey,
        child: CdsVStack(
          gap: 2,
          children: [
            CdsTextFormField(
              label: 'Full name',
              helperText: 'As it appears on your ID',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
              onSaved: (v) => _saved = v,
            ),
            CdsTextFormField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email address' : null,
            ),
            CdsHStack(
              gap: 1,
              children: [
                CdsButton(
                  label: 'Save',
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {});
                    }
                  },
                ),
                CdsButton(
                  label: 'Reset',
                  variant: CdsButtonVariant.secondary,
                  onPress: () => setState(() {
                    _formKey.currentState!.reset();
                    _saved = null;
                  }),
                ),
              ],
            ),
            if (_saved != null) CdsText.label2('Saved name: $_saved', color: CdsColor.fgMuted),
          ],
        ),
      ),
    );
  }
}

class _TextAreaDemo extends StatefulWidget {
  const _TextAreaDemo();

  @override
  State<_TextAreaDemo> createState() => _TextAreaDemoState();
}

class _TextAreaDemoState extends State<_TextAreaDemo> {
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'With character count',
          child: CdsTextArea(
            label: 'Message to support',
            placeholder: 'Describe what happened',
            helperText: 'Do not share your password',
            value: _message,
            onChange: (v) => setState(() => _message = v),
            maxLength: 200,
          ),
        ),
        const DemoSection(
          title: 'Error and disabled',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsTextArea(label: 'Reason', variant: CdsInputVariant.negative, helperText: 'Add a reason to continue'),
              CdsTextArea(label: 'Notes', value: 'Sample data', disabled: true, minLines: 2),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextSearchDemo extends StatefulWidget {
  const _TextSearchDemo();

  @override
  State<_TextSearchDemo> createState() => _TextSearchDemoState();
}

class _TextSearchDemoState extends State<_TextSearchDemo> {
  static const _assets = ['Bitcoin', 'Ethereum', 'Solana', 'USD Coin', 'Litecoin'];
  String _query = '';
  String _submitted = '';

  @override
  Widget build(BuildContext context) {
    final results = _assets.where((a) => a.toLowerCase().contains(_query.toLowerCase())).toList();
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Filter a list',
          caption: 'Sample data',
          child: CdsVStack(
            gap: 1.5,
            children: [
              CdsSearchInput(
                placeholder: 'Search assets',
                value: _query,
                onChange: (v) => setState(() => _query = v),
                onSearch: (v) => setState(() => _submitted = v),
              ),
              if (_submitted.isNotEmpty) CdsText.label2('Submitted: $_submitted', color: CdsColor.fgMuted),
              if (results.isEmpty)
                const CdsText.body('No assets match. Try a shorter name.', color: CdsColor.fgMuted)
              else
                for (final r in results) CdsText.body(r),
            ],
          ),
        ),
        const DemoSection(
          title: 'Compact and disabled',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsSearchInput(compact: true, placeholder: 'Compact search'),
              CdsSearchInput(disabled: true, placeholder: 'Search unavailable'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextOtpDemo extends StatefulWidget {
  const _TextOtpDemo();

  @override
  State<_TextOtpDemo> createState() => _TextOtpDemoState();
}

class _TextOtpDemoState extends State<_TextOtpDemo> {
  // Sample data: the demo accepts this code.
  static const _expected = '123456';
  String _code = '';
  bool? _verified;

  @override
  Widget build(BuildContext context) {
    final failed = _verified == false;
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Verify a code',
          caption: 'Sample data: enter 123456. Any other code shows the error state.',
          child: CdsOtpInput(
            label: 'Verification code',
            value: _code,
            onChange: (v) => setState(() {
              _code = v;
              _verified = null;
            }),
            onComplete: (v) => setState(() => _verified = v == _expected),
            variant: failed
                ? CdsInputVariant.negative
                : (_verified == true ? CdsInputVariant.positive : CdsInputVariant.foregroundMuted),
            helperText: failed
                ? 'That code is not right. Check the latest SMS and try again.'
                : (_verified == true ? 'Code verified' : 'We sent a 6-digit code to your phone'),
          ),
        ),
        const DemoSection(
          title: 'Obscured and disabled',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsOtpInput(label: 'PIN', length: 4, obscureText: true),
              CdsOtpInput(label: 'Code', length: 4, value: '12', disabled: true),
            ],
          ),
        ),
      ],
    );
  }
}

final List<CdsDemo> _controlsDemos = [
  CdsDemo(
    title: 'CdsCheckbox',
    description: 'Checked, unchecked and indeterminate checkboxes with labels.',
    docPath: 'doc/components/CdsCheckbox.md',
    builder: (_) => const _ControlsCheckboxDemo(),
  ),
  CdsDemo(
    title: 'CdsCheckboxGroup',
    description: 'A labelled set of checkboxes bound to a Set of values.',
    docPath: 'doc/components/CdsCheckboxGroup.md',
    builder: (_) => const _ControlsCheckboxGroupDemo(),
  ),
  CdsDemo(
    title: 'CdsCheckboxCell',
    description: 'Bordered rows with a checkbox, title and description.',
    docPath: 'doc/components/CdsCheckboxCell.md',
    builder: (_) => const _ControlsCheckboxCellDemo(),
  ),
  CdsDemo(
    title: 'CdsRadio',
    description: 'Standalone radio buttons.',
    docPath: 'doc/components/CdsRadio.md',
    builder: (_) => const _ControlsRadioDemo(),
  ),
  CdsDemo(
    title: 'CdsRadioGroup',
    description: 'Single choice with arrow-key navigation, vertical and horizontal.',
    docPath: 'doc/components/CdsRadioGroup.md',
    builder: (_) => const _ControlsRadioGroupDemo(),
  ),
  CdsDemo(
    title: 'CdsRadioCell',
    description: 'Rich single choice built from bordered radio rows.',
    docPath: 'doc/components/CdsRadioCell.md',
    builder: (_) => const _ControlsRadioCellDemo(),
  ),
  CdsDemo(
    title: 'CdsSwitch',
    description: 'Tap or drag the thumb. Variants, disabled and read-only states.',
    docPath: 'doc/components/CdsSwitch.md',
    builder: (_) => const _ControlsSwitchDemo(),
  ),
  CdsDemo(
    title: 'CdsControlGroup',
    description: 'One API for groups of radios, checkboxes or switches.',
    docPath: 'doc/components/CdsControlGroup.md',
    builder: (_) => const _ControlsControlGroupDemo(),
  ),
];

class _ControlsCheckboxDemo extends StatefulWidget {
  const _ControlsCheckboxDemo();

  @override
  State<_ControlsCheckboxDemo> createState() => _ControlsCheckboxDemoState();
}

class _ControlsCheckboxDemoState extends State<_ControlsCheckboxDemo> {
  bool _terms = false;
  final Set<String> _assets = {'btc'};
  static const _all = {'btc', 'eth', 'usdc'};

  @override
  Widget build(BuildContext context) {
    final allChecked = _assets.length == _all.length;
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Basic',
          child: CdsCheckbox(
            label: 'I agree to the terms of service',
            checked: _terms,
            onChange: (v) => setState(() => _terms = v),
          ),
        ),
        DemoSection(
          title: 'Indeterminate parent',
          caption: 'Sample data',
          child: CdsVStack(
            children: [
              CdsCheckbox(
                label: 'All assets',
                checked: allChecked,
                indeterminate: _assets.isNotEmpty && !allChecked,
                onChange: (v) => setState(() {
                  _assets
                    ..clear()
                    ..addAll(v ? _all : const <String>{});
                }),
              ),
              for (final (value, name) in const [('btc', 'Bitcoin'), ('eth', 'Ethereum'), ('usdc', 'USD Coin')])
                CdsBox(
                  paddingStart: 3,
                  child: CdsCheckbox(
                    label: name,
                    checked: _assets.contains(value),
                    onChange: (v) => setState(() => v ? _assets.add(value) : _assets.remove(value)),
                  ),
                ),
            ],
          ),
        ),
        const DemoSection(
          title: 'Disabled and read-only',
          child: CdsVStack(
            children: [
              CdsCheckbox(label: 'Disabled, unchecked', disabled: true),
              CdsCheckbox(label: 'Disabled, checked', checked: true, disabled: true),
              CdsCheckbox(label: 'Read-only, checked', checked: true, readOnly: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlsCheckboxGroupDemo extends StatefulWidget {
  const _ControlsCheckboxGroupDemo();

  @override
  State<_ControlsCheckboxGroupDemo> createState() => _ControlsCheckboxGroupDemoState();
}

class _ControlsCheckboxGroupDemoState extends State<_ControlsCheckboxGroupDemo> {
  Set<String> _alerts = {'price'};

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Notification types',
      caption: 'Selected: ${_alerts.isEmpty ? 'none' : (_alerts.toList()..sort()).join(', ')}',
      child: CdsCheckboxGroup<String>(
        label: 'Send me',
        options: const [
          CdsControlOption(value: 'price', label: 'Price alerts'),
          CdsControlOption(value: 'news', label: 'Market news'),
          CdsControlOption(value: 'security', label: 'Security alerts (always on)', readOnly: true),
          CdsControlOption(value: 'promo', label: 'Promotions', disabled: true),
        ],
        selectedValues: {..._alerts, 'security'},
        onChange: (next) => setState(() => _alerts = next..remove('security')),
      ),
    );
  }
}

class _ControlsCheckboxCellDemo extends StatefulWidget {
  const _ControlsCheckboxCellDemo();

  @override
  State<_ControlsCheckboxCellDemo> createState() => _ControlsCheckboxCellDemoState();
}

class _ControlsCheckboxCellDemoState extends State<_ControlsCheckboxCellDemo> {
  bool _recurring = true;
  bool _roundUp = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Purchase options',
      child: CdsVStack(
        gap: 1.5,
        children: [
          CdsCheckboxCell(
            title: 'Recurring buy',
            description: 'Repeat this purchase every week',
            checked: _recurring,
            onChange: (v) => setState(() => _recurring = v),
          ),
          CdsCheckboxCell(
            title: 'Round up',
            description: 'Invest spare change from card purchases',
            checked: _roundUp,
            onChange: (v) => setState(() => _roundUp = v),
          ),
          const CdsCheckboxCell(
            title: 'Margin trading',
            description: 'Not available in your region',
            disabled: true,
          ),
        ],
      ),
    );
  }
}

class _ControlsRadioDemo extends StatefulWidget {
  const _ControlsRadioDemo();

  @override
  State<_ControlsRadioDemo> createState() => _ControlsRadioDemoState();
}

class _ControlsRadioDemoState extends State<_ControlsRadioDemo> {
  String _unit = 'usd';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Display currency',
          child: CdsHStack(
            gap: 3,
            children: [
              CdsRadio(label: 'USD', checked: _unit == 'usd', onChange: (_) => setState(() => _unit = 'usd')),
              CdsRadio(label: 'EUR', checked: _unit == 'eur', onChange: (_) => setState(() => _unit = 'eur')),
              CdsRadio(
                label: 'GBP',
                checked: _unit == 'gbp',
                controlColor: CdsColor.bgPositive,
                onChange: (_) => setState(() => _unit = 'gbp'),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: 'Disabled',
          child: CdsHStack(
            gap: 3,
            children: [
              CdsRadio(label: 'Off', disabled: true),
              CdsRadio(label: 'On', checked: true, disabled: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlsRadioGroupDemo extends StatefulWidget {
  const _ControlsRadioGroupDemo();

  @override
  State<_ControlsRadioGroupDemo> createState() => _ControlsRadioGroupDemoState();
}

class _ControlsRadioGroupDemoState extends State<_ControlsRadioGroupDemo> {
  String? _method = 'bank';
  String _frequency = 'weekly';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Vertical',
          caption: 'Tab into the group, then use the arrow keys.',
          child: CdsRadioGroup<String>(
            label: 'Payment method',
            options: const [
              CdsControlOption(value: 'bank', label: 'Bank account'),
              CdsControlOption(value: 'card', label: 'Debit card'),
              CdsControlOption(value: 'gift', label: 'Gift card (unavailable)', disabled: true),
              CdsControlOption(value: 'wire', label: 'Wire transfer'),
            ],
            value: _method,
            radioSemanticLabel: '{{number}} of {{total}}',
            onChange: (v) => setState(() => _method = v),
          ),
        ),
        DemoSection(
          title: 'Horizontal',
          child: CdsRadioGroup<String>(
            label: 'Frequency',
            direction: Axis.horizontal,
            gap: 3,
            options: const [
              CdsControlOption(value: 'daily', label: 'Daily'),
              CdsControlOption(value: 'weekly', label: 'Weekly'),
              CdsControlOption(value: 'monthly', label: 'Monthly'),
            ],
            value: _frequency,
            onChange: (v) => setState(() => _frequency = v),
          ),
        ),
      ],
    );
  }
}

class _ControlsRadioCellDemo extends StatefulWidget {
  const _ControlsRadioCellDemo();

  @override
  State<_ControlsRadioCellDemo> createState() => _ControlsRadioCellDemoState();
}

class _ControlsRadioCellDemoState extends State<_ControlsRadioCellDemo> {
  String _speed = 'standard';

  @override
  Widget build(BuildContext context) {
    Widget cell(String value, String title, String description, {bool disabled = false}) => CdsRadioCell(
          title: title,
          description: description,
          checked: _speed == value,
          disabled: disabled,
          onChange: (_) => setState(() => _speed = value),
        );
    return DemoSection(
      title: 'Transfer speed',
      caption: 'Sample data',
      child: CdsVStack(
        gap: 1.5,
        children: [
          cell('standard', 'Standard', '1 to 3 business days. No fee'),
          cell('instant', 'Instant', 'Arrives in minutes. 1.5% fee'),
          cell('wire', 'Wire', 'Same day. Not available on weekends', disabled: true),
        ],
      ),
    );
  }
}

class _ControlsSwitchDemo extends StatefulWidget {
  const _ControlsSwitchDemo();

  @override
  State<_ControlsSwitchDemo> createState() => _ControlsSwitchDemoState();
}

class _ControlsSwitchDemoState extends State<_ControlsSwitchDemo> {
  bool _alerts = true;
  bool _biometrics = false;
  final Map<CdsSwitchVariant, bool> _variants = {for (final v in CdsSwitchVariant.values) v: true};

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'With labels',
          caption: 'Drag the thumb or tap the row.',
          child: CdsVStack(
            children: [
              CdsSwitch(label: 'Price alerts', checked: _alerts, onChange: (v) => setState(() => _alerts = v)),
              CdsSwitch(
                label: 'Unlock with Face ID',
                checked: _biometrics,
                onChange: (v) => setState(() => _biometrics = v),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Variants',
          child: CdsHStack(
            gap: 2,
            children: [
              for (final v in CdsSwitchVariant.values)
                CdsSwitch(
                  semanticLabel: '${v.name} switch',
                  variant: v,
                  checked: _variants[v]!,
                  onChange: (on) => setState(() => _variants[v] = on),
                ),
            ],
          ),
        ),
        const DemoSection(
          title: 'Disabled and read-only',
          child: CdsVStack(
            children: [
              CdsSwitch(label: 'Disabled, off', disabled: true),
              CdsSwitch(label: 'Disabled, on', checked: true, disabled: true),
              CdsSwitch(label: 'Read-only, on', checked: true, readOnly: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlsControlGroupDemo extends StatefulWidget {
  const _ControlsControlGroupDemo();

  @override
  State<_ControlsControlGroupDemo> createState() => _ControlsControlGroupDemoState();
}

class _ControlsControlGroupDemoState extends State<_ControlsControlGroupDemo> {
  String? _theme = 'system';
  Set<String> _channels = {'email'};
  Set<String> _privacy = {'hide'};

  static const _channelOptions = [
    CdsControlOption(value: 'email', label: 'Email'),
    CdsControlOption(value: 'push', label: 'Push notifications'),
    CdsControlOption(value: 'sms', label: 'Text message'),
  ];

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: '.radio',
          child: CdsControlGroup<String>.radio(
            label: 'Appearance',
            options: const [
              CdsControlOption(value: 'system', label: 'Match device'),
              CdsControlOption(value: 'light', label: 'Light'),
              CdsControlOption(value: 'dark', label: 'Dark'),
            ],
            value: _theme,
            onChange: (v) => setState(() => _theme = v),
          ),
        ),
        DemoSection(
          title: '.checkbox',
          caption: _channels.isEmpty ? 'Select at least one channel.' : null,
          child: CdsControlGroup<String>.checkbox(
            label: 'Contact me by',
            options: _channelOptions,
            value: _channels,
            onChange: (next) => setState(() => _channels = next),
          ),
        ),
        DemoSection(
          title: '.switches',
          child: CdsControlGroup<String>.switches(
            label: 'Privacy',
            options: const [
              CdsControlOption(value: 'hide', label: 'Hide balances'),
              CdsControlOption(value: 'share', label: 'Share usage data'),
              CdsControlOption(value: 'locked', label: 'Managed by your organization', disabled: true),
            ],
            value: _privacy,
            onChange: (next) => setState(() => _privacy = next),
          ),
        ),
      ],
    );
  }
}

final List<CdsDemo> _padsDemos = [
  CdsDemo(
    title: 'CdsNumpad',
    description: 'Amount entry keypad. Long-press backspace to clear.',
    docPath: 'doc/components/CdsNumpad.md',
    builder: (_) => const _PadsNumpadDemo(),
  ),
  CdsDemo(
    title: 'CdsSegmentedControl',
    description: 'Tap or drag across segments; the highlight springs to the selection.',
    docPath: 'doc/components/CdsSegmentedControl.md',
    builder: (_) => const _PadsSegmentedDemo(),
  ),
  CdsDemo(
    title: 'CdsChip',
    description: 'Filter chips in two sizes, with active, slot and disabled states.',
    docPath: 'doc/components/CdsChip.md',
    builder: (_) => const _PadsChipDemo(),
  ),
  CdsDemo(
    title: 'CdsInputChip',
    description: 'Removable chips for selected values.',
    docPath: 'doc/components/CdsInputChip.md',
    builder: (_) => const _PadsInputChipDemo(),
  ),
  CdsDemo(
    title: 'CdsMediaChip',
    description: 'Chips that lead with media and tighten their padding around it.',
    docPath: 'doc/components/CdsMediaChip.md',
    builder: (_) => const _PadsMediaChipDemo(),
  ),
  CdsDemo(
    title: 'CdsTileButton',
    description: 'Square shortcut buttons with an optional count badge.',
    docPath: 'doc/components/CdsTileButton.md',
    builder: (_) => const _PadsTileDemo(),
  ),
];

class _PadsNumpadDemo extends StatefulWidget {
  const _PadsNumpadDemo();

  @override
  State<_PadsNumpadDemo> createState() => _PadsNumpadDemoState();
}

class _PadsNumpadDemoState extends State<_PadsNumpadDemo> {
  String _amount = '';
  bool _wholeNumbers = false;
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Amount entry',
          caption: 'Up to 2 decimals. Long-press the backspace key to clear.',
          child: CdsNumpad(
            disabled: _disabled,
            hideSeparator: _wholeNumbers,
            accessory: CdsVStack(
              gap: 0.5,
              alignItems: CrossAxisAlignment.center,
              children: [
                CdsText(
                  _amount.isEmpty ? r'$0' : '\$$_amount',
                  font: CdsFont.display3,
                  tabularNumbers: true,
                ),
                const CdsText.label2('Sample data', color: CdsColor.fgMuted),
              ],
            ),
            action: CdsButton(
              label: 'Review order',
              block: true,
              onPress: _amount.isEmpty || _disabled ? null : () {},
            ),
            onPress: (key) => setState(
              () => _amount = CdsNumpad.apply(_amount, key, maxDecimals: _wholeNumbers ? 0 : 2, maxLength: 10),
            ),
            onClear: () => setState(() => _amount = ''),
          ),
        ),
        DemoSection(
          title: 'Options',
          child: CdsHStack(
            gap: 1,
            wrap: true,
            children: [
              CdsChip(
                label: 'Whole numbers',
                active: _wholeNumbers,
                selected: _wholeNumbers,
                onPress: () => setState(() => _wholeNumbers = !_wholeNumbers),
              ),
              CdsChip(
                label: 'Disabled',
                active: _disabled,
                selected: _disabled,
                onPress: () => setState(() => _disabled = !_disabled),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PadsSegmentedDemo extends StatefulWidget {
  const _PadsSegmentedDemo();

  @override
  State<_PadsSegmentedDemo> createState() => _PadsSegmentedDemoState();
}

class _PadsSegmentedDemoState extends State<_PadsSegmentedDemo> {
  String _side = 'buy';
  String _range = '1W';
  String _chart = 'line';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Text',
          child: CdsSegmentedControl<String>(
            value: _side,
            onChange: (v) => setState(() => _side = v),
            semanticLabel: 'Order side',
            options: const [
              CdsSegmentedControlOption(value: 'buy', label: 'Buy'),
              CdsSegmentedControlOption(value: 'sell', label: 'Sell'),
              CdsSegmentedControlOption(value: 'convert', label: 'Convert'),
            ],
          ),
        ),
        DemoSection(
          title: 'Block',
          caption: 'Fills the width. Drag across to scrub between ranges.',
          child: CdsSegmentedControl<String>(
            value: _range,
            block: true,
            onChange: (v) => setState(() => _range = v),
            semanticLabel: 'Chart range',
            options: [
              for (final r in const ['1D', '1W', '1M', '1Y', 'All']) CdsSegmentedControlOption(value: r, label: r),
            ],
          ),
        ),
        DemoSection(
          title: 'Icons',
          child: CdsSegmentedControl<String>(
            value: _chart,
            onChange: (v) => setState(() => _chart = v),
            semanticLabel: 'Chart type',
            options: const [
              CdsSegmentedControlOption(value: 'line', icon: CdsIconName.chartLine, semanticLabel: 'Line chart'),
              CdsSegmentedControlOption(value: 'bar', icon: CdsIconName.chartBar, semanticLabel: 'Bar chart'),
            ],
          ),
        ),
        DemoSection(
          title: 'Disabled',
          child: CdsSegmentedControl<String>(
            value: 'buy',
            disabled: true,
            onChange: (_) {},
            options: const [
              CdsSegmentedControlOption(value: 'buy', label: 'Buy'),
              CdsSegmentedControlOption(value: 'sell', label: 'Sell'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PadsChipDemo extends StatefulWidget {
  const _PadsChipDemo();

  @override
  State<_PadsChipDemo> createState() => _PadsChipDemoState();
}

class _PadsChipDemoState extends State<_PadsChipDemo> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Filter row',
          caption: 'The active chip inverts its colors.',
          child: CdsHStack(
            gap: 1,
            wrap: true,
            children: [
              for (final f in ['All', 'Gainers', 'Losers', 'Watchlist'])
                CdsChip(
                  label: f,
                  active: _filter == f,
                  selected: _filter == f,
                  onPress: () => setState(() => _filter = f),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Sizes and slots',
          child: CdsHStack(
            gap: 1,
            wrap: true,
            children: [
              CdsChip(label: 'Size s', onPress: () {}),
              CdsChip(label: 'Size xs', size: CdsChipSize.xs, onPress: () {}),
              CdsChip(
                label: 'Sort',
                end: const CdsIcon(CdsIconName.caretDown, size: CdsIconSize.xs),
                onPress: () {},
              ),
              CdsChip(
                label: 'Search',
                start: const CdsIcon(CdsIconName.search, size: CdsIconSize.s),
                onPress: () {},
              ),
              const CdsChip(label: 'Static'),
              CdsChip(label: 'Disabled', disabled: true, onPress: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _PadsInputChipDemo extends StatefulWidget {
  const _PadsInputChipDemo();

  @override
  State<_PadsInputChipDemo> createState() => _PadsInputChipDemoState();
}

class _PadsInputChipDemoState extends State<_PadsInputChipDemo> {
  static const _all = ['BTC', 'ETH', 'SOL', 'USDC', 'DOGE'];
  List<String> _selected = List.of(_all);

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Selected assets',
      caption: 'Sample data. Press a chip to remove it.',
      child: CdsVStack(
        gap: 2,
        alignItems: CrossAxisAlignment.start,
        children: [
          if (_selected.isEmpty)
            const CdsText.label2('No assets selected. Reset to add them back.', color: CdsColor.fgMuted)
          else
            CdsHStack(
              gap: 1,
              wrap: true,
              children: [
                for (final a in _selected)
                  CdsInputChip(label: a, onPress: () => setState(() => _selected = [..._selected]..remove(a))),
                const CdsInputChip(label: 'Disabled', disabled: true),
              ],
            ),
          CdsButton(
            label: 'Reset',
            variant: CdsButtonVariant.secondary,
            size: CdsButtonSize.s,
            onPress: () => setState(() => _selected = List.of(_all)),
          ),
        ],
      ),
    );
  }
}

class _PadsMediaDot extends StatelessWidget {
  const _PadsMediaDot(this.color);

  final CdsColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: context.cds.colorOf(color), shape: BoxShape.circle),
    );
  }
}

class _PadsMediaChipDemo extends StatefulWidget {
  const _PadsMediaChipDemo();

  @override
  State<_PadsMediaChipDemo> createState() => _PadsMediaChipDemoState();
}

class _PadsMediaChipDemoState extends State<_PadsMediaChipDemo> {
  String _network = 'Base';

  @override
  Widget build(BuildContext context) {
    const networks = {
      'Base': CdsColor.accentBoldBlue,
      'Ethereum': CdsColor.accentBoldPurple,
      'Solana': CdsColor.accentBoldGreen,
    };
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Network picker',
          caption: 'Sample data. Colored dots stand in for network logos.',
          child: CdsHStack(
            gap: 1,
            wrap: true,
            children: [
              for (final e in networks.entries)
                CdsMediaChip(
                  label: e.key,
                  start: _PadsMediaDot(e.value),
                  active: _network == e.key,
                  selected: _network == e.key,
                  onPress: () => setState(() => _network = e.key),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Slot combinations',
          child: CdsHStack(
            gap: 1,
            wrap: true,
            children: [
              CdsMediaChip(start: const _PadsMediaDot(CdsColor.accentBoldYellow), onPress: () {}, semanticLabel: 'Media only'),
              CdsMediaChip(
                start: const _PadsMediaDot(CdsColor.accentBoldRed),
                end: const CdsIcon(CdsIconName.caretDown, size: CdsIconSize.xs),
                onPress: () {},
                semanticLabel: 'Choose asset',
              ),
              CdsMediaChip(
                label: 'Size xs',
                size: CdsChipSize.xs,
                start: const _PadsMediaDot(CdsColor.accentBoldGray),
                onPress: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PadsTileDemo extends StatefulWidget {
  const _PadsTileDemo();

  @override
  State<_PadsTileDemo> createState() => _PadsTileDemoState();
}

class _PadsTileDemoState extends State<_PadsTileDemo> {
  int _unread = 3;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Shortcuts',
      caption: 'Sample data. Press Inbox to mark messages read.',
      child: CdsHStack(
        gap: 1,
        wrap: true,
        children: [
          CdsTileButton(
            title: 'Send',
            onPress: () {},
            child: const CdsIcon(CdsIconName.paperAirplane, size: CdsIconSize.l),
          ),
          CdsTileButton(
            title: 'Inbox',
            count: _unread,
            onPress: () => setState(() => _unread = _unread == 0 ? 3 : 0),
            child: const CdsIcon(CdsIconName.bell, size: CdsIconSize.l),
          ),
          CdsTileButton(
            title: 'Notifications',
            count: 120,
            onPress: () {},
            child: const CdsIcon(CdsIconName.bellCheck, size: CdsIconSize.l),
          ),
          CdsTileButton(
            title: 'Recurring purchases',
            onPress: () {},
            child: const CdsIcon(CdsIconName.wallet, size: CdsIconSize.l),
          ),
          const CdsTileButton(
            title: 'Disabled',
            disabled: true,
            child: CdsIcon(CdsIconName.star, size: CdsIconSize.l),
          ),
        ],
      ),
    );
  }
}

final List<CdsDemo> _gesturesDemos = [
  CdsDemo(
    title: 'CdsSlideButton',
    description: 'Slide-to-confirm with a reset, every variant and size, and a disabled state.',
    docPath: 'doc/components/CdsSlideButton.md',
    builder: (context) => const _GesturesSlideButtonDemo(),
  ),
  CdsDemo(
    title: 'CdsSlider',
    description: 'Continuous and stepped sliders with live values.',
    docPath: 'doc/components/CdsSlider.md',
    builder: (context) => const _GesturesSliderDemo(),
  ),
  CdsDemo(
    title: 'CdsRangeSlider',
    description: 'Two thumbs that pick a start and end value.',
    docPath: 'doc/components/CdsRangeSlider.md',
    builder: (context) => const _GesturesRangeSliderDemo(),
  ),
];

class _GesturesSlideButtonDemo extends StatefulWidget {
  const _GesturesSlideButtonDemo();

  @override
  State<_GesturesSlideButtonDemo> createState() => _GesturesSlideButtonDemoState();
}

class _GesturesSlideButtonDemoState extends State<_GesturesSlideButtonDemo> {
  bool _sent = false;
  final Map<String, bool> _checked = {};

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Slide to confirm',
          caption: 'Sample data. Release past 70% or flick forward to commit.',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsSlideButton(
                checked: _sent,
                onChange: (v) => setState(() => _sent = v),
                uncheckedLabel: 'Slide to send 0.05 BTC',
                checkedLabel: 'Sending',
              ),
              CdsButton(
                label: 'Reset',
                variant: CdsButtonVariant.secondary,
                disabled: !_sent,
                onPress: () => setState(() => _sent = false),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Variants and sizes',
          caption: 'Each one stays committed until you press Reset variants.',
          child: CdsVStack(
            gap: 2,
            children: [
              for (final variant in CdsSlideButtonVariant.values)
                for (final size in CdsSlideButtonSize.values)
                  _variantButton(variant, size),
            ],
          ),
        ),
        DemoSection(
          title: 'Reset all',
          child: CdsButton(
            label: 'Reset variants',
            variant: CdsButtonVariant.secondary,
            onPress: () => setState(_checked.clear),
          ),
        ),
        const DemoSection(
          title: 'Disabled',
          child: CdsSlideButton(checked: false, disabled: true, uncheckedLabel: 'Slide to send'),
        ),
      ],
    );
  }

  Widget _variantButton(CdsSlideButtonVariant variant, CdsSlideButtonSize size) {
    final key = '${variant.name}-${size.name}';
    final label = switch (variant) {
      CdsSlideButtonVariant.primary => 'Slide to buy',
      CdsSlideButtonVariant.positive => 'Slide to deposit',
      CdsSlideButtonVariant.negative => 'Slide to close account',
    };
    return CdsSlideButton(
      checked: _checked[key] ?? false,
      onChange: (v) => setState(() => _checked[key] = v),
      variant: variant,
      size: size,
      uncheckedLabel: '$label (${size.name})',
      checkedLabel: 'Done',
    );
  }
}

class _GesturesSliderDemo extends StatefulWidget {
  const _GesturesSliderDemo();

  @override
  State<_GesturesSliderDemo> createState() => _GesturesSliderDemoState();
}

class _GesturesSliderDemoState extends State<_GesturesSliderDemo> {
  double _percent = 0.4;
  double _amount = 250;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Continuous',
          caption: 'Allocation: ${(_percent * 100).round()}%',
          child: CdsSlider(
            value: _percent,
            onChange: (v) => setState(() => _percent = v),
            semanticLabel: 'Allocation',
          ),
        ),
        DemoSection(
          title: 'Stepped',
          caption: 'Sample data. Amount: \$${_amount.round()} in \$50 steps.',
          child: CdsSlider(
            value: _amount,
            min: 0,
            max: 1000,
            divisions: 20,
            onChange: (v) => setState(() => _amount = v),
            semanticLabel: 'Amount',
            formatValue: (v) => '${v.round()} dollars',
          ),
        ),
        const DemoSection(
          title: 'Disabled',
          child: CdsSlider(value: 0.6, onChange: null, disabled: true, semanticLabel: 'Disabled'),
        ),
      ],
    );
  }
}

class _GesturesRangeSliderDemo extends StatefulWidget {
  const _GesturesRangeSliderDemo();

  @override
  State<_GesturesRangeSliderDemo> createState() => _GesturesRangeSliderDemoState();
}

class _GesturesRangeSliderDemoState extends State<_GesturesRangeSliderDemo> {
  CdsRangeValues _range = (start: 20000, end: 60000);

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Price range',
      caption: 'Sample data. \$${_range.start.round()} to \$${_range.end.round()}',
      child: CdsRangeSlider(
        values: _range,
        min: 0,
        max: 100000,
        divisions: 100,
        onChange: (v) => setState(() => _range = v),
        startSemanticLabel: 'Minimum price',
        endSemanticLabel: 'Maximum price',
        formatValue: (v) => '${v.round()} dollars',
      ),
    );
  }
}
