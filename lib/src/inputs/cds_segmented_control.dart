import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// One choice in a [CdsSegmentedControl]: a text [label] or an [icon].
@immutable
class CdsSegmentedControlOption<T> {
  const CdsSegmentedControlOption({
    required this.value,
    this.label,
    this.icon,
    this.iconActive = false,
    this.semanticLabel,
  }) : assert((label == null) != (icon == null), 'Give each option either a label or an icon.');

  final T value;
  final String? label;
  final CdsIconName? icon;

  /// Use the filled glyph for [icon].
  final bool iconActive;

  /// Read by screen readers. Required in practice for icon options;
  /// defaults to [label].
  final String? semanticLabel;
}

/// A row of mutually exclusive options with a highlight that slides to the
/// selected one. Use it to switch views or units within a screen, like
/// "Buy | Sell" or "1D | 1W | 1M".
///
/// ```dart
/// CdsSegmentedControl<String>(
///   value: side,
///   onChange: (v) => setState(() => side = v),
///   options: const [
///     CdsSegmentedControlOption(value: 'buy', label: 'Buy'),
///     CdsSegmentedControlOption(value: 'sell', label: 'Sell'),
///   ],
/// )
/// ```
///
/// Tap a segment to select it, or drag across the control: the segment under
/// the finger is selected as you go. Grabbing the highlight itself makes it
/// follow the finger 1:1, and on release it springs to the selected segment
/// carrying the finger's velocity. Left and right arrow keys move the
/// selection.
class CdsSegmentedControl<T> extends StatefulWidget {
  const CdsSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    this.onChange,
    this.block = false,
    this.disabled = false,
    this.iconSize = CdsIconSize.m,
    this.feedback = CdsHapticFeedback.selection,
    this.semanticLabel,
  }) : assert(options.length > 1, 'A segmented control needs at least two options.');

  final List<CdsSegmentedControlOption<T>> options;

  /// The selected option's value. A value matching no option shows no highlight.
  final T value;

  /// Called with the newly selected value. Null makes the control read-only.
  final ValueChanged<T>? onChange;

  /// Stretch to the parent's width. Otherwise every segment is as wide as
  /// the widest label.
  final bool block;
  final bool disabled;

  /// Size for icon options.
  final CdsIconSize iconSize;

  /// Haptic fired when the selection changes.
  final CdsHapticFeedback feedback;

  /// Names the whole group for screen readers.
  final String? semanticLabel;

  @override
  State<CdsSegmentedControl<T>> createState() => _CdsSegmentedControlState<T>();
}

enum _DragMode { none, follow, chase }

