import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';

/// Where an anchored overlay (popover, dropdown, tooltip) sits relative to
/// its anchor. Names follow CDS (`'bottom-start'` is [bottomStart]).
///
/// `start` and `end` alignments follow the text direction for [top] and
/// [bottom] placements. When the preferred side does not fit, the overlay
/// flips to the opposite side.
enum CdsPlacement {
  top,
  topStart,
  topEnd,
  bottom,
  bottomStart,
  bottomEnd,
  left,
  leftStart,
  leftEnd,
  right,
  rightStart,
  rightEnd,
}

/// The dimmed scrim CDS draws behind modals, alerts, trays and tours.
///
/// [opacity] scales the `bgOverlay` token so callers can fade or dim the scrim
/// in step with a sheet. When [onPress] is set, tapping the scrim calls it.
///
/// ```dart
/// CdsOverlay(onPress: () => Navigator.of(context).maybePop())
/// ```
class CdsOverlay extends StatelessWidget {
  const CdsOverlay({super.key, this.opacity = 1, this.onPress, this.semanticLabel});

  /// 0 hides the scrim, 1 shows the full `bgOverlay` color.
  final double opacity;
  final VoidCallback? onPress;

  /// Screen reader label for the scrim when [onPress] is set, e.g. "Dismiss".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final base = context.cds.color.bgOverlay;
    final t = opacity.clamp(0.0, 1.0);
    Widget scrim = SizedBox.expand(
      child: ColoredBox(color: base.withValues(alpha: base.a * t)),
    );
    if (onPress != null) {
      scrim = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onPress, child: scrim);
      scrim = Semantics(
        button: semanticLabel != null,
        label: semanticLabel,
        onTap: semanticLabel != null ? onPress : null,
        child: scrim,
      );
    } else {
      scrim = ExcludeSemantics(child: scrim);
    }
    return scrim;
  }
}

/// Renders [child] in the nearest [Overlay] (or the root overlay) while
/// [visible] is true, above the rest of the screen. The portal inherits the
/// theme, directionality and media query of the place it is declared, so a
/// `CdsTheme` override above the portal still applies.
///
/// ```dart
/// CdsPortal(
///   visible: showBanner,
///   child: const Align(alignment: Alignment.topCenter, child: MyBanner()),
/// )
/// ```
class CdsPortal extends StatefulWidget {
  const CdsPortal({super.key, required this.child, this.visible = true, this.useRootOverlay = false});

  final Widget child;
  final bool visible;

  /// Render into the root overlay instead of the nearest one, so the portal
  /// also covers nested navigators.
  final bool useRootOverlay;

  @override
  State<CdsPortal> createState() => _CdsPortalState();
}

class _CdsPortalState extends State<CdsPortal> {
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    // The portal stays attached; [CdsPortal.visible] decides what it renders.
    // OverlayPortalController cannot be toggled during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(_controller.show);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayLocation: widget.useRootOverlay ? OverlayChildLocation.rootOverlay : OverlayChildLocation.nearestOverlay,
      overlayChildBuilder: (context) => widget.visible ? widget.child : const SizedBox.shrink(),
    );
  }
}
