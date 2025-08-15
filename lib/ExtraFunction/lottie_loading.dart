import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoading extends StatelessWidget {
  final double size;
  final String animationPath;

  const LottieLoading({
    super.key,
    this.size = 100,
    this.animationPath = 'assets/animation/loading.json',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Lottie.asset(
        animationPath,
        fit: BoxFit.contain,
      ),
    );
  }
}