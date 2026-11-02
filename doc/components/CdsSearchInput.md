# CdsSearchInput

A filled, pill-shaped search field with a search icon at the start and a clear button once there is text. Reach for it at the top of a list or screen to filter or search.

CDS reference: https://cds.coinbase.com/components/inputs/SearchInput

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSearchInput(
  placeholder: 'Search assets',
  value: query,
  onChange: (v) => setState(() => query = v),
  onSearch: runSearch,
)
```

Control it with `value` + `onChange`, or with a `controller`, like `CdsTextInput`.

## When to use / when not to

- Use to search or filter content.
- Use `CdsTextInput` for regular data entry; the search look implies a query, not a value that gets saved.

## Behavior

- While focused, the search icon becomes a back arrow. Pressing it calls `onBack` and removes focus (dismissing the keyboard). Set `disableBackArrow` to keep the search icon, or `startIcon` to fix the glyph.
- Pressing the search icon calls `onSearch` with the current text and focuses the field.
- Submitting from the keyboard (search action) calls `onSearch`.
- The clear button shows when the text is not empty. It calls `onClear`, clears the text, keeps focus, then calls `onChange('')` and `onSearch('')`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | `null` | Owns the text when given. |
| `value` | `String?` | `null` | Text to show when no controller is given. |
| `onChange` | `ValueChanged<String>?` | `null` | Full text after every edit, and `''` after clear. |
| `onSearch` | `ValueChanged<String>?` | `null` | Submit, search icon press, and clear (with `''`). |
| `onClear` | `VoidCallback?` | `null` | Clear button pressed. |
| `onBack` | `VoidCallback?` | `null` | Back arrow pressed. |
| `focusNode` | `FocusNode?` | `null` | |
| `placeholder` | `String?` | `'Search'` | |
| `label` | `String?` | `null` | Optional label above the field. |
| `helperText` | `String?` | `null` | |
| `size` | `CdsTextInputSize?` | `null` (`l`) | |
| `compact` | `bool` | `false` | Size `s`. |
| `disabled` | `bool` | `false` | |
| `bordered` | `bool` | `true` | Shows the focus border. The resting field has no border. |
| `borderRadius` | `int` | `1000` | Radius token (pill). |
| `font` | `CdsFont` | `CdsFont.body` | |
| `startIcon` | `CdsSearchInputStartIcon?` | `null` | `search` or `backArrow`. Fixes the glyph. |
| `hideStartIcon` | `bool` | `false` | |
| `disableBackArrow` | `bool` | `false` | Keep the search glyph while focused. |
| `hideEndIcon` | `bool` | `false` | Never show the clear button. |
| `end` | `Widget?` | `null` | Replaces the clear button. |
| `autofocus` | `bool` | `false` | |
| `onFocus` | `VoidCallback?` | `null` | |
| `onBlur` | `VoidCallback?` | `null` | |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | |
| `semanticLabel` | `String?` | `null` | Defaults to `label`, then `placeholder`. |
| `startIconSemanticLabel` | `String` | `'Back'` | Back arrow label. |
| `searchIconSemanticLabel` | `String` | `'Search'` | Search icon button label. |
| `clearIconSemanticLabel` | `String` | `'Clear text'` | |

## Examples

### Fixed search glyph

```dart
CdsSearchInput(
  disableBackArrow: true,
  value: query,
  onChange: (v) => setState(() => query = v),
)
```

### Compact in a toolbar

```dart
const CdsSearchInput(compact: true, placeholder: 'Search')
```

## Accessibility

- The field is a text field node labeled by `semanticLabel ?? label ?? placeholder`.
- The start icon and clear button are separate buttons with their own labels and are reachable by keyboard.
- Tapping the icons does not count as tapping outside the field, so focus is kept on desktop.

## Motion

Same as `CdsTextInput`: the focus border cross-fades in `moderate1`; instant under reduced motion. The icon swap on focus is immediate.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `value` / `onChangeText` | `value` / `onChange` |
| `onSearch`, `onClear`, `onBack` | same names |
| `startIcon` (`'search' \| 'backArrow'`) | `startIcon` (`CdsSearchInputStartIcon`) |
| `hideStartIcon`, `hideEndIcon`, `disableBackArrow`, `end` | same names |
| `startIconAccessibilityLabel`, `clearIconAccessibilityLabel` | `startIconSemanticLabel`, `clearIconSemanticLabel` |
| (none) | `searchIconSemanticLabel` |
| `borderRadius` (default 1000), `compact`, `size`, `disabled`, `placeholder` | same names |
| `accessibilityLabel` | `semanticLabel` |
