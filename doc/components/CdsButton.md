# CdsButton

A pill-shaped button with a text label, for the actions people take on a screen.

CDS reference: https://cds.coinbase.com/components/inputs/Button

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsButton(label: 'Buy Bitcoin', onPress: () => buy())
```

## When to use / when not to

- Use one `primary` button for the main action of a screen. Pair it with `secondary` for the alternative.
- Use `negative` only for destructive or irreversible actions, `positive` for confirming a good outcome.
- Use `transparent: true` for low-emphasis actions in headers and toolbars.
- For an icon-only action use `CdsIconButton`. For navigation inside text use `CdsLink`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | required | Button text. Truncates after `maxLines`. |
| `onPress` | `VoidCallback?` | `null` | Called on tap, Enter or Space. `null` renders the button disabled. |
| `onLongPress` | `VoidCallback?` | `null` | Called on long press. |
| `variant` | `CdsButtonVariant` | `primary` | `primary`, `secondary`, `tertiary`, `foregroundMuted`, `positive`, `negative`, `inverse`. |
| `size` | `CdsButtonSize` | `l` | `xs` (label1 font), `s`, `m`, `l` (56px tall). |
| `disabled` | `bool` | `false` | Dims the button and blocks presses. |
| `loading` | `bool` | `false` | Shows a spinner in place of the label, keeps the width, blocks presses, announces "loading". |
| `transparent` | `bool` | `false` | No background until pressed or hovered. |
| `block` | `bool` | `false` | Stretch to the parent's width. |
| `startIcon` / `endIcon` | `CdsIconName?` | `null` | Icons before / after the label. |
| `startIconActive` / `endIconActive` | `bool` | `false` | Use the filled glyph. |
| `start` / `end` | `Widget?` | `null` | Custom slots; override the icons. |
| `flush` | `CdsFlush?` | `null` | `start` or `end`: offsets the padding so the label aligns with the edge content. |
| `noScaleOnPress` | `bool` | `false` | Disable the 0.98 press scale. |
| `maxLines` | `int` | `1` | Lines before the label truncates. |
| `feedback` | `CdsHapticFeedback?` | light for xs/s, normal for m/l | Haptic fired on press. |
| `semanticLabel` | `String?` | label | Override what screen readers announce. |
| `semanticHint` | `String?` | `null` | Extra screen reader hint. |
| `focusNode`, `autofocus` | | | Keyboard focus control. |

## Examples

### Primary and secondary pair

```dart
CdsHStack(gap: 1, children: [
  Expanded(child: CdsButton(label: 'Cancel', variant: CdsButtonVariant.secondary, block: true, onPress: close)),
  Expanded(child: CdsButton(label: 'Send USDC', block: true, onPress: send)),
])
```

### Loading while a request runs

```dart
CdsButton(label: 'Place order', block: true, loading: isSubmitting, onPress: submit)
```

### With icons

```dart
CdsButton(label: 'Receive', startIcon: CdsIconName.arrowDown, variant: CdsButtonVariant.secondary, onPress: receive)
```

### Destructive, low emphasis

```dart
CdsButton(label: 'Remove wallet', variant: CdsButtonVariant.negative, transparent: true, onPress: confirmRemove)
```

## Accessibility

- Announced as a button with its label; disabled and loading states are exposed.
- Hit area is at least 44px tall even at `xs`.
- Focusable with Tab; Enter and Space activate; the focus ring uses `bgLinePrimary`.

## Motion

Pointer-down tints the background and scales the button to 0.98 with a spring that starts from the current scale, so rapid taps never jump. Release eases back. Reduced motion keeps the tint and drops the scale.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `label` |
| `onPress` | `onPress` |
| `variant`, `size`, `disabled`, `loading`, `transparent`, `block` | same names |
| `startIcon`, `endIcon`, `start`, `end`, `flush` | same names (`flush: CdsFlush.start`) |
| `compact` (deprecated) | `size: CdsButtonSize.s` |
| `numberOfLines` | `maxLines` |
| `accessibilityLabel` | `semanticLabel` |
