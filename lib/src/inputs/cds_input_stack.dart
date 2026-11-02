import 'package:flutter/widgets.dart';

import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Sentiment of a text field. Drives border, helper text and caret color.
enum CdsInputVariant {
  positive,
  negative,
  foreground,
  primary,

  /// The resting look: a `bgLineHeavy` border and muted helper text.
  foregroundMuted,

  /// Filled `bgSecondary` field without a border. Used by [CdsSearchInput].
  secondary;

  /// The variant shown while the field has focus. Focus turns every variant
  /// primary except [positive] and [negative], so validation state stays visible.
  CdsInputVariant focusedVariant(bool focused) =>
      focused && this != positive && this != negative ? primary : this;

  /// Text color for helper text, the caret and selection.
  CdsColor get foregroundColor => switch (this) {
        primary => CdsColor.fgPrimary,
        positive => CdsColor.fgPositive,
        negative => CdsColor.fgNegative,
        foreground => CdsColor.fg,
        foregroundMuted || secondary => CdsColor.fgMuted,
      };

  /// Border color for the field.
  CdsColor get borderColor => switch (this) {
        primary => CdsColor.bgPrimary,
        positive => CdsColor.bgPositive,
        negative => CdsColor.bgNegative,
        foreground => CdsColor.bgInverse,
        foregroundMuted => CdsColor.bgLineHeavy,
        secondary => CdsColor.bgSecondary,
      };
}

/// Vertical density of a text field, inside its border.
enum CdsTextInputSize { s, m, l }

/// Where a text field's label renders.
enum CdsInputLabelVariant {
  /// Above the field.
  outside,

  /// Inside the border: stacked above the text at size `l`, inline before
  /// the text at `m` and `s`.
  inside,
}

/// Shares the focused variant of the enclosing text field with the widgets in
/// its `start` and `end` slots, so [CdsInputIcon] and [CdsInputIconButton]
/// can follow the focus color.
class CdsTextInputFocusVariant extends InheritedWidget {
  const CdsTextInputFocusVariant({super.key, required this.variant, required super.child});

  final CdsInputVariant variant;

  static CdsInputVariant? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsTextInputFocusVariant>()?.variant;

  @override
  bool updateShouldNotify(CdsTextInputFocusVariant oldWidget) => variant != oldWidget.variant;
}

/// The frame shared by every CDS text field: label, bordered input area with
/// start and end slots, and helper text. [CdsTextInput] is built on it; use
/// it directly to build a custom field.
///
/// ```dart
/// CdsInputStack(
///   labelNode: const CdsInputLabel('Amount'),
///   inputNode: myEditableWidget,
///   helperTextNode: const CdsHelperText('Enter an amount in USD'),
///   focused: hasFocus,
/// )
/// ```
///
/// When [focused] turns true, a second border fades in over the first
/// (CDS `moderate1`, enter-functional easing) and fades out the same way.
class CdsInputStack extends StatefulWidget {
  const CdsInputStack({
    super.key,
    required this.inputNode,
    this.labelNode,
    this.helperTextNode,
    this.startNode,
    this.endNode,
    this.prependNode,
    this.appendNode,
    this.variant = CdsInputVariant.foregroundMuted,
    this.focused = false,
    this.disabled = false,
    this.borderWidth = 100,
    this.focusedBorderWidth,
    this.borderRadius = 200,
    this.labelVariant = CdsInputLabelVariant.outside,
    this.inputBackground = CdsColor.bg,
    this.onFieldPress,
  });

  /// The editable area.
  final Widget inputNode;

  /// Label. Rendered above the field, or inside it when [labelVariant] is
  /// [CdsInputLabelVariant.inside].
  final Widget? labelNode;
  final Widget? helperTextNode;

  /// Content inside the border, before [inputNode].
  final Widget? startNode;

  /// Content inside the border, after [inputNode].
  final Widget? endNode;

  /// Content outside the border, before the field. Squares the field's start corners.
  final Widget? prependNode;

  /// Content outside the border, after the field. Squares the field's end corners.
  final Widget? appendNode;
  final CdsInputVariant variant;

  /// Shows the focus border.
  final bool focused;

  /// Dims the whole stack to 50% opacity.
  final bool disabled;

  /// Border width token. 100 is 1px.
  final int borderWidth;

  /// Extra border width token added while focused. Defaults to [borderWidth].
  final int? focusedBorderWidth;

  /// Radius token. 200 is 8px.
  final int borderRadius;
  final CdsInputLabelVariant labelVariant;
  final CdsColor inputBackground;

  /// Makes the whole bordered area pressable. For trigger-style fields only;
  /// a text field must keep its editable area as the focus target.
  final VoidCallback? onFieldPress;

