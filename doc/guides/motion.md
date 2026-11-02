# Motion

Motion answers touch. Feedback on press, springs that start from where things are, sheets that follow the finger. Nothing loops forever.

## Rules every component follows

1. **Feedback on pointer-down.** Pressables tint and scale the moment a finger lands, not on release.
2. **Springs for anything touchable.** A spring starts from the current on-screen value and carries velocity, so a moving element can be grabbed and reversed without a jump.
3. **Drags follow the finger 1:1.** On release, the element continues at the finger's velocity, the resting point is projected from that velocity, and edges rubberband instead of stopping dead.
4. **Same path in and out.** A tray leaves downward because it came from below; a popover grows from its trigger.
5. **Nothing loops forever.** Spinners turn only while something is loading and only while on screen. No idle pulses, no decorative shimmer by default.
6. **Reduced motion is honored.** When the platform asks, slides and springs become instant changes or short fades.

## API

```dart
// Springs: damping ratio + response (seconds to reach the target).
CdsSprings.standard   // 1.0 / 0.35, default, no overshoot
CdsSprings.press      // 1.0 / 0.20, press feedback
CdsSprings.momentum   // 0.8 / 0.35, only after a flick
CdsSprings.sheet      // 0.86 / 0.32, trays and drawers
CdsSprings.of(dampingRatio: 0.9, response: 0.3)

// Drive an unbounded controller from where it is now, with the finger's velocity.
final c = AnimationController.unbounded(vsync: this);
CdsMotion.springTo(c, target, spring: CdsSprings.sheet, velocity: releaseVelocity);

// Where a flick would come to rest (UIScrollView deceleration).
final restingPoint = offset + CdsMotion.project(velocityPxPerSecond);

// Resistance past a boundary.
final shown = CdsMotion.rubberband(overshoot, containerExtent);

// Reduced motion.
if (CdsMotion.reduceMotion(context)) { /* fade or jump */ }
final d = CdsMotion.duration(context, CdsDurations.moderate2); // zero when reduced
```

Use an unbounded controller for springs that can overshoot; a bounded `AnimationController` clamps the value.

## Building a draggable sheet (sketch)

```dart
void onDragUpdate(DragUpdateDetails d) {
  final next = offset + d.delta.dy;
  offset = next < 0 ? -CdsMotion.rubberband(-next, height) : next; // resist above the top
  controller.value = offset;
}

void onDragEnd(DragEndDetails d) {
  final v = d.velocity.pixelsPerSecond.dy;
  final projected = offset + CdsMotion.project(v);
  final dismiss = projected > height / 2;
  CdsMotion.springTo(controller, dismiss ? height : 0, spring: CdsSprings.sheet, velocity: v);
}
```

`CdsTray` implements this fully, including handing off between the sheet and a scrollable inside it.
