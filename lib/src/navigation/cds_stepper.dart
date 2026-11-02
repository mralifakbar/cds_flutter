import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Layout of a [CdsStepper].
enum CdsStepperDirection { horizontal, vertical }

/// One step in a [CdsStepper]. Steps can nest through [subSteps].
@immutable
class CdsStepperStep {
  const CdsStepperStep({required this.id, this.label, this.accessibilityLabel, this.subSteps});

  /// Unique within the stepper; [CdsStepper.activeStepId] refers to it.
  final String id;
  final String? label;

  /// Read instead of [label] by screen readers.
  final String? accessibilityLabel;
  final List<CdsStepperStep>? subSteps;
}

List<CdsStepperStep> _flatten(List<CdsStepperStep> steps) => [
      for (final step in steps) ...[step, ..._flatten(step.subSteps ?? const [])],
    ];

bool _contains(CdsStepperStep step, String targetId) =>
    (step.subSteps ?? const []).any((s) => s.id == targetId || _contains(s, targetId));

/// Shows progress through a sequence of steps, such as an onboarding or
/// verification flow.
///
/// Horizontal steppers show a "2/4 Label" header over one bar per step.
/// Vertical steppers show an icon, connector line and label per step, and
/// support nested [CdsStepperStep.subSteps].
///
/// ```dart
/// CdsStepper(
///   direction: CdsStepperDirection.vertical,
///   activeStepId: 'id',
///   steps: const [
///     CdsStepperStep(id: 'email', label: 'Verify email'),
///     CdsStepperStep(id: 'id', label: 'Verify identity'),
///     CdsStepperStep(id: 'bank', label: 'Link a bank'),
///   ],
/// )
/// ```
class CdsStepper extends StatefulWidget {
  const CdsStepper({
    super.key,
    required this.direction,
    required this.steps,
    required this.activeStepId,
    this.complete = false,
    this.animate = true,
    this.completedStepAccessibilityLabel = 'Complete',
    this.accessibilityLabel,
  });

  final CdsStepperDirection direction;
  final List<CdsStepperStep> steps;

  /// Id of the current step, or null when no step is active.
  final String? activeStepId;

  /// Marks every step as done.
  final bool complete;

  /// Fills bars one step at a time. Off, or under reduced motion, bars fill
  /// instantly.
  final bool animate;

  /// Appended to the label of visited steps for screen readers.
  final String completedStepAccessibilityLabel;

  /// Overrides the default "Label N of M" announcement of a horizontal
  /// stepper. On a vertical stepper it labels the group.
  final String? accessibilityLabel;

  @override
  State<CdsStepper> createState() => _CdsStepperState();
}

class _CdsStepperState extends State<CdsStepper> with SingleTickerProviderStateMixin {
  int? _filled;

  // Paces the cascade on a ticker rather than a Timer so it pauses off
  // screen and test frameworks can settle it.
  late final AnimationController _stagger = AnimationController(vsync: this, duration: CdsDurations.slow2)
    ..addStatusListener(_onStaggerStatus);

  List<CdsStepperStep> get _flat => _flatten(widget.steps);

  int get _activeTopIndex {
    final id = widget.activeStepId;
    if (id == null) return -1;
    return widget.steps.indexWhere((s) => s.id == id || _contains(s, id));
  }

  int get _target => widget.complete ? widget.steps.length - 1 : _activeTopIndex;

  bool get _instant => !widget.animate || CdsMotion.reduceMotion(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync(initial: _filled == null);
  }

  @override
  void didUpdateWidget(CdsStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  // Advances the filled index one step per slow2 so bars fill in sequence,
  // like CDS, and stops once the target is reached.
  void _sync({bool initial = false}) {
    if (_instant) {
      _stagger.stop();
      _filled = _target;
      return;
    }
    if (initial) _filled = -1;
    if (_filled == _target) return;
    _step();
    if (!_stagger.isAnimating) _stagger.forward(from: 0);
  }

  void _onStaggerStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    if (_filled == _target) return;
    setState(_step);
    if (_filled != _target) _stagger.forward(from: 0);
  }

