# CdsTabLabel

The text of one tab in a [CdsTabNavigation], with an optional count badge that animates in and out.

CDS reference: https://cds.coinbase.com/components/navigation/TabLabel

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsTabLabel('Watchlist', active: true, count: 2)
```

## When to use / when not to

- Use inside a custom tab row, or via `CdsTabNavigation.tabBuilder` to reuse the CDS look.
- `CdsTabNavigation` already renders `CdsTabLabel` for each tab; you rarely need it directly.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| label | `String` | required (positional) | Tab text. |
| active | `bool` | `false` | Active styling. |
| variant | `CdsTabLabelVariant` | `primary` | `primary`: headline, `fgPrimary` when active, `fg` otherwise, padding 16 top / 14 bottom to sit on a 2px indicator. `secondary`: `title3` active / `title4` inactive, `fg` / `fgMuted`. |
| count | `int` | `0` | Badge value; zero or less hides it. |
| max | `int?` | `null` (99) | Counts above this show as `max+`. |

## Examples

### Secondary variant

```dart
const CdsTabLabel('Assets', variant: CdsTabLabelVariant.secondary, active: true)
```

The secondary variant reserves the width of its bold active style, so switching tabs never shifts neighbouring labels. CDS marks it deprecated; prefer primary tabs or [CdsTabbedChips](CdsTabbedChips.md).

## Accessibility

- Renders plain text; the surrounding tab supplies the role and selected state.
- The badge digits are read with the label (for example "Inbox 3").

## Motion

- The badge grows from zero width with `CdsDurations.fast1` and `CdsCurves.global` and fades in; it fades out and collapses when the count returns to zero.
- Reduced motion shows and hides the badge instantly.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `label` |
| `active` | `active` |
| `variant` | `variant` |
| `count` | `count` |
| `max` | `max` |
