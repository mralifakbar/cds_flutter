# CdsPortal

Renders its child in the nearest (or root) `Overlay`, above the rest of the screen, while keeping the theme and directionality of where it is declared.

CDS reference: Not a CDS docs page. Closest is https://cds.coinbase.com/components/overlay/PortalProvider (CDS web `Portal`).

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPortal(
  visible: showNotice,
  child: const Align(alignment: Alignment.topCenter, child: CdsText('Sample data: maintenance at 02:00 UTC')),
)
```

## When to use / when not to

Use for custom floating layers. For standard overlays use the dedicated components, which already render above the page.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | Rendered in the overlay, sized to the overlay. |
| visible | `bool` | `true` | Show or hide the portal content. |
| useRootOverlay | `bool` | `false` | Use the root overlay so it also covers nested navigators. |

The widget itself takes no space in place.

## Examples

### Root overlay

```dart
CdsPortal(useRootOverlay: true, child: const Center(child: CdsSpinner(size: CdsSpinnerSize.large)))
```

## Accessibility

Content keeps its semantics; position it so it does not cover controls people need.

## Motion

None.

## CDS React Native mapping

| CDS API | Flutter |
| --- | --- |
| `Portal` / `PortalProvider` | `CdsPortal` (no provider needed: Flutter apps already have an `Overlay`) |
