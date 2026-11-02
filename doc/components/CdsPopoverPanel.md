# CdsPopoverPanel

A panel anchored to a trigger for content that does not need a full modal, such as filters, account switchers or short forms.

CDS reference: https://cds.coinbase.com/components/overlay/PopoverPanel

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPopoverPanel(
  builder: (context, controller) => CdsButton(label: 'Filters', onPress: controller.toggle),
  contentBuilder: (context, close) => Padding(
    padding: const EdgeInsets.all(16),
    child: CdsButton(label: 'Show top gainers', onPress: close),
  ),
)
```

## When to use / when not to

Use on wide screens for secondary content tied to a control. On phones prefer `CdsTray`. For a list of options use `CdsDropdown`; for a one-line hint use `CdsTooltip`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| builder | `CdsPopoverTriggerBuilder` | required | `Widget Function(BuildContext, CdsPopoverController)`; call `controller.toggle` from the trigger's `onPress`. |
| content | `Widget?` | `null` | Panel content. One of `content` or `contentBuilder` is required. |
| contentBuilder | `CdsPopoverContentBuilder?` | `null` | `Widget Function(BuildContext, VoidCallback closePopover)`; overrides `content`. |
| controller | `CdsPopoverController?` | `null` | Control open state from outside. |
| placement | `CdsPlacement` | `CdsPlacement.bottomStart` | Preferred position; flips when it does not fit. |
| gap | `double` | `0.5` | Space token between trigger and panel. |
| panelWidth | `double?` | `null` | Fixed width. |
| minPanelWidth | `double?` | `null` | Minimum width. |
| maxPanelWidth | `double?` | `null` | Maximum width. |
| panelHeight | `double?` | `null` | Fixed height. |
| maxPanelHeight | `double?` | `null` | Maximum height; otherwise limited to the space on the chosen side. |
| showOverlay | `bool` | `false` | Dim the page; tapping the scrim closes. |
| block | `bool` | `false` | Trigger and panel take the parent's width. |
| disabled | `bool` | `false` | Keep the panel closed. |
| onOpen | `VoidCallback?` | `null` | Called on open. |
| onClose | `VoidCallback?` | `null` | Called on close. |
| accessibilityLabel | `String?` | `null` | Label for the panel. |
| restoreFocusOnUnmount | `bool` | `true` | Return focus to the trigger on close. |

Panel surface: `bg`, 1px `bgLine` border, radius 400, elevation 2. Content scrolls inside the panel.

### CdsPopoverController

`CdsPopoverController({bool initiallyOpen = false})`, a `ChangeNotifier` with `isOpen`, `open()`, `close()`, `toggle()`. Shared by `CdsPopoverPanel`, `CdsDropdown`.

### CdsPlacement

`top`, `topStart`, `topEnd`, `bottom`, `bottomStart`, `bottomEnd`, `left`, `leftStart`, `leftEnd`, `right`, `rightStart`, `rightEnd`. `start`/`end` alignments follow text direction for top and bottom placements.

## Examples

### Controlled from outside

```dart
final controller = CdsPopoverController();

CdsPopoverPanel(
  controller: controller,
  placement: CdsPlacement.bottomEnd,
  builder: (context, c) => CdsIconButton(CdsIconName.more, semanticLabel: 'More', onPress: c.toggle),
  content: const Padding(padding: EdgeInsets.all(16), child: CdsText('Sample data: account details')),
)
```

## Accessibility

Focus moves into the panel and is trapped while open; Escape or a tap outside closes it and focus returns to the trigger. The panel is a semantics container labelled by `accessibilityLabel`.

## Motion

CDS dropdown tokens: opacity plus a 16px slide away from the trigger over `moderate3` (global curve), with a slight scale from the edge facing the trigger so the panel grows out of it. Exit reverses the same path. Reduced motion: a `fast1` fade.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` (trigger) | `builder(context, controller)` |
| `content` (node / render prop) | `content` / `contentBuilder` |
| `contentPosition.placement`, `contentPosition.gap` | `placement`, `gap` |
| `panelWidth`, `minPanelWidth`, `maxPanelWidth`, `panelHeight`, `maxPanelHeight` | same |
| `showOverlay`, `block`, `disabled` | same |
| `onOpen`, `onClose` | same |
| `restoreFocusOnUnmount`, `accessibilityLabel` | same |
| ref `openPopover` / `closePopover` | `controller.open()` / `controller.close()` |

The trigger is built with `builder` instead of being a wrapped child, so the trigger keeps its own `onPress` and enabled state.
