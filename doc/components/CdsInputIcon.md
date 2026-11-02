# CdsInputIcon

Icons for a text field's `start` and `end` slots: `CdsInputIcon` is decorative, `CdsInputIconButton` is a transparent icon button for actions such as clear or reveal password. Both follow the field's focus color.

CDS reference: https://cds.coinbase.com/components/inputs/TextInput

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTextInput(
  label: 'Wallet address',
  start: const CdsInputIcon(CdsIconName.wallet),
  end: CdsInputIconButton(
    CdsIconName.close,
    semanticLabel: 'Clear address',
    onPress: () => setState(() => address = ''),
  ),
  value: address,
  onChange: (v) => setState(() => address = v),
)
```

## When to use / when not to

- Use `CdsInputIcon` to hint at the field's content (a search glass, a currency).
- Use `CdsInputIconButton` for one action tied to the field.
- Do not put more than one button in a slot; move extra actions next to the field.

## Parameters

### CdsInputIcon

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `CdsIconName` | required (positional) | Glyph. |
| `color` | `CdsColor` | `CdsColor.fg` | Used when there is no enclosing field or `disableInheritFocusStyle` is set. |
| `active` | `bool` | `false` | Filled glyph. |
| `disableInheritFocusStyle` | `bool` | `false` | Keep `color` while the field is focused. |
| `compact` | `bool` | `false` | 8px horizontal padding instead of 16px. |
| `semanticLabel` | `String?` | `null` | Decorative (hidden from screen readers) when null. |

Size is `CdsIconSize.s` (16px).

### CdsInputIconButton

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `CdsIconName` | required (positional) | Glyph. |
| `semanticLabel` | `String` | required | What the button does. |
| `onPress` | `VoidCallback?` | `null` | Disabled when null. |
| `variant` | `CdsButtonVariant` | `primary` | Used when there is no enclosing field or `disableInheritFocusStyle` is set. |
| `disableInheritFocusStyle` | `bool` | `false` | Keep `variant` regardless of the field's state. |
| `disabled` | `bool` | `false` | |
| `active` | `bool` | `false` | Filled glyph. |
| `focusNode` | `FocusNode?` | `null` | |

Inside a field the button is `primary` (blue glyph) when the field's focused variant is anything but `foregroundMuted` or `secondary`, and `secondary` otherwise. It renders a transparent `CdsIconButton` with a 44px hit area, 8px start and 4px end padding.

## Examples

### Follow the focus color

```dart
const CdsTextInput(label: 'Search', start: CdsInputIcon(CdsIconName.search))
```

### Fixed color

```dart
const CdsInputIcon(CdsIconName.info, color: CdsColor.fgMuted, disableInheritFocusStyle: true)
```

## Accessibility

`CdsInputIcon` is hidden from screen readers unless you pass `semanticLabel`. `CdsInputIconButton` requires `semanticLabel`, is keyboard focusable and activates with Enter or Space.

## Motion

`CdsInputIconButton` inherits `CdsPressable` feedback: tint and 0.98 scale on pointer-down. Color changes with focus are immediate.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `InputIcon` `name`, `color`, `active` | `CdsInputIcon` `name`, `color`, `active` |
| `disableInheritFocusStyle` | same name |
| `compact` | `compact` |
| `accessibilityLabel` | `semanticLabel` |
| `InputIconButton` `name`, `onPress`, `variant` | `CdsInputIconButton` `name`, `onPress`, `variant` |
| `InputIconButton` `accessibilityLabel` | `semanticLabel` (required) |
