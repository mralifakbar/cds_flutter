import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

import '../demo.dart';
import '../page_frame.dart';

class PrimitivesPage extends StatelessWidget {
  const PrimitivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageFrame(
      title: 'Buttons and primitives',
      subtitle: 'The building blocks every other component uses.',
      children: [
        CdsBox(
          paddingX: 3,
          child: CdsVStack(gap: 5, children: [
            _Variants(),
            _Sizes(),
            _LoadingDemo(),
            _IconButtons(),
            _PressableDemo(),
            _ProgressDemo(),
            _SpringDemo(),
          ]),
        ),
      ],
    );
  }
}

class _Variants extends StatelessWidget {
  const _Variants();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'CdsButton variants',
      caption: 'One primary per screen. Negative for destructive actions only.',
      child: CdsHStack(wrap: true, gap: 1, children: [
        for (final v in CdsButtonVariant.values)
          CdsButton(label: v.name, variant: v, size: CdsButtonSize.m, onPress: () {}),
        const CdsButton(label: 'Disabled', size: CdsButtonSize.m),
        CdsButton(label: 'Transparent', transparent: true, size: CdsButtonSize.m, onPress: () {}),
      ]),
    );
  }
}

class _Sizes extends StatelessWidget {
  const _Sizes();

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Sizes and icons',
      child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
        for (final s in CdsButtonSize.values)
          CdsButton(label: 'Size ${s.name}', size: s, variant: CdsButtonVariant.secondary, onPress: () {}),
        CdsButton(label: 'Receive', startIcon: CdsIconName.arrowDown, onPress: () {}),
        CdsButton(label: 'Review order', endIcon: CdsIconName.caretRight, block: true, onPress: () {}),
      ]),
    );
  }
}

class _LoadingDemo extends StatefulWidget {
  const _LoadingDemo();

  @override
  State<_LoadingDemo> createState() => _LoadingDemoState();
}

class _LoadingDemoState extends State<_LoadingDemo> {
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Loading',
      caption: 'The label stays in layout so the button keeps its width. Presses are blocked until it finishes.',
      child: CdsButton(label: 'Place order', block: true, loading: _loading, onPress: _submit),
    );
  }
}

class _IconButtons extends StatefulWidget {
  const _IconButtons();

  @override
  State<_IconButtons> createState() => _IconButtonsState();
}

class _IconButtonsState extends State<_IconButtons> {
  bool _starred = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'CdsIconButton',
      caption: 'The circle follows CDS sizing; the hit area is padded to 44px.',
      child: CdsHStack(gap: 1, children: [
        for (final s in CdsButtonSize.values)
          CdsIconButton(CdsIconName.add, semanticLabel: 'Add, size ${s.name}', size: s, onPress: () {}),
        CdsIconButton(
          CdsIconName.star,
          semanticLabel: _starred ? 'Remove from watchlist' : 'Add to watchlist',
          variant: _starred ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
          active: _starred,
          onPress: () => setState(() => _starred = !_starred),
        ),
      ]),
    );
  }
}

class _PressableDemo extends StatefulWidget {
  const _PressableDemo();

  @override
  State<_PressableDemo> createState() => _PressableDemoState();
}

class _PressableDemoState extends State<_PressableDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'CdsPressable',
      caption: 'Tint and scale start on touch-down. Press and hold, then slide off to cancel.',
      child: CdsPressable(
        onPress: () => setState(() => _count++),
        background: CdsColor.bgSecondary,
        borderRadius: 500,
        feedback: CdsHapticFeedback.light,
        semanticLabel: 'Custom surface, pressed $_count times',
        excludeChildSemantics: true,
        child: CdsBox(
          padding: 3,
          child: Row(children: [
            const CdsIcon(CdsIconName.fingerprint, size: CdsIconSize.l, color: CdsColor.fgPrimary),
            SizedBox(width: context.cds.space(2)),
            Expanded(
              child: CdsVStack(gap: 0.25, mainAxisSize: MainAxisSize.min, children: [
                const CdsText.headline('Custom surface'),
                CdsText.label2('Pressed $_count times', color: CdsColor.fgMuted, tabularNumbers: true),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ProgressDemo extends StatefulWidget {
  const _ProgressDemo();

  @override
  State<_ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<_ProgressDemo> {
  double _value = 0.35;

  void _step(double d) => setState(() => _value = (_value + d).clamp(0, 1));

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'CdsProgressCircle',
      caption: 'Determinate values animate from where they are. The spinner turns only while it is shown.',
      child: CdsHStack(gap: 3, children: [
        CdsProgressCircle(progress: _value, size: 72, showLabel: true, semanticLabel: 'Sample progress'),
        const CdsProgressCircle.indeterminate(size: 32),
        const Spacer(),
        CdsIconButton(CdsIconName.minus, semanticLabel: 'Decrease', onPress: () => _step(-0.1)),
        CdsIconButton(CdsIconName.add, semanticLabel: 'Increase', onPress: () => _step(0.1)),
      ]),
    );
  }
}

/// Drag the chip anywhere and let go: it returns with the velocity of the
/// throw, and can be caught again mid-flight.
class _SpringDemo extends StatefulWidget {
  const _SpringDemo();

  @override
  State<_SpringDemo> createState() => _SpringDemoState();
}

class _SpringDemoState extends State<_SpringDemo> with TickerProviderStateMixin {
  late final _x = AnimationController.unbounded(vsync: this);
  late final _y = AnimationController.unbounded(vsync: this);

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Springs from where things are',
      caption: 'Throw the chip. It returns carrying your velocity, and you can catch it mid-flight. X and Y run as separate springs.',
      child: CdsBox(
        height: 200,
        borderRadius: 500,
        background: CdsColor.bgSecondaryWash,
        bordered: true,
        clip: true,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_x, _y]),
            builder: (context, child) => Transform.translate(offset: Offset(_x.value, _y.value), child: child),
            child: GestureDetector(
              onPanDown: (_) {
                _x.stop();
                _y.stop();
              },
              onPanUpdate: (d) {
                _x.value += d.delta.dx;
                _y.value += d.delta.dy;
              },
              onPanEnd: (d) {
                final v = d.velocity.pixelsPerSecond;
                CdsMotion.springTo(_x, 0, spring: CdsSprings.momentum, velocity: v.dx);
                CdsMotion.springTo(_y, 0, spring: CdsSprings.momentum, velocity: v.dy);
              },
              child: Semantics(
                label: 'Draggable chip',
                child: CdsBox(
                  paddingX: 3,
                  paddingY: 1.5,
                  borderRadius: 1000,
                  background: CdsColor.bgPrimary,
                  elevation: CdsElevation.level1,
                  child: const CdsText.headline('Throw me', color: CdsColor.fgInverse),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
