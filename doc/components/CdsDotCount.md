# CdsDotCount

A numeric badge, such as an unread count, pinned to a widget or shown on its own.

CDS reference: https://cds.coinbase.com/components/other/DotCount

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDotCount(
  count: unread,
  semanticLabel: '$unread unread notifications',
  child: CdsIconButton(CdsIconName.bell, semanticLabel: 'Notifications', onPress: openInbox),
)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `int` | required | 0 or less hides the badge. |
| `max` | `int` | `99` | Larger counts show as `99+`. |
| `variant` | `CdsDotCountVariant` | `negative` | `bgNegative` fill. CDS defines only this variant. |
| `pin` | `CdsDotPinPlacement?` | `topEnd` with a child | `topStart`, `topEnd`, `bottomStart`, `bottomEnd`. |
| `overlap` | `CdsDotOverlap?` | `null` | `circular` pulls the badge inward for round hosts. |
| `child` | `Widget?` | `null` | The anchor. Without it the badge renders inline. |
| `semanticLabel` | `String?` | the number | What the count means. |

The badge is at least 24x24 with 6px side padding, `caption` text in `fgInverse`, and a 1px `bgSecondary` ring.

## Examples

### Inline

```dart
const CdsDotCount(count: 3)
```

## Accessibility

Labelled with `semanticLabel` (or the shown number). The count text carries the meaning, not the color.

## Motion

Enters with fade and scale 0.9 to 1 over `moderate1` (`enterFunctional`) and exits the reverse (`global` curve), keeping the last count visible while it leaves. Instant under reduced motion. The badge is centered on the pinned corner, mirrored in RTL.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `count`, `max`, `variant`, `pin`, `overlap`, `children` | `count`, `max`, `variant`, `pin`, `overlap`, `child` |
| `accessibilityLabel` | `semanticLabel` |
| `height`, style props | not exposed |
