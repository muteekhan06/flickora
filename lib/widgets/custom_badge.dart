import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CustomBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor = FlickoraTheme.bgCardHighlight,
    this.textColor = FlickoraTheme.textPrimary,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  factory CustomBadge.rating(String rating) {
    return CustomBadge(
      text: rating,
      icon: Icons.star_rounded,
      backgroundColor: const Color(0x33FFB800),
      textColor: FlickoraTheme.goldAccent,
      fontSize: 12,
    );
  }

  factory CustomBadge.quality(String text) {
    return CustomBadge(
      text: text,
      backgroundColor: const Color(0x33E50914),
      textColor: FlickoraTheme.accentRed,
      fontSize: 10,
    );
  }

  factory CustomBadge.genre(String name) {
    return CustomBadge(
      text: name,
      backgroundColor: const Color(0x22FFFFFF),
      textColor: Colors.white70,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
