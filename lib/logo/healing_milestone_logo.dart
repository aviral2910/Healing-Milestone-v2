import 'dart:ui';
import 'package:flutter/material.dart';

// ==========================================
// 1. Interactive Wrapper / Trigger Widget
// ==========================================
class HealingMilestonesLogo extends StatelessWidget {
  final double logoSize;
  final Color? logoColor;
  final Color? textColor;
  final bool showText;

  const HealingMilestonesLogo({
    Key? key,
    this.logoSize = 35.0,
    this.logoColor,
    this.textColor,
    this.showText = true,
  }) : super(key: key);

  void _openAscensionScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AscensionOverlayScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // Ensures the whole bounding box catches taps
      onTap: () {
        _openAscensionScreen(context);
      },
      child: Container(
        color: Colors
            .transparent, // Required for reliable hit testing on empty spaces
        child: HealingMilestonesLogoWidget(
          logoSize: logoSize,
          logoColor: logoColor,
          textColor: textColor,
          showText: showText,
        ),
      ),
    );
  }
}

// ==========================================
// 1. Interactive Wrapper / Trigger Widget
// ==========================================
class HealingMilestonesLogoWidget extends StatelessWidget {
  final double logoSize;
  final Color? logoColor;
  final Color? textColor;
  final bool showText;

  const HealingMilestonesLogoWidget({
    Key? key,
    this.logoSize = 35.0,
    this.logoColor,
    this.textColor,
    this.showText = true,
  }) : super(key: key);

  void _openAscensionScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AscensionOverlayScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _openAscensionScreen(context);
      },
      child: Container(
        color: Colors.transparent,
        child: HealingMilestonesStaticLogoWidget(
          logoSize: logoSize,
          logoColor: logoColor,
          textColor: textColor,
          showText: showText,
        ),
      ),
    );
  }
}

// ==========================================
// 2. Ascension Overlay Screen with Refined Animation
// ==========================================
class AscensionOverlayScreen extends StatefulWidget {
  const AscensionOverlayScreen({Key? key}) : super(key: key);

  @override
  State<AscensionOverlayScreen> createState() => _AscensionOverlayScreenState();
}

class _AscensionOverlayScreenState extends State<AscensionOverlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _sweepAnimation;
  late Animation<double> _bottomLeavesAnimation;
  late Animation<double> _topLeafAnimation;
  
  bool _isClosing = false;
  
  void _closeScreen() {
    if (!_isClosing && mounted) {
      _isClosing = true;
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // 1. Bottom-right dot to square
    _dot1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeInOutCubic),
      ),
    );

    // 2. Top-right dot appears
    _dot2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.25, curve: Curves.easeOutBack),
      ),
    );

    // 3. The sweep up, left, and down
    _sweepAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeInOut),
      ),
    );

    // 4. Fresh leaves pop from bottom to top
    _bottomLeavesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.75, curve: Curves.elasticOut),
      ),
    );

    _topLeafAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          _closeScreen();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeScreen,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return HealingMilestonesAnimatedLogoMark(
                size: 120.0,
                color: theme.primaryColor,
                textColor: theme.colorScheme.onSurface,
                dot1Progress: _dot1Animation.value,
                dot2Progress: _dot2Animation.value,
                sweepProgress: _sweepAnimation.value,
                bottomLeavesProgress: _bottomLeavesAnimation.value,
                topLeafProgress: _topLeafAnimation.value,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. Step-by-Step Animated Logo Painter
// ==========================================
class HealingMilestonesAnimatedLogoMark extends StatelessWidget {
  final double size;
  final Color color;
  final Color textColor;
  final double dot1Progress;
  final double dot2Progress;
  final double sweepProgress;
  final double bottomLeavesProgress;
  final double topLeafProgress;

  const HealingMilestonesAnimatedLogoMark({
    Key? key,
    required this.size,
    required this.color,
    required this.textColor,
    required this.dot1Progress,
    required this.dot2Progress,
    required this.sweepProgress,
    required this.bottomLeavesProgress,
    required this.topLeafProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = (size * 30) / 80;
    final double lateralGap = (size * 24) / 80;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _AscensionLogoPainter(
              logoColor: color,
              dot1Progress: dot1Progress,
              dot2Progress: dot2Progress,
              sweepProgress: sweepProgress,
              bottomLeavesProgress: bottomLeavesProgress,
              topLeafProgress: topLeafProgress,
            ),
          ),
        ),
      ],
    );
  }
}

class _AscensionLogoPainter extends CustomPainter {
  final Color logoColor;
  final double dot1Progress;
  final double dot2Progress;
  final double sweepProgress;
  final double bottomLeavesProgress;
  final double topLeafProgress;

