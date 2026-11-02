# Contributing to cds_flutter

This file is the contract every component follows. Read it fully before adding or changing a component. It applies to human contributors and to coding agents alike.

## What this package is

`cds_flutter` is an unofficial Flutter port of the [Coinbase Design System](https://cds.coinbase.com) (CDS). The reference implementation is CDS React Native (`packages/mobile` in [github.com/coinbase/cds](https://github.com/coinbase/cds)), Apache-2.0. When in doubt about a value, a prop, or a behavior, read the React Native source and match it.

Licensing rules that are not negotiable:

- Never ship Coinbase logos, wordmarks, sub-brand marks, or the proprietary Coinbase Sans/Display/Mono fonts. `LogoMark`, `LogoWordMark`, `SubBrandLogoMark`, `SubBrandLogoWordMark` are intentionally not ported.
- Code ported from CDS keeps the Apache-2.0 header obligations: `NOTICE` lists what came from CDS. Do not remove attribution.
- Never describe the package as official or endorsed by Coinbase.

## Layout

```
lib/
  cds_flutter.dart            public barrel (maintainers edit this)
  src/
    theme/                    tokens, palettes, typography, motion, provider
    icons/  layout/  system/  typography/  buttons/  feedback/   foundation
    <category>/               one folder per component category
      <category>.dart         category barrel: exports every public file in the folder
      cds_<component>.dart    one public component (plus its sub-widgets) per file
test/
  helpers/harness.dart        pumpCds(), cdsHarness(), goldenPair()
  <category>/cds_<component>_test.dart
doc/components/<component>.md one reference page per component (template below)
example/lib/gallery/categories/<category>.dart   demos for the example app
```

## API conventions

1. **Prefix every public widget with `Cds`** (`CdsButton`, `CdsTextInput`). It avoids clashes with Material and Cupertino.
2. **Mirror CDS prop names**, translated to Dart style: `onPress` (not `onTap`), `disabled`, `loading`, `variant`, `size`, `start`/`end` (leading/trailing slots), `startIcon`/`endIcon`, `block`, `transparent`, `compact`, `helperText`, `label`, `title`, `description`, `accessory`, `media`, `selected`, `value`/`onChange`. If CDS calls it `onChange`, so do we. Text content is a `String label`/`title`; arbitrary content goes in a `Widget` slot.
3. **Enums for closed sets** (`CdsButtonVariant`, `CdsButtonSize`, `CdsIconSize`). Name enum values exactly as CDS names the string union (`foregroundMuted`, `xs`).
4. **Colors are tokens.** Color props take `CdsColor`. A raw `Color` escape hatch, when needed, is named `dangerouslySet<Prop>` exactly like CDS (`dangerouslySetColor`, `dangerouslySetBackground`).
5. **Space, radius, border width are scale tokens**: space is a `double` on the 8px scale (`padding: 2` is 16px), radius an `int` key (`borderRadius: 400` is 16px), border width an `int` key (`borderWidth: 100` is 1px). Resolve with `context.cds.space(2)`, `.radius(400)`, `.borderWidth(100)`. Never hardcode a pixel value that exists as a token.
6. **Read the theme through `context.cds`** (`CdsThemeData`). Typography: `context.cds.typography[CdsFont.body]` or `CdsText`. Never use Material `Theme.of` inside a component.
7. **Controlled by default.** Stateful inputs take `value` + `onChange` and do not hold their own copy of the value. Internal state is only for transient UI (pressed, focused, open, drag offset).
8. **`const` constructors** wherever possible. Required params first, positional only for the obvious primary value (`CdsIcon(CdsIconName.add)`, `CdsText('Hi')`).
9. **Composition over configuration.** Expose sub-widgets (`CdsModalHeader`, `CdsModalBody`, `CdsModalFooter`) the way CDS does, and give every slot a sensible default.
10. **No new dependencies** without maintainer approval. The package depends only on Flutter and `clock` (for test-clock-aware timing; use `clock.now()`, never `DateTime.now()`, in component logic). Painting (charts, rings) uses `CustomPainter`.

## Interaction and motion

Motion answers touch. Feedback on press, springs that start from where things are, sheets that follow the finger. Nothing loops forever.

- **Build every tappable surface on `CdsPressable`.** It gives pointer-down tint and 0.98 scale, hover, keyboard focus ring (`CdsFocusRingPainter`), Enter/Space activation, haptics, debounce and semantics. Do not use `GestureDetector`/`InkWell` directly for buttons, cells, chips or tiles.
- **Feedback starts on pointer-down**, never only on release.
- **Springs, not fixed curves, for anything a finger touches.** Use `AnimationController.unbounded` + `CdsMotion.springTo(controller, target, spring: ..., velocity: ...)`. A spring always starts from the controller's current value, so an animation can be grabbed and reversed mid-flight without a jump. Pick from `CdsSprings.standard` (no bounce, default), `.press`, `.momentum` (only after a flick), `.sheet`.
- **Drag follows the finger 1:1**, respecting the grab offset. On release, hand the finger's velocity to the spring, use `CdsMotion.project(velocity)` to choose the snap target from where the gesture is heading, and `CdsMotion.rubberband` past bounds instead of a hard stop. Decide dismiss vs. return from velocity direction, not only position.
- **Fixed-duration transitions** (fades, color changes, expand/collapse) use `CdsDurations` + `CdsCurves`, and `CdsMotion.duration(context, d)` so reduced motion collapses them.
- **Enter and exit on the same path**, anchored to the trigger (a popover grows from its anchor, a tray leaves the way it came).
- **Nothing loops forever.** A repeating animation exists only while a real state is true (loading), stops when the widget leaves the screen (`TickerMode`), and is replaced by a static state under reduced motion. No idle pulses, no decorative shimmer that runs by default.
- **Reduced motion** (`CdsMotion.reduceMotion(context)`): replace slides, scales and springs with an instant change or a short cross-fade. Keep color/opacity changes that aid comprehension.
- **Haptics on the causal event** (commit, snap, selection change), through `cdsHaptic`. Not on every frame.

## Accessibility

- Every interactive element exposes `Semantics`: role (`button`, `toggled`, `checked`, `selected`, `slider`, `textField`), a label, and state. Icon-only controls require a `semanticLabel` parameter.
- Hit areas are at least 44x44 logical px (`minTapTargetSize: 44` on `CdsPressable`), even when the visual is smaller.
- Keyboard: Tab order follows visual order, Enter/Space activate, Escape closes overlays, arrow keys move within groups (radio group, segmented control, tabs, menus), focus is trapped inside modal overlays and restored on close.
- Text scales with the platform setting. Never put text in a fixed-height box that clips it; use min heights.
- Contrast comes from tokens. Never pair `fgMuted` with `bgSecondary`-family backgrounds for body text without checking `CdsColorUtils.contrastRatio` (>= 4.5).
- Status is never color alone: pair color with an icon or text.
- Toasts and inline errors announce through `liveRegion`/`SemanticsService.announce`.
- RTL: use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`.

## States

Any component that shows data supports empty, loading and error states, or documents how the caller provides them (for example a `loading` flag that swaps in `CdsFallback` placeholders). Empty and error copy names the cause and the next action.

## Writing: docs, comments, demo copy

- Dartdoc on every public class and constructor parameter that is not self-explanatory, with one short usage example. Comments explain why, never restate the code. No banner comments, no step narration, no emoji.
- No em dash character in any text. No buzzwords (seamless, powerful, effortless, next-generation). Specific CTAs ("Buy Bitcoin", "Send USDC"), never "Get started" / "Learn more".
- Demo data is sample data and is labeled as such in the example app. Never present invented numbers, names, or testimonials as real.

## Tests

Every component ships with widget tests in `test/<category>/cds_<component>_test.dart` using `pumpCds` from `test/helpers/harness.dart`. Cover, as applicable:

1. Renders in light and dark without exceptions.
2. Callbacks fire on tap, and do not fire when disabled or loading.
3. Controlled value: tapping calls `onChange` with the next value; the widget reflects the `value` it is given.
4. Semantics: role, label, state flags (`tester.getSemantics(...)` + `matchesSemantics`, or `find.bySemanticsLabel`).
5. Keyboard: focus via `tester.sendKeyEvent(LogicalKeyboardKey.tab)`, activate with Enter/Space, Escape closes overlays.
6. Gestures: drags with `tester.drag`/`tester.fling`, verifying snap targets and velocity-driven dismissal.
7. Reduced motion: `pumpCds(..., disableAnimations: true)` and verify no running tickers after one pump where relevant.
8. Text scale 2.0 does not overflow (no exceptions).
9. One golden per category file is welcome: tag it `@Tags(['golden'])`, render with `goldenPair`, store under `test/goldens/`.

Run before finishing: `flutter analyze` (zero issues) and `flutter test test/<category>`.

## Component doc template (`doc/components/<component>.md`)

```markdown
# CdsComponentName

One sentence: what it is and when to reach for it.

CDS reference: https://cds.coinbase.com/components/<category>/<Name>

## Import

(fenced dart block) import 'package:cds_flutter/cds_flutter.dart';

## Usage

(fenced dart block) smallest useful example

## When to use / when not to

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |

## Examples
### <Variant or scenario>

## Accessibility
## Motion
## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
```

Code goes in fenced blocks tagged `dart`. Keep examples compilable and minimal. Agents read these pages to build apps, so be exact about types and defaults.
