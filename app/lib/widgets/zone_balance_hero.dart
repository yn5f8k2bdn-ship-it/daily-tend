import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Placeholder hero for the welcome screen — three overlapping circles in the
/// zone container colours, evoking the "balance across Self / Purpose / Loved
/// Ones" idea without pretending to be a final illustration.
///
/// Replace with the real commissioned illustration when it lands.
class ZoneBalanceHero extends StatelessWidget {
  const ZoneBalanceHero({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selfFill = isDark
        ? AppColors.zoneSelfContainerDark
        : AppColors.zoneSelfContainer;
    final purposeFill = isDark
        ? AppColors.zonePurposeContainerDark
        : AppColors.zonePurposeContainer;
    final lovedFill = isDark
        ? AppColors.zoneLovedOnesContainerDark
        : AppColors.zoneLovedOnesContainer;

    return SizedBox(
      height: 220,
      child: Center(
        child: SizedBox(
          width: 260,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 30,
                child: _Circle(color: selfFill, size: 130),
              ),
              Positioned(
                right: 0,
                top: 30,
                child: _Circle(color: lovedFill, size: 130),
              ),
              Positioned(
                top: 0,
                child: _Circle(color: purposeFill, size: 130),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
    );
  }
}