class _CdsSegmentedControlState<T> extends State<CdsSegmentedControl<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _position =
      AnimationController.unbounded(vsync: this, value: _selectedIndex.clamp(0, widget.options.length - 1).toDouble());
  final GlobalKey _trackKey = GlobalKey();
  List<FocusNode> _focusNodes = [];
  _DragMode _drag = _DragMode.none;
  double _grabOffset = 0;
  int _dragIndex = -1;

  int get _selectedIndex => widget.options.indexWhere((o) => o.value == widget.value);
  int get _count => widget.options.length;
  bool get _interactive => !widget.disabled && widget.onChange != null;

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
  }

  void _syncFocusNodes() {
    while (_focusNodes.length < _count) {
      _focusNodes = [..._focusNodes, FocusNode(debugLabel: 'CdsSegmentedControl segment ${_focusNodes.length}')];
    }
    while (_focusNodes.length > _count) {
      _focusNodes.removeLast().dispose();
    }
  }

  @override
  void didUpdateWidget(CdsSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusNodes();
    if (_drag != _DragMode.none) return;
    final index = _selectedIndex;
    if (index >= 0 && index.toDouble() != _position.value) _settleAt(index);
  }

  @override
  void dispose() {
    _position.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _settleAt(int index, {double velocity = 0}) {
    if (CdsMotion.reduceMotion(context)) {
      _position.stop();
      _position.value = index.toDouble();
      return;
    }
    CdsMotion.springTo(_position, index.toDouble(), velocity: velocity);
  }

  void _select(int index) {
    if (!_interactive || index < 0 || index >= _count) return;
    final value = widget.options[index].value;
    if (value == widget.value) return;
    cdsHaptic(widget.feedback);
    widget.onChange!(value);
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  /// Finger position in segment units (0 at the start edge, [_count] at the end).
  double? _units(Offset global) {
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || box.size.width == 0) return null;
    final dx = box.globalToLocal(global).dx;
    final segment = box.size.width / _count;
    return (_rtl ? box.size.width - dx : dx) / segment;
  }

  double get _segmentWidth {
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    return box == null || !box.hasSize ? 1 : box.size.width / _count;
  }

  int _indexAt(double units) => units.floor().clamp(0, _count - 1);

  void _onDragStart(DragStartDetails details) {
    if (!_interactive) return;
    final u = _units(details.globalPosition);
    if (u == null) return;
    final v = _position.value;
    _dragIndex = _indexAt(u);
    if (_selectedIndex >= 0 && u >= v && u <= v + 1) {
      _position.stop();
      _drag = _DragMode.follow;
      _grabOffset = u - v;
    } else {
      _drag = _DragMode.chase;
      _select(_dragIndex);
      _settleAt(_dragIndex, velocity: _position.velocity);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_drag == _DragMode.none) return;
    final u = _units(details.globalPosition);
    if (u == null) return;
    final index = _indexAt(u);
    if (_drag == _DragMode.follow) {
      final max = (_count - 1).toDouble();
      var target = u - _grabOffset;
      final w = _segmentWidth;
      if (target < 0) target = CdsMotion.rubberband(target * w, w) / w;
      if (target > max) target = max + CdsMotion.rubberband((target - max) * w, w) / w;
      _position.value = target;
    }
    if (index != _dragIndex) {
      _dragIndex = index;
      _select(index);
      if (_drag == _DragMode.chase) _settleAt(index, velocity: _position.velocity);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_drag == _DragMode.none) return;
    final mode = _drag;
    _drag = _DragMode.none;
    if (mode == _DragMode.follow) {
      final px = details.velocity.pixelsPerSecond.dx;
      _settleAt(_dragIndex, velocity: (_rtl ? -px : px) / _segmentWidth);
    }
  }

  void _onDragCancel() {
    if (_drag == _DragMode.none) return;
    _drag = _DragMode.none;
    final index = _selectedIndex;
    if (index >= 0) _settleAt(index);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !_interactive) return KeyEventResult.ignored;
    final key = event.logicalKey;
    int step;
    if (key == LogicalKeyboardKey.arrowRight) {
      step = _rtl ? -1 : 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      step = _rtl ? 1 : -1;
    } else {
      return KeyEventResult.ignored;
    }
    final current = _focusNodes.indexWhere((n) => n.hasFocus);
    final from = current >= 0 ? current : _selectedIndex.clamp(0, _count - 1);
    final next = (from + step).clamp(0, _count - 1);
    if (next == from) return KeyEventResult.handled;
    _focusNodes[next].requestFocus();
    _select(next);
    return KeyEventResult.handled;
  }

  Widget _optionVisual(CdsSegmentedControlOption<T> option, {required bool selected}) {
    final color = selected ? CdsColor.fgPrimary : CdsColor.fgMuted;
    if (option.label != null) {
      return CdsText(option.label!, font: selected ? CdsFont.headline : CdsFont.body, color: color, maxLines: 1);
    }
    return CdsIcon(option.icon!, size: widget.iconSize, active: option.iconActive, color: color);
  }

  Widget _segment(int index, bool selected) {
    final theme = context.cds;
    final option = widget.options[index];
    final checkPx = theme.iconSize(CdsIconSize.xs);
    final gap = theme.space(0.5);
    final reserve = checkPx + gap;

    // The invisible headline-weight copy sizes the segment, so switching
    // between body and headline weight never changes its width.
    final content = Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.space(1.5) + reserve / 2),
          child: Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: _optionVisual(option, selected: true),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: _optionVisual(option, selected: selected)),
                if (selected) ...[
                  SizedBox(width: gap),
                  const CdsIcon(CdsIconName.checkmark, size: CdsIconSize.xs, color: CdsColor.fgPrimary),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    return CdsPressable(
      onPress: _interactive ? () => _select(index) : null,
      disabled: widget.disabled,
      noScaleOnPress: true,
      debounce: Duration.zero,
      borderRadius: 200,
      focusNode: _focusNodes[index],
      selected: selected,
      semanticLabel: option.semanticLabel ?? option.label,
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final selectedIndex = _selectedIndex;
    final radius = BorderRadius.circular(theme.radius(200));

    final indicator = Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / _count;
          return AnimatedBuilder(
            animation: _position,
            builder: (context, _) {
              final v = _position.value;
              final start = _rtl ? (_count - 1 - v) * segment : v * segment;
              return Stack(
                children: [
                  Positioned(
                    left: start,
                    top: 0,
                    bottom: 0,
                    width: segment,
                    child: Opacity(
                      opacity: selectedIndex < 0 ? 0 : 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: theme.color.bgPrimaryWash, borderRadius: radius),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    Widget track = Stack(
      key: _trackKey,
      children: [
        indicator,
        Row(
          children: [
            for (var i = 0; i < _count; i++) Expanded(child: _segment(i, i == selectedIndex)),
          ],
        ),
      ],
    );

    track = RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          HorizontalDragGestureRecognizer.new,
          (r) => r
            ..onStart = _onDragStart
            ..onUpdate = _onDragUpdate
            ..onEnd = _onDragEnd
            ..onCancel = _onDragCancel,
        ),
      },
      child: track,
    );

    track = DecoratedBox(
      decoration: BoxDecoration(color: theme.color.bgAlternate, borderRadius: radius),
      child: track,
    );

    track = widget.block ? SizedBox(width: double.infinity, child: track) : IntrinsicWidth(child: track);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Focus(canRequestFocus: false, skipTraversal: true, onKeyEvent: _onKey, child: track),
    );
  }
}
