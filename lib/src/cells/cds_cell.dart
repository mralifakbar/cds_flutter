import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../layout/cds_box.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_cell_layout.dart';

/// Spacing for the inner content or outer wrapper of a cell, in space tokens
/// (1 = 8px). Unset values fall back to the cell's defaults.
///
/// [marginX] is a negative token on the inner spacing by default (-2): it
/// pulls the pressed or selected highlight out into the outer padding while
/// the content stays aligned with the page gutter.
@immutable
class CdsCellSpacing {
  const CdsCellSpacing({
    this.padding,
    this.paddingX,
    this.paddingY,
    this.paddingTop,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
    this.marginX,
  });

  final double? padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd;
  final double? marginX;

  /// CDS `defaultSpacingConfig.innerSpacing`.
  static const CdsCellSpacing defaultInner = CdsCellSpacing(paddingX: 2, paddingY: 1, marginX: -2);

  /// CDS `defaultSpacingConfig.outerSpacing` (the page gutter is 3).
  static const CdsCellSpacing defaultOuter = CdsCellSpacing(paddingX: 3, paddingY: 1, marginX: 0);

  /// Inner spacing of the `condensed` spacing variant.
  static const CdsCellSpacing condensedInner = CdsCellSpacing(paddingX: 3, paddingY: 1, marginX: 0);

  /// Outer spacing of the `condensed` variant: no padding outside the press area.
  static const CdsCellSpacing condensedOuter = CdsCellSpacing(paddingX: 0, paddingY: 0, marginX: 0);

  /// Overlays [other] on this spacing. A `padding` in [other] resets both
  /// axes, as `useCellSpacing` does in CDS.
  CdsCellSpacing merge(CdsCellSpacing? other) {
    if (other == null) return this;
    final x = other.paddingX ?? other.padding ?? paddingX;
    final y = other.paddingY ?? other.padding ?? paddingY;
    return CdsCellSpacing(
      padding: other.padding ?? padding,
      paddingX: x,
      paddingY: y,
      paddingTop: other.paddingTop ?? (other.padding != null || other.paddingY != null ? null : paddingTop),
      paddingBottom: other.paddingBottom ?? (other.padding != null || other.paddingY != null ? null : paddingBottom),
      paddingStart: other.paddingStart ?? (other.padding != null || other.paddingX != null ? null : paddingStart),
      paddingEnd: other.paddingEnd ?? (other.padding != null || other.paddingX != null ? null : paddingEnd),
      marginX: other.marginX ?? marginX,
    );
  }

  EdgeInsetsDirectional insets(CdsThemeData theme) => cdsInsets(theme,
      all: padding, x: paddingX, y: paddingY, top: paddingTop, bottom: paddingBottom, start: paddingStart, end: paddingEnd);

  /// [marginX] in logical pixels, keeping its sign.
  double marginPixels(CdsThemeData theme) {
    final m = marginX ?? 0;
    return m < 0 ? -theme.space(-m) : theme.space(m);
  }

  @override
  bool operator ==(Object other) =>
      other is CdsCellSpacing &&
      other.padding == padding &&
      other.paddingX == paddingX &&
      other.paddingY == paddingY &&
      other.paddingTop == paddingTop &&
      other.paddingBottom == paddingBottom &&
      other.paddingStart == paddingStart &&
      other.paddingEnd == paddingEnd &&
      other.marginX == marginX;

  @override
  int get hashCode =>
      Object.hash(padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd, marginX);
}

/// Density of a list or content cell.
enum CdsCellSpacingVariant {
  /// 80px minimum height, 24px gutter. Deprecated in CDS; still the CDS default.
  normal,

  /// Like [normal] with a 40px minimum height. Deprecated in CDS.
  compact,

  /// The current CDS design: no minimum height, no outer padding, square
  /// corners, `label2` descriptions. Prefer this for new screens.
  condensed,
}

/// The layout primitive behind [CdsListCell] and [CdsContentCell]: a row of
/// media, main content, intermediary, end content and accessory, with
/// optional content below.
///
/// ```dart
/// CdsCell(
///   media: CdsCellMedia.icon(CdsIconName.wallet),
///   end: CdsText.body(r'$120.00'),
///   accessory: const CdsCellAccessory(CdsCellAccessoryType.arrow),
///   onPress: openWallet,
///   child: CdsText.headline('Cash'),
/// )
/// ```
///
/// Reach for [CdsListCell] first; use [CdsCell] when you need a layout the
/// list cell's props cannot express.
class CdsCell extends StatelessWidget {
  const CdsCell({
    super.key,
    required this.child,
    this.media,
    this.intermediary,
    this.end,
    this.accessory,
    this.bottomContent,
    this.onPress,
    this.onLongPress,
    this.disabled = false,
    this.selected = false,
    this.priority = const {},
    this.alignItems = CrossAxisAlignment.center,
    this.gap = 2,
    this.rowGap = 1,
    this.background = CdsColor.bgAlternate,
    this.borderRadius = 200,
    this.bordered = false,
    this.minHeight,
    this.maxHeight,
    this.endWidth,
    this.innerSpacing,
    this.outerSpacing,
    this.feedback = CdsHapticFeedback.none,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
  });

