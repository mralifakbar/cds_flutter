# CdsSwitch

An on/off switch with an optional label, for settings that take effect as soon as they change.

CDS reference: https://cds.coinbase.com/components/inputs/Switch

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSwitch(
  label: 'Price alerts',
  checked: alerts,
  onChange: (value) => setState(() => alerts = value),
)
```

## When to use / when not to

- Use for a binary setting applied immediately (notifications, biometrics, hide balances).
- Use `CdsCheckbox` when the choice is submitted later with a form, or for selecting items in a list.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `bool` | `false` | Whether the switch is on. Controlled. |
| `onChange` | `ValueChanged<bool>?` | `null` | Called with the next state after a tap or a drag that changes sides. Null makes the switch inert and dimmed. |
| `label` | `String?` | `null` | Label next to the switch. Also the accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom label widget. Takes precedence over `label`. |
| `variant` | `CdsSwitchVariant` | `CdsSwitchVariant.primary` | Track color when on: `primary` (`bgPrimary`), `positive` (`bgPositive`), `negative` (`bgNegative`). |
| `disabled` | `bool` | `false` | Blocks taps and drags, dims to 50%. |
| `readOnly` | `bool` | `false` | Blocks interaction and dims, announced as read-only. |
| `background` | `CdsColor?` | `null` | Track color when on. Overrides `variant`. The off track is always `bgTertiary`. |
| `controlColor` | `CdsColor?` | `null` | Thumb color. Defaults to `fgInverse` in light and `fg` in dark. |
| `elevation` | `CdsElevation` | `CdsElevation.none` | Thumb shadow. |
| `font` | `CdsFont` | `CdsFont.body` | Label ramp entry. |
| `color` | `CdsColor?` | `null` | Fixed label color. By default `fgMuted` off and `fg` on. |
| `semanticLabel` | `String?` | `null` | Replaces the label for screen readers. Required when there is no `label`. |
| `semanticHint` | `String?` | `null` | Extra hint. |
| `focusNode` | `FocusNode?` | `null` | Focus node for the control. |
| `autofocus` | `bool` | `false` | Request focus on first build. |

Track and thumb sizes come from `theme.controlSize`: `switchWidth` 52, `switchHeight` 32, `switchThumbSize` 30.

## Examples

### Variants

```dart
CdsSwitch(semanticLabel: 'Auto-invest', variant: CdsSwitchVariant.positive, checked: on, onChange: setOn)
CdsSwitch(semanticLabel: 'Lock account', variant: CdsSwitchVariant.negative, checked: locked, onChange: setLocked)
```

### Disabled and read-only

```dart
const CdsSwitch(label: 'Managed by your organization', checked: true, disabled: true)
const CdsSwitch(label: 'Two-step verification', checked: true, readOnly: true)
```

## Accessibility

- Exposes toggled state, the label, enabled state and a tap action.
- The whole row is pressable; the hit area is at least 44px tall.
- Tab focuses and shows the focus ring; Space or Enter toggles.
- In right-to-left layouts "on" sits at the left and drag direction is mirrored.

## Motion

- Tapping springs the thumb to the other side with `CdsSprings.standard`, starting from wherever it is, so rapid taps never jump. The track color follows the thumb position.
- The thumb can be dragged. It follows the finger 1:1 from the touch point, and rubberbands (`CdsMotion.rubberband`) past either end. On release, `CdsMotion.project` of the release velocity decides the side, so a short quick flick commits while a slow short drag returns. The settle spring (`CdsSprings.momentum` after a flick) carries the release velocity.
- A light haptic fires when the value changes. If a controlled parent rejects the change, the thumb springs back to the parent's value.
- Reduced motion: the thumb jumps to its new side; dragging still follows the finger.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `checked` | `checked` |
| `onChange(value, checked)` | `onChange(bool)` |
| `children` | `label` / `labelNode` |
| `variant` | `variant` (`CdsSwitchVariant`) |
| `background` | `background` |
| `controlColor` | `controlColor` |
| `elevation` | `elevation` |
| `disabled` / `readOnly` | `disabled` / `readOnly` |
| `accessibilityLabel` / `accessibilityHint` | `semanticLabel` / `semanticHint` |
