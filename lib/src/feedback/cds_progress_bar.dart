import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_progress_circle.dart';

/// Where the labels of a progress bar sit.
enum CdsProgressLabelPlacement { above, below, beside }

/// A numeric progress label, usually a percentage (`70` reads "70%").
///
/// The number counts from its previous value when it changes. Pass [render]
/// for custom text:
///
/// ```dart
/// CdsProgressBarLabel(3, render: (value, disabled) => CdsText('${value.round()} of 5 steps'))
/// ```
@immutable
class CdsProgressBarLabel {
  const CdsProgressBarLabel(this.value, {this.render});

  final double value;
  final Widget Function(double value, bool disabled)? render;
}

/// A horizontal progress track. Value changes animate from wherever the bar
/// is (CDS `slow3` with the global curve); under reduced motion the bar jumps.
///
/// ```dart
/// CdsProgressBar(progress: 0.4)
/// CdsProgressBar(progress: 0.75, weight: CdsProgressWeight.heavy, color: CdsColor.bgPositive)
/// ```
class CdsProgressBar extends StatefulWidget {
  const CdsProgressBar({
    super.key,
    this.progress = 0,
    this.weight = CdsProgressWeight.normal,
    this.color = CdsColor.bgPrimary,
    this.disabled = false,
    this.disableAnimateOnMount = false,
    this.accessibilityLabel,
    this.onAnimationStart,
    this.onAnimationEnd,
  });

  /// 0 to 1.
  final double progress;

  /// Track height: thin 2, normal 4, semiheavy 8, heavy 12.
  final CdsProgressWeight weight;
  final CdsColor color;

  /// Grays the fill out (`bgLineHeavy`).
  final bool disabled;

  /// Start at [progress] instead of filling from 0 on first build.
  final bool disableAnimateOnMount;
  final String? accessibilityLabel;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationEnd;

  @override
  State<CdsProgressBar> createState() => _CdsProgressBarState();
}

class _CdsProgressBarState extends State<CdsProgressBar> {
  @override
  void initState() {
    super.initState();
    if (!widget.disableAnimateOnMount && widget.progress > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onAnimationStart?.call());
    }
  }

  @override
  void didUpdateWidget(CdsProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) widget.onAnimationStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final progress = widget.progress;
    final disabled = widget.disabled;
    final target = progress.clamp(0.0, 1.0);
    final height = widget.weight.strokeWidth;
    final radius = BorderRadius.circular(theme.radius(200));
    final fill = theme.colorOf(disabled ? CdsColor.bgLineHeavy : widget.color);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      label: widget.accessibilityLabel,
      value: '${(target * 100).round()}%',
      enabled: !disabled,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: widget.disableAnimateOnMount ? target : 0, end: target),
        duration: CdsMotion.duration(context, CdsDurations.slow3),
        curve: CdsCurves.global,
        onEnd: widget.onAnimationEnd,
        builder: (context, value, _) => ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.color.bgLine, borderRadius: radius),
              child: FractionallySizedBox(
                alignment: rtl ? Alignment.centerRight : Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: DecoratedBox(decoration: BoxDecoration(color: fill, borderRadius: radius)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated number label shared by the labelled progress bars.
class _ProgressTextLabel extends StatelessWidget {
  const _ProgressTextLabel({
    required this.label,
    required this.disabled,
    required this.disableAnimateOnMount,
    this.color = CdsColor.fg,
  });

  final CdsProgressBarLabel label;
  final bool disabled;
  final bool disableAnimateOnMount;
  final CdsColor color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: disableAnimateOnMount ? label.value : 0, end: label.value),
      duration: CdsMotion.duration(context, CdsDurations.slow3),
      curve: CdsCurves.global,
      builder: (context, value, _) {
        final custom = label.render?.call(value, disabled);
        if (custom != null) return custom;
        return Opacity(
          opacity: disabled ? 0.5 : 1,
          child: CdsText(
            '${value.round()}%',
            font: CdsFont.label2,
            color: color,
            tabularNumbers: true,
            align: TextAlign.end,
            softWrap: false,
          ),
        );
      },
    );
  }
}

/// A [CdsProgressBar] with fixed labels at its start and end, placed above,
/// below or beside the track.
///
/// ```dart
/// CdsProgressBarWithFixedLabels(
///   progress: 0.3,
///   startLabel: const CdsProgressBarLabel(30),
///   endLabel: const CdsProgressBarLabel(100),
///   labelPlacement: CdsProgressLabelPlacement.below,
/// )
/// ```
class CdsProgressBarWithFixedLabels extends StatelessWidget {
  const CdsProgressBarWithFixedLabels({
    super.key,
    required this.progress,
    this.startLabel,
    this.endLabel,
    this.labelPlacement = CdsProgressLabelPlacement.beside,
    this.disabled = false,
    this.disableAnimateOnMount = false,
    this.weight = CdsProgressWeight.normal,
    this.color = CdsColor.bgPrimary,
    this.accessibilityLabel,
    this.child,
  });

  /// 0 to 1.
  final double progress;
  final CdsProgressBarLabel? startLabel;
  final CdsProgressBarLabel? endLabel;
  final CdsProgressLabelPlacement labelPlacement;
  final bool disabled;
  final bool disableAnimateOnMount;
  final CdsProgressWeight weight;
  final CdsColor color;
  final String? accessibilityLabel;

  /// Custom bar; defaults to a [CdsProgressBar] built from [progress].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final bar = child ??
        CdsProgressBar(
          progress: progress,
          disabled: disabled,
          disableAnimateOnMount: disableAnimateOnMount,
          weight: weight,
          color: color,
          accessibilityLabel: accessibilityLabel,
        );
    Widget? text(CdsProgressBarLabel? l) => l == null
        ? null
        : _ProgressTextLabel(label: l, disabled: disabled, disableAnimateOnMount: disableAnimateOnMount);

    if (labelPlacement == CdsProgressLabelPlacement.beside) {
      final start = text(startLabel);
      final end = text(endLabel);
      return Row(
        children: [
          if (start != null) Padding(padding: EdgeInsetsDirectional.only(end: theme.space(1)), child: start),
          Expanded(child: bar),
          if (end != null) Padding(padding: EdgeInsetsDirectional.only(start: theme.space(1)), child: end),
        ],
      );
    }
    final labels = Padding(
      padding: EdgeInsets.only(
        top: labelPlacement == CdsProgressLabelPlacement.below ? theme.space(1) : 0,
        bottom: labelPlacement == CdsProgressLabelPlacement.above ? theme.space(1) : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [text(startLabel) ?? const SizedBox.shrink(), text(endLabel) ?? const SizedBox.shrink()],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: labelPlacement == CdsProgressLabelPlacement.above ? [labels, bar] : [bar, labels],
    );
  }
}

/// A [CdsProgressBar] with a label that rides along with the fill, above or
/// below the track. The label moves and counts in step with the bar.
///
/// ```dart
/// CdsProgressBarWithFloatLabel(progress: 0.6, label: const CdsProgressBarLabel(60))
/// ```
class CdsProgressBarWithFloatLabel extends StatelessWidget {
  const CdsProgressBarWithFloatLabel({
    super.key,
    required this.progress,
    required this.label,
    this.labelPlacement = CdsProgressLabelPlacement.above,
    this.disabled = false,
    this.disableAnimateOnMount = false,
    this.weight = CdsProgressWeight.normal,
    this.color = CdsColor.bgPrimary,
    this.accessibilityLabel,
    this.child,
  }) : assert(labelPlacement != CdsProgressLabelPlacement.beside, 'Float labels sit above or below the bar.');

  /// 0 to 1.
  final double progress;
  final CdsProgressBarLabel label;

  /// [CdsProgressLabelPlacement.above] or [CdsProgressLabelPlacement.below].
  final CdsProgressLabelPlacement labelPlacement;
  final bool disabled;
  final bool disableAnimateOnMount;
  final CdsProgressWeight weight;
  final CdsColor color;
  final String? accessibilityLabel;

  /// Custom bar; defaults to a [CdsProgressBar] built from [progress].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final target = progress.clamp(0.0, 1.0);
    final bar = child ??
        CdsProgressBar(
          progress: progress,
          disabled: disabled,
          disableAnimateOnMount: disableAnimateOnMount,
          weight: weight,
          color: color,
          accessibilityLabel: accessibilityLabel,
        );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final floating = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: disableAnimateOnMount ? target : 0, end: target),
      duration: CdsMotion.duration(context, CdsDurations.slow3),
      curve: CdsCurves.global,
      builder: (context, value, child) => CustomSingleChildLayout(
        delegate: _FloatLabelLayout(progress: value, rtl: rtl),
        child: child,
      ),
      child: ExcludeSemantics(
        child: _ProgressTextLabel(
          label: label,
          disabled: disabled,
          disableAnimateOnMount: disableAnimateOnMount,
          color: CdsColor.fgMuted,
        ),
      ),
    );
    final labelRow = Padding(
      padding: EdgeInsets.only(
        top: labelPlacement == CdsProgressLabelPlacement.below ? theme.space(1) : 0,
        bottom: labelPlacement == CdsProgressLabelPlacement.above ? theme.space(1) : 0,
      ),
      child: _FloatLabelHeight(child: floating),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: labelPlacement == CdsProgressLabelPlacement.above ? [labelRow, bar] : [bar, labelRow],
    );
  }
}

/// Gives the floating label row the height of one `label2` line, scaled with
/// the text scale, so the row never clips.
class _FloatLabelHeight extends StatelessWidget {
  const _FloatLabelHeight({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lineHeight = context.cds.typography[CdsFont.label2].lineHeight;
    final scaled = MediaQuery.textScalerOf(context).scale(lineHeight);
    return SizedBox(height: math.max(lineHeight, scaled), child: child);
  }
}

class _FloatLabelLayout extends SingleChildLayoutDelegate {
  const _FloatLabelLayout({required this.progress, required this.rtl});

  final double progress;
  final bool rtl;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = rtl
        ? math.min(size.width - childSize.width, size.width - size.width * progress)
        : math.max(0.0, size.width * progress - childSize.width);
    return Offset(x.clamp(0.0, math.max(0.0, size.width - childSize.width)), 0);
  }

  @override
  bool shouldRelayout(_FloatLabelLayout old) => old.progress != progress || old.rtl != rtl;
}
