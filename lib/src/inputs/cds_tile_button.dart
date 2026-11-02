import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// A square button with media above a short title, for shortcut grids such
/// as "Send", "Receive", "Buy".
///
/// ```dart
/// CdsTileButton(
///   title: 'Send',
///   onPress: openSend,
///   child: const CdsIcon(CdsIconName.send, size: CdsIconSize.l),
/// )
/// ```
///
/// The tile is `context.cds.controlSize.tileSize` square (106px). CDS shows a
/// pictogram by default; pictograms are not part of this package, so pass
/// any widget as [child] (about 48px reads best). [count] pins a red count
/// badge to the top-end of the media.
class CdsTileButton extends StatelessWidget {
  const CdsTileButton({
    super.key,
    required this.title,
    this.child,
    this.onPress,
    this.onLongPress,
    this.count,
    this.maxCount = 99,
    this.showOverflow = false,
    this.disabled = false,
    this.feedback = CdsHapticFeedback.light,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.autofocus = false,
  });

  /// Short label under the media. Required: a tile needs a readable name.
  final String title;

  /// Media shown above the title.
  final Widget? child;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;

  /// Shows a count badge when greater than 0.
  final int? count;

  /// Counts above this show as `maxCount+`.
  final int maxCount;

  /// Let the title wrap instead of truncating with an ellipsis.
  final bool showOverflow;
  final bool disabled;
  final CdsHapticFeedback feedback;

  /// Defaults to [title], plus the count when one shows.
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final size = theme.controlSize.tileSize;
    final showCount = count != null && count! > 0;
    final countText = showCount ? (count! > maxCount ? '$maxCount+' : '$count') : null;

    Widget media = child ?? const SizedBox.shrink();
    if (showCount) {
      media = Stack(
        clipBehavior: Clip.none,
        children: [
          media,
          PositionedDirectional(
            top: 0,
            end: 0,
            child: FractionalTranslation(
              translation: Offset(Directionality.of(context) == TextDirection.rtl ? -0.5 : 0.5, -0.5),
              child: _TileCount(text: countText!),
            ),
          ),
        ],
      );
    }

    final content = Padding(
      padding: EdgeInsets.all(theme.space(1)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.space(1),
        children: [
          media,
          CdsText(
            title,
            font: CdsFont.label2,
            align: TextAlign.center,
            maxLines: showOverflow ? null : 1,
            overflow: showOverflow ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: showOverflow,
          ),
        ],
      ),
    );

    return SizedBox(
      width: size,
      child: CdsPressable(
        onPress: disabled ? null : onPress,
        onLongPress: disabled ? null : onLongPress,
        disabled: disabled,
        background: CdsColor.bg,
        transparentWhileInactive: true,
        noScaleOnPress: true,
        borderRadius: 400,
        feedback: feedback,
        semanticLabel: semanticLabel ?? (showCount ? '$title, $countText' : title),
        semanticHint: semanticHint,
        excludeChildSemantics: true,
        focusNode: focusNode,
        autofocus: autofocus,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: size, minHeight: size),
          child: Center(widthFactor: 1, heightFactor: 1, child: content),
        ),
      ),
    );
  }
}

/// The count badge CDS calls DotCount: 24px tall pill, `bgNegative` with a
/// 1px `bgSecondary` border and `caption` text in `fgInverse`.
class _TileCount extends StatelessWidget {
  const _TileCount({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: EdgeInsets.symmetric(horizontal: theme.space(0.75)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.color.bgNegative,
        borderRadius: BorderRadius.circular(theme.radius(400)),
        border: Border.all(color: theme.color.bgSecondary, width: theme.borderWidth(100)),
      ),
      child: CdsText(text, font: CdsFont.caption, color: CdsColor.fgInverse, tabularNumbers: true),
    );
  }
}
