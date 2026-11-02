---
name: cds-flutter-craft
description: |
  Craft standard for Flutter apps built with cds_flutter: honest content, screens that reflow from phone to desktop,
  accessibility for every kind of user, fluid touch-driven motion, CDS typography, clear copy and clean code comments.
  Use whenever you build, change or review a screen, flow or custom widget in a cds_flutter app, alongside the
  cds-flutter skill (which covers which component to use). Ends every UI task with the delivery checklist.
license: Apache-2.0
---

# cds_flutter craft

The cds-flutter skill tells you *which* component to use. This skill tells you how to make the result feel designed rather than generated: purposeful, honest, usable by everyone, and alive under the finger.

## Two modes

- **Build** (default): apply every section while you write, then run the delivery checklist before you hand anything over.
- **Review** (only when asked to audit or review): produce a numbered list of findings, each with severity (blocker, should fix, polish), the rule it breaks, `file:line`, and a one-line reason. Change nothing until the user picks numbers. Fix exactly those, then re-run the checklist.

## 1. Direction before pixels

CDS is the visual language: its palette, type ramp, spacing and shapes are already decided. What the app brings is identity: its content, its voice, and where the single accent moment lands.

Before building a screen, write one line:

> Building `<screen>` for `<who>`, so they can `<one decision or task>`. Energy `<calm|balanced|bold>`, rhythm `<uniform|mostly consistent|varied>`, motion `<feedback only|transitions|choreographed>`.

- **Energy** is how loudly the screen greets you. A settings page is calm; an onboarding hero may be bold.
- **Rhythm** is how much consecutive sections differ in composition.
- **Motion** is how much moves and why.

Hold those choices to the end of the screen. If you cannot name the user's one decision on a screen, the screen is not ready to build. If the product owner has not given a direction for voice or brand moments, ask one short question; if you cannot ask, build calm/uniform/feedback-only and say it is a draft.

## 2. Honesty (blocking)

- Never show numbers, prices, balances, statistics, testimonials, names, avatars or logos that are not real data or explicitly labeled sample data. Empty is better than invented.
- Placeholders say what they are: `Your name`, `name@example.com`, "Sample data", "Coming soon". Never `John Doe` or `$48.2K +12%`.
- No security, compliance, performance or "trusted by" claims without evidence the user gave you.
- Do not create logos, app icons or photos of people on assumption. Use the product name in text, initials avatars (`CdsAvatar` fallback), or ask.
- Never use Coinbase logos, wordmarks or proprietary fonts, and never imply Coinbase made or endorsed the app.

## 3. Function and states (blocking)

- Every control does something real: navigates to a route that exists, opens and closes an overlay, toggles state, submits with feedback. Otherwise remove it, or ship it disabled with a visible "Coming soon" and a `TODO:` naming the task.
- Navigation items (tabs, sidebar, menus) only point at destinations that exist.
- Every data view has three states, each saying *why* and *what next*:
  - **Loading**: `CdsFallback` shapes that match the real layout, or a progress indicator with text.
  - **Empty**: `CdsEmptyState` with the reason and the one action that fills it ("No transactions yet. Buy crypto to see activity here.").
  - **Error**: what failed in plain words and how to recover (retry button, check connection).
  - First run, filtered-to-nothing, offline and permission-denied are different screens with different copy.
- Forms validate inline as the user leaves a field (`CdsTextFormField`), keep the entered value on error, and disable submit only while submitting (`loading: true`).

## 4. Accessibility (blocking)

- **Contrast**: text at least 4.5:1, large text (24px+ or 19px+ bold) and UI boundaries at least 3:1. Stick to CDS foreground tokens on CDS backgrounds; when you combine anything custom, compute it with `CdsColorUtils.contrastRatio`, never eyeball grey on grey. Text over images needs a scrim and is checked at its lightest spot.
- **Touch**: every target at least 44x44 with a few pixels between neighbours. `CdsPressable(minTapTargetSize: 44)` pads small visuals.
- **Screen readers**: every control has a role, label and state. Icon-only buttons get `semanticLabel`. Decorative icons stay excluded. Group a row's text with `MergeSemantics`. Mark screen and section titles as headers. Announce async results (`liveRegion`, `SemanticsService.announce`).
- **Keyboard and switch access**: Tab follows visual order, Enter/Space activate, Escape closes overlays, arrows move inside groups, focus is trapped in modals and restored to the trigger. Never remove the focus ring.
- **Text size**: verify at 2x text scale. No fixed heights around text; use min heights, `Flexible`, wrapping and ellipsis only where truncation is acceptable.
- **Never color alone**: pair positive/negative color with a sign, icon or word ("+2.4%", "Failed").
- **Platform settings**: reduced motion (`CdsMotion.reduceMotion`), high contrast (handled by `CdsThemeProvider`), bold text, RTL (use start/end and `EdgeInsetsDirectional`).

