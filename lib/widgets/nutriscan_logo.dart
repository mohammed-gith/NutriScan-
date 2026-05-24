import 'package:flutter/material.dart';

class NutriScanLogo extends StatelessWidget {
  final double iconSize;
  final double textSize;
  final MainAxisAlignment alignment;

  const NutriScanLogo({
    super.key,
    this.iconSize = 48,
    this.textSize = 28,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: Stack(
            children: [
              _CornerMark(
                alignment: Alignment.topLeft,
                color: const Color(0xFF5956F2),
                iconSize: iconSize,
              ),
              _CornerMark(
                alignment: Alignment.topRight,
                color: const Color(0xFF9BE7A7),
                iconSize: iconSize,
              ),
              _CornerMark(
                alignment: Alignment.bottomLeft,
                color: const Color(0xFF9BE7A7),
                iconSize: iconSize,
              ),
              _CornerMark(
                alignment: Alignment.bottomRight,
                color: const Color(0xFF5956F2),
                iconSize: iconSize,
              ),
              Center(
                child: Icon(
                  Icons.eco_outlined,
                  color: const Color(0xFF9BE7A7),
                  size: iconSize * 0.22,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: iconSize * 0.18),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Nutri',
                style: TextStyle(
                  color: const Color(0xFF17145D),
                  fontWeight: FontWeight.w800,
                  fontSize: textSize,
                ),
              ),
              TextSpan(
                text: 'Scan',
                style: TextStyle(
                  color: const Color(0xFF17145D),
                  fontWeight: FontWeight.w400,
                  fontSize: textSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerMark extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double iconSize;

  const _CornerMark({
    required this.alignment,
    required this.color,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: iconSize * 0.26,
        height: iconSize * 0.26,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
