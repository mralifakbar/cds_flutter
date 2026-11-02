import 'package:clock/clock.dart';
import 'package:flutter/material.dart' show DateTimeRange;
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
import 'cds_dates_internal.dart';

const double _dayDimension = 40;
const double _slotDimension = 44;

/// A month grid for picking a single date.
///
/// ```dart
/// CdsCalendar(
///   selectedDate: date,
///   onPressDate: (d) => setState(() => date = d),
///   minDate: DateTime(2026, 1, 1),
/// )
/// ```
///
/// The month shown starts at [selectedDate], then [seedDate], then today
/// (or [maxDate] when it is in the past). The calendar keeps track of the
/// month being browsed itself; [selectedDate] stays controlled.
///
/// Keyboard: Tab moves into the grid on the selected day (or today, or the
/// first available day). Arrow keys move by day and week, Page Up and Page
/// Down by month, Home and End to the start and end of the week, Enter or
/// Space selects. Moving past the edge of the month shows the next or
/// previous month. Unavailable days are skipped, so focus only lands on days
/// that can be picked.
///
/// Labels are English and weeks start on Sunday, like CDS. Override the
/// accessibility strings to localize them.
class CdsCalendar extends StatefulWidget {
  const CdsCalendar({
    super.key,
    this.selectedDate,
    this.seedDate,
    this.onPressDate,
    this.disabled = false,
    this.hideControls = false,
    this.disabledDates = const [],
    this.disabledDateRanges = const [],
    this.highlightedDates = const [],
    this.highlightedDateRanges = const [],
    this.minDate,
    this.maxDate,
    this.currentDate,
    this.autofocus = false,
    this.disabledDateError = 'Date unavailable',
    this.nextArrowSemanticLabel = 'Go to next month',
    this.previousArrowSemanticLabel = 'Go to previous month',
    this.todaySemanticHint = 'Today',
    this.highlightedDateSemanticHint = 'Highlighted',
  });

  /// Shown with the primary fill. Only the day is used; time is ignored.
  final DateTime? selectedDate;

  /// Month to show when there is no [selectedDate].
  final DateTime? seedDate;

  /// Called with the pressed day at midnight. Null makes the days read-only.
  final ValueChanged<DateTime>? onPressDate;

  /// Dims the calendar and blocks every interaction.
  final bool disabled;

  /// Hides the previous and next month arrows. Useful when [minDate] and
  /// [maxDate] fall in the same month.
  final bool hideControls;

  /// Individual days that cannot be picked.
  final List<DateTime> disabledDates;

  /// Inclusive ranges of days that cannot be picked. Every day in a range is
  /// expanded into a set, so keep ranges to a sensible size.
  final List<DateTimeRange> disabledDateRanges;

  /// Days drawn with `fgPrimary` text, e.g. days with scheduled activity.
  final List<DateTime> highlightedDates;
  final List<DateTimeRange> highlightedDateRanges;

  /// Earliest selectable day, inclusive. Browsing before its month is blocked.
  final DateTime? minDate;

  /// Latest selectable day, inclusive. Browsing after its month is blocked.
  final DateTime? maxDate;

  /// The day treated as today. Defaults to [DateTime.now]. Pass a fixed day
  /// in tests and previews.
  final DateTime? currentDate;

  /// Moves keyboard focus to the selected day (or today) when the calendar
  /// first appears. [CdsDatePicker] sets this when it opens.
  final bool autofocus;

  /// Read as a hint on unavailable days.
  final String disabledDateError;
  final String nextArrowSemanticLabel;
  final String previousArrowSemanticLabel;

  /// Read as a hint on today's date.
  final String todaySemanticHint;

  /// Read as a hint on highlighted dates.
  final String highlightedDateSemanticHint;

  @override
  State<CdsCalendar> createState() => _CdsCalendarState();
}

class _CdsCalendarState extends State<CdsCalendar> {
  late DateTime _month;
  DateTime? _focusDate;
  late final List<FocusNode> _dayNodes = List.generate(31, (i) {
    final node = FocusNode(debugLabel: 'CdsCalendar day ${i + 1}');
    node.addListener(() => _handleDayFocus(i + 1, node));
    return node;
  });

  DateTime get _today => cdsMidnight(widget.currentDate ?? clock.now());
  DateTime? get _min => widget.minDate == null ? null : cdsMidnight(widget.minDate!);
  DateTime? get _max => widget.maxDate == null ? null : cdsMidnight(widget.maxDate!);

  bool _navigated = false;
  late Set<DateTime> _disabledSet;
  late Set<DateTime> _highlightedSet;