  _AscensionLogoPainter({
    required this.logoColor,
    required this.dot1Progress,
    required this.dot2Progress,
    required this.sweepProgress,
    required this.bottomLeavesProgress,
    required this.topLeafProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 100;
    final double scaleY = size.height / 100;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // --- Define the Exact Solid Shape ---
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

    final Path cutout = Path();
    cutout.moveTo(42, 100);
    cutout.lineTo(42, 32);
    cutout.arcToPoint(const Offset(54, 32),
        radius: const Radius.circular(6), clockwise: true);
    cutout.lineTo(54, 45);
    cutout.arcToPoint(const Offset(64, 55),
        radius: const Radius.circular(10), clockwise: false);
    cutout.lineTo(100, 55);
    cutout.lineTo(100, 68);
    cutout.lineTo(64, 68);
    cutout.arcToPoint(const Offset(54, 78),
        radius: const Radius.circular(10), clockwise: false);
    cutout.lineTo(54, 100);
    cutout.close();

    // Dynamically Add Animated Leaf Cutouts
    if (bottomLeavesProgress > 0) {
      final Path leaf1 = Path();
      leaf1.moveTo(38, 18);
      leaf1.quadraticBezierTo(43, 19, 44, 27);
      leaf1.quadraticBezierTo(38, 24, 38, 18);
      leaf1.close();

      final Matrix4 leftM = Matrix4.identity()
        ..translate(41.0, 22.5)
        ..scale(bottomLeavesProgress, bottomLeavesProgress)
        ..translate(-41.0, -22.5);
      cutout.addPath(leaf1.transform(leftM.storage), Offset.zero);

      final Path leaf3 = Path();
      leaf3.moveTo(58, 18);
      leaf3.quadraticBezierTo(53, 19, 52, 27);
      leaf3.quadraticBezierTo(58, 24, 58, 18);
      leaf3.close();

      final Matrix4 rightM = Matrix4.identity()
        ..translate(55.0, 22.5)
        ..scale(bottomLeavesProgress, bottomLeavesProgress)
        ..translate(-55.0, -22.5);
      cutout.addPath(leaf3.transform(rightM.storage), Offset.zero);
    }

    if (topLeafProgress > 0) {
      final Path leaf2 = Path();
      leaf2.moveTo(48, 10);
      leaf2.quadraticBezierTo(52, 17, 48, 27);
      leaf2.quadraticBezierTo(44, 17, 48, 10);
      leaf2.close();

      final Matrix4 topM = Matrix4.identity()
        ..translate(48.0, 18.5)
        ..scale(topLeafProgress, topLeafProgress)
        ..translate(-48.0, -18.5);
      cutout.addPath(leaf2.transform(topM.storage), Offset.zero);
    }

    final Path rawSolidShape =
        Path.combine(PathOperation.difference, hull, cutout);

    final Path oldBottomRight = Path()..addRect(const Rect.fromLTRB(54, 68, 100, 100));
    final Path topPieceOnly = Path.combine(PathOperation.difference, rawSolidShape, oldBottomRight);
    
    final Path newBottomRight = Path()..addRRect(RRect.fromLTRBAndCorners(
      54, 68, 95, 100,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    ));
    
    final Path solidShape = Path.combine(PathOperation.union, topPieceOnly, newBottomRight);

    final Paint fillPaint = Paint()
      ..color = logoColor
      ..style = PaintingStyle.fill;

    // 1. Stage 1 & 2: Dot to Square (Bottom Right)
    if (dot1Progress > 0) {
      final RRect startDot = RRect.fromLTRBAndCorners(
        64.5,
        74,
        84.5,
        94,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      final RRect targetRect = RRect.fromLTRBAndCorners(
        54,
        68,
        95,
        100,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      );
      final RRect? currentDot1 = RRect.lerp(startDot, targetRect, dot1Progress);
      if (currentDot1 != null) {
        canvas.drawRRect(currentDot1, fillPaint);
      }
    }

    // 2. Stage 3: Top Dot Appears (Above the gap)
    if (dot2Progress > 0 && sweepProgress == 0) {
      // Just draw a pure circle for the second dot
      double radius = 20.5 * dot2Progress;
      canvas.drawCircle(const Offset(74.5, 45), radius, fillPaint);
    }

    // 3. Stage 4 & 5: The Sweep
    if (sweepProgress > 0) {
      // Create a layer for piece1
      canvas.saveLayer(Rect.fromLTWH(-20, -20, 140, 140), Paint());

      final Paint srcInPaint = Paint()
        ..color = logoColor
        ..style = PaintingStyle.fill;

      // Extract piece1 by subtracting piece2 (the bottom right square) from solidShape
      final Path piece2Path = Path()
        ..addRRect(RRect.fromLTRBAndCorners(
          54,
          68,
          95,
          100,
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ));
      final Path piece1 =
          Path.combine(PathOperation.difference, solidShape, piece2Path);

      // Draw piece1 in gold
      canvas.drawPath(piece1, srcInPaint);

      // Now apply the sweeping mask using dstIn!
      canvas.saveLayer(Rect.fromLTWH(-20, -20, 140, 140),
          Paint()..blendMode = BlendMode.dstIn);

      final Path sweepPath = Path();
      sweepPath.moveTo(74.5, 55); // Start at bottom of upper-right leg
      sweepPath.lineTo(74.5, 16); // Up
      sweepPath.lineTo(21, 16); // Left
      sweepPath.lineTo(21, 110); // Down

      final Paint sweepMaskPaint = Paint()
        ..color = Colors.black // Color doesn't matter for dstIn, only alpha
        ..style = PaintingStyle.stroke
        ..strokeWidth = 60
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      for (final PathMetric metric in sweepPath.computeMetrics()) {
        final Path extractPath =
            metric.extractPath(0.0, metric.length * sweepProgress);
        canvas.drawPath(extractPath, sweepMaskPaint);
      }

      // Keep the starting dot visible in the mask so it seamlessly connects
      canvas.drawCircle(
          const Offset(74.5, 45), 20.5, Paint()..color = Colors.black);

      canvas.restore(); // Applies the mask to piece1
      canvas.restore(); // Applies masked piece1 to the main canvas
    }

    // (Leaves are now processed dynamically as cutouts above)

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AscensionLogoPainter oldDelegate) =>
      oldDelegate.dot1Progress != dot1Progress ||
      oldDelegate.dot2Progress != dot2Progress ||
      oldDelegate.sweepProgress != sweepProgress ||
      oldDelegate.bottomLeavesProgress != bottomLeavesProgress ||
      oldDelegate.topLeafProgress != topLeafProgress ||
      oldDelegate.logoColor != logoColor;
}

// ==========================================
// 4. Original Static Logo Widget Reference
// ==========================================
class HealingMilestonesStaticLogoWidget extends StatelessWidget {
  final double logoSize;
  final Color? logoColor;
  final Color? textColor;
  final bool showText;

  const HealingMilestonesStaticLogoWidget({
    Key? key,
    this.logoSize = 35.0,
    this.logoColor,
    this.textColor,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = (logoSize * 30) / 80;
    final double lateralGap = (logoSize * 24) / 80;

    final Color effectiveLogoColor =
        logoColor ?? Theme.of(context).primaryColor;
    final Color effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: CustomPaint(
            painter: _LogoMarkPainter(effectiveLogoColor),
          ),
        ),
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

    final Path cutout = Path();
    cutout.moveTo(42, 100);
    cutout.lineTo(42, 32);
    cutout.arcToPoint(
      const Offset(54, 32),
      radius: const Radius.circular(6),
      clockwise: true,
    );
    cutout.lineTo(54, 45);
    cutout.arcToPoint(
      const Offset(64, 55),
      radius: const Radius.circular(10),
      clockwise: false,
    );
    cutout.lineTo(100, 55);
    cutout.lineTo(100, 68);
    cutout.lineTo(64, 68);
    cutout.arcToPoint(
      const Offset(54, 78),
      radius: const Radius.circular(10),
      clockwise: false,
    );
    cutout.lineTo(54, 100);
    cutout.close();

    cutout.moveTo(48, 10);
    cutout.quadraticBezierTo(52, 17, 48, 27);
    cutout.quadraticBezierTo(44, 17, 48, 10);
    cutout.close();

    cutout.moveTo(38, 18);
    cutout.quadraticBezierTo(43, 19, 44, 27);
    cutout.quadraticBezierTo(38, 24, 38, 18);
    cutout.close();

    cutout.moveTo(58, 18);
    cutout.quadraticBezierTo(53, 19, 52, 27);
    cutout.quadraticBezierTo(58, 24, 58, 18);
    cutout.close();

    final Path rawSolidShape = Path.combine(
      PathOperation.difference,
      hull,
      cutout,
    );

    final Path oldBottomRight = Path()..addRect(const Rect.fromLTRB(54, 68, 100, 100));
    final Path topPieceOnly = Path.combine(PathOperation.difference, rawSolidShape, oldBottomRight);
    
    final Path newBottomRight = Path()..addRRect(RRect.fromLTRBAndCorners(
      54, 68, 95, 100,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    ));
    
    final Path finalLogoPath = Path.combine(PathOperation.union, topPieceOnly, newBottomRight);

    canvas.drawPath(finalLogoPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) =>
      oldDelegate.logoColor != logoColor;
}
