# CdsNavigationTitleSelect

A navigation title with a caret that opens a picker, for example to switch between portfolios or accounts.

CDS reference: https://cds.coinbase.com/components/navigation/NavigationTitleSelect

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
bool open = false;

CdsNavigationTitleSelect(
  label: 'Main portfolio',
  open: open,
  onPress: () async {
    setState(() => open = true);
    await showMyPortfolioPicker(context);
    setState(() => open = false);
  },
)
```

## When to use / when not to

- Use when the screen's content depends on one choice the user switches occasionally.
- This widget only renders the trigger and calls `onPress`. Open your own tray, sheet or menu there.
- Use a regular select input for form fields.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| label | `String` | required | The selected option's label. |
| onPress | `VoidCallback?` | required | Opens your picker. `null` disables the trigger. |
| open | `bool` | `false` | Pass `true` while your picker is showing: the caret flips and the expanded state is announced. |
| color | `CdsColor` | `CdsColor.fg` | Text and caret color. |
| font | `CdsFont` | `CdsFont.headline` | Label font. |
| semanticHint | `String?` | `null` | Spoken after the label, for example `'Switch portfolio'`. |

## Examples

### In a top navigation bar

```dart
CdsTopNavBar(
  start: CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: pop),
  child: CdsNavigationTitleSelect(label: portfolio, open: open, onPress: openPicker),
)
```

## Accessibility

- Button with the header flag, expanded state from `open`, and an optional hint.
- 44px minimum hit area; Enter and Space activate.
- Presses within 500ms of the previous one are ignored, so a double tap does not open two pickers.

## Motion

The caret rotates 180 degrees over `CdsDurations.moderate1` with `CdsCurves.global` when `open` changes; instant under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `options`, `value` | resolve the label yourself and pass `label` |
| `onChange` | handled by your picker; this widget calls `onPress` |
| `color`, `font` | `color`, `font` |

Deviation: CDS opens its own `Tray` with option cells. Overlays live in another part of this package, so this widget leaves the picker to the caller and exposes `open` for the caret and semantics.
