# CdsTimeline

A vertical list of events joined by a line, each with a status dot. Use it for order history, transfer progress and account activity.

CDS reference: none. This is a cds_flutter extra built from CDS tokens.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsTimeline(events: [
  CdsTimelineEvent(title: 'Order placed', timestamp: 'Today, 09:41', status: CdsTimelineStatus.complete),
  CdsTimelineEvent(title: 'Processing', status: CdsTimelineStatus.active),
  CdsTimelineEvent(title: 'Funds available'),
])
```

## When to use / when not to

Use it to show what happened and what comes next. For a flow the user steps through, use `CdsStepper`.

## Parameters

`CdsTimeline`

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `events` | `List<CdsTimelineEvent>` | required | Events from first to last. |

`CdsTimelineEvent`

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | required | `headline`. |
| `description` | `String?` | `null` | `label2`, `fgMuted`. |
| `timestamp` | `String?` | `null` | `legal`, `fgMuted`, under the title. |
| `status` | `CdsTimelineStatus` | `upcoming` | `complete`, `active`, `upcoming` or `error`. |
| `statusLabel` | `String?` | `Complete` / `In progress` / `Upcoming` / `Failed` | Spoken status. |
| `media` | `Widget?` | `null` | Extra content below the text, such as a button. |

Dots follow the CDS vertical Stepper: `circleCheckmark` in `bgPrimary` (complete), `outline` in `bgPrimary` (active), `outline` in `bgLineHeavy` (upcoming), `error` in `fgNegative` (error). The 2px connector is `bgPrimary` below a complete event and `bgLine` otherwise.

## Examples

### With an action

```dart
CdsTimeline(events: [
  const CdsTimelineEvent(title: 'Withdrawal sent', status: CdsTimelineStatus.complete),
  CdsTimelineEvent(
    title: 'Receipt ready',
    media: CdsButton(label: 'View receipt', size: CdsButtonSize.s, onPress: openReceipt),
  ),
])
```

## Accessibility

Each event reads as one phrase: `title, status, timestamp, description`. Status has its own glyph and spoken label, so it never depends on color alone.

## Motion

None.

## CDS React Native mapping

| Closest CDS piece | Flutter parameter |
| --- | --- |
| `Stepper direction="vertical"` icon and progress styling | `status` |
| `StepperValue.label` | `title` |
