# CdsKbd

Keyboard keys drawn as keycaps, for documenting shortcuts.

Not part of CDS. Styled with CDS tokens: `bgAlternate` keys, `bgLineHeavy` border with a heavier bottom edge, `label2` text.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsKbd(['⌘', 'K'])
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `List<String>` | required (positional) | One entry per key, in press order. |
| `semanticLabel` | `String?` | spoken key names | |

`CdsKbd.spokenLabel(keys)` returns the spoken form: ⌘ Command, ⇧ Shift, ⌥ Option, ⌃ Control, ↵ Enter, ⏎ Return, ⌫ Delete, ⎋ Escape, ⇥ Tab, arrows by name.

## Examples

```dart
Row(children: [const CdsText.label2('Search'), const SizedBox(width: 8), const CdsKbd(['Ctrl', 'K'])])
```

## Accessibility

One node labelled with the spoken keys ("Command K"). Keys wrap onto new lines instead of overflowing at large text sizes.

## Motion

None.

## CDS React Native mapping

Not in CDS. Inspired by shadcn_flutter's KeyboardDisplay.
