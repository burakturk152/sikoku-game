import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback? onTap;
  final bool showEllipsis;
  final Color textColor;

  const BottomNavItem({
    super.key,
    required this.assetPath,
    required this.label,
    this.onTap,
    this.showEllipsis = true,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double iconSize = (size.width * 0.09).clamp(28.0, 46.0).toDouble();

    return SizedBox(
      width: iconSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox.shrink(),
          Text(
            label,
            maxLines: 1,
            overflow: showEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}


