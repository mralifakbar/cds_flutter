# CdsStepper

Shows progress through a fixed sequence of steps, such as identity verification or a multi-screen form.

CDS reference: https://cds.coinbase.com/components/navigation/Stepper

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsStepper(
  direction: CdsStepperDirection.horizontal,
  activeStepId: 'id',
  steps: const [
    CdsStepperStep(id: 'email', label: 'Verify email'),
    CdsStepperStep(id: 'id', label: 'Verify identity'),
    CdsStepperStep(id: 'bank', label: 'Link a bank'),
  ],
)
```

## When to use / when not to

Use when a task has a known number of ordered steps and seeing the remaining work helps. Use horizontal at the top of a flow screen; use vertical for an overview with labels and nested sub-steps. Do not use for free navigation between sections; use tabs. For a single percentage, use a progress bar.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `CdsStepperDirection` | required | `horizontal` or `vertical`. |
| `steps` | `List<CdsStepperStep>` | required | The steps, in order. |
| `activeStepId` | `String?` | required | Id of the current step (may be a sub-step), or null for none. |
| `complete` | `bool` | `false` | Marks every step done and hides the horizontal header text. |
| `animate` | `bool` | `true` | Fill bars one step at a time. Off, bars change instantly. |
| `completedStepAccessibilityLabel` | `String` | `'Complete'` | Appended to visited step labels for screen readers. |
| `accessibilityLabel` | `String?` | `null` | Horizontal: replaces the "Label N of M" announcement. Vertical: labels the group. |

`CdsStepperStep({required String id, String? label, String? accessibilityLabel, List<CdsStepperStep>? subSteps})`.

## Examples

### Vertical with sub-steps

```dart
CdsStepper(
  direction: CdsStepperDirection.vertical,
  activeStepId: 'selfie',
  steps: const [
    CdsStepperStep(id: 'email', label: 'Verify email'),
    CdsStepperStep(id: 'id', label: 'Verify identity', subSteps: [
      CdsStepperStep(id: 'doc', label: 'Upload document'),
      CdsStepperStep(id: 'selfie', label: 'Take a selfie'),
    ]),
    CdsStepperStep(id: 'bank', label: 'Link a bank'),
  ],
)
```

### Finished flow

```dart
CdsStepper(direction: CdsStepperDirection.horizontal, steps: steps, activeStepId: null, complete: true)
```

## Visual reference

- Horizontal: caption header "N/M Label" (`fgMuted` count, 12px gap, 12px bottom padding) over one 4px bar per top-level step, 4px apart. Track `bgLine`, radius 200. Fill `bgPrimary` for the active step and `bgLinePrimarySubtle` for visited or complete steps.
- Vertical: a 16px icon (`outline` in `bgLine`, `outline` in `bgLinePrimarySubtle` when active, `circleCheckmark` in `bgPrimary` when visited or complete), a 2px connector (minimum 16px, `bgPrimary` once passed, partially filled while a sub-step is active), and a label (`label1`, `label2` for sub-steps; `fgPrimary` when active, otherwise `fgMuted`) with 24px below it.

## Accessibility

- Horizontal: one node announcing "Label N of M" (for example "Link a bank 3 of 3"), or "No active step".
- Vertical: each step label is its own node reading "Label N of M", with " (Complete)" for visited steps and the selected state on the active step.

## Motion

Bars fill over `CdsDurations.slow2` with `CdsCurves.global`. When the active step jumps ahead, bars fill one after another, `slow2` apart, driven by a ticker that stops when the target is reached and pauses off screen. The horizontal header fades out and in over `fast1` each when the step changes. Under reduced motion, or with `animate: false`, everything changes instantly.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `direction` | `direction` |
| `steps` (`StepperValue`) | `steps` (`CdsStepperStep`) |
| `activeStepId` | `activeStepId` |
| `complete` | `complete` |
| `animate` | `animate` |
| `completedStepAccessibilityLabel` | `completedStepAccessibilityLabel` |
| `accessibilityLabel` | `accessibilityLabel` |
| `disableAnimateOnMount` | not supported; bars animate in on mount unless `animate` is false |
| `Stepper*Component` overrides, `metadata`, `progressTimingConfig` | not supported |
