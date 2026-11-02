# CdsPressable

The interaction primitive behind every tappable CDS component. Use it to make a custom surface behave like CDS buttons and cells.

CDS reference: https://cds.coinbase.com/components/inputs/Pressable

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPressable(
  onPress: () => openAsset('btc'),
  background: CdsColor.bgSecondary,
  borderRadius: 400,
  semanticLabel: 'Bitcoin',
  child: const CdsBox(padding: 2, child: CdsText.headline('Bitcoin')),
)
```

## What it gives you

- Pointer-down feedback: background tint (CDS blend at 0.82) and a 0.98 scale driven by a spring that starts from the current value.
- Hover tint (0.88) on pointer devices.
- Keyboard: focusable, visible focus ring, Enter and Space activate.
- Leading-edge debounce (500ms) so double taps do not push a route twice.
- Haptic feedback on commit.
- Button semantics with label, hint, selected and toggled state.
- Optional 44px minimum hit area.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | |
| `onPress`, `onLongPress` | `VoidCallback?` | `null` | |
| `onPressIn`, `onPressOut` | `VoidCallback?` | `null` | Fire on pointer down / up or cancel. |
| `disabled` | `bool` | `false` | Dims (0.5) and blocks input. |
| `loading` | `bool` | `false` | Blocks input without dimming. |
| `background` | `CdsColor` | `transparent` | |
| `dangerouslySetBackground` | `Color?` | `null` | |
| `borderColor` | `CdsColor?` | background | |
| `borderWidth` | `int` | `0` | Border width token. |
| `borderRadius` | `int?` | `null` | Radius token. |
| `elevation` | `CdsElevation` | `none` | |
| `transparentWhileInactive` | `bool` | `false` | Background appears only while pressed or hovered. |
| `noScaleOnPress` | `bool` | `false` | |
| `feedback` | `CdsHapticFeedback` | `none` | `light`, `normal`, `heavy`, `selection`. |
| `debounce` | `Duration` | 500ms | `Duration.zero` disables. |
| `minTapTargetSize` | `double` | `0` | Pads layout and hit area to this size. |
| `block` | `bool` | `false` | Full width. |
| `semanticLabel`, `semanticHint` | `String?` | `null` | |
| `selected`, `toggled`, `checked`, `mixed`, `expanded`, `inMutuallyExclusiveGroup` | `bool?` | `null` | State exposed to assistive tech. |
| `isButton` | `bool` | `true` | Set false for cells that are not buttons semantically. |
| `excludeChildSemantics` | `bool` | `false` | Announce only `semanticLabel`. |
| `mergeChildSemantics` | `bool` | `true` | Set false when the surface contains its own buttons so they stay separately reachable. |
| `focusNode`, `autofocus`, `mouseCursor` | | | |

## Motion

Press uses `CdsSprings.press`, release `CdsSprings.standard`, both from the current scale and velocity. Reduced motion disables the scale.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `onPress`, `onPressIn`, `onPressOut`, `disabled`, `loading`, `background`, `borderColor`, `borderRadius`, `elevation`, `transparentWhileInactive`, `noScaleOnPress`, `feedback`, `block` | same names |
| `debounceTime` / `disableDebounce` | `debounce` |
| `accessibilityLabel`, `accessibilityHint` | `semanticLabel`, `semanticHint` |
