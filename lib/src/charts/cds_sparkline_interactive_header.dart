import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Color of the sub head (price change) in a [CdsSparklineInteractiveHeader].
enum CdsSparklineInteractiveHeaderVariant { foregroundMuted, positive, negative }

/// Symbol drawn before the sub head text.
enum CdsSparklineInteractiveHeaderSignVariant {
  /// `+`
  positive,

  /// `-`
  negative,

  /// `↗`
  upwardTrend,

  /// `↘`
  downwardTrend,

  /// No symbol.
  none,
}

/// The price change line under the header title.
@immutable
class CdsSparklineInteractiveSubHead {
  const CdsSparklineInteractiveSubHead({
    required this.percent,
    required this.sign,
    required this.variant,
    this.priceChange,
    this.accessoryText,
    this.accessibilityLabel,
  });

  /// Formatted percentage change, such as `4.55%`.
  final String percent;
  final CdsSparklineInteractiveHeaderSignVariant sign;
  final CdsSparklineInteractiveHeaderVariant variant;

  /// Formatted amount of change, such as `$1,204.18`.
  final String? priceChange;

  /// Muted text after the change, such as `All time`.
  final String? accessoryText;

  /// Localized screen reader text for the change. Defaults to "up" or "down"
  /// followed by the price change and percent.
  final String? accessibilityLabel;

  @override
  bool operator ==(Object other) =>
      other is CdsSparklineInteractiveSubHead &&
      other.percent == percent &&
      other.sign == sign &&
      other.variant == variant &&
      other.priceChange == priceChange &&
      other.accessoryText == accessoryText &&
      other.accessibilityLabel == accessibilityLabel;

  @override
  int get hashCode => Object.hash(percent, sign, variant, priceChange, accessoryText, accessibilityLabel);
}

/// Pushes scrub updates into a [CdsSparklineInteractiveHeader] without
/// rebuilding the screen around it, the Flutter counterpart of the CDS header
/// ref's `update()`.
///
/// ```dart
/// final header = CdsSparklineInteractiveHeaderController();
/// // in CdsSparklineInteractive.onScrub:
/// header.update(title: formatPrice(params.point.value), label: formatDate(params.point.date));
/// // in onScrubEnd:
/// header.reset();
/// ```
class CdsSparklineInteractiveHeaderController extends ChangeNotifier {
  String? _label;
  String? _title;
  CdsSparklineInteractiveSubHead? _subHead;

  String? get label => _label;
  String? get title => _title;
  CdsSparklineInteractiveSubHead? get subHead => _subHead;

  /// Overrides the header's label, title and sub head. Null arguments leave
  /// that part unchanged.
  void update({String? label, String? title, CdsSparklineInteractiveSubHead? subHead}) {
    final changed =
        (label != null && label != _label) ||
        (title != null && title != _title) ||
        (subHead != null && subHead != _subHead);
    if (!changed) return;
    _label = label ?? _label;
    _title = title ?? _title;
    _subHead = subHead ?? _subHead;
    notifyListeners();
  }

  /// Returns the header to its default values.
  void reset() {
    if (_label == null && _title == null && _subHead == null) return;
    _label = _title = null;
    _subHead = null;
    notifyListeners();
  }
}

/// The asset header that sits above a [CdsSparklineInteractive]: a label
/// (such as "Bitcoin price"), a large tabular title (the price) and a sub head
/// with the change for the period. Update it while scrubbing through
/// [controller].
///
/// ```dart
/// CdsSparklineInteractiveHeader(
///   controller: header,
///   defaultLabel: 'Sample asset price',
///   defaultTitle: r'$1,204.18',
///   defaultSubHead: const CdsSparklineInteractiveSubHead(
///     percent: '4.55%',
///     priceChange: r'$52.40',
///     sign: CdsSparklineInteractiveHeaderSignVariant.positive,
///     variant: CdsSparklineInteractiveHeaderVariant.positive,
///   ),
/// )
/// ```
class CdsSparklineInteractiveHeader extends StatelessWidget {
  const CdsSparklineInteractiveHeader({
    super.key,
    required this.defaultTitle,
    this.defaultLabel,
    this.defaultSubHead,
    this.controller,
    this.labelNode,
    this.trailing,
    this.compact = false,
  });

