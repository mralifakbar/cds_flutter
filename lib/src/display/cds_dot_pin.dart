import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';

/// Corner of the host widget a dot is pinned to.
enum CdsDotPinPlacement { topStart, topEnd, bottomStart, bottomEnd }

/// Shape the dot overlaps. `circular` pulls the dot inward so it hugs a
/// round host such as an avatar.
enum CdsDotOverlap { circular }

/// Status color of a [CdsDotStatusColor].
enum CdsDotVariant {
  positive(CdsColor.bgPositive),
  negative(CdsColor.bgNegative),
  primary(CdsColor.bgPrimary),
  foregroundMuted(CdsColor.fgMuted),
  warning(CdsColor.bgWarning);

  const CdsDotVariant(this.color);
  final CdsColor color;
}

/// Pins [dot] to a corner of [child], centered on the corner the way
/// `useDotPinStyles` does in CDS. Without a child, the dot renders inline.
/// Internal to cds_flutter.
class CdsDotPin extends StatelessWidget {
  const CdsDotPin({super.key, required this.dot, this.child, this.pin, this.overlap});

  final Widget dot;
  final Widget? child;

  /// Defaults to [CdsDotPinPlacement.topEnd] when there is a child.
  final CdsDotPinPlacement? pin;
  final CdsDotOverlap? overlap;

  @override
  Widget build(BuildContext context) {
    if (child == null) return dot;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned.fill(
          child: CustomSingleChildLayout(
            delegate: _DotPinDelegate(
              pin: pin ?? CdsDotPinPlacement.topEnd,
              overlap: overlap,
              rtl: Directionality.of(context) == TextDirection.rtl,
            ),
            child: dot,
          ),
        ),
      ],
    );
  }
}

class _DotPinDelegate extends SingleChildLayoutDelegate {
  const _DotPinDelegate({required this.pin, required this.overlap, required this.rtl});

  final CdsDotPinPlacement pin;
  final CdsDotOverlap? overlap;
  final bool rtl;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var end = size.width - childSize.width / 2;
    var start = -childSize.width / 2;
    var bottom = size.height - childSize.height / 2;
    var top = -childSize.height / 2;
    if (overlap == CdsDotOverlap.circular) {
      final dx = (size.width / 2 - childSize.width / 2) / 2.5;
      final dy = (size.height / 2 - childSize.height / 2) / 2.5;
      end -= dx;
      start += dx;
      bottom -= dy;
      top += dy;
    }
    final atEnd = pin == CdsDotPinPlacement.topEnd || pin == CdsDotPinPlacement.bottomEnd;
    final atTop = pin == CdsDotPinPlacement.topStart || pin == CdsDotPinPlacement.topEnd;
    final x = (atEnd != rtl) ? end : start;
    return Offset(x, atTop ? top : bottom);
  }

  @override
  bool shouldRelayout(_DotPinDelegate old) => old.pin != pin || old.overlap != overlap || old.rtl != rtl;
}
