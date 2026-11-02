# CdsInputStack

The frame shared by every CDS text field: label, bordered input area with start and end slots, focus border and helper text. Reach for it to build a custom field (a masked input, a trigger that opens a picker) that must look like `CdsTextInput`.

CDS reference: https://cds.coinbase.com/components/inputs/TextInput

This page also covers the helpers that go with it: `CdsInputLabel`, `CdsHelperText`, `CdsTextInputFocusVariant`, and the enums `CdsInputVariant`, `CdsTextInputSize`, `CdsInputLabelVariant`.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsInputStack(
  labelNode: const CdsInputLabel('Network'),
  inputNode: const Padding(
    padding: EdgeInsets.all(16),
    child: CdsText('Ethereum'),
  ),
  endNode: const CdsInputIcon(CdsIconName.caretDown),
  helperTextNode: const CdsHelperText('Sample data'),
  onFieldPress: openPicker,
)
```

## When to use / when not to

- Use for custom fields that need the CDS field look and focus behavior.
- Use `CdsTextInput` for ordinary text entry; it already composes this stack.
- `inputNode` brings its own padding. `CdsTextInput` uses 16px horizontal and 8, 12 or 16px vertical depending on size.

## Parameters

### CdsInputStack

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `inputNode` | `Widget` | required | The editable area. |
| `labelNode` | `Widget?` | `null` | Above the field, or inside it when `labelVariant` is `inside`. |
| `helperTextNode` | `Widget?` | `null` | Below the field. |
| `startNode` | `Widget?` | `null` | Inside the border, before `inputNode`. |
| `endNode` | `Widget?` | `null` | Inside the border, after `inputNode`. |
| `prependNode` | `Widget?` | `null` | Outside the border, before the field. Squares the start corners. |
| `appendNode` | `Widget?` | `null` | Outside the border, after the field. Squares the end corners. |
| `variant` | `CdsInputVariant` | `foregroundMuted` | Border color source. |
| `focused` | `bool` | `false` | Shows the focus border and switches to the focused variant. |
| `disabled` | `bool` | `false` | Dims the whole stack to 50%. |
| `borderWidth` | `int` | `100` | Border width token (1px). |
| `focusedBorderWidth` | `int?` | `null` (= `borderWidth`) | Extra width token added while focused. |
| `borderRadius` | `int` | `200` | Radius token (8px). |
| `labelVariant` | `CdsInputLabelVariant` | `outside` | Where `labelNode` goes. `inside` stacks it above `inputNode` with 6px vertical padding. |
| `inputBackground` | `CdsColor` | `CdsColor.bg` | Ignored for `secondary`, which uses `bgSecondary`. |
| `onFieldPress` | `VoidCallback?` | `null` | Makes the bordered area pressable. For trigger-style fields only. |

### CdsInputLabel

`const CdsInputLabel(String text, {CdsColor color = CdsColor.fgMuted, CdsFont font = CdsFont.label2, double paddingStart = 0, double paddingEnd = 0, double paddingY = 0.5})`

Padding values are space tokens.

### CdsHelperText

`const CdsHelperText(String text, {CdsColor color = CdsColor.fgMuted, TextAlign align = TextAlign.start, String errorIconSemanticLabel = 'error'})`

With `color: CdsColor.fgNegative` it leads with a filled `info` icon (12px) aligned to the first line.

### CdsTextInputFocusVariant

`const CdsTextInputFocusVariant({required CdsInputVariant variant, required Widget child})`

An inherited widget the stack places around its slots. `CdsTextInputFocusVariant.maybeOf(context)` returns the focused variant, which `CdsInputIcon` and `CdsInputIconButton` use to follow the focus color.

### CdsInputVariant

| Value | Border | Helper text and caret |
| --- | --- | --- |
| `positive` | `bgPositive` | `fgPositive` |
| `negative` | `bgNegative` | `fgNegative` |
| `foreground` | `bgInverse` | `fg` |
| `primary` | `bgPrimary` | `fgPrimary` |
| `foregroundMuted` | `bgLineHeavy` | `fgMuted` |
| `secondary` | none, `bgSecondary` fill | `fgMuted` |

`variant.focusedVariant(focused)` returns `primary` while focused, except for `positive` and `negative`, which keep their color so validation stays visible.

### CdsTextInputSize

`s`, `m`, `l`: 8, 12 and 16px vertical padding inside the border.

### CdsInputLabelVariant

`outside` (above the field) or `inside` (inside the border).

## Examples

### Prepend and append

```dart
CdsInputStack(
  prependNode: const CdsBox(padding: 2, background: CdsColor.bgSecondary, child: CdsText('https://')),
  inputNode: const Padding(padding: EdgeInsets.all(16), child: CdsText('example.com')),
)
```

### Error helper

```dart
const CdsHelperText('Enter a valid address', color: CdsColor.fgNegative)
```

## Accessibility

The stack adds no semantics of its own. The widget you pass as `inputNode` provides the field semantics; `CdsTextInput` shows how (labeled text field, helper as hint, errors in a live region). With `onFieldPress` the area is focusable and activates with Enter and Space.

## Motion

When `focused` turns true, a second border fades in over the first in `CdsDurations.moderate1` with `CdsCurves.enterFunctional`, and fades out with `CdsCurves.exitFunctional`. It sits half outside the field, so layout never shifts. Reduced motion makes it instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `inputNode`, `labelNode`, `helperTextNode` | same names |
| `startNode`, `endNode`, `prependNode`, `appendNode` | same names |
| `variant`, `focused`, `disabled` | same names |
| `borderWidth`, `focusedBorderWidth`, `borderRadius` | same names |
| `labelVariant`, `inputBackground`, `onFieldPress` | same names |
| `borderStyle`, `borderFocusedStyle` | computed from `variant` and `focused` |
| `enableColorSurge`, `width`, `height` | not ported |
| `HelperText` `color`, `errorIconAccessibilityLabel` | `CdsHelperText` `color`, `errorIconSemanticLabel` |
| `InputLabel` | `CdsInputLabel` |
| `TextInputFocusVariantContext` | `CdsTextInputFocusVariant` |
