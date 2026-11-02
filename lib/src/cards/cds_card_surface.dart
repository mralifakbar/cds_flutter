import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';

/// The rounded surface every card is drawn on. Internal to cds_flutter.
///
/// When [onPress] is set, a [CdsPressable] fills the card behind its
/// content instead of wrapping it. Wrapping would merge every inner button
/// into the card's single semantics node, so a screen reader activating the
/// card would trigger the inner button. Here the card is one button
/// labelled [semanticLabel], and inner buttons (dismiss, actions) stay
/// separate. Taps that land on an inner gesture detector go to it alone;
/// taps anywhere else reach the card.
class CdsCardSurface extends StatefulWidget {
  const CdsCardSurface({
    super.key,
    required this.child,
    this.onPress,
    this.background,
    this.dangerouslySetBackground,
    this.borderRadius = 500,
    this.bordered = false,
    this.borderColor,
    this.elevation = CdsElevation.none,
    this.semanticLabel,
    this.semanticHint,
    this.feedback = CdsHapticFeedback.none,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onPress;
  final CdsColor? background;
  final Color? dangerouslySetBackground;
  final int borderRadius;
  final bool bordered;
  final CdsColor? borderColor;
  final CdsElevation elevation;
  final String? semanticLabel;
  final String? semanticHint;
  final CdsHapticFeedback feedback;
  final FocusNode? focusNode;

  @override
  State<CdsCardSurface> createState() => _CdsCardSurfaceState();
}

class _CdsCardSurfaceState extends State<CdsCardSurface> with SingleTickerProviderStateMixin {
  late final AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController.unbounded(vsync: this, value: 1);
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _press(bool down) {
    if (!mounted) return;
    if (CdsMotion.reduceMotion(context)) {
      _scale.value = 1;
      return;
    }
    CdsMotion.springTo(
      _scale,
      down ? CdsMotion.pressScale : 1,
      spring: down ? CdsSprings.press : CdsSprings.standard,
      velocity: _scale.velocity,
    ).whenCompleteOrCancel(() {
      // The spring stops within its tolerance; land exactly on rest so the
      // card is not left a fraction of a pixel scaled.
      if (mounted && !down && !_scale.isAnimating) _scale.value = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final radius = BorderRadius.circular(theme.radius(widget.borderRadius));
    final background = widget.dangerouslySetBackground ??
        (widget.background != null
            ? theme.colorOf(widget.background!)
            : (widget.elevation != CdsElevation.none ? theme.elevationBackground(widget.elevation) : null));
    final hasBorder = widget.bordered || widget.borderColor != null;
    final content = ClipRRect(borderRadius: radius, child: widget.child);

    if (widget.onPress == null) {
      return Semantics(
        container: true,
        label: widget.semanticLabel,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: hasBorder
                ? Border.all(color: theme.colorOf(widget.borderColor ?? CdsColor.bgLine), width: theme.borderWidth(100))
                : null,
            boxShadow: theme.shadow(widget.elevation),
          ),
          child: content,
        ),
      );
    }

    final card = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: CdsPressable(
            onPress: widget.onPress,
            onPressIn: () => _press(true),
            onPressOut: () => _press(false),
            background: widget.background ?? CdsColor.transparent,
            dangerouslySetBackground: background,
            borderColor: hasBorder ? (widget.borderColor ?? CdsColor.bgLine) : null,
            borderWidth: hasBorder ? 100 : 0,
            borderRadius: widget.borderRadius,
            elevation: widget.elevation,
            noScaleOnPress: true,
            feedback: widget.feedback,
            semanticLabel: widget.semanticLabel,
            semanticHint: widget.semanticHint,
            excludeChildSemantics: true,
            focusNode: widget.focusNode,
            child: const SizedBox.expand(),
          ),
        ),
        _CardContentHitTest(child: content),
      ],
    );

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: card,
    );
  }
}

/// Lets taps fall through the card content to the pressable surface below,
/// unless they land on a gesture detector inside the content.
class _CardContentHitTest extends SingleChildRenderObjectWidget {
  const _CardContentHitTest({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderCardContentHitTest();
}

class _RenderCardContentHitTest extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final before = result.path.length;
    super.hitTest(result, position: position);
    return result.path.skip(before).any((entry) => entry.target is RenderPointerListener);
  }
}

/// Hides [child] from screen readers when the card's own label already
/// carries its text.
Widget cdsCardText(bool excluded, Widget child) => excluded ? ExcludeSemantics(child: child) : child;

/// Joins non-empty parts into a screen reader label.
String? cdsCardLabel(Iterable<String?> parts) {
  final text = parts.whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
  return text.isEmpty ? null : text;
}

/// Places [content] and [media] side by side in equal halves. The content
/// sets the height and the media stretches to match, so media without an
/// intrinsic height (such as an image sized to fill) never drives layout.
Widget cdsMediaSplit({required Widget content, required Widget media, required bool mediaFirst}) {
  return Stack(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mediaFirst) const Spacer(),
          Expanded(child: content),
          if (!mediaFirst) const Spacer(),
        ],
      ),
      Positioned.fill(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!mediaFirst) const Spacer(),
            Expanded(child: media),
            if (mediaFirst) const Spacer(),
          ],
        ),
      ),
    ],
  );
}
