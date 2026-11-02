# CdsAccordionItem

One expandable row inside a `CdsAccordion`: a pressable header with title, optional media and an animated caret, over a collapsible panel.

CDS reference: https://cds.coinbase.com/components/layout/AccordionItem

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsAccordionItem(
  itemKey: 'fees',
  title: 'Trading fees',
  subtitle: 'Charged per order',
  child: CdsText('Fees depend on order size and payment method.'),
)
```

## When to use / when not to

Only as a direct child of `CdsAccordion`; it reads the open key from there and asserts otherwise. For a standalone toggle, use `CdsCollapsible`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `itemKey` | `String` | required | Unique key inside the accordion. |
| `title` | `String` | required | Header title, `headline` font. |
| `child` | `Widget` | required | Panel content. |
| `subtitle` | `String?` | `null` | `label2`, `fgMuted` (or `fg` when `tertiaryTitle` is set). |
| `tertiaryTitle` | `String?` | `null` | Third line, `legal` font, `fgMuted`. |
| `media` | `Widget?` | `null` | Leading slot, such as a `CdsIcon` or avatar. |
| `onPress` | `ValueChanged<String>?` | `null` | Called with `itemKey` before the accordion toggles. |
| `showHeaderBorder` | `bool` | `false` | Divider between header and panel. |
| `background` | `CdsColor` | `CdsColor.bg` | Header color shown while pressed or hovered. |
| `caretSize` | `CdsIconSize` | `CdsIconSize.s` | Size of the caret. |
| `borderRadius` | `int?` | `null` | Radius token; clips the item. |
| `padding`, `paddingX`, `paddingY`, `paddingTop`, `paddingBottom`, `paddingStart`, `paddingEnd` | `double?` | `paddingX: 3, paddingY: 1` | Header padding as space tokens. |

The panel has padding top 2, horizontal 3, bottom 3, and caps at 400px; taller content scrolls.

## Examples

### With media and three lines

```dart
const CdsAccordionItem(
  itemKey: 'tax',
  title: 'Tax documents',
  subtitle: 'Available each February',
  tertiaryTitle: 'Downloadable as PDF',
  media: CdsIcon(CdsIconName.info),
  showHeaderBorder: true,
  child: CdsText('Download gain and loss reports from Settings.'),
)
```

## Accessibility

Header: button role, `expanded` state, label `title, subtitle, tertiaryTitle`. Focus ring on keyboard focus. Arrow key navigation is handled by the parent `CdsAccordion`.

## Motion

Header press tints without scaling (CDS `noScaleOnPress`). Caret rotates from -180 degrees (collapsed, pointing down) to 0 over `slow1`. See `CdsCollapsible` for the panel.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `itemKey` | `itemKey` |
| `title`, `subtitle`, `tertiaryTitle` | same |
| `media` | `media` |
| `children` | `child` |
| `onPress` | `onPress` |
| `showHeaderBorder` | `showHeaderBorder` |
| `background` | `background` |
| `caretSize` | `caretSize` |
| `borderRadius` | `borderRadius` |
| padding props | same names |
| `headerRef`, `panelRef`, `styles` | not ported |