  void _step() {
    final current = _filled ?? -1;
    final target = _target;
    if (current == target) return;
    _filled = current < target ? current + 1 : current - 1;
  }

  double _progressFor(int index) {
    final filled = _filled ?? -1;
    if (filled < 0) return 0;
    return index <= filled ? 1 : 0;
  }

  String _rootLabel(List<CdsStepperStep> flat) {
    if (widget.accessibilityLabel != null) return widget.accessibilityLabel!;
    final id = widget.activeStepId;
    final index = id == null ? -1 : flat.indexWhere((s) => s.id == id);
    if (index < 0) return 'No active step';
    final step = flat[index];
    final base = step.accessibilityLabel ?? step.label ?? 'Step ${index + 1}';
    return '$base ${index + 1} of ${flat.length}';
  }

  _StepState _stateFor(CdsStepperStep step, List<String> flatIds) {
    final id = widget.activeStepId;
    return _StepState(
      active: !widget.complete && id != null && step.id == id,
      visited: id != null && flatIds.indexOf(id) > flatIds.indexOf(step.id),
      descendantActive: id != null && _contains(step, id),
      complete: widget.complete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final flat = _flat;
    final flatIds = [for (final s in flat) s.id];
    final label = _rootLabel(flat);

    if (widget.direction == CdsStepperDirection.horizontal) {
      return Semantics(
        container: true,
        label: label,
        child: ExcludeSemantics(child: _buildHorizontal(context, flat, flatIds)),
      );
    }
    // Vertical steps announce themselves; a root label would repeat the active one.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.accessibilityLabel,
      child: _buildVertical(context, flatIds),
    );
  }

