import 'package:flutter/material.dart';

enum SlideDirection { top, left, right }

class AnimatedSlideInCard extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final int delayMilliseconds;
  final Duration duration;
  final Key? animationKey; // Add this line

  const AnimatedSlideInCard({
    Key? key,
    required this.child,
    this.direction = SlideDirection.top,
    this.delayMilliseconds = 0,
    this.duration = const Duration(milliseconds: 600),
    this.animationKey, // Add this line
  }) : super(key: key);

  @override
  State<AnimatedSlideInCard> createState() => _AnimatedSlideInCardState();
}

class _AnimatedSlideInCardState extends State<AnimatedSlideInCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(AnimatedSlideInCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationKey != widget.animationKey) {
      _controller.reset();
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    Offset begin;
    switch (widget.direction) {
      case SlideDirection.top:
        begin = const Offset(0, -2);
        break;
      case SlideDirection.left:
        begin = const Offset(-1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(1, 0);
        break;
    }

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offsetAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}