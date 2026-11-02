# CdsBreadcrumb

A trail of links from the top of a hierarchy to the current page, for tablet and desktop layouts with deep navigation.

CDS reference: none. This is a cds_flutter extra built from CDS tokens.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsBreadcrumb(
  items: [
    CdsBreadcrumbItem(label: 'Assets', onPress: () => go('/assets')),
    CdsBreadcrumbItem(label: 'Bitcoin', onPress: () => go('/assets/btc')),
    const CdsBreadcrumbItem(label: 'Transactions'),
  ],
)
```

## When to use / when not to

Use on wide layouts where pages sit three or more levels deep. On phones, a back button in `CdsTopNavBar` is clearer. Do not use as the only navigation.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<CdsBreadcrumbItem>` | required | Levels from top to current. The last item is the current page. |
| `accessibilityLabel` | `String` | `'Breadcrumb'` | Label for the group. |
| `maxItems` | `int?` | `null` | When exceeded, keeps the first item and the last `maxItems - 1` items and collapses the rest into `...`. Must be at least 2. |
| `expandAccessibilityLabel` | `String` | `'Show all levels'` | Screen reader label for the `...` button, which expands the trail. |

`CdsBreadcrumbItem({required String label, VoidCallback? onPress})`. `onPress` is ignored on the last item.

## Examples

### Collapsed middle

```dart
CdsBreadcrumb(
  maxItems: 3,
  items: [
    CdsBreadcrumbItem(label: 'Home', onPress: () {}),
    CdsBreadcrumbItem(label: 'Assets', onPress: () {}),
    CdsBreadcrumbItem(label: 'Bitcoin', onPress: () {}),
    CdsBreadcrumbItem(label: 'Wallets', onPress: () {}),
    const CdsBreadcrumbItem(label: 'Transactions'),
  ],
)
// Home > ... > Wallets > Transactions
```

## Visual reference

Earlier items are `label2` in `fgMuted`; the current page is `label1` in `fg`. Separators are `caretRight` at size `xs` in `fgMuted` (`caretLeft` in RTL), with 4px gaps. Items wrap onto new lines instead of overflowing.

## Accessibility

- The trail is a group labelled `accessibilityLabel`. Earlier items are buttons; the current page is not interactive and carries the selected state.
- Every link has a 44px minimum hit area.

## Motion

Links use `CdsPressable` press feedback with a `bgSecondary` wash while pressed or hovered.

## CDS React Native mapping

No CDS equivalent.
