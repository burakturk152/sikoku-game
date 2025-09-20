import 'package:flutter/material.dart';

class StarIndicator extends StatelessWidget {
  final int starCount;
  final double size;
  final Color? starColor;
  final Color? emptyStarColor;

  const StarIndicator({
    super.key,
    required this.starCount,
    this.size = 12.0,
    this.starColor,
    this.emptyStarColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStarColor = starColor ?? const Color(0xFFFFD700);
    final effectiveEmptyStarColor = emptyStarColor ?? Colors.grey.shade400;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isFilled = index < starCount;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          size: size,
          color: isFilled ? effectiveStarColor : effectiveEmptyStarColor,
        );
      }),
    );
  }
}