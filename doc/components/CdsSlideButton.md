# CdsSlideButton

A slide-to-confirm control: the user drags a handle across the track to commit an action that should not fire on a stray tap, such as sending funds or closing an account.

CDS reference: https://cds.coinbase.com/components/inputs/SlideButton

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
bool sent = false;

CdsSlideButton(
  checked: sent,
  onChange: (v) => setState(() => sent = v),
  uncheckedLabel: 'Slide to send',
  checkedLabel: 'Sending',
)
```

## When to use / when not to

Use it for a single high-stakes confirmation at the bottom of a review screen. Use `CdsButton` for routine actions, and a confirmation dialog when the user needs to read terms before confirming. Do not place two slide buttons on one screen.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `bool` | required | Whether the action is confirmed. The handle fills the track when true. |
| `onChange` | `ValueChanged<bool>?` | `null` | Called with `true` when a slide commits. The widget never calls it with `false`; reset by passing `checked: false`. |
| `uncheckedLabel` | `String?` | `null` | Text centered on the track while unchecked. Also the accessibility label. |
| `checkedLabel` | `String?` | `null` | Text on the full-width handle while checked. Also the accessibility label when checked. |
| `uncheckedLabelNode` | `Widget?` | `null` | Custom track content; overrides `uncheckedLabel` visually. |
| `checkedLabelNode` | `Widget?` | `null` | Custom checked handle content; overrides `checkedLabel` visually. |
| `startUncheckedNode` | `Widget?` | forward arrow icon | Content at the end of the resting handle. |
| `endCheckedNode` | `Widget?` | indeterminate `CdsProgressCircle` | Content at the end of the checked handle. |
| `onSlideStart` | `VoidCallback?` | `null` | A drag on the handle began. |
| `onSlideCancel` | `VoidCallback?` | `null` | The drag ended without committing. Called before `onSlideEnd`. |
| `onSlideComplete` | `VoidCallback?` | `null` | The slide committed. Called after `onChange`, before `onSlideEnd`. |
| `onSlideEnd` | `VoidCallback?` | `null` | Called last in every slide sequence. |
| `disabled` | `bool` | `false` | Ignores drags, dims the handle and shows the track label at 50% opacity. |
| `size` | `CdsSlideButtonSize?` | `l` (or `s` with `compact`) | `s` 40px, `m` 48px, `l` 56px tall. |
| `compact` | `bool` | `false` | Same as `size: CdsSlideButtonSize.s`. Kept for parity with the deprecated CDS prop. |
| `height` | `double?` | size height | Overrides the size's height. The control grows when large text needs more room. |
| `variant` | `CdsSlideButtonVariant` | `primary` | Handle color: `primary` (bgPrimary), `positive` (bgPositive), `negative` (bgNegative). |
| `borderRadius` | `int?` | `700` for `s`, `900` for `m`/`l` | Radius token. |
| `checkThreshold` | `double` | `0.7` | Fraction of the track, in (0, 1], the handle must cover to commit. |
| `autoCompleteSlideOnThresholdMet` | `bool` | `false` | Commit as soon as the threshold is reached, without waiting for release. |
| `feedback` | `CdsHapticFeedback` | `normal` | Haptic fired on commit. |
| `semanticLabel` | `String?` | current label | Overrides the accessibility label. |
| `focusNode` | `FocusNode?` | `null` | |
| `autofocus` | `bool` | `false` | |

Callback order on commit: `onSlideStart`, `onChange(true)`, `onSlideComplete`, `onSlideEnd`. On cancel: `onSlideStart`, `onSlideCancel`, `onSlideEnd`.

## Examples

### Reset after a failed action

```dart
CdsSlideButton(
  checked: sending,
  onChange: (_) async {
    setState(() => sending = true);
    final ok = await send();
    if (!ok) setState(() => sending = false);
  },
  uncheckedLabel: 'Slide to send',
  checkedLabel: 'Sending',
)
```

### Destructive action

```dart
CdsSlideButton(
  checked: closing,
  onChange: (v) => setState(() => closing = v),
  variant: CdsSlideButtonVariant.negative,
  uncheckedLabel: 'Slide to close account',
  checkedLabel: 'Closing account',
)
```

### Compact, custom handle content

```dart
CdsSlideButton(
  checked: done,
  onChange: (v) => setState(() => done = v),
  size: CdsSlideButtonSize.s,
  uncheckedLabel: 'Slide to buy',
  startUncheckedNode: const CdsIcon(CdsIconName.arrowRight, size: CdsIconSize.s, color: CdsColor.fgInverse),
  endCheckedNode: const CdsIcon(CdsIconName.checkmark, size: CdsIconSize.s, color: CdsColor.fgInverse),
)
```

## Accessibility

- Exposed as one button whose label is `uncheckedLabel` or `checkedLabel`. While unchecked and enabled it has a tap action that commits, so screen reader users activate it with a double tap instead of a drag.
- Keyboard: Tab focuses it (focus ring drawn outside the track), Enter or Space commits.
- The control grows taller instead of clipping when the text scale is large.
- Pass string labels, or set `semanticLabel` when you use the `...Node` slots.

## Motion

- The handle tints on pointer-down and follows the finger 1:1 from where it was grabbed. Past the end it stretches with `CdsMotion.rubberband` resistance.
- On release it commits when it covers `checkThreshold`, or when the flick velocity projected with `CdsMotion.project` would carry it there. Otherwise it springs back to rest, starting with the release velocity.
- Changes to `checked` spring the handle from wherever it is (`CdsSprings.standard`), so a reset mid-flight never jumps.
- The checked and unchecked handle contents cross-fade over `moderate1`.
- The default checked spinner runs only while `checked` is true and holds still under reduced motion.
- Reduced motion: state changes jump instantly; drags still follow the finger.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `checked` | `checked` |
| `onChange` | `onChange` |
| `uncheckedLabel` (string / node) | `uncheckedLabel` / `uncheckedLabelNode` |
| `checkedLabel` (string / node) | `checkedLabel` / `checkedLabelNode` |
| `startUncheckedNode` | `startUncheckedNode` |
| `endCheckedNode` | `endCheckedNode` |
| `onSlideStart` / `onSlideCancel` / `onSlideComplete` / `onSlideEnd` | same names |
| `disabled` | `disabled` |
| `size` / `compact` | `size` / `compact` |
| `height` | `height` |
| `variant` | `variant` (`CdsSlideButtonVariant`) |
| `borderRadius` | `borderRadius` |
| `checkThreshold` | `checkThreshold` |
| `autoCompleteSlideOnThresholdMet` | `autoCompleteSlideOnThresholdMet` |
| `SlideButtonHandleComponent` / `SlideButtonBackgroundComponent` | not ported; use the `...Node` slots |
| `accessibilityLabel` | `semanticLabel` |
