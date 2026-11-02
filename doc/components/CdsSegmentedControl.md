# CdsSegmentedControl

A row of mutually exclusive options with a highlight that slides to the selected one, for switching views or units within a screen ("Buy | Sell", "1D | 1W | 1M").

CDS reference: https://cds.coinbase.com/components/inputs/SegmentedControl

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSegmentedControl<String>(
  value: side,
  onChange: (v) => setState(() => side = v),
  options: const [
    CdsSegmentedControlOption(value: 'buy', label: 'Buy'),
    CdsSegmentedControlOption(value: 'sell', label: 'Sell'),
  ],
)
```

## When to use / when not to

- Use for 2 to 5 short options that change what the current screen shows.
- Do not use for navigation between screens (use tabs) or for settings that submit a form (use `CdsRadioGroup`).

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<CdsSegmentedControlOption<T>>` | required | At least two. |
| `value` | `T` | required | Selected value. A value matching no option shows no highlight. |
| `onChange` | `ValueChanged<T>?` | `null` | Called with the newly selected value. `null` makes the control read-only. |
| `block` | `bool` | `false` | Fill the parent width. Otherwise every segment is as wide as the widest label. |
| `disabled` | `bool` | `false` | Dims the segments and ignores taps, drags and keys. |
| `iconSize` | `CdsIconSize` | `m` | Size of icon options. |
| `feedback` | `CdsHapticFeedback` | `selection` | Haptic when the selection changes. |
| `semanticLabel` | `String?` | `null` | Names the group for screen readers. |

### CdsSegmentedControlOption<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `T` | required | |
| `label` | `String?` | `null` | Text label. Give either `label` or `icon`. |
| `icon` | `CdsIconName?` | `null` | Icon label. |
| `iconActive` | `bool` | `false` | Filled glyph. |
| `semanticLabel` | `String?` | `label` | Required in practice for icon options. |

## Examples

### Full-width range picker

```dart
CdsSegmentedControl<String>(
  value: range,
  block: true,
  onChange: (v) => setState(() => range = v),
  semanticLabel: 'Chart range',
  options: [
    for (final r in const ['1D', '1W', '1M', '1Y', 'All']) CdsSegmentedControlOption(value: r, label: r),
  ],
)
```

### Icons

```dart
CdsSegmentedControl<String>(
  value: chart,
  onChange: (v) => setState(() => chart = v),
  options: const [
    CdsSegmentedControlOption(value: 'line', icon: CdsIconName.chartLine, semanticLabel: 'Line chart'),
    CdsSegmentedControlOption(value: 'bar', icon: CdsIconName.chartBar, semanticLabel: 'Bar chart'),
  ],
)
```

## Accessibility

- The group is a container labeled `semanticLabel`. Each segment is a button in a mutually exclusive group with a `selected` state, labeled by its `semanticLabel` or `label`.
- Tab reaches the segments; Enter or Space selects; Left and Right arrows move the selection (mirrored in RTL).
- The selected segment adds a checkmark and a heavier weight, so state is not conveyed by color alone.
- Segments are at least 44px tall.

## Motion

- The highlight springs (`CdsSprings.standard`) from wherever it is to the selected segment, so rapid changes never jump.
- Dragging across the control selects the segment under the finger as it passes, with a selection haptic on each change. If the drag starts on the highlight, the highlight follows the finger 1:1 (with a rubberband past the ends) and on release springs to the selected segment carrying the finger's velocity.
- Reduced motion moves the highlight instantly.

## CDS React Native mapping

CDS ships SegmentedControl on web only (deprecated there in favor of SegmentedTabs). This port follows the web visuals: `bgAlternate` track, `bgPrimaryWash` highlight, `fgPrimary` headline label with a checkmark.

| CDS prop | Flutter parameter |
| --- | --- |
| `options` (`{ value, label, accessibilityLabel }`) | `options` (`CdsSegmentedControlOption`) |
| `type: 'icon'` + `label: IconName` | `CdsSegmentedControlOption(icon: ...)` |
| `iconSize`, `value`, `onChange`, `block`, `disabled` | same names |

Deviations: the highlight is one rounded shape that slides between segments instead of per-segment backgrounds, and the control is controlled (`value` is required) rather than holding its own copy.
