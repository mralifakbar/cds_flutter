# CdsProgressBar

A horizontal track that shows how far a task has progressed; value changes animate from the current position.

CDS reference: https://cds.coinbase.com/components/feedback/ProgressBar

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsProgressBar(progress: 0.4, accessibilityLabel: 'Verification progress')
```

## When to use / when not to

Use for determinate progress (uploads, steps completed, goal funding). Add labels with `CdsProgressBarWithFixedLabels` or `CdsProgressBarWithFloatLabel`. Use `CdsSpinner` when progress is unknown.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| progress | `double` | `0` | 0 to 1 (clamped). |
| weight | `CdsProgressWeight` | `CdsProgressWeight.normal` | Track height: thin 2, normal 4, semiheavy 8, heavy 12. |
| color | `CdsColor` | `CdsColor.bgPrimary` | Fill color. |
| disabled | `bool` | `false` | Fill in `bgLineHeavy`. |
| disableAnimateOnMount | `bool` | `false` | Start at `progress` instead of filling from 0. |
| accessibilityLabel | `String?` | `null` | What is progressing. |
| onAnimationStart | `VoidCallback?` | `null` | Called when the value starts animating. |
| onAnimationEnd | `VoidCallback?` | `null` | Called when the animation ends. |

Track: `bgLine`, radius 200. The fill grows from the start edge (mirrored in right-to-left).

## Examples

### Heavy, positive

```dart
const CdsProgressBar(progress: 0.75, weight: CdsProgressWeight.heavy, color: CdsColor.bgPositive)
```

## Accessibility

Exposes the percentage as its semantic value ("40%") and `accessibilityLabel` as its label.

## Motion

Changes animate from wherever the bar is over `slow3` with the global curve (CDS `animateProgressBaseSpec`). Reduced motion: jumps to the value.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `progress`, `weight`, `color`, `disabled` | same |
| `disableAnimateOnMount` | same |
| `accessibilityLabel` | same |
| `onAnimationStart`, `onAnimationEnd` | same |