  @override
  State<CdsInputStack> createState() => _CdsInputStackState();
}

class _CdsInputStackState extends State<CdsInputStack> with SingleTickerProviderStateMixin {
  late final AnimationController _focus = AnimationController(
    vsync: this,
    value: widget.focused ? 1 : 0,
    duration: CdsDurations.moderate1,
  );

  @override
  void didUpdateWidget(CdsInputStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focused == widget.focused) return;
    final duration = CdsMotion.duration(context, CdsDurations.moderate1);
    if (duration == Duration.zero) {
      _focus.value = widget.focused ? 1 : 0;
    } else if (widget.focused) {
      _focus.animateTo(1, duration: duration, curve: CdsCurves.enterFunctional);
    } else {
      _focus.animateTo(0, duration: duration, curve: CdsCurves.exitFunctional);
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final variant = widget.variant;
    final focusedVariant = variant.focusedVariant(widget.focused);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final radius = theme.radius(widget.borderRadius);
    final squareStart = widget.prependNode != null;
    final squareEnd = widget.appendNode != null;

    BorderRadius corners(double r) {
      final start = squareStart ? Radius.zero : Radius.circular(r);
      final end = squareEnd ? Radius.zero : Radius.circular(r);
      return BorderRadiusDirectional.horizontal(start: start, end: end)
          .resolve(rtl ? TextDirection.rtl : TextDirection.ltr);
    }

    final borderWidth = theme.borderWidth(widget.borderWidth);
    final focusedWidth = theme.borderWidth(widget.focusedBorderWidth ?? widget.borderWidth);
    final borderColor = widget.focused
        ? theme.colorOf(focusedVariant.borderColor)
        : variant == CdsInputVariant.secondary
            ? const Color(0x00000000)
            : theme.colorOf(variant.borderColor);
    final background =
        variant == CdsInputVariant.secondary ? theme.color.bgSecondary : theme.colorOf(widget.inputBackground);

    final Widget editable;
    if (widget.labelNode != null && widget.labelVariant == CdsInputLabelVariant.inside) {
      editable = Padding(
        padding: EdgeInsets.symmetric(vertical: theme.space(0.75)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [widget.labelNode!, widget.inputNode],
        ),
      );
    } else {
      editable = widget.inputNode;
    }

    Widget inputArea = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: corners(radius),
        border: borderWidth > 0 ? Border.all(color: borderColor, width: borderWidth) : null,
      ),
      child: ClipRRect(
        borderRadius: corners((radius - borderWidth).clamp(0, double.infinity)),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: CdsTextInputFocusVariant(
            variant: focusedVariant,
            child: Row(
              children: [?widget.startNode, Expanded(child: editable), ?widget.endNode],
            ),
          ),
        ),
      ),
    );

    if (widget.onFieldPress != null) {
      inputArea = CdsPressable(
        onPress: widget.onFieldPress,
        disabled: widget.disabled,
        noScaleOnPress: true,
        debounce: Duration.zero,
        isButton: false,
        child: inputArea,
      );
    }

    final field = Stack(
      clipBehavior: Clip.none,
      children: [
        inputArea,
        Positioned(
          left: -focusedWidth,
          top: -focusedWidth,
          right: -focusedWidth,
          bottom: -focusedWidth,
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _focus,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: corners(radius + focusedWidth),
                  border: Border.all(
                    color: theme.colorOf(focusedVariant.borderColor),
                    width: borderWidth + focusedWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [?widget.prependNode, Expanded(child: field), ?widget.appendNode],
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.space(0.5),
      children: [
        if (widget.labelNode != null && widget.labelVariant == CdsInputLabelVariant.outside) widget.labelNode!,
        row,
        ?widget.helperTextNode,
      ],
    );

    return Opacity(opacity: widget.disabled ? CdsInteractionOpacity.disabled : 1, child: column);
  }
}

/// A text field label in the CDS style (`label2`, `fgMuted`).
///
/// ```dart
/// CdsInputLabel('Email')
/// ```
class CdsInputLabel extends StatelessWidget {
  const CdsInputLabel(
    this.text, {
    super.key,
    this.color = CdsColor.fgMuted,
    this.font = CdsFont.label2,
    this.paddingStart = 0,
    this.paddingEnd = 0,
    this.paddingY = 0.5,
  });

  final String text;
  final CdsColor color;
  final CdsFont font;

  /// Space tokens.
  final double paddingStart, paddingEnd, paddingY;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        theme.space(paddingStart),
        theme.space(paddingY),
        theme.space(paddingEnd),
        theme.space(paddingY),
      ),
      child: CdsText(text, font: font, color: color),
    );
  }
}

