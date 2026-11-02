# CdsAccordion

A vertical list of expandable rows where at most one is open. Reach for it to tuck secondary details (fees, limits, FAQs) under short headers.

CDS reference: https://cds.coinbase.com/components/layout/Accordion

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsAccordion(
  activeKey: open,
  onChange: (key) => setState(() => open = key),
  children: const [
    CdsAccordionItem(itemKey: 'fees', title: 'Fees', child: CdsText('Fees vary by network.')),
    CdsAccordionItem(itemKey: 'limits', title: 'Limits', child: CdsText('Limits reset daily.')),
  ],
)
```

## When to use / when not to

Use it for optional content the reader opens one section at a time. Do not hide information people need to complete a task (prices, required steps). To show or hide a single block, use `CdsCollapsible` directly.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<CdsAccordionItem>` | required | The rows, in order. Each `itemKey` must be unique. |
| `activeKey` | `String?` | `null` | Open item when controlled. Ignored when `onChange` is null. |
| `onChange` | `ValueChanged<String?>?` | `null` | Makes the accordion controlled. Called with the key to open, or `null` when the open item is closed. |
| `defaultActiveKey` | `String?` | `null` | Open item on first build when uncontrolled. |
| `borderRadius` | `int?` | `null` | Radius token for the container; clips items when set. |
| `showItemSeparators` | `bool` | `true` | Draws a `CdsDivider` between items. |

Controlled vs. uncontrolled: with `onChange` set, the accordion renders `activeKey` and never changes on its own. Without `onChange`, it keeps its own open item starting from `defaultActiveKey`.

## Examples

### Uncontrolled with a default

```dart
const CdsAccordion(
  defaultActiveKey: 'staking',
  children: [
    CdsAccordionItem(itemKey: 'staking', title: 'Staking', child: CdsText('Rewards depend on network conditions.')),
    CdsAccordionItem(itemKey: 'unstaking', title: 'Unstaking', child: CdsText('Can take several days.')),
  ],
)
```

### Rounded, without separators

```dart
const CdsAccordion(
  borderRadius: 400,
  showItemSeparators: false,
  children: [
    CdsAccordionItem(itemKey: 'a', title: 'Account', background: CdsColor.bgAlternate, child: CdsText('Details')),
  ],
)
```

## Accessibility

- Each header is a button with an expanded state and a label joining title, subtitle and tertiary title with commas.
- Collapsed panels are hidden from screen readers and skipped by Tab.
- Up and Down arrows move focus between headers (wrapping), Home and End jump to the first and last. Enter or Space toggles.
- Headers are at least 80px tall.

## Motion

Panels animate height and opacity (open `slow1`, close `moderate3`, `CdsCurves.global`) and reverse from their current size if toggled mid-flight. The caret rotates 180 degrees over `slow1`. Reduced motion makes both instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `activeKey` | `activeKey` |
| `defaultActiveKey` | `defaultActiveKey` |
| `onChange` / `setActiveKey` | `onChange` |
| `borderRadius` | `borderRadius` |
| `showItemSeparators` | `showItemSeparators` |
| `style`, `testID` | not ported; wrap the widget or use a `Key` |
