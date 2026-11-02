import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';

/// Opens the URLs that [CdsLink.to] points at.
///
/// cds_flutter has no dependencies, so it cannot open URLs itself. Put a
/// scope near the root and forward to your URL launcher:
///
/// ```dart
/// CdsLinkScope(
///   onOpen: (url) => launchUrl(Uri.parse(url)),
///   child: MyApp(),
/// )
/// ```
class CdsLinkScope extends InheritedWidget {
  const CdsLinkScope({super.key, required this.onOpen, required super.child});

  final void Function(String url) onOpen;

  static CdsLinkScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CdsLinkScope>();

  @override
  bool updateShouldNotify(CdsLinkScope oldWidget) => onOpen != oldWidget.onOpen;
}

/// Pressable text that navigates somewhere, announced as a link.
///
/// ```dart
/// CdsLink('View all assets', onPress: openAssets)
/// CdsLink('Fee schedule', to: 'https://example.com/fees', font: CdsFont.label1)
/// ```
///
/// Inside running text, place an inline link in a [WidgetSpan]. Inline
/// links are underlined by default so they do not rely on color alone:
///
/// ```dart
/// CdsText.rich(TextSpan(children: [
///   const TextSpan(text: 'Read the '),
///   WidgetSpan(
///     alignment: PlaceholderAlignment.baseline,
///     baseline: TextBaseline.alphabetic,
///     child: CdsLink('user agreement', inline: true, onPress: openTerms),
///   ),
/// ]))
/// ```
///
/// A [WidgetSpan] does not break across lines, so keep inline link text short.
class CdsLink extends StatelessWidget {
  const CdsLink(
    this.label, {
    super.key,
    this.onPress,
    this.to,
    this.font,
    this.color = CdsColor.fgPrimary,
    this.underline,
    this.mono = false,
    this.inline = false,
    this.maxLines,
    this.align,
    this.semanticLabel,
    this.focusNode,
  });

  final String label;

  /// Called on press, before [to] is opened.
  final VoidCallback? onPress;

  /// URL handed to the nearest [CdsLinkScope] on press.
  final String? to;

  /// Ramp entry. Null inherits the ambient [DefaultTextStyle], like CDS
  /// `font="inherit"`.
  final CdsFont? font;
  final CdsColor color;

  /// Defaults to true when [inline], false otherwise.
  final bool? underline;
  final bool mono;

  /// Sized to sit inside text: no 44px tap padding, underlined by default.
  final bool inline;
  final int? maxLines;
  final TextAlign? align;

  /// Replaces [label] for screen readers.
  final String? semanticLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final resolvedColor = theme.colorOf(color);
    TextStyle style;
    var text = label;
    if (font != null) {
      final fontStyle = theme.typography[font!];
      style = fontStyle.toTextStyle(color: resolvedColor, mono: mono);
      if (fontStyle.textTransform == CdsTextTransform.uppercase) text = label.toUpperCase();
    } else {
      style = DefaultTextStyle.of(context).style.copyWith(color: resolvedColor);
      if (mono) {
        final body = theme.typography[CdsFont.body];
        style = style.copyWith(fontFamily: body.monoFontFamily, package: body.fontPackage);
      }
    }
    style = (underline ?? inline)
        ? style.copyWith(decoration: TextDecoration.underline, decorationColor: resolvedColor)
        : style.copyWith(decoration: TextDecoration.none);

    final scope = CdsLinkScope.maybeOf(context);
    final url = to;
    final enabled = onPress != null || url != null;
    void open() {
      onPress?.call();
      if (url != null) scope?.onOpen(url);
    }

    return CdsPressable(
      onPress: enabled ? open : null,
      noScaleOnPress: true,
      isButton: false,
      minTapTargetSize: inline ? 0 : 44,
      focusNode: focusNode,
      child: Semantics(
        link: true,
        linkUrl: url == null ? null : Uri.tryParse(url),
        label: semanticLabel,
        excludeSemantics: semanticLabel != null,
        child: Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          textAlign: align,
          semanticsLabel: text == label ? null : label,
        ),
      ),
    );
  }
}
