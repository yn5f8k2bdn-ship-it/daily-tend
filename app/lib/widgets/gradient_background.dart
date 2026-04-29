import 'package:flutter/material.dart';

/// Full-screen gradient background applied app-wide via MaterialApp.builder.
///
/// White top → teal `#54A4AE` bottom (founder direction 2026-04-29). The
/// calmer/lighter half is at viewing focus; the saturated teal sits behind
/// the action zone where primary CTAs live. Pairs with the honey primary +
/// deep-teal secondary palette (see `app_tokens.dart`).
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  static const Color _topColor = Colors.white;
  static const Color _bottomColor = Color(0xFF54A4AE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_topColor, _bottomColor],
          stops: [0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}
