# CdsSegmentedTabs

Pill-shaped tabs on a tinted track. The active pill slides between options with a spring and the label colors cross-fade. Reach for it for compact, mutually exclusive modes such as Buy / Sell.

CDS reference: https://cds.coinbase.com/components/navigation/SegmentedTabs

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
String side = 'buy';

CdsSegmentedTabs(
  accessibilityLabel: 'Order type',
  tabs: const [
    CdsTabValue(id: 'buy', label: 'Buy'),
    CdsTabValue(id: 'sell', label: 'Sell'),
  ],
  activeTab: side,
  onChange: (id) => setState(() => side = id),
)
```

## When to use / when not to

- Use for two to four short options that switch a mode or view.
- Use [CdsTabs](CdsTabs.md) when labels are longer or there are more options.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| tabs | `List<CdsTabValue>` | required | Options in display order. |
| activeTab | `String?` | required | Id of the active option; `null` shows no pill. |
| onChange | `ValueChanged<String>` | required | Called with the picked id. |
| disabled | `bool` | `false` | Disables every option. |
| equalWidth | `bool` | `false` | Fill the parent's width and split it evenly. |
| color | `CdsColor` | `CdsColor.fg` | Inactive label color. |
| activeColor | `CdsColor` | `CdsColor.fgInverse` | Active label color. |
| background | `CdsColor` | `CdsColor.bgSecondary` | Track color. |
| activeBackground | `CdsColor` | `CdsColor.bgInverse` | Pill color. |
| borderRadius | `int` | `700` | Track radius token. |
| font | `CdsFont` | `CdsFont.headline` | Label font. |
| gap | `double` | `0` | Space token between options. |
| pageController | `PageController?` | `null` | Pill follows a `PageView` swipe. |
| tabBuilder | `CdsTabContentBuilder?` | `null` | Custom label content per option. |
| accessibilityLabel | `String?` | `null` | Names the group for screen readers. |

## Examples

### Equal width

```dart
CdsSegmentedTabs(
  equalWidth: true,
  tabs: const [
    CdsTabValue(id: '1d', label: '1D'),
    CdsTabValue(id: '1w', label: '1W'),
    CdsTabValue(id: '1m', label: '1M'),
    CdsTabValue(id: '1y', label: '1Y'),
  ],
  activeTab: range,
  onChange: (id) => setState(() => range = id),
)
```

## Accessibility

- Tab bar and tab roles with selected state and tap action.
- Left and Right arrows (mirrored in RTL), Home and End move the selection.
- Each option is at least 44px tall.

## Motion

- The pill springs (`CdsSprings.standard`) from its current position and width.
- Label colors cross-fade over `CdsDurations.fast3` with `CdsCurves.global`.
- Reduced motion moves the pill and colors instantly.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `tabs`, `activeTab`, `onChange` | `tabs`, `activeTab` (id), `onChange` (id) |
| `equalWidth` | `equalWidth` |
| `background`, `activeBackground` | `background`, `activeBackground` |
| `color`, `activeColor` | `color`, `activeColor` |
| `borderRadius` | `borderRadius` |
| `TabComponent` | `tabBuilder` |
| `TabsActiveIndicatorComponent` | not exposed |

Deviation: options are at least 44px tall (CDS draws 40px) so each pill meets the minimum tap target.