## 5. Layout that reflows (blocking on phones)

A phone layout is its own layout, not the desktop one squeezed.

- Decide breakpoints from content, using width classes as a starting point: compact (< 600), medium (600 to 1024), expanded (> 1024). Use `LayoutBuilder` or `MediaQuery.sizeOf`.
  - Compact: one column, bottom navigation for up to five primary destinations, sticky primary action in `CdsStickyFooter`.
  - Medium: two columns where content has two natural groups, or a list/detail split.
  - Expanded: `CdsSidebar` navigation, content capped at a readable width (about 720 for text, wider for tables and charts).
- Check the narrowest phone (320 wide) and every width between: no horizontal overflow, no clipped text, no colliding rows.
- Long content scrolls (`ListView`, slivers). Tables scroll horizontally inside their own container, never the page.
- Respect safe areas, the home indicator and the on-screen keyboard (`MediaQuery.viewInsetsOf`): a focused field is never hidden, a fixed bottom bar never covers the last row (reserve its height as bottom padding).
- Keep fixed chrome compact so content dominates; a header can shrink on scroll.
- Size with tokens and relative constraints, not fixed pixel widths. Give flex children room to shrink.

## 6. Composition and hierarchy

- **One focal point per screen**: the balance, the price, the primary action. Everything else defers to it in size, weight and color.
- **Type hierarchy from the CDS ramp**: `title1` for the screen, `title3` for sections, `headline` for row titles, `body` for prose, `label2` with `fgMuted` for metadata, `caption` for overlines, `legal` for disclosures. Emphasize with weight before size.
- **Spacing as structure**: `0.5` icon to label, `1` inside a group, `2` between groups, `3` page gutter, `4` to `5` between sections. Varying gaps is how the eye finds groups; one value everywhere flattens the screen.
- **One accent**: `bgPrimary` belongs to the primary action and the current selection. Zero accent feels sterile; accent on everything means nothing stands out.
- **One primary button per screen**; secondary and transparent buttons for the rest.
- **Build from the user's decision, not a template.** Avoid the default dashboard (sidebar, four stat cards, a chart, a table) and the default landing (hero, three feature cards, testimonials, FAQ). If a section exists only because "apps usually have one", cut it.
- **Vary composition by content weight**: the flagship item can be a full-width card, the rest a list. Identical cards for unequal content hide the hierarchy.

## 7. Techniques that need a reason

Each is allowed when you can state its purpose in one line; otherwise leave it out.

- **Elevation** (`CdsElevation.level1/2`) only for surfaces that float above others: cards in a feed, menus, trays. Most surfaces sit flat.
- **Translucency/blur** (`BackdropFilter`) on at most one piece of chrome that content scrolls under, with a solid fallback in high contrast.
- **Gradients** only to encode data (chart fills) or an established brand moment.
- **Tags and dots** only for real state (pending, failed, new since last visit), never decoration. A dot that marks nothing goes.
- **Icons** chosen for meaning. No sparkle, magic wand, lightning or robot glyphs as generic "feature" icons. No emoji in UI text.
- **Arrows and chevrons** where they signal navigation (`caretRight` on a row that opens a page), not on every button.
- **Illustrations** only when they explain something about this product.
- **Radius** follows CDS: pills for buttons and chips, 300 to 500 for cards and sheets. Do not round everything to a pill.

## 8. Motion that answers touch

Motion answers touch. Feedback on press, springs that start from where things are, sheets that follow the finger. Nothing loops forever.