  /// Title shown when the controller has no override, usually the price.
  final String defaultTitle;
  final String? defaultLabel;
  final CdsSparklineInteractiveSubHead? defaultSubHead;

  /// Live overrides while scrubbing.
  final CdsSparklineInteractiveHeaderController? controller;

  /// Replaces the text label with a custom widget.
  final Widget? labelNode;

  /// Content at the end of the header, such as an action button.
  final Widget? trailing;

  /// Use the smaller `title3` ramp entry for the title.
  final bool compact;

  static const Map<CdsSparklineInteractiveHeaderSignVariant, String> _signs = {
    CdsSparklineInteractiveHeaderSignVariant.positive: '+',
    CdsSparklineInteractiveHeaderSignVariant.negative: '-',
    CdsSparklineInteractiveHeaderSignVariant.upwardTrend: '↗',
    CdsSparklineInteractiveHeaderSignVariant.downwardTrend: '↘',
    CdsSparklineInteractiveHeaderSignVariant.none: '',
  };

  static String subHeadText(CdsSparklineInteractiveSubHead s) {
    if (s.priceChange != null && s.percent.isNotEmpty) return '${s.priceChange} (${s.percent})';
    return s.priceChange ?? s.percent;
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return _build(context, defaultLabel, defaultTitle, defaultSubHead);
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) =>
          _build(context, c.label ?? defaultLabel, c.title ?? defaultTitle, c.subHead ?? defaultSubHead),
    );
  }

  Widget _build(BuildContext context, String? label, String title, CdsSparklineInteractiveSubHead? subHead) {
    final theme = context.cds;
    final titleFont = compact ? CdsFont.title3 : CdsFont.title1;
    final titleStyle = theme.typography[titleFont];
    // CDS shrinks the title once it passes 12 characters so long prices fit.
    final ratio = title.length <= 12 ? 1.0 : 12 / title.length;
    final titleText = Text(
      title,
      maxLines: 1,
      style: titleStyle
          .toTextStyle(color: theme.color.fg, tabularNumbers: true)
          .copyWith(fontSize: titleStyle.fontSize * ratio),
    );

    Widget? subHeadRow;
    if (subHead != null) {
      final color = switch (subHead.variant) {
        CdsSparklineInteractiveHeaderVariant.positive => CdsColor.fgPositive,
        CdsSparklineInteractiveHeaderVariant.negative => CdsColor.fgNegative,
        CdsSparklineInteractiveHeaderVariant.foregroundMuted => CdsColor.fgMuted,
      };
      final label1 = theme.typography[CdsFont.label1];
      final muted = subHead.variant == CdsSparklineInteractiveHeaderVariant.foregroundMuted;
      subHeadRow = Row(
        children: [
          // A fixed width keeps the text from shifting when + becomes - (0.6em).
          SizedBox(
            width: muted ? 0 : MediaQuery.textScalerOf(context).scale(label1.fontSize) * 0.6,
            child: CdsText(
              _signs[subHead.sign]!,
              font: CdsFont.label1,
              color: color,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: theme.space(0.5) / 2),
          Flexible(
            child: CdsText(subHeadText(subHead), font: CdsFont.label1, color: color, tabularNumbers: true, maxLines: 1),
          ),
          if (subHead.accessoryText != null) ...[
            SizedBox(width: theme.space(0.5)),
            Flexible(
              child: CdsText(subHead.accessoryText!, font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: 1),
            ),
          ],
        ],
      );
    }

    final trend = subHead == null
        ? ''
        : subHead.accessibilityLabel ??
              '${subHead.variant == CdsSparklineInteractiveHeaderVariant.positive ? 'up' : 'down'} '
                  '${subHead.priceChange ?? ''}, ${subHead.percent}';
    final a11y = [?label, title, if (trend.isNotEmpty) trend].join(', ');

    return Semantics(
      header: true,
      liveRegion: true,
      container: true,
      label: a11y,
      hint: 'The price and difference for this time period',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?(labelNode ??
                      (label == null
                          ? null
                          : CdsText(label, font: CdsFont.label1, color: CdsColor.fgMuted, maxLines: 1))),
                  titleText,
                  ?subHeadRow,
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: theme.space(2)),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
