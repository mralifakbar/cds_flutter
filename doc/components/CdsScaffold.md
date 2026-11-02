# CdsScaffold

A CDS page frame: an optional header pinned to the top, a scrolling body, and an optional footer pinned to the bottom, with safe areas and the keyboard handled.

CDS reference: none. This is a cds_flutter extra built from CDS tokens.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsScaffold(
  header: CdsTopNavBar(
    start: CdsNavBarIconButton(CdsIconName.backArrow, semanticLabel: 'Back', onPress: pop),
    child: const CdsNavigationTitle('Send'),
  ),
  body: const SendForm(),
  footer: CdsStickyFooter(
    child: CdsButton(label: 'Send USDC', block: true, onPress: send),
  ),
)
```

## When to use / when not to

Use as the root of a screen in a CDS app instead of Material `Scaffold`. It does not provide app bars, drawers or snack bars; compose CDS components into its slots.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `Widget?` | `null` | Pinned above the body, padded below the status bar. |
| `body` | `Widget` | required | Page content. |
| `footer` | `Widget?` | `null` | Pinned below the body, e.g. `CdsStickyFooter`. |
| `background` | `CdsColor` | `CdsColor.bg` | Fills the whole page, including behind safe areas. |
| `scrollable` | `bool` | `true` | Wraps `body` in a `SingleChildScrollView`. Set false when `body` is a `ListView` or `CustomScrollView`. |
| `bodyPadding` | `EdgeInsetsGeometry?` | `null` | Padding around `body` inside the scroll view. |
| `scrollController` | `ScrollController?` | `null` | Controller for the scroll view when `scrollable` is true. |
| `resizeToAvoidKeyboard` | `bool` | `true` | Lifts the footer and shrinks the body when the keyboard opens. |
| `showHeaderDivider` | `bool` | `true` | Fades in a `bgLine` hairline under the header once the body scrolls. |

## Safe areas and keyboard

- With a header, the header clears the top inset; without one, the body does.
- With a footer, the footer receives the bottom inset (so `CdsStickyFooter` pads for the home indicator); without one, the body's scroll padding does.
- While the keyboard is open, the footer sits directly above it and the bottom inset is removed, so the gap is not counted twice.
- Left and right insets pad the whole page in landscape.

## Examples

### List body

```dart
CdsScaffold(
  scrollable: false,
  header: const CdsPageHeader(title: 'Activity'),
  body: ListView.builder(itemCount: rows.length, itemBuilder: (context, i) => rows[i]),
)
```

## Accessibility

The frame adds no semantics of its own; reading order is header, body, footer.

## Motion

The header divider fades over `CdsDurations.fast3`; instant under reduced motion.

## CDS React Native mapping

No CDS equivalent. CDS apps compose `TopNavBar`, a `ScrollView` and `StickyFooter` inside a safe-area view; `CdsScaffold` does that composition.
