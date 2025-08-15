import 'package:flutter/material.dart';
import 'dart:math';

class FlippableCard extends StatefulWidget {
  final Widget child;
  final int delayMilliseconds;

  const FlippableCard({
    Key? key,
    required this.child,
    this.delayMilliseconds = 0,
  }) : super(key: key);

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: pi, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        // Flip on Y axis
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value),
          child: _animation.value < (pi / 2)
              ? widget.child
              : Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: widget.child,
          ),
        );
      },
    );
  }
}