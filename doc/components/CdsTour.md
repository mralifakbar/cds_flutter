# CdsTour

Steps through feature introductions: each step dims the screen except a spotlight on its target and shows a card (usually a `CdsCoachmark`) with an arrow pointing at it.

CDS reference: https://cds.coinbase.com/components/overlay/Tour

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTour(
  activeTourStep: step,
  onChange: (id) => setState(() => step = id),
  steps: [
    CdsTourStepValue(
      id: 'balance',
      builder: (context, tour) => CdsCoachmark(
        title: 'Your balance',
        content: 'Sample data: the total value of your assets.',
        action: CdsButton(label: 'Next', size: CdsButtonSize.s, onPress: tour.goNextTourStep),
        onClose: tour.stopTour,
      ),
    ),
    CdsTourStepValue(
      id: 'send',
      builder: (context, tour) => CdsCoachmark(
        title: 'Send crypto',
        content: 'Send to any address or username.',
        action: CdsButton(label: 'Done', size: CdsButtonSize.s, onPress: tour.goNextTourStep),
      ),
    ),
  ],
  child: Column(children: [
    const CdsTourStep(id: 'balance', child: CdsText('Sample data: 1,240.00 USD')),
    CdsTourStep(id: 'send', child: CdsButton(label: 'Send', onPress: send)),
  ]),
)

// Start it from anywhere below CdsTour:
CdsTour.of(context).startTour();
```

## When to use / when not to

Use once, for new or changed features, with three to five steps. Do not use to explain basic controls or to block the person repeatedly.

## Parameters

### CdsTour

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| steps | `List<CdsTourStepValue>` | required | Steps in order. |
| activeTourStep | `String?` | required | Id of the step to show; null when not running. |
| onChange | `ValueChanged<String?>` | required | Called with the next step id, or null to end. |
| child | `Widget` | required | The screen containing `CdsTourStep` targets. |
| hideOverlay | `bool` | `false` | Do not dim around the target. |
| tourMaskPadding | `double` | `2` | Space token added around the spotlight (half on each side). |
| tourMaskBorderRadius | `double` | `12` | Spotlight corner radius in px. |
| tourStepOffset | `double` | `3` | Space token between target and card. |
| accessibilityLabel | `String?` | `null` | Label for the tour layer. |

`CdsTour.of(context)` returns the `CdsTourController`.

### CdsTourStepValue

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| id | `String` | required | Matches a `CdsTourStep.id`. |
| builder | `CdsTourStepBuilder` | required | `Widget Function(BuildContext, CdsTourController)`. |
| disabled | `bool` | `false` | Skipped by next and previous. |
| hideOverlay | `bool?` | `null` | Per-step override. |
| tourMaskPadding | `double?` | `null` | Per-step override. |
| tourMaskBorderRadius | `double?` | `null` | Per-step override. |
| disableAutoScroll | `bool` | `false` | Do not scroll the target into view. |
| onActive | `VoidCallback?` | `null` | Called when the step shows. |
| onInactive | `VoidCallback?` | `null` | Called when the step leaves. |

### CdsTourStep

`CdsTourStep({required String id, required Widget child})` marks `child` as the target of the step with the same id.

### CdsTourController

`activeTourStep`, `startTour([String? tourStepId])`, `stopTour()`, `goNextTourStep()` (ends after the last step), `goPreviousTourStep()`, `setActiveTourStep(String? id)`.

## Examples

### Start at a specific step

```dart
CdsButton(label: 'Show me around', onPress: () => CdsTour.of(context).startTour('send'))
```

## Accessibility

The tour layer is its own semantics scope with focus trapped in the card; Escape ends the tour. The page behind does not react to taps while a step is shown. The step card should include a visible way to end the tour (`onClose` on `CdsCoachmark`).

## Motion

Targets scroll into view first (`moderate3`). The scrim and card fade in (`moderate3`, global) and the card slides 8px from the target. Moving to the next step glides the spotlight to the new target. Reduced motion: no scroll animation or glide; the spotlight jumps.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `steps` (`{id, Component, ...}`) | `steps` (`CdsTourStepValue` with `builder`) |
| `activeTourStep` (step object) | `activeTourStep` (step id) |
| `onChange` | `onChange` (step id or null) |
| `hideOverlay`, `tourMaskPadding`, `tourMaskBorderRadius` | same |
| `tourStepOffset` | `tourStepOffset` (space token) |
| `TourStep` | `CdsTourStep` |
| `useTourContext()` | `CdsTour.of(context)` |
| `TourMaskComponent`, `TourStepArrowComponent` | not customizable; default mask and arrow |