- **Respond instantly.** Visual feedback on pointer-down (CDS pressables do this). No artificial delays, debounces on the visual path, or waiting for a transition before accepting input.
- **Direct manipulation.** Dragged things move 1:1 with the finger and keep the offset from where they were grabbed. Track velocity during the drag.
- **Interruptible always.** Use `AnimationController.unbounded` + `CdsMotion.springTo`, which starts from the current value and velocity. A user must be able to catch a closing sheet and pull it back without a jump. Never lock input during a transition.
- **Springs, not stopwatch curves, for touch.** `CdsSprings.standard` (no overshoot) by default; `CdsSprings.momentum` (a little bounce) only when the gesture carried momentum, such as a flick or a throw; `CdsSprings.sheet` for trays and drawers. Move X and Y with separate springs.
- **Velocity handoff.** On release, pass the finger's velocity into the spring so there is no seam between dragging and animating.
- **Project momentum.** Choose the snap target from `position + CdsMotion.project(velocity)`, not from where the finger lifted. Decide dismiss vs. return from velocity direction, not position alone.
- **Soft edges.** Past a boundary, resist with `CdsMotion.rubberband` instead of stopping dead.
- **Spatial consistency.** Things leave the way they came; overlays grow from their trigger; page transitions match navigation direction. Intermediate frames hint where the motion is going.
- **Fixed-duration transitions** (fades, color, expand/collapse) use `CdsDurations` and `CdsCurves`: fast (100 to 150ms) for controls, moderate (200 to 300ms) for small moves and modals, slow (350 to 500ms) for large moves.
- **Nothing loops forever.** Repetition is allowed only while a real process runs (loading), stops off screen, and becomes static under reduced motion. No idle pulses, floating elements, or decorative shimmer.
- **Haptics on the causal moment** (commit, snap, selection change) through `cdsHaptic`, on the same frame as the visual. Not on every scroll tick.
- **Reduced motion** swaps slides, scales and springs for an instant change or a short cross-fade, keeps opacity and color changes that aid understanding, and avoids large moving surfaces.
- Animate transform and opacity; avoid animating layout every frame.

## 9. Typography details

- Money, balances, counters and changing numbers use `tabularNumbers: true` so digits do not jiggle; addresses and hashes use `mono: true`.
- Do not invent letter-spacing or font sizes outside the ramp. If something needs to be bigger, move up the ramp.
- Format numbers and dates with the user's locale (`intl`), including currency symbols and decimal separators.
- Truncate only where the full value is available elsewhere (a detail screen, a tooltip).

## 10. Copy

- Labels name the action and the object: "Send USDC", "Add payment method", "Review order". Not "Submit", "Get started", "Learn more".
- Sentence case for titles and buttons. Uppercase only through the `caption` token.
- Errors: what happened, then what to do ("Card declined. Try another card or contact your bank."). Never blame the user, never show raw exception text.
- Empty states: why it is empty, then the action.
- Confirmation dialogs only for destructive or irreversible actions, and the confirm button repeats the verb ("Remove wallet").
- No em dash character. Use a period, comma, colon or parentheses.
- No hype words: seamless, effortless, powerful, revolutionary, next-generation, cutting-edge, unlock, elevate, supercharge. Say the concrete benefit.
- No announcements of what you are about to say, no chatty sign-offs, no rhetorical "Honestly?" openers, no lists forced into threes.
- Name the actor: "We sent a code to your phone", not "A code has been sent".
- Keep the product's own voice when the user provides one.

## 11. Code and comments

- Public widgets get dartdoc: one sentence on purpose plus a short example. Parameters get docs only when the name does not say everything.
- Comments explain why (a platform quirk, a CDS rule, a non-obvious constraint) in one or two lines. Never restate the code, narrate steps, add banner separators, emoji, end-of-block markers, or vague TODOs.
- Build features in source. Never patch generated files or other code with scripts.
- Prefer small composable widgets, `const` constructors, controlled inputs (`value` + `onChange`), and tokens from `context.cds` over literals.

## 12. Delivery checklist

Run before handing over any UI. Report each line as PASS or FAIL with concrete evidence. Any FAIL means fix and re-run; never deliver with a FAIL.

**Blocking**
1. No invented data, people, logos or claims; sample data labeled.
2. Every control and navigation item works or is visibly marked "Coming soon".
3. Loading, empty and error states exist for every data view, each with cause and next action.
4. Contrast checked (4.5:1 text, 3:1 large text and UI); no color-only status.
5. Targets at least 44px; semantics labels, roles and states present; keyboard path works; focus ring visible.
6. No overflow or clipping at 320 wide and at 2x text scale; safe areas and keyboard respected; medium and expanded widths have their own layout.
7. Light, dark and high-contrast all render correctly.
8. Ran the app (simulator, device or web) and tapped every control. Evidence recorded per control, for example: "Send -> opens amount screen", "empty amount -> inline error", "tray -> drags, flings closed, Escape closes".

**Purpose**
9. Elevation, blur, gradients, tags, dots, icons and arrows each have a stated reason.
10. Motion follows section 8: press feedback, interruptible springs, velocity handoff, no endless loops, reduced motion handled.

**Craft**
11. The direction line from section 1 was written and the screen matches it.
12. One focal point, one primary action, one accent moment per screen.
13. Hierarchy from the CDS ramp and token spacing; no template sections.
14. Copy passes section 10: specific labels, no em dash, no hype words.
15. Comments pass section 11.
16. Swap the product name and logo: the screen still feels like this product because of its content and decisions, not because of decoration.
