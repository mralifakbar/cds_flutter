import 'dart:async';

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

/// A block of monospaced code or other literal text, such as a wallet
/// address or an API key, with a copy button.
///
/// ```dart
/// const CdsCodeSnippet('flutter pub add cds_flutter')
/// CdsCodeSnippet(address, title: 'Deposit address', wrap: true, onCopy: logCopy)
/// ```
///
/// Not part of CDS; styled with CDS tokens. Pressing copy writes [code] to
/// the clipboard, and the button reads "Copied" with a checkmark for
/// [confirmationDuration] before returning to "Copy".
class CdsCodeSnippet extends StatefulWidget {
  const CdsCodeSnippet(
    this.code, {
    super.key,
    this.title,
    this.showCopyButton = true,
    this.onCopy,
    this.wrap = false,
    this.maxLines,
    this.font = CdsFont.label2,
    this.copyLabel = 'Copy',
    this.copiedLabel = 'Copied',
    this.copySemanticLabel,
    this.confirmationDuration = const Duration(seconds: 2),
  });

  final String code;

  /// Optional caption above the code, e.g. the language or file name.
  final String? title;
  final bool showCopyButton;

  /// Called after [code] is on the clipboard.
  final VoidCallback? onCopy;

  /// Wrap long lines instead of scrolling horizontally.
  final bool wrap;

  /// Truncates the code after this many lines.
  final int? maxLines;
  final CdsFont font;

  /// Visible button text before copying.
  final String copyLabel;

  /// Visible button text after copying; also announced to screen readers.
  final String copiedLabel;

  /// Screen reader label of the button. Defaults to "[copyLabel] [title]",
  /// or "Copy code" without a title.
  final String? copySemanticLabel;
  final Duration confirmationDuration;

  @override
  State<CdsCodeSnippet> createState() => _CdsCodeSnippetState();
}

class _CdsCodeSnippetState extends State<CdsCodeSnippet> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    cdsHaptic(CdsHapticFeedback.selection);
    setState(() => _copied = true);
    widget.onCopy?.call();
    _reset?.cancel();
    _reset = Timer(widget.confirmationDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final codeStyle = theme.typography[widget.font].toTextStyle(color: theme.color.fg, mono: true);

    Widget code = Text(
      widget.code,
      style: codeStyle,
      softWrap: widget.wrap,
      maxLines: widget.maxLines,
      overflow: widget.maxLines == null ? null : TextOverflow.ellipsis,
    );
    if (!widget.wrap) {
      code = SingleChildScrollView(scrollDirection: Axis.horizontal, child: code);
    }

    final label = _copied ? widget.copiedLabel : widget.copyLabel;
    final semantic = _copied
        ? widget.copiedLabel
        : (widget.copySemanticLabel ??
            (widget.title != null ? '${widget.copyLabel} ${widget.title}' : '${widget.copyLabel} code'));
    final button = widget.showCopyButton
        ? CdsPressable(
            onPress: _copy,
            borderRadius: 1000,
            background: CdsColor.bgAlternate,
            transparentWhileInactive: true,
            minTapTargetSize: 44,
            debounce: Duration.zero,
            semanticLabel: semantic,
            excludeChildSemantics: true,
            child: Semantics(
              liveRegion: _copied,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.space(1), vertical: theme.space(0.5)),
                child: AnimatedSwitcher(
                  duration: CdsMotion.duration(context, CdsDurations.fast3),
                  switchInCurve: CdsCurves.enterFunctional,
                  switchOutCurve: CdsCurves.exitFunctional,
                  child: Row(
                    key: ValueKey(_copied),
                    mainAxisSize: MainAxisSize.min,
                    spacing: theme.space(0.5),
                    children: [
                      CdsIcon(
                        _copied ? CdsIconName.checkmark : CdsIconName.copy,
                        size: CdsIconSize.s,
                        color: _copied ? CdsColor.fgPositive : CdsColor.fgMuted,
                      ),
                      CdsText(label, font: CdsFont.label1, color: _copied ? CdsColor.fgPositive : CdsColor.fgMuted),
                    ],
                  ),
                ),
              ),
            ),
          )
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.color.bgAlternate,
        borderRadius: BorderRadius.circular(theme.radius(300)),
        border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(theme.space(2), theme.space(1), theme.space(1), theme.space(1)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.space(0.5),
          children: [
            if (widget.title != null || button != null)
              Row(
                children: [
                  Expanded(
                    child: widget.title != null
                        ? CdsText(widget.title!, font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: 1)
                        : const SizedBox.shrink(),
                  ),
                  ?button,
                ],
              ),
            Padding(
              padding: EdgeInsetsDirectional.only(end: theme.space(1), bottom: theme.space(1)),
              child: code,
            ),
          ],
        ),
      ),
    );
  }
}
