import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// The bottom bar of a page that holds its main action, with optional legal
/// text underneath.
///
/// ```dart
/// CdsPageFooter(
///   action: CdsButton(label: 'Continue', block: true, onPress: next),
///   legalText: 'Prices update every 30 seconds.',
/// )
/// ```
///
/// The bar is at least 80px tall and grows with its content. Pair it with
/// [CdsStickyFooter] or [CdsScaffold] to pin it above the keyboard and the
/// home indicator.
class CdsPageFooter extends StatelessWidget {
  const CdsPageFooter({
    super.key,
    required this.action,
    this.legalText,
    this.background,
    this.accessibilityLabel,
  });

  /// Usually a block [CdsButton] or a button group.
  final Widget action;

  /// Small print shown under [action] in `legal` and `fgMuted`.
  final String? legalText;
  final CdsColor? background;

  /// Names the footer region for screen readers.
  final String? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final body = legalText == null
        ? action
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.space(2),
            children: [
              action,
              CdsText(legalText!, font: CdsFont.legal, color: CdsColor.fgMuted, align: TextAlign.center),
            ],
          );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: accessibilityLabel,
      child: Container(
        color: background == null ? null : theme.colorOf(background!),
        constraints: BoxConstraints(minHeight: legalText == null ? 80 : 0),
        padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(3), vertical: theme.space(1.5)),
        child: Center(heightFactor: 1, child: body),
      ),
    );
  }
}
