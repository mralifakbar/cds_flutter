# CdsPageFooter

The bottom bar of a page that holds its main action, with optional legal text underneath.

CDS reference: https://cds.coinbase.com/components/navigation/PageFooter

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPageFooter(
  action: CdsButton(label: 'Continue', block: true, onPress: next),
)
```

## When to use / when not to

- Use for the one primary action of a flow step.
- Wrap it in [CdsStickyFooter](CdsStickyFooter.md) or pass it as [CdsScaffold](CdsScaffold.md)'s `footer` to pin it above the keyboard and home indicator.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| action | `Widget` | required | Usually a block `CdsButton` or a button group. |
| legalText | `String?` | `null` | `legal`, `fgMuted`, centered under the action with a 16px gap. |
| background | `CdsColor?` | `null` | Fill behind the footer. |
| accessibilityLabel | `String?` | `null` | Names the footer region. |

Layout: 24px horizontal and 12px vertical padding; at least 80px tall without legal text; content centered.

## Examples

### With legal text

```dart
CdsPageFooter(
  action: CdsButton(label: 'Buy Bitcoin', block: true, onPress: buy),
  legalText: 'Prices update every 30 seconds.',
)
```

## Accessibility

A labelled container when `accessibilityLabel` is set; the action keeps its own button semantics.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `action` | `action` |
| `legalText` | `legalText` |
| `background` | `background` |
| `accessibilityRole="toolbar"` | labelled container via `accessibilityLabel` |
