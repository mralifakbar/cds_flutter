# CdsAvatarButton

A `CdsAvatar` that can be pressed, typically to open a profile or account switcher.

CDS reference: https://cds.coinbase.com/components/inputs/AvatarButton

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsAvatarButton(name: 'Satoshi', semanticLabel: 'Open profile', onPress: openProfile)
```

## When to use / when not to

Use in app bars and headers where the user's avatar leads to their account. For a decorative avatar, use `CdsAvatar`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `semanticLabel` | `String` | required | What pressing does, e.g. "Open profile". |
| `onPress` | `VoidCallback?` | `null` | Null disables the button. |
| `onLongPress` | `VoidCallback?` | `null` | |
| `src` | `String?` | `null` | Image URL. |
| `image` | `ImageProvider?` | `null` | Any image provider; wins over `src`. |
| `name` | `String?` | `null` | First letter shown without a picture. |
| `shape` | `CdsAvatarShape` | `circle` | |
| `colorScheme` | `CdsHue` | `CdsHue.blue` | Letter tile hue. |
| `borderColor` | `CdsColor?` | `null` | |
| `compact` | `bool` | `false` | `xl` (40px) avatar instead of `xxxl` (56px). |
| `disabled` | `bool` | `false` | |
| `feedback` | `CdsHapticFeedback` | `light` | Haptic on press. |
| `focusNode` | `FocusNode?` | `null` | |
| `autofocus` | `bool` | `false` | |

## Examples

### Compact in an app bar

```dart
CdsAvatarButton(src: photoUrl, name: 'Ada', compact: true, semanticLabel: 'Switch account', onPress: switchAccount)
```

## Accessibility

Announced as a button with `semanticLabel`. Hit area is at least 44x44. Focusable; Enter and Space activate.

## Motion

Built on `CdsPressable`: tint and 0.98 scale on pointer-down with a spring; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `src`, `name`, `shape`, `colorScheme`, `borderColor` | same names |
| `compact` | `compact` |
| `onPress` | `onPress` |
| `accessibilityLabel` | `semanticLabel` (required) |
| `feedback` | `feedback` |
