import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import 'cds_progress_circle.dart';

/// Size of a [CdsSpinner], matching the platform activity indicator CDS
/// mobile wraps.
enum CdsSpinnerSize {
  /// 20px.
  small,

  /// 36px.
  large,
}

/// An indeterminate loading indicator for waits of unknown length. Built on
/// [CdsProgressCircle.indeterminate]: it spins only while on screen, holds
/// still under reduced motion, and announces [accessibilityLabel].
///
/// For buttons, use their `loading` flag instead.
///
/// ```dart
/// const CdsSpinner()
/// const CdsSpinner(size: CdsSpinnerSize.large)
/// ```
class CdsSpinner extends StatelessWidget {
  const CdsSpinner({
    super.key,
    this.size = CdsSpinnerSize.small,
    this.pixelSize,
    this.color = CdsColor.bgPrimary,
    this.animating = true,
    this.accessibilityLabel = 'Loading',
  });

  final CdsSpinnerSize size;

  /// Exact diameter in px; overrides [size].
  final double? pixelSize;
  final CdsColor color;

  /// When false the spinner is hidden but keeps its space, like the
  /// `animating` prop of the platform indicator.
  final bool animating;
  final String accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final diameter = pixelSize ?? (size == CdsSpinnerSize.small ? 20.0 : 36.0);
    if (!animating) return SizedBox.square(dimension: diameter);
    return CdsProgressCircle.indeterminate(
      size: diameter,
      weight: size == CdsSpinnerSize.large && pixelSize == null ? CdsProgressWeight.normal : CdsProgressWeight.thin,
      color: color,
      semanticLabel: accessibilityLabel,
    );
  }
}
