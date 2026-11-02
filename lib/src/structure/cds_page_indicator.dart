import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';

const double _dotHeight = 4;
const double _dotInactiveWidth = 4;
const double _dotActiveWidth = 24;

String _defaultLabel(int pageIndex) => 'Go to page ${pageIndex + 1}';

/// A row of dots showing which page of a paged view is visible. The active
/// dot stretches into a short bar.
///
/// ```dart
/// CdsPageIndicator(
///   totalPages: 4,
///   activePageIndex: page,
///   onPressPage: (index) => controller.goToPage(index),
/// )
/// ```
///
/// Each dot is a button whose hit area is padded to 44px tall. The dots sit
/// close together, so horizontally the targets stay small: pair the indicator
/// with swipe or previous/next buttons for primary navigation. [CdsCarousel]
/// uses it as its pagination.
class CdsPageIndicator extends StatelessWidget {
  const CdsPageIndicator({
    super.key,
    required this.totalPages,
    required this.activePageIndex,
    this.onPressPage,
    this.accessibilityLabel,
  });

  final int totalPages;

  /// Zero-based index of the visible page.
  final int activePageIndex;

  /// Called with a page index when its dot is pressed. Null makes dots
  /// display-only.
  final ValueChanged<int>? onPressPage;

  /// Label for each dot. Defaults to `Go to page N`.
  final String Function(int pageIndex)? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final label = accessibilityLabel ?? _defaultLabel;
    final halfGap = theme.space(0.5) / 2;
    final duration = CdsMotion.duration(context, CdsDurations.fast1);
    const verticalPad = (44 - _dotHeight) / 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < totalPages; i++)
          CdsPressable(
            onPress: onPressPage == null ? null : () => onPressPage!(i),
            noScaleOnPress: true,
            debounce: Duration.zero,
            selected: i == activePageIndex,
            semanticLabel: label(i),
            excludeChildSemantics: true,
            isButton: onPressPage != null,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: halfGap, vertical: verticalPad),
              child: AnimatedContainer(
                duration: duration,
                curve: CdsCurves.global,
                width: i == activePageIndex ? _dotActiveWidth : _dotInactiveWidth,
                height: _dotHeight,
                decoration: BoxDecoration(
                  color: theme.colorOf(i == activePageIndex ? CdsColor.bgPrimary : CdsColor.bgLine),
                  borderRadius: BorderRadius.circular(theme.radius(100)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
