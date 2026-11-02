import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Looks up a token value and fails loudly in debug when the key is not part
/// of the scale, so typos like `gap: 2.5` surface immediately.
///
/// Entries are stored as records because Dart const maps cannot use `double`
/// keys.
@immutable
class _Scale<K extends num> {
  const _Scale(this.entries, this.label);

  final List<(K, double)> entries;
  final String label;

  /// Every valid token on this scale, in order.
  Iterable<K> get tokens => entries.map((e) => e.$1);

  double resolve(K token) {
    for (final (key, value) in entries) {
      if (key == token) return value;
    }
    assert(false, '$token is not a valid CDS $label token. Valid: ${tokens.join(', ')}');
    return 0;
  }

  @override
  bool operator ==(Object other) => other is _Scale<K> && listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hashAll(entries);
}

/// Spacing scale. Tokens are multiples of 8: `1` is 8px, `0.5` is 4px, `3` is 24px.
///
/// Every CDS layout prop (`padding`, `gap`, `margin`...) takes a token from this
/// scale, matching `<Box padding={2} />` in CDS web and React Native.
class CdsSpaceScale extends _Scale<double> {
  const CdsSpaceScale(List<(double, double)> entries) : super(entries, 'space');

  static const CdsSpaceScale standard = CdsSpaceScale([
    (0, 0), (0.25, 2), (0.5, 4), (0.75, 6), (1, 8), (1.5, 12), (2, 16), (3, 24), (4, 32), //
    (5, 40), (6, 48), (7, 56), (8, 64), (9, 72), (10, 80),
  ]);

  double call(double token) => resolve(token);
}

/// Corner radius scale. `1000` is a full pill.
class CdsRadiusScale extends _Scale<int> {
  const CdsRadiusScale(List<(int, double)> entries) : super(entries, 'borderRadius');

  static const CdsRadiusScale standard = CdsRadiusScale([
    (0, 0), (100, 4), (200, 8), (300, 12), (400, 16), (500, 24), (600, 32), (700, 40), //
    (800, 48), (900, 56), (1000, 100000),
  ]);

  double call(int token) => resolve(token);
}

/// Border width scale.
class CdsBorderWidthScale extends _Scale<int> {
  const CdsBorderWidthScale(List<(int, double)> entries) : super(entries, 'borderWidth');

  static const CdsBorderWidthScale standard =
      CdsBorderWidthScale([(0, 0), (100, 1), (200, 2), (300, 4), (400, 6), (500, 8)]);

  double call(int token) => resolve(token);
}

/// Icon sizes.
enum CdsIconSize { xs, s, m, l }

/// Avatar sizes.
enum CdsAvatarSize { s, m, l, xl, xxl, xxxl }

/// Pixel values for [CdsIconSize] and [CdsAvatarSize].
@immutable
class CdsSizes {
  const CdsSizes({
    this.iconXs = 12,
    this.iconS = 16,
    this.iconM = 24,
    this.iconL = 32,
    this.avatarS = 16,
    this.avatarM = 24,
    this.avatarL = 32,
    this.avatarXl = 40,
    this.avatarXxl = 48,
    this.avatarXxxl = 56,
  });

  final double iconXs, iconS, iconM, iconL;
  final double avatarS, avatarM, avatarL, avatarXl, avatarXxl, avatarXxxl;

  double icon(CdsIconSize size) => switch (size) {
        CdsIconSize.xs => iconXs,
        CdsIconSize.s => iconS,
        CdsIconSize.m => iconM,
        CdsIconSize.l => iconL,
      };

  double avatar(CdsAvatarSize size) => switch (size) {
        CdsAvatarSize.s => avatarS,
        CdsAvatarSize.m => avatarM,
        CdsAvatarSize.l => avatarL,
        CdsAvatarSize.xl => avatarXl,
        CdsAvatarSize.xxl => avatarXxl,
        CdsAvatarSize.xxxl => avatarXxxl,
      };

  @override
  bool operator ==(Object other) =>
      other is CdsSizes &&
      other.iconXs == iconXs &&
      other.iconS == iconS &&
      other.iconM == iconM &&
      other.iconL == iconL &&
      other.avatarS == avatarS &&
      other.avatarM == avatarM &&
      other.avatarL == avatarL &&
      other.avatarXl == avatarXl &&
      other.avatarXxl == avatarXxl &&
      other.avatarXxxl == avatarXxxl;

  @override
  int get hashCode => Object.hash(iconXs, iconS, iconM, iconL, avatarS, avatarM, avatarL,
      avatarXl, avatarXxl, avatarXxxl);
}

/// Dimensions of selection controls.
@immutable
class CdsControlSize {
  const CdsControlSize({
    this.checkboxSize = 20,
    this.radioSize = 20,
    this.switchWidth = 52,
    this.switchHeight = 32,
    this.switchThumbSize = 30,
    this.tileSize = 106,
  });

  final double checkboxSize;
  final double radioSize;
  final double switchWidth;
  final double switchHeight;
  final double switchThumbSize;
  final double tileSize;

  @override
  bool operator ==(Object other) =>
      other is CdsControlSize &&
      other.checkboxSize == checkboxSize &&
      other.radioSize == radioSize &&
      other.switchWidth == switchWidth &&
      other.switchHeight == switchHeight &&
      other.switchThumbSize == switchThumbSize &&
      other.tileSize == tileSize;

  @override
  int get hashCode =>
      Object.hash(checkboxSize, radioSize, switchWidth, switchHeight, switchThumbSize, tileSize);
}

/// Elevation levels. CDS has two: cards that float (1) and overlays (2).
enum CdsElevation { none, level1, level2 }

/// Shadows for each elevation level.
@immutable
class CdsShadows {
  const CdsShadows({
    this.elevation1 = const [
      BoxShadow(color: Color(0x1F5B616E), offset: Offset(0, 8), blurRadius: 12),
    ],
    this.elevation2 = const [
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 8), blurRadius: 24),
    ],
  });

  final List<BoxShadow> elevation1;
  final List<BoxShadow> elevation2;

  List<BoxShadow> of(CdsElevation elevation) => switch (elevation) {
        CdsElevation.none => const [],
        CdsElevation.level1 => elevation1,
        CdsElevation.level2 => elevation2,
      };

  @override
  bool operator ==(Object other) =>
      other is CdsShadows &&
      _listEq(other.elevation1, elevation1) &&
      _listEq(other.elevation2, elevation2);

  @override
  int get hashCode => Object.hash(Object.hashAll(elevation1), Object.hashAll(elevation2));
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
