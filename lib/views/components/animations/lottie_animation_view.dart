// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:instant_gram/views/components/animations/models/lottie_animations.dart';

import 'package:lottie/lottie.dart';

class LottieAnimationView extends StatelessWidget {
  final LottieAnimations animation;
  final bool repeat;
  final bool reverse;

  const LottieAnimationView({
    Key? key,
    required this.animation,
    this.repeat = true,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animation.getFullPath(),
      repeat: repeat,
      reverse: reverse,
    );
  }
}

extension GetFullPath on LottieAnimations {
  String getFullPath() => 'assets/animations/$name.json';
}
