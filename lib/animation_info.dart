import 'package:flutter/widgets.dart';

class AnimationInfo {
  final AnimationTrigger trigger;
  final List<Effect> Function() effectsBuilder;

  AnimationInfo({required this.trigger, required this.effectsBuilder});
}

enum AnimationTrigger { onPageLoad }

abstract class Effect {}

class ScaleEffect extends Effect {
  final Curve curve;
  final Duration delay;
  final Duration duration;
  final Offset begin;
  final Offset end;

  ScaleEffect({
    required this.curve,
    required this.delay,
    required this.duration,
    required this.begin,
    required this.end,
  });
}

class MoveEffect extends Effect {
  final Curve curve;
  final Duration delay;
  final Duration duration;
  final Offset begin;
  final Offset end;

  MoveEffect({
    required this.curve,
    required this.delay,
    required this.duration,
    required this.begin,
    required this.end,
  });
}

extension WidgetExtension on Widget {
  Widget animateOnPageLoad(AnimationInfo animationInfo) {
    return _AnimateOnPageLoad(
      child: this,
      animationInfo: animationInfo,
    );
  }
}

class _AnimateOnPageLoad extends StatefulWidget {
  final Widget child;
  final AnimationInfo animationInfo;

  const _AnimateOnPageLoad({
    Key? key,
    required this.child,
    required this.animationInfo,
  }) : super(key: key);

  @override
  __AnimateOnPageLoadState createState() => __AnimateOnPageLoadState();
}

class __AnimateOnPageLoadState extends State<_AnimateOnPageLoad>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _moveAnimation;
  late Animation<Offset> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    final effects = widget.animationInfo.effectsBuilder();
    if (effects.isNotEmpty) {
      final effect = effects.first;
      if (effect is ScaleEffect) {
        _scaleAnimation = Tween<Offset>(
          begin: effect.begin,
          end: effect.end,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: effect.curve,
          ),
        );

        _controller.duration = effect.duration;
        _controller.forward();
      } else if (effect is MoveEffect) {
        _moveAnimation = Tween<Offset>(
          begin: effect.begin,
          end: effect.end,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: effect.curve,
          ),
        );

        _controller.duration = effect.duration;
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final effect = widget.animationInfo.effectsBuilder().first;
        if (effect is ScaleEffect) {
          return Transform.scale(
            scale: _scaleAnimation.value.dx,
            child: child,
          );
        } else if (effect is MoveEffect) {
          return Transform.translate(
            offset: _moveAnimation.value,
            child: child,
          );
        }
        return child!;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
