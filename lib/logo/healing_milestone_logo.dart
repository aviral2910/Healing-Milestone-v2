import 'package:flutter/material.dart';

class HealingMilestonesLogoWidget extends StatelessWidget {
  /// The sizing factor for the graphical logo mark (both width and height).
  final double logoSize;

  /// The color applied to the logo mark.
  final Color? logoColor;

  /// The color applied to the text. If null, it defaults to the [logoColor].
  final Color? textColor;

  /// Determines whether the "HEALING MILESTONES" text is displayed.
  final bool showText;

  const HealingMilestonesLogoWidget({
    Key? key,
    this.logoSize = 35.0,
    this.logoColor,
    this.textColor,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate font size and spacing relative to the logo size
    final double baseFontSize = (logoSize * 30) / 80;
    final double lateralGap = (logoSize * 24) / 80;

    // Determine colors based on context or parameters
    final Color effectiveLogoColor = logoColor ?? Theme.of(context).primaryColor;
    final Color effectiveTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. The Graphical Logo Mark
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: CustomPaint(
            painter: _LogoMarkPainter(effectiveLogoColor),
          ),
        ),

        // 2. The Text Portion (Conditionally rendered based on showText)
        if (showText) ...[
          SizedBox(width: lateralGap),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HEALING',
                style: TextStyle(
                  fontSize: baseFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: baseFontSize * 0.05,
                  color: effectiveTextColor,
                  fontFamily: 'Oswald',
                ),
              ),
              Text(
                'MILESTONES',
                style: TextStyle(
                  fontSize: baseFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: baseFontSize * 0.013,
                  color: effectiveTextColor,
                  fontFamily: 'Oswald',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  final Color logoColor;

  _LogoMarkPainter(this.logoColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 100;
    final double scaleY = size.height / 100;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final Paint paint = Paint()
      ..color = logoColor
      ..style = PaintingStyle.fill;

    // --- STEP 1: Define the Outer Hull Base ---
    final RRect hullRRect = RRect.fromLTRBAndCorners(
      0,
      0,
      95,
      100,
      topLeft: const Radius.circular(50),
      bottomLeft: const Radius.circular(50),
      topRight: const Radius.circular(40),
      bottomRight: const Radius.circular(10),
    );
    final Path hull = Path()..addRRect(hullRRect);

    // --- STEP 2: Define the Negative Space (The Cutout) ---
    final Path cutout = Path();

    // 2a. The central vertical stem
    cutout.moveTo(42, 100);
    cutout.lineTo(42, 32);

    // Rounded top of the vertical stem
    cutout.arcToPoint(
      const Offset(54, 32),
      radius: const Radius.circular(6),
      clockwise: true,
    );
    cutout.lineTo(54, 45);

    // 2b. Inner curve feeding into the horizontal channel
    cutout.arcToPoint(
      const Offset(64, 55),
      radius: const Radius.circular(10),
      clockwise: false,
    );

    // 2c. The horizontal channel exiting right
    cutout.lineTo(100, 55);
    cutout.lineTo(100, 68);
    cutout.lineTo(64, 68);

    // 2d. Inner curve looping back to the vertical stem
    cutout.arcToPoint(
      const Offset(54, 78),
      radius: const Radius.circular(10),
      clockwise: false,
    );

    cutout.lineTo(54, 100);
    cutout.close();

    // --- STEP 3: Define the Three Floating Leaves ---

    // Center Leaf
    cutout.moveTo(48, 10);
    cutout.quadraticBezierTo(52, 17, 48, 27);
    cutout.quadraticBezierTo(44, 17, 48, 10);
    cutout.close();

    // Left Leaf
    cutout.moveTo(38, 18);
    cutout.quadraticBezierTo(43, 19, 44, 27);
    cutout.quadraticBezierTo(38, 24, 38, 18);
    cutout.close();

    // Right Leaf
    cutout.moveTo(58, 18);
    cutout.quadraticBezierTo(53, 19, 52, 27);
    cutout.quadraticBezierTo(58, 24, 58, 18);
    cutout.close();

    // --- STEP 4: Combine Paths ---
    final Path finalLogoPath = Path.combine(
      PathOperation.difference,
      hull,
      cutout,
    );

    canvas.drawPath(finalLogoPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) =>
      oldDelegate.logoColor != logoColor;
}