  Widget _buildHorizontal(BuildContext context, List<CdsStepperStep> flat, List<String> flatIds) {
    final theme = context.cds;
    final id = widget.activeStepId;
    final activeIndex = id == null ? -1 : flatIds.indexOf(id);
    final activeStep = activeIndex < 0 ? null : flat[activeIndex];
    final showHeader = activeStep != null && !widget.complete;
    final half = CdsMotion.duration(context, CdsDurations.fast1);

    final header = Padding(
      padding: EdgeInsetsDirectional.only(bottom: theme.space(1.5)),
      child: AnimatedSwitcher(
        duration: half * 2,
        switchInCurve: const Interval(0.5, 1),
        switchOutCurve: const Interval(0.5, 1),
        layoutBuilder: (current, previous) => Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [...previous, ?current],
        ),
        child: KeyedSubtree(
          key: ValueKey(showHeader ? activeStep.id : '_none'),
          child: showHeader
              ? Row(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: theme.space(1)),
                      child: CdsText('${activeIndex + 1}/${flat.length}', font: CdsFont.caption, color: CdsColor.fgMuted),
                    ),
                    if (activeStep.label != null)
                      Flexible(child: CdsText(activeStep.label!, font: CdsFont.caption, maxLines: 1)),
                  ],
                )
              : const CdsText(' ', font: CdsFont.caption),
        ),
      ),
    );

    Widget step(CdsStepperStep s, double progress) {
      final state = _stateFor(s, flatIds);
      final fill = state.complete
          ? CdsColor.bgLinePrimarySubtle
          : (state.active || state.descendantActive)
              ? CdsColor.bgPrimary
              : state.visited
                  ? CdsColor.bgLinePrimarySubtle
                  : CdsColor.bgPrimary;
      final subs = s.subSteps;
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.space(0.5),
          children: [
            _HorizontalBar(progress: progress, fill: fill),
            if (subs != null && subs.isNotEmpty)
              Row(spacing: theme.space(0.5), children: [for (final sub in subs) step(sub, progress)]),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.space(0.5),
          children: [
            for (var i = 0; i < widget.steps.length; i++) step(widget.steps[i], _progressFor(i)),
          ],
        ),
      ],
    );
  }

  Widget _buildVertical(BuildContext context, List<String> flatIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.steps.length; i++)
          _verticalStep(context, widget.steps[i], 0, _progressFor(i), flatIds),
      ],
    );
  }

  Widget _verticalStep(
      BuildContext context, CdsStepperStep step, int depth, double progress, List<String> flatIds) {
    final theme = context.cds;
    final state = _stateFor(step, flatIds);
    final isLast = flatIds.last == step.id;
    final flatIndex = flatIds.indexOf(step.id);

    Widget? icon;
    Widget? line;
    if (depth == 0) {
      final (name, color) = state.complete
          ? (CdsIconName.circleCheckmark, CdsColor.bgPrimary)
          : state.active
              ? (CdsIconName.outline, CdsColor.bgLinePrimarySubtle)
              : state.descendantActive
                  ? (CdsIconName.outline, CdsColor.bgLinePrimarySubtle)
                  : state.visited
                      ? (CdsIconName.circleCheckmark, CdsColor.bgPrimary)
                      : (CdsIconName.outline, CdsColor.bgLine);
      icon = CdsIcon(name, size: CdsIconSize.s, active: true, color: color);

      if (!isLast) {
        final subIds = [for (final s in _flatten(step.subSteps ?? const [])) s.id];
        final double portion;
        if (state.active && subIds.isNotEmpty && !state.descendantActive) {
          portion = 0;
        } else if (state.descendantActive && subIds.isNotEmpty) {
          portion = (subIds.indexOf(widget.activeStepId!) + 1) / subIds.length;
        } else {
          portion = 1;
        }
        final fill = (state.complete || (!state.active && !state.descendantActive && state.visited))
            ? CdsColor.bgPrimary
            : CdsColor.bgLinePrimarySubtle;
        line = _VerticalLine(progress: progress * portion, fill: fill);
      }
    }

    final labelColor = state.complete
        ? CdsColor.fgMuted
        : (state.active || state.descendantActive)
            ? CdsColor.fgPrimary
            : CdsColor.fgMuted;
    final base = step.accessibilityLabel ?? step.label ?? 'Step ${flatIndex + 1}';
    final done = state.visited || state.complete ? ' (${widget.completedStepAccessibilityLabel})' : '';
    final label = Semantics(
      container: true,
      label: '$base$done ${flatIndex + 1} of ${flatIds.length}',
      selected: state.active,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.only(bottom: theme.space(3)),
          child: step.label == null
              ? const SizedBox(width: double.infinity)
              : CdsText(step.label!, font: depth == 0 ? CdsFont.label1 : CdsFont.label2, color: labelColor, maxLines: 1),
        ),
      ),
    );

    final subs = step.subSteps;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [?icon, if (line != null) Expanded(child: line)],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: (depth + 2) * theme.space(1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  if (subs != null)
                    for (final sub in subs) _verticalStep(context, sub, depth + 1, progress, flatIds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _StepState {
  const _StepState({required this.active, required this.visited, required this.descendantActive, required this.complete});

  final bool active;
  final bool visited;
  final bool descendantActive;
  final bool complete;
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({required this.progress, required this.fill});

  final double progress;
  final CdsColor fill;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final radius = BorderRadius.circular(theme.radius(200));
    return SizedBox(
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.color.bgLine, borderRadius: radius),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: CdsMotion.duration(context, CdsDurations.slow2),
          curve: CdsCurves.global,
          builder: (context, value, _) => FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.colorOf(fill), borderRadius: radius),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine({required this.progress, required this.fill});

  final double progress;
  final CdsColor fill;

  // Painted rather than laid out so the line works inside IntrinsicHeight.
  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 16, minWidth: 2, maxWidth: 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress),
        duration: CdsMotion.duration(context, CdsDurations.slow2),
        curve: CdsCurves.global,
        builder: (context, value, _) => CustomPaint(
          painter: _LinePainter(progress: value, track: theme.color.bgLine, fill: theme.colorOf(fill)),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.progress, required this.track, required this.fill});

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = track);
    final filled = size.height * progress.clamp(0.0, 1.0);
    if (filled > 0) canvas.drawRect(Rect.fromLTWH(0, 0, size.width, filled), Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.progress != progress || old.track != track || old.fill != fill;
}
