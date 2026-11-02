import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// The title in a [CdsTopNavBar] or [CdsNavigationBar]: headline text marked
/// as a header for screen readers.
///
/// ```dart
/// const CdsNavigationTitle('Send Bitcoin')
/// ```
class CdsNavigationTitle extends StatelessWidget {
  const CdsNavigationTitle(
    this.title, {
    super.key,
    this.font = CdsFont.headline,
    this.color = CdsColor.fg,
    this.maxLines = 1,
    this.align,
  });

  final String title;
  final CdsFont font;
  final CdsColor color;

  /// Long titles ellipsize after this many lines.
  final int? maxLines;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: CdsText(title, font: font, color: color, maxLines: maxLines, align: align),
    );
  }
}

/// A muted second line under a [CdsNavigationTitle], also exposed as a
/// header.
///
/// ```dart
/// const CdsNavigationSubtitle('Step 2 of 3')
/// ```
class CdsNavigationSubtitle extends StatelessWidget {
  const CdsNavigationSubtitle(
    this.subtitle, {
    super.key,
    this.font = CdsFont.label2,
    this.color = CdsColor.fgMuted,
    this.maxLines = 1,
    this.align,
  });

  final String subtitle;
  final CdsFont font;
  final CdsColor color;
  final int? maxLines;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: CdsText(subtitle, font: font, color: color, maxLines: maxLines, align: align),
    );
  }
}
