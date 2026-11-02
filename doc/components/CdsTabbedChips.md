# CdsTabbedChips

A horizontally scrolling row of chips that behaves as a tab list. The active chip inverts its color scheme. Reach for it for nested tabs and filters under a top-level tab bar.

CDS reference: https://cds.coinbase.com/components/navigation/TabbedChips

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
String filter = 'all';

CdsTabbedChips(
  accessibilityLabel: 'Asset filters',
  tabs: const [
    CdsTabValue(id: 'all', label: 'All'),
    CdsTabValue(id: 'gainers', label: 'Top gainers'),
    CdsTabValue(id: 'new', label: 'New'),
  ],
  value: filter,
  onChange: (id) => setState(() => filter = id),
)
```

## When to use / when not to

- Use for secondary navigation or filters, many options, or labels of varied length.
- Use [CdsTabNavigation](CdsTabNavigation.md) for the primary tab bar of a screen.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| tabs | `List<CdsTabValue>` | required | Chips in display order. |
| onChange | `ValueChanged<String>` | required | Called with the picked id. |
| value | `String?` | first tab | Id of the active chip. |
| gap | `double` | `1` | Space token between chips. |
| paddingX | `double` | `0` | Space token inset at both ends of the scrolling row. |
| tabBuilder | `CdsTabContentBuilder?` | `null` | Custom chip content. |
| accessibilityLabel | `String?` | `null` | Names the list for screen readers. |

## Examples

### Edge-to-edge row with page gutters

```dart
CdsTabbedChips(paddingX: 3, tabs: filters, value: filter, onChange: (id) => setState(() => filter = id))
```

## Accessibility

- Tab bar and tab roles with selected state. The inverted chip is not the only cue: selection is also exposed semantically.
- Arrow keys, Home and End move the selection; the chip keeps keyboard focus as it inverts.
- Chips are 40px tall and centered in a 44px hit area.

## Motion

- The active chip scrolls into view (`CdsDurations.moderate2`, `CdsCurves.global`; instant under reduced motion).
- The trailing fade appears only while more chips are offscreen.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `tabs` | `tabs` |
| `value` | `value` |
| `onChange` | `onChange` |
| `Component` | `tabBuilder` |
| `gap` | `gap` |
