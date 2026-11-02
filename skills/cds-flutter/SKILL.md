---
name: cds-flutter
description: |
  Build and review Flutter UI with cds_flutter, the unofficial Flutter port of the Coinbase Design System (CDS).
  Use when creating screens, components or visual changes in a Flutter app that depends on cds_flutter, when choosing
  CDS components, tokens, icons or motion, or when auditing Flutter code for CDS adherence.
  Not for non-visual logic (state management, networking, persistence) or for apps that do not use cds_flutter.
license: Apache-2.0
---

# cds_flutter

## Companion skill

Load `cds-flutter-craft` together with this one for every UI task. It holds the design, accessibility, motion and copy standard and the delivery checklist that closes each task.

## Before writing code

1. Confirm the app depends on `cds_flutter` (check `pubspec.yaml`). If not, ask before adding it.
2. Read `references/guides/for-ai-agents.md` once per session. It has the ground rules and the component picker table.
3. For every component you plan to use, read its page in `references/components/<Name>.md`. Parameters, defaults and examples there are exact; do not guess names from React CDS or Material.
4. Tell the user which CDS components you will use before building.

## Rules

- `import 'package:cds_flutter/cds_flutter.dart';` and `CdsThemeProvider` at the root. Read the theme with `context.cds`.
- Layout with `CdsVStack`, `CdsHStack`, `CdsBox`, `CdsSpacer`, `CdsDivider`. Text with `CdsText`. Icons with `CdsIcon(CdsIconName.x)`.
- Colors: `CdsColor` tokens only. Spacing: 8px token scale (`gap: 2` is 16px). Radius: token keys (`borderRadius: 400`). Never hardcode a hex color or a pixel value a token covers.
- Every widget is `Cds`-prefixed; props follow CDS names (`onPress`, `onChange`, `value`, `variant`, `size`, `disabled`, `loading`, `start`/`end`, `block`, `transparent`, `helperText`).
- One primary `CdsButton` per screen. Icon-only buttons need `semanticLabel`.
- Custom tappable surfaces use `CdsPressable`, never raw `GestureDetector`/`InkWell`.
- Custom motion follows `references/guides/motion.md`: feedback on press, springs from the current value (`CdsMotion.springTo`), drags follow the finger with velocity handoff, nothing loops forever, honor `CdsMotion.reduceMotion`.
- Every data view ships loading (`CdsFallback`), empty and error (`CdsEmptyState`) states.
- Accessibility per `references/guides/accessibility.md`: 44px targets, keyboard, contrast, never color-only status.
- Copy: specific labels ("Send USDC"), no em dash, no buzzwords, no invented numbers or testimonials presented as real.

## If no component fits

1. Compose CDS primitives (`CdsBox`, stacks, `CdsPressable`, `CdsText`, `CdsIcon`) with tokens.
2. Only then fall back to plain Flutter widgets, styled from `context.cds`.

## Review mode

When asked to audit code for CDS adherence, check in this order and report findings with file:line:
hardcoded colors or spacing; Material widgets where a CDS component exists; missing semantics or tap targets;
missing loading/empty/error states; motion that ignores reduced motion or loops forever; more than one primary button.