  /// Main content, typically a title and description.
  final Widget child;

  /// Leading media such as an icon, avatar or image.
  final Widget? media;

  /// Content between the main content and the end content.
  final Widget? intermediary;

  /// End-aligned content such as a value, status or control.
  final Widget? end;

  /// Trailing accessory such as [CdsCellAccessory].
  final Widget? accessory;

  /// Content below the row, e.g. [CdsCellHelperText].
  final Widget? bottomContent;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;

  /// Dims the cell and blocks presses.
  final bool disabled;

  /// Fills the content with [background] and marks the cell selected for
  /// screen readers.
  final bool selected;

  /// Pieces that keep their natural width when space runs out.
  final Set<CdsCellPriority> priority;
  final CrossAxisAlignment alignItems;

  /// Space token between row pieces.
  final double gap;

  /// Space token between the row and [bottomContent].
  final double rowGap;

  /// Background shown when [selected].
  final CdsColor background;

  /// Radius token of the press and selection highlight.
  final int borderRadius;

  /// Adds a 1px `bgLine` border around the content.
  final bool bordered;

  /// Minimum height of the whole cell, including outer spacing.
  final double? minHeight;
  final double? maxHeight;

  /// Fixed width for [end]; it then neither grows nor shrinks.
  final double? endWidth;
  final CdsCellSpacing? innerSpacing;
  final CdsCellSpacing? outerSpacing;
  final CdsHapticFeedback feedback;

  /// Replaces the text a screen reader builds from the cell's content.
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final inner = CdsCellSpacing.defaultInner.merge(innerSpacing);
    final outer = CdsCellSpacing.defaultOuter.merge(outerSpacing);
    final innerPad = inner.insets(theme);
    final outerPad = outer.insets(theme);
    final margin = inner.marginPixels(theme);
    final rootPad = EdgeInsetsDirectional.fromSTEB(
      (outerPad.start + margin).clamp(0, double.infinity),
      outerPad.top,
      (outerPad.end + margin).clamp(0, double.infinity),
      outerPad.bottom,
    );
    final radius = BorderRadius.circular(theme.radius(borderRadius));

    Widget row = CdsCellLayout(
      media: media,
      main: child,
      intermediary: intermediary,
      end: end,
      accessory: accessory,
      gap: theme.space(gap),
      alignItems: alignItems,
      priority: priority,
      endWidth: endWidth,
    );
    if (bottomContent != null) {
      row = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.space(rowGap),
        children: [row, bottomContent!],
      );
    }

    final contentMin = minHeight == null ? 0.0 : (minHeight! - rootPad.vertical).clamp(0.0, double.infinity);
    final contentMax = maxHeight == null ? double.infinity : (maxHeight! - rootPad.vertical).clamp(0.0, double.infinity);
    Widget content = Container(
      constraints: BoxConstraints(minHeight: contentMin, maxHeight: contentMax),
      padding: innerPad,
      decoration: selected || bordered
          ? BoxDecoration(
              color: selected ? theme.colorOf(background) : null,
              borderRadius: radius,
              border: bordered ? Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)) : null,
            )
          : null,
      child: row,
    );

    if (onPress != null || onLongPress != null) {
      content = CdsPressable(
        onPress: disabled ? null : onPress,
        onLongPress: disabled ? null : onLongPress,
        disabled: disabled,
        block: true,
        noScaleOnPress: true,
        transparentWhileInactive: true,
        background: CdsColor.bg,
        borderRadius: borderRadius,
        feedback: feedback,
        selected: selected ? true : null,
        semanticLabel: semanticLabel,
        semanticHint: semanticHint,
        focusNode: focusNode,
        child: content,
      );
    } else {
      if (disabled) content = Opacity(opacity: CdsInteractionOpacity.disabled, child: content);
      content = Semantics(
        container: true,
        selected: selected ? true : null,
        enabled: disabled ? false : null,
        label: semanticLabel,
        hint: semanticHint,
        child: content,
      );
    }

    return Padding(padding: rootPad, child: content);
  }
}

/// Trailing accessory of a cell.
enum CdsCellAccessoryType {
  /// Caret pointing to the end edge; the row opens something.
  arrow,

