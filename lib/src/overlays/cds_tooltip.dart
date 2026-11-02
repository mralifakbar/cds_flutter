import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_overlay.dart';
import 'cds_overlay_internal.dart';

/// Inverts the color scheme for its subtree (dark surface in light mode and
/// the reverse), the way CDS renders tooltips and coachmarks.
class CdsInvertedTheme extends StatelessWidget {
  const CdsInvertedTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return CdsTheme(
      data: CdsThemeData(config: theme.config, brightness: theme.isDark ? Brightness.light : Brightness.dark),
      child: child,
    );
  }
}

/// A short label that explains a control. Opens on long-press with touch,
/// and on hover or keyboard focus with a mouse or keyboard. Grows out of its
/// anchor and closes on Escape, a tap elsewhere or when the pointer leaves.
///
/// The text is also exposed to screen readers as the child's tooltip, so it
/// is never the only way to learn what a control does.
///
/// ```dart
/// CdsTooltip(
///   content: 'Network fees go to validators, not to this app.',
///   child: CdsIconButton(CdsIconName.info, semanticLabel: 'About fees', onPress: showFees),
/// )
/// ```
class CdsTooltip extends StatefulWidget {
  const CdsTooltip({
    super.key,
    required this.child,
    this.content,
    this.contentWidget,
    this.placement = CdsPlacement.top,
    this.gap = 1,
    this.visible = true,
    this.openDelay = Duration.zero,
    this.closeDelay = Duration.zero,
    this.touchDisplayDuration = const Duration(milliseconds: 1500),
    this.invertColorScheme = true,
    this.elevation = CdsElevation.none,
    this.maxWidth = 260,
    this.onOpenTooltip,
    this.onCloseTooltip,
    this.accessibilityLabel,
  }) : assert(content != null || contentWidget != null, 'Pass content or contentWidget.');

  /// The trigger.
  final Widget child;

  /// Tooltip text in the `label2` style.
  final String? content;

  /// Custom tooltip content; overrides [content] visually. [content] (or
  /// [accessibilityLabel]) is still used for screen readers.
  final Widget? contentWidget;
  final CdsPlacement placement;

  /// Space token between the anchor and the tooltip.
  final double gap;

  /// Set false to suppress the tooltip without removing it from the tree.
  final bool visible;
  final Duration openDelay;
  final Duration closeDelay;

  /// How long the tooltip stays up after a long-press is released.
  final Duration touchDisplayDuration;

  /// Render on the opposite color scheme, as CDS does by default.
  final bool invertColorScheme;
  final CdsElevation elevation;
  final double maxWidth;
  final VoidCallback? onOpenTooltip;
  final VoidCallback? onCloseTooltip;

  /// Screen reader text. Defaults to [content].
  final String? accessibilityLabel;

  @override
  State<CdsTooltip> createState() => _CdsTooltipState();
}

class _CdsTooltipState extends State<CdsTooltip> {
  final Object _group = Object();
  bool _open = false;
  bool _hovering = false;
  Timer? _openTimer;
  Timer? _closeTimer;

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  void _scheduleOpen({Duration? delay}) {
    if (!widget.visible) return;
    _closeTimer?.cancel();
    _openTimer?.cancel();
    final d = delay ?? widget.openDelay;
    if (d == Duration.zero) {
      _setOpen(true);
    } else {
      _openTimer = Timer(d, () => _setOpen(true));
    }
  }

  void _scheduleClose({Duration? delay}) {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    final d = delay ?? widget.closeDelay;
    if (d == Duration.zero) {
      _setOpen(false);
    } else {
      _closeTimer = Timer(d, () => _setOpen(false));
    }
  }

  void _setOpen(bool open) {
    if (!mounted || open == _open) return;
    setState(() => _open = open);
    if (open) {
      HardwareKeyboard.instance.addHandler(_onKey);
      widget.onOpenTooltip?.call();
    } else {
      HardwareKeyboard.instance.removeHandler(_onKey);
      widget.onCloseTooltip?.call();
    }
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape && _open) {
      _scheduleClose(delay: Duration.zero);
      return true;
    }
    return false;
  }

  @override
  void didUpdateWidget(CdsTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.visible && _open) _setOpen(false);
  }

  Widget _panel(BuildContext context) =>
      widget.invertColorScheme ? CdsInvertedTheme(child: Builder(builder: _panelBody)) : _panelBody(context);

  Widget _panelBody(BuildContext context) {
    final theme = context.cds;
    Widget body = widget.contentWidget ?? CdsText(widget.content!, font: CdsFont.label2, color: CdsColor.fg);
    body = Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      padding: EdgeInsets.symmetric(horizontal: theme.space(2), vertical: theme.space(1)),
      decoration: BoxDecoration(
        color: theme.color.bg,
        borderRadius: BorderRadius.circular(theme.radius(200)),
        boxShadow: theme.shadow(widget.elevation),
      ),
      child: body,
    );
    // The trigger already carries the text as its semantic tooltip.
    return ExcludeSemantics(child: body);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final label = widget.accessibilityLabel ?? widget.content;
    Widget trigger = Semantics(tooltip: label, child: widget.child);
    trigger = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        final keyboard = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
        if (focused && keyboard) {
          _scheduleOpen();
        } else if (!focused && !_hovering) {
          _scheduleClose();
        }
      },
      child: trigger,
    );
    trigger = MouseRegion(
      onEnter: (_) {
        _hovering = true;
        _scheduleOpen();
      },
      onExit: (_) {
        _hovering = false;
        _scheduleClose();
      },
      child: trigger,
    );
    trigger = GestureDetector(
      onLongPress: () => _scheduleOpen(delay: Duration.zero),
      onLongPressUp: () => _scheduleClose(delay: widget.touchDisplayDuration),
      child: trigger,
    );

    return TapRegion(
      groupId: _group,
      onTapOutside: (_) {
        if (_open) _scheduleClose(delay: Duration.zero);
      },
      child: CdsAnchoredPortal(
        open: _open,
        placement: widget.placement,
        gap: theme.space(widget.gap),
        enterDuration: CdsDurations.fast1,
        exitDuration: CdsDurations.fast1,
        curve: CdsCurves.enterFunctional,
        panelBuilder: _panel,
        child: trigger,
      ),
    );
  }
}
