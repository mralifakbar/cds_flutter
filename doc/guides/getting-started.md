# Getting started

Install the package, wrap your app in `CdsThemeProvider`, and build your first screen.

## Install

```sh
flutter pub add cds_flutter
```

Requires Flutter 3.35 or newer. The package bundles Inter, Source Code Pro and the CDS icon font; nothing else to configure.

## Wrap your app

`CdsThemeProvider` resolves light or dark (following the system by default), switches to the high-contrast theme when the platform asks for it, and cross-fades colors when the scheme changes.

```dart
import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CdsThemeProvider(
      colorScheme: CdsColorSchemePreference.system,
      child: Builder(
        builder: (context) => MaterialApp(
          // Lets Material widgets you still use (Scaffold, text selection) match CDS.
          theme: cdsMaterialTheme(context.cds),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
```

`MaterialApp` is optional. Any `WidgetsApp` works; CDS widgets only need a `CdsTheme` above them (and an `Overlay`/`Navigator` for overlays).

## Build a screen

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.cds.color.bg,
      child: SafeArea(
        child: CdsVStack(
          padding: 3,
          gap: 2,
          children: [
            const CdsText.title1('Wallet'),
            const CdsText.body('Send and receive crypto with your self-custody wallet.', color: CdsColor.fgMuted),
            const Spacer(),
            CdsButton(label: 'Receive', block: true, onPress: () {}),
          ],
        ),
      ),
    );
  }
}
```

## Next

- [Theming](theming.md): brand colors, your own fonts, forcing a scheme for a subtree.
- [Tokens](tokens.md): colors, spacing, radius, typography.
- [Motion](motion.md): springs, gestures, reduced motion.
- [Accessibility](accessibility.md)
- [Component reference](../components/)
- [For AI coding agents](for-ai-agents.md)