  /// Three dots; the row opens a menu.
  more,

  /// Primary-colored checkmark.
  selected,

  /// Keeps the checkmark's space without showing it, so selectable rows align.
  unselected,
}

/// The trailing icon of a cell: an arrow, a more menu or a selection checkmark.
///
/// ```dart
/// const CdsCellAccessory(CdsCellAccessoryType.arrow)
/// ```
class CdsCellAccessory extends StatelessWidget {
  const CdsCellAccessory(this.type, {super.key});

  final CdsCellAccessoryType type;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return switch (type) {
      CdsCellAccessoryType.more => const CdsIcon(CdsIconName.more, size: CdsIconSize.s, color: CdsColor.fgMuted),
      CdsCellAccessoryType.arrow => CdsIcon(rtl ? CdsIconName.caretLeft : CdsIconName.caretRight,
          size: CdsIconSize.s, color: CdsColor.fgMuted),
      CdsCellAccessoryType.selected => const CdsIcon(CdsIconName.checkmark, size: CdsIconSize.s, color: CdsColor.fgPrimary),
      CdsCellAccessoryType.unselected =>
        const Opacity(opacity: 0, child: CdsIcon(CdsIconName.checkmark, size: CdsIconSize.s)),
    };
  }
}

/// Color of a cell's subdetail text.
enum CdsCellDetailVariant { foregroundMuted, negative, positive, warning }

/// End-aligned detail and subdetail text of a cell, such as a balance and
/// its change.
///
/// ```dart
/// CdsCellDetail(detail: r'$4,201.10', subdetail: '+2.4%', variant: CdsCellDetailVariant.positive)
/// ```
class CdsCellDetail extends StatelessWidget {
  const CdsCellDetail({
    super.key,
    this.detail,
    this.detailNode,
    this.subdetail,
    this.subdetailNode,
    this.variant = CdsCellDetailVariant.foregroundMuted,
    this.subdetailFont = CdsFont.label2,
  });

  final String? detail;

  /// Custom detail content; takes precedence over [detail].
  final Widget? detailNode;
  final String? subdetail;

  /// Custom subdetail content; takes precedence over [subdetail].
  final Widget? subdetailNode;

  /// Color of [subdetail]. Pair color with a sign or word so the meaning does
  /// not rest on color alone.
  final CdsCellDetailVariant variant;
  final CdsFont subdetailFont;

  static CdsColor colorOf(CdsCellDetailVariant variant) => switch (variant) {
        CdsCellDetailVariant.foregroundMuted => CdsColor.fgMuted,
        CdsCellDetailVariant.negative => CdsColor.fgNegative,
        CdsCellDetailVariant.positive => CdsColor.fgPositive,
        CdsCellDetailVariant.warning => CdsColor.fgWarning,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        detailNode ??
            (detail != null ? CdsText(detail!, font: CdsFont.body, maxLines: 1, align: TextAlign.end) : null),
        subdetailNode ??
            (subdetail != null
                ? CdsText(subdetail!, font: subdetailFont, color: colorOf(variant), maxLines: 1, align: TextAlign.end)
                : null),
      ].nonNulls.toList(),
    );
  }
}

/// Tone of a [CdsCellHelperText], from `cellHelperTextVariants` in CDS.
enum CdsCellHelperTextVariant { information, warning, error }

/// An assistive message under a cell's content, led by an icon so the tone
/// does not rest on color alone.
///
/// ```dart
/// CdsListCell(
///   title: 'Bank account',
///   helperText: CdsCellHelperText('Verification pending', variant: CdsCellHelperTextVariant.warning),
/// )
/// ```
class CdsCellHelperText extends StatelessWidget {
  const CdsCellHelperText(this.text, {super.key, this.variant = CdsCellHelperTextVariant.information});

  final String text;
  final CdsCellHelperTextVariant variant;

  @override
  Widget build(BuildContext context) {
    final (icon, color, prefix) = switch (variant) {
      CdsCellHelperTextVariant.information => (CdsIconName.info, CdsColor.fgMuted, null),
      CdsCellHelperTextVariant.warning => (CdsIconName.warning, CdsColor.fgWarning, 'Warning'),
      CdsCellHelperTextVariant.error => (CdsIconName.error, CdsColor.fgNegative, 'Error'),
    };
    return CdsText.rich(
      TextSpan(children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: CdsIcon(icon, size: CdsIconSize.xs, active: true, color: color),
        ),
        TextSpan(text: ' $text'),
      ]),
      font: CdsFont.body,
      color: color,
      semanticsLabel: prefix == null ? text : '$prefix: $text',
    );
  }
}
