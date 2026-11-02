# CdsPeriodSelector

Chart period tabs (1H, 1D, 1W...) with a pill that slides to the active tab.

CDS reference: https://cds.coinbase.com/components/charts/PeriodSelector

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPeriodSelector(
  tabs: const [
    CdsPeriodSelectorTab(id: '1D', label: '1D'),
    CdsPeriodSelectorTab(id: '1W', label: '1W'),
    CdsPeriodSelectorTab(id: '1M', label: '1M'),
  ],
  activeTab: '1D',
  onChange: (id) {},
)
```

## When to use / when not to

- Use it under or above a chart to switch its time range. It is controlled: keep the active id in state and update it in `onChange`.
- `CdsSparklineInteractive` has its own built-in period row; use this with `CdsLineChart` and other charts.
- For general content switching use segmented tabs instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `tabs` | `List<CdsPeriodSelectorTab>` | required | Options: `id`, `label`, optional `labelWidget` and `semanticLabel`. |
| `activeTab` | `String?` | required | Id of the selected tab, or null. |
| `onChange` | `ValueChanged<String>` | required | Called with the pressed tab's id (not for the already active tab). |
| `background` | `CdsColor` | `CdsColor.transparent` | Track color. |
| `activeBackground` | `CdsColor` | `CdsColor.bgPrimaryWash` | Sliding pill color. |
| `color` | `CdsColor` | `CdsColor.fg` | Inactive label color. |
| `activeColor` | `CdsColor` | `CdsColor.fgPrimary` | Active label color. |
| `font` | `CdsFont` | `CdsFont.label1` | Label ramp entry. |
| `block` | `bool` | `true` | Spread tabs across the full width (CDS `width: 100%`, `space-between`). |
| `gap` | `double` | `0` | Space token between tabs when `block` is false. |
| `disabled` | `bool` | `false` | Disable every tab. |
| `semanticLabel` | `String?` | `null` | Label for the group. |

`CdsLiveTabLabel({label = 'LIVE', color = CdsColor.fgNegative, font = CdsFont.label1, hideDot = false})` is a ready-made `labelWidget` for a real-time period.

## Examples

### Live period

```dart
class PeriodPicker extends StatefulWidget {
  const PeriodPicker({super.key});

  @override
  State<PeriodPicker> createState() => _PeriodPickerState();
}

class _PeriodPickerState extends State<PeriodPicker> {
  String _period = 'LIVE';

  @override
  Widget build(BuildContext context) {
    final live = _period == 'LIVE';
    return CdsPeriodSelector(
      activeBackground: live ? CdsColor.bgNegativeWash : CdsColor.bgPrimaryWash,
      activeColor: live ? CdsColor.fgNegative : CdsColor.fgPrimary,
      tabs: const [
        CdsPeriodSelectorTab(id: 'LIVE', label: 'LIVE', labelWidget: CdsLiveTabLabel(), semanticLabel: 'Live'),
        CdsPeriodSelectorTab(id: '1D', label: '1D'),
        CdsPeriodSelectorTab(id: '1W', label: '1W'),
      ],
      activeTab: _period,
      onChange: (id) => setState(() => _period = id),
    );
  }
}
```

## Accessibility

- Each tab is a button with selected state and a 44x44 hit area. `1H`, `1D`, `1W`, `1M` and `1Y` are read as "1 hour", "1 day" and so on; set `semanticLabel` for other labels.
- Keyboard: Tab focuses a tab, Enter or Space selects it, Left and Right arrows move the selection within the group (mirrored in RTL).
- A selection haptic fires on change.

## Motion

The pill slides to the new tab with `CdsSprings.standard`, starting from wherever it is, and labels cross-fade color over 150ms. Under reduced motion the pill jumps.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `tabs` (`{id, label}`) | `tabs` (`CdsPeriodSelectorTab`) |
| `activeTab` (tab object) | `activeTab` (tab id) |
| `onChange` | `onChange` (receives the id) |
| `background`, `activeBackground`, `activeColor`, `font` | same names |
| `width="100%"` / `fit-content` | `block: true` / `false` |
| `gap` | `gap` |
| `LiveTabLabel` | `CdsLiveTabLabel` |
| `TabComponent`, `TabsActiveIndicatorComponent` | not ported |