/// Helper or error text under a field. With `color: CdsColor.fgNegative` it
/// leads with an info icon, so the error is not conveyed by color alone.
///
/// ```dart
/// CdsHelperText('We will send a code to this address')
/// CdsHelperText('Enter a valid email', color: CdsColor.fgNegative)
/// ```
class CdsHelperText extends StatelessWidget {
  const CdsHelperText(
    this.text, {
    super.key,
    this.color = CdsColor.fgMuted,
    this.align = TextAlign.start,
    this.errorIconSemanticLabel = 'error',
  });

  final String text;
  final CdsColor color;
  final TextAlign align;

  /// Read before the text when the error icon shows.
  final String errorIconSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    if (color != CdsColor.fgNegative) {
      return CdsText(text, font: CdsFont.label2, color: color, align: align);
    }
    final iconPx = theme.iconSize(CdsIconSize.xs);
    final offset = (theme.typography[CdsFont.label2].lineHeight - iconPx) / 2;
    return Row(
      mainAxisAlignment: switch (align) {
        TextAlign.center => MainAxisAlignment.center,
        TextAlign.end || TextAlign.right => MainAxisAlignment.end,
        _ => MainAxisAlignment.start,
      },
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.space(0.5),
      children: [
        Padding(
          padding: EdgeInsets.only(top: offset),
          child: CdsIcon(
            CdsIconName.info,
            size: CdsIconSize.xs,
            active: true,
            color: CdsColor.fgNegative,
            semanticLabel: errorIconSemanticLabel,
          ),
        ),
        Flexible(child: CdsText(text, font: CdsFont.label2, color: color, align: align)),
      ],
    );
  }
}

/// A decorative icon for a text field's `start` or `end` slot. Inside a
/// focused field it takes the focus color unless [disableInheritFocusStyle].
///
/// ```dart
/// CdsTextInput(label: 'Amount', start: const CdsInputIcon(CdsIconName.cashUSD))
/// ```
class CdsInputIcon extends StatelessWidget {
  const CdsInputIcon(
    this.name, {
    super.key,
    this.color = CdsColor.fg,
    this.active = false,
    this.disableInheritFocusStyle = false,
    this.compact = false,
    this.semanticLabel,
  });

  final CdsIconName name;
  final CdsColor color;
  final bool active;
  final bool disableInheritFocusStyle;

  /// Halves the horizontal padding (8px instead of 16px).
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final contextVariant = CdsTextInputFocusVariant.maybeOf(context);
    final resolved = disableInheritFocusStyle || contextVariant == null
        ? color
        : (contextVariant == CdsInputVariant.secondary ? CdsColor.fgMuted : contextVariant.foregroundColor);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.cds.space(compact ? 1 : 2)),
      child: CdsIcon(name, size: CdsIconSize.s, active: active, color: resolved, semanticLabel: semanticLabel),
    );
  }
}

/// A transparent icon button for a text field's `start` or `end` slot, such
/// as a clear or reveal-password action.
///
/// ```dart
/// CdsTextInput(
///   label: 'Password',
///   obscureText: hidden,
///   end: CdsInputIconButton(
///     hidden ? CdsIconName.visible : CdsIconName.invisible,
///     semanticLabel: hidden ? 'Show password' : 'Hide password',
///     onPress: toggle,
///   ),
/// )
/// ```
class CdsInputIconButton extends StatelessWidget {
  const CdsInputIconButton(
    this.name, {
    super.key,
    required this.semanticLabel,
    this.onPress,
    this.variant = CdsButtonVariant.primary,
    this.disableInheritFocusStyle = false,
    this.disabled = false,
    this.active = false,
    this.focusNode,
  });

  final CdsIconName name;
  final String semanticLabel;
  final VoidCallback? onPress;

  /// Used when there is no enclosing field or [disableInheritFocusStyle] is set.
  final CdsButtonVariant variant;
  final bool disableInheritFocusStyle;
  final bool disabled;
  final bool active;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final contextVariant = CdsTextInputFocusVariant.maybeOf(context);
    final resolved = disableInheritFocusStyle || contextVariant == null
        ? variant
        : switch (contextVariant) {
            CdsInputVariant.foregroundMuted || CdsInputVariant.secondary => CdsButtonVariant.secondary,
            _ => CdsButtonVariant.primary,
          };
    final theme = context.cds;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: theme.space(1), end: theme.space(0.5)),
      child: CdsIconButton(
        name,
        semanticLabel: semanticLabel,
        onPress: onPress,
        disabled: disabled,
        active: active,
        transparent: true,
        variant: resolved,
        focusNode: focusNode,
      ),
    );
  }
}
