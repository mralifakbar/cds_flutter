import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';

/// Text set in the CDS type ramp.
///
/// ```dart
/// CdsText('Portfolio', font: CdsFont.title1)
/// CdsText.label2('Updated 2 min ago', color: CdsColor.fgMuted)
/// CdsText(r'$1,204.18', font: CdsFont.title2, tabularNumbers: true)
/// ```
class CdsText extends StatelessWidget {
  const CdsText(
    String this.data, {
    super.key,
    this.font = CdsFont.body,
    this.color = CdsColor.fg,
    this.dangerouslySetColor,
    this.mono = false,
    this.tabularNumbers = false,
    this.align,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textTransform,
    this.semanticsLabel,
    this.underline = false,
  }) : span = null;

  /// Rich text. Child spans inherit the ramp style unless they override it.
  const CdsText.rich(
    InlineSpan this.span, {
    super.key,
    this.font = CdsFont.body,
    this.color = CdsColor.fg,
    this.dangerouslySetColor,
    this.mono = false,
    this.tabularNumbers = false,
    this.align,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.underline = false,
  })  : data = null,
        textTransform = null;

  const CdsText.display1(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.display1, span = null;
  const CdsText.display2(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.display2, span = null;
  const CdsText.display3(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.display3, span = null;
  const CdsText.title1(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.title1, span = null;
  const CdsText.title2(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.title2, span = null;
  const CdsText.title3(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.title3, span = null;
  const CdsText.title4(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.title4, span = null;
  const CdsText.headline(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.headline, span = null;
  const CdsText.body(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.body, span = null;
  const CdsText.label1(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.label1, span = null;
  const CdsText.label2(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.label2, span = null;
  const CdsText.caption(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.caption, span = null;
  const CdsText.legal(String this.data, {super.key, this.color = CdsColor.fg, this.dangerouslySetColor, this.mono = false, this.tabularNumbers = false, this.align, this.maxLines, this.overflow, this.softWrap, this.textTransform, this.semanticsLabel, this.underline = false}) : font = CdsFont.legal, span = null;

  final String? data;
  final InlineSpan? span;
  final CdsFont font;
  final CdsColor color;

  /// Raw color escape hatch. Prefer [color] so text follows the theme.
  final Color? dangerouslySetColor;

  /// Use the theme's monospace family for this ramp entry.
  final bool mono;

  /// Equal-width digits so prices and counters do not shift as they change.
  final bool tabularNumbers;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  /// Overrides the transform the font token defines (caption is uppercase).
  final CdsTextTransform? textTransform;
  final String? semanticsLabel;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final fontStyle = theme.typography[font];
    var style = fontStyle.toTextStyle(
      color: dangerouslySetColor ?? theme.colorOf(color),
      mono: mono,
      tabularNumbers: tabularNumbers,
    );
    if (underline) style = style.copyWith(decoration: TextDecoration.underline);
    final effectiveOverflow = overflow ?? (maxLines != null ? TextOverflow.ellipsis : null);

    if (span != null) {
      return Text.rich(
        span!,
        style: style,
        textAlign: align,
        maxLines: maxLines,
        overflow: effectiveOverflow,
        softWrap: softWrap,
        semanticsLabel: semanticsLabel,
      );
    }
    final transform = textTransform ?? fontStyle.textTransform;
    final text = switch (transform) {
      CdsTextTransform.none => data!,
      CdsTextTransform.uppercase => data!.toUpperCase(),
      CdsTextTransform.lowercase => data!.toLowerCase(),
    };
    return Text(
      text,
      style: style,
      textAlign: align,
      maxLines: maxLines,
      overflow: effectiveOverflow,
      softWrap: softWrap,
      // Screen readers spell out all-caps strings letter by letter; read the source text.
      semanticsLabel: semanticsLabel ?? (transform == CdsTextTransform.none ? null : data),
    );
  }
}