  @override
  void initState() {
    super.initState();
    _month = cdsFirstOfMonth(_initialSeed());
    _computeSets();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final day = _tabStopDay();
        if (day != null) _dayNodes[day - 1].requestFocus();
      });
    }
  }

  DateTime _initialSeed() {
    if (widget.selectedDate != null) return widget.selectedDate!;
    if (widget.seedDate != null) return widget.seedDate!;
    final max = _max;
    if (max != null && max.isBefore(_today)) return max;
    return _today;
  }

  void _computeSets() {
    _disabledSet = cdsDateSet(widget.disabledDates, widget.disabledDateRanges);
    _highlightedSet = cdsDateSet(widget.highlightedDates, widget.highlightedDateRanges);
  }

  @override
  void didUpdateWidget(CdsCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _computeSets();
    final selected = widget.selectedDate;
    if (selected != null &&
        !cdsSameDay(selected, oldWidget.selectedDate) &&
        cdsFirstOfMonth(selected) != _month) {
      _month = cdsFirstOfMonth(selected);
    }
  }

  @override
  void dispose() {
    for (final node in _dayNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleDayFocus(int day, FocusNode node) {
    if (!node.hasFocus) return;
    final date = DateTime(_month.year, _month.month, day);
    if (!cdsSameDay(date, _focusDate)) setState(() => _focusDate = date);
  }

  bool _isDisabled(DateTime date) {
    if (widget.disabled) return true;
    final min = _min;
    final max = _max;
    if (min != null && date.isBefore(min)) return true;
    if (max != null && date.isAfter(max)) return true;
    return _disabledSet.contains(date);
  }

  bool _inMonth(DateTime? d) => d != null && d.year == _month.year && d.month == _month.month;

  /// The one day reachable with Tab, so the grid is a single tab stop.
  int? _tabStopDay() {
    for (final candidate in [_focusDate, widget.selectedDate, _today]) {
      if (candidate == null) continue;
      final day = cdsMidnight(candidate);
      if (_inMonth(day) && !_isDisabled(day)) return day.day;
    }
    for (var day = 1; day <= cdsDaysInMonth(_month); day++) {
      if (!_isDisabled(DateTime(_month.year, _month.month, day))) return day;
    }
    return null;
  }

  bool get _canGoPrevious {
    if (widget.disabled) return false;
    final min = _min;
    return min == null || !min.isAfter(DateTime(_month.year, _month.month, 0));
  }

  bool get _canGoNext {
    if (widget.disabled) return false;
    final max = _max;
    return max == null || !max.isBefore(DateTime(_month.year, _month.month + 1));
  }

  void _showMonth(DateTime month) {
    final first = cdsFirstOfMonth(month);
    if (first == _month) return;
    setState(() {
      _month = first;
      _navigated = true;
    });
    cdsAnnounce(context, cdsMonthLabel(first));
  }

  DateTime? _findEnabled(DateTime start, int step) {
    final min = _min;
    final max = _max;
    var date = start;
    for (var i = 0; i < 400; i++) {
      if ((min != null && date.isBefore(min)) || (max != null && date.isAfter(max))) return null;
      if (!_isDisabled(date)) return date;
      date = DateTime(date.year, date.month, date.day + step);
    }
    return null;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final from = _focusDate;
    if (from == null || !_inMonth(from)) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final weekdayIndex = from.weekday % 7;
    DateTime? target;
    var step = 1;
    DateTime addDays(int n) => DateTime(from.year, from.month, from.day + n);
    DateTime addMonths(int n) {
      final first = DateTime(from.year, from.month + n);
      final day = from.day.clamp(1, cdsDaysInMonth(first));
      return DateTime(first.year, first.month, day);
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      step = rtl ? 1 : -1;
      target = addDays(step);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      step = rtl ? -1 : 1;
      target = addDays(step);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      step = -1;
      target = addDays(-7);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      target = addDays(7);
    } else if (key == LogicalKeyboardKey.pageUp) {
      step = -1;
      target = addMonths(-1);
    } else if (key == LogicalKeyboardKey.pageDown) {
      target = addMonths(1);
    } else if (key == LogicalKeyboardKey.home) {
      target = addDays(-weekdayIndex);
    } else if (key == LogicalKeyboardKey.end) {
      step = -1;
      target = addDays(6 - weekdayIndex);
    } else {
      return KeyEventResult.ignored;
    }

    final resolved = _findEnabled(target, step);
    if (resolved != null) _moveFocusTo(resolved);
    return KeyEventResult.handled;
  }

  void _moveFocusTo(DateTime date) {
    _focusDate = date;
    if (_inMonth(date)) {
      setState(() {});
      _dayNodes[date.day - 1].requestFocus();
      return;
    }
    _showMonth(date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dayNodes[date.day - 1].requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final slotGap = theme.space(0.5);
    final tabStop = _tabStopDay();

    final header = Padding(
      padding: EdgeInsetsDirectional.only(start: theme.space(1.5), bottom: theme.space(2)),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: CdsText(cdsMonthLabel(_month), font: CdsFont.headline),
            ),
          ),
          if (!widget.hideControls)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: theme.space(1),
              children: [
                _ArrowButton(
                  icon: rtl ? CdsIconName.forwardArrow : CdsIconName.backArrow,
                  semanticLabel: widget.previousArrowSemanticLabel,
                  onPress: _canGoPrevious ? () => _showMonth(DateTime(_month.year, _month.month - 1)) : null,
                ),
                _ArrowButton(
                  icon: rtl ? CdsIconName.backArrow : CdsIconName.forwardArrow,
                  semanticLabel: widget.nextArrowSemanticLabel,
                  onPress: _canGoNext ? () => _showMonth(DateTime(_month.year, _month.month + 1)) : null,
                ),
              ],
            ),
        ],
      ),
    );

    final weekdays = ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.only(bottom: theme.space(0.5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: slotGap,
          children: [
            for (final name in cdsWeekdayNames)
              SizedBox(
                width: _slotDimension,
                height: _dayDimension,
                child: Center(child: CdsText(name.substring(0, 1))),
              ),
          ],
        ),
      ),
    );

    final leading = _month.weekday % 7;
    final days = cdsDaysInMonth(_month);
    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox.square(dimension: _slotDimension),
      for (var day = 1; day <= days; day++) _buildDay(DateTime(_month.year, _month.month, day), tabStop),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.square(dimension: _slotDimension));
    }

    final grid = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: _MonthFade(
        key: ValueKey(_month),
        animate: _navigated,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: slotGap,
          children: [
            for (var row = 0; row < cells.length; row += 7)
              Row(mainAxisSize: MainAxisSize.min, spacing: slotGap, children: cells.sublist(row, row + 7)),
          ],
        ),
      ),
    );

    return Opacity(
      opacity: widget.disabled ? CdsInteractionOpacity.disabled : 1,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            // Day numbers sit in fixed 40px circles; cap their growth so the
            // grid still fits a phone width at large text sizes.
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.4,
              child: Column(mainAxisSize: MainAxisSize.min, children: [weekdays, grid]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(DateTime date, int? tabStop) {
    final disabled = _isDisabled(date);
    final active = cdsSameDay(date, widget.selectedDate);
    final isToday = cdsSameDay(date, _today);
    final highlighted = _highlightedSet.contains(date);
    final node = _dayNodes[date.day - 1]..skipTraversal = date.day != tabStop;
    final hints = [
      if (isToday) widget.todaySemanticHint,
      if (highlighted) widget.highlightedDateSemanticHint,
      if (disabled) widget.disabledDateError,
    ];
    final textColor = active && !disabled
        ? CdsColor.fgInverse
        : (highlighted ? CdsColor.fgPrimary : CdsColor.fg);
    final onPress = widget.onPressDate;

    return SizedBox.square(
      dimension: _slotDimension,
      child: CdsPressable(
        key: ValueKey(date),
        focusNode: node,
        onPress: disabled || onPress == null ? null : () => onPress(date),
        disabled: disabled,
        background: active && !disabled ? CdsColor.bgPrimary : CdsColor.transparent,
        borderColor: isToday ? CdsColor.bgPrimary : null,
        borderWidth: isToday ? 100 : 0,
        borderRadius: 1000,
        feedback: CdsHapticFeedback.light,
        debounce: Duration.zero,
        minTapTargetSize: _slotDimension,
        semanticLabel: cdsDayLabel(date),
        semanticHint: hints.isEmpty ? null : hints.join('. '),
        selected: active,
        excludeChildSemantics: true,
        child: SizedBox.square(
          dimension: _dayDimension,
          child: Center(child: CdsText('${date.day}', color: textColor, maxLines: 1)),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.semanticLabel, required this.onPress});

  final CdsIconName icon;
  final String semanticLabel;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return CdsPressable(
      onPress: onPress,
      disabled: onPress == null,
      borderRadius: 1000,
      feedback: CdsHapticFeedback.light,
      debounce: Duration.zero,
      minTapTargetSize: _slotDimension,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      child: SizedBox.square(
        dimension: _dayDimension,
        child: Center(child: CdsIcon(icon, size: CdsIconSize.s)),
      ),
    );
  }
}

/// Fades a newly shown month in once. Keyed by month, so it never loops.
class _MonthFade extends StatefulWidget {
  const _MonthFade({super.key, required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  State<_MonthFade> createState() => _MonthFadeState();
}

class _MonthFadeState extends State<_MonthFade> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: CdsDurations.moderate1);
  late final CurvedAnimation _opacity = CurvedAnimation(parent: _controller, curve: CdsCurves.enterFunctional);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.animate || CdsMotion.reduceMotion(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}
