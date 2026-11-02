# CdsDataCard

A card pairing a title with a data visualization such as a progress bar or circle.

CDS reference: https://cds.coinbase.com/components/cards/DataCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDataCard(
  title: 'Savings goal',
  subtitle: r'$450 of $1,000',
  thumbnail: const CdsCellMedia.icon(CdsIconName.wallet),
  child: const CdsProgressCircle(progress: 0.45, size: 48),
)
```

## When to use / when not to

Use for goals, limits and progress summaries. The visualization is a widget slot, so any progress or chart widget fits.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | Up to two `headline` lines. A title or `titleNode` is required. |
| `titleNode` | `Widget?` | `null` | |
| `subtitle` | `String?` | `null` | One muted `label2` line above the title. |
| `subtitleNode` | `Widget?` | `null` | |
| `titleAccessory` | `Widget?` | `null` | Right after the title, e.g. a `CdsTag`. |
| `thumbnail` | `Widget?` | `null` | Image or icon in the header. |
| `layout` | `CdsDataCardLayout` | `vertical` | `vertical` stacks header over visualization; `horizontal` puts them side by side. |
| `child` | `Widget?` | `null` | The visualization. |
| `background` | `CdsColor` | `bgAlternate` | |
| `onPress` | `VoidCallback?` | `null` | |
| `feedback` | `CdsHapticFeedback` | `none` | |
| `semanticLabel` | `String?` | subtitle and title | Card button label when pressable. |

## Examples

### Horizontal

```dart
CdsDataCard(
  layout: CdsDataCardLayout.horizontal,
  title: 'Weekly limit',
  subtitle: 'Sample data',
  child: const CdsProgressCircle(progress: 0.7, size: 64, showLabel: true),
)
```

## Accessibility

When pressable, the card is one button labelled with its subtitle and title.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

This follows the current CDS DataCard (`@coinbase/cds-mobile/alpha/data-card`). The older DataCard with `progress`/`progressVariant` props is deprecated in CDS.

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `subtitle` (string / node) | `title`/`titleNode`, `subtitle`/`subtitleNode` |
| `titleAccessory`, `thumbnail`, `layout` | same names |
| `children` | `child` |
| `renderAsPressable` + `onPress` | `onPress` |
