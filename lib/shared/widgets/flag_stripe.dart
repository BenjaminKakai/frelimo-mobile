import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Four vertical stripes — green / gold / red / black — used as a
/// brand stamp on the login screen, the digital card, and section headers.
/// Always render against a dark or contrasting surface so all four bars
/// are visible (the black bar disappears on near-black backgrounds).
class FlagStripe extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const FlagStripe({
    super.key,
    this.width = 24,
    this.height = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      child: SizedBox(
        width: width,
        height: height,
        child: Row(
          children: AppColors.flagStripes
              .map((c) => Expanded(child: Container(color: c)))
              .toList(),
        ),
      ),
    );
  }
}

/// Horizontal version — used as a thin accent above section titles.
class FlagStripeHorizontal extends StatelessWidget {
  final double width;
  final double height;
  const FlagStripeHorizontal({super.key, this.width = 80, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: AppColors.flagStripes
              .map((c) => Expanded(child: Container(color: c)))
              .toList(),
        ),
      ),
    );
  }
}
