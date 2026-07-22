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
  late AnimationController _leafController;

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

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

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
    _leafController.dispose();
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
            animation: Listenable.merge([_controller, _leafController]),
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
                leafAnimationValue: _leafController.value,
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
  final double leafAnimationValue;

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
    this.leafAnimationValue = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              leafAnimationValue: leafAnimationValue,
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
  final double leafAnimationValue;

  _AscensionLogoPainter({
    required this.logoColor,
    required this.dot1Progress,
    required this.dot2Progress,
    required this.sweepProgress,
    required this.bottomLeavesProgress,
    required this.topLeafProgress,
    required this.leafAnimationValue,
  });

  Path _buildLeaf(Offset center, double size, double rotation, double scale) {
    final Path path = Path();
    path.moveTo(center.dx, center.dy - (size * 0.5 * scale));
    path.quadraticBezierTo(
        center.dx + (size * 0.2 * scale),
        center.dy - (size * 0.1 * scale),
        center.dx,
        center.dy + (size * 0.5 * scale));
    path.quadraticBezierTo(
        center.dx - (size * 0.2 * scale),
        center.dy - (size * 0.1 * scale),
        center.dx,
        center.dy - (size * 0.5 * scale));
    path.close();

    final Matrix4 matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..rotateZ(rotation)
      ..translate(-center.dx, -center.dy);
    return path.transform(matrix.storage);
  }

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
    final leafSize = 22.0; // Same size as static logo
    final topLeafCenter = const Offset(48, 18);
    final midLeafCenter = const Offset(41, 22.5);
    final bottomLeafCenter = const Offset(55, 22.5);

    final breathScale = 1.0 + (leafAnimationValue * 0.15);
    final swayAngle = (leafAnimationValue - 0.5) * 0.15;

    if (bottomLeavesProgress > 0) {
      final double currentScale = bottomLeavesProgress * breathScale;
      cutout.addPath(
          _buildLeaf(midLeafCenter, leafSize, -0.392 - swayAngle, currentScale),
          Offset.zero);
      cutout.addPath(
          _buildLeaf(bottomLeafCenter, leafSize, 0.392 + (swayAngle * 1.5),
              currentScale),
          Offset.zero);
    }

    if (topLeafProgress > 0) {
      final double currentScale = topLeafProgress * breathScale;
      cutout.addPath(
          _buildLeaf(topLeafCenter, leafSize, 0 + swayAngle, currentScale),
          Offset.zero);
    }

    final Path rawSolidShape =
        Path.combine(PathOperation.difference, hull, cutout);

    final Path oldBottomRight = Path()
      ..addRect(const Rect.fromLTRB(54, 68, 100, 100));
    final Path topPieceOnly =
        Path.combine(PathOperation.difference, rawSolidShape, oldBottomRight);

    final Path newBottomRight = Path()
      ..addRRect(RRect.fromLTRBAndCorners(
        54,
        68,
        95,
        100,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ));

    final Path solidShape =
        Path.combine(PathOperation.union, topPieceOnly, newBottomRight);

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
      oldDelegate.leafAnimationValue != leafAnimationValue ||
      oldDelegate.logoColor != logoColor;
}

// ==========================================
// 4. Original Static Logo Widget Reference
// ==========================================
class HealingMilestonesStaticLogoWidget extends StatefulWidget {
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
  State<HealingMilestonesStaticLogoWidget> createState() =>
      _HealingMilestonesStaticLogoWidgetState();
}

class _HealingMilestonesStaticLogoWidgetState
    extends State<HealingMilestonesStaticLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = (widget.logoSize * 30) / 80;
    final double lateralGap = (widget.logoSize * 24) / 80;

    final Color effectiveLogoColor =
        widget.logoColor ?? Theme.of(context).primaryColor;
    final Color effectiveTextColor =
        widget.textColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: widget.logoSize,
          height: widget.logoSize,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter:
                    _LogoMarkPainter(effectiveLogoColor, _controller.value),
              );
            },
          ),
        ),
        if (widget.showText) ...[
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
  final double animationValue;

  _LogoMarkPainter(this.logoColor, this.animationValue);

  Path _buildLeaf(Offset center, double size, double rotation, double scale) {
    final Path path = Path();
    path.moveTo(center.dx, center.dy - (size * 0.5 * scale));
    path.quadraticBezierTo(
        center.dx + (size * 0.2 * scale),
        center.dy - (size * 0.1 * scale),
        center.dx,
        center.dy + (size * 0.5 * scale));
    path.quadraticBezierTo(
        center.dx - (size * 0.2 * scale),
        center.dy - (size * 0.1 * scale),
        center.dx,
        center.dy - (size * 0.5 * scale));
    path.close();

    final Matrix4 matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..rotateZ(rotation)
      ..translate(-center.dx, -center.dy);
    return path.transform(matrix.storage);
  }

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

    final leafSize = 22.0; // Larger leaves for static logo
    final topLeafCenter = const Offset(48, 18);
    final midLeafCenter = const Offset(41, 22.5);
    final bottomLeafCenter = const Offset(55, 22.5);

    // Calculate breathing and swaying animations for leaves
    final breathScale = 1.0 + (animationValue * 0.15); // Pulse up to 15% larger
    final swayAngle = (animationValue - 0.5) * 0.15; // Rotate back and forth

    cutout.addPath(
        _buildLeaf(topLeafCenter, leafSize, 0 + swayAngle, breathScale),
        Offset.zero);
    cutout.addPath(
        _buildLeaf(midLeafCenter, leafSize, -0.392 - swayAngle, breathScale),
        Offset.zero); // -pi/8 approx -0.392
    cutout.addPath(
        _buildLeaf(
            bottomLeafCenter, leafSize, 0.392 + (swayAngle * 1.5), breathScale),
        Offset.zero);

    final Path rawSolidShape = Path.combine(
      PathOperation.difference,
      hull,
      cutout,
    );

    final Path oldBottomRight = Path()
      ..addRect(const Rect.fromLTRB(54, 68, 100, 100));
    final Path topPieceOnly =
        Path.combine(PathOperation.difference, rawSolidShape, oldBottomRight);

    final Path newBottomRight = Path()
      ..addRRect(RRect.fromLTRBAndCorners(
        54,
        68,
        95,
        100,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ));

    final Path finalLogoPath =
        Path.combine(PathOperation.union, topPieceOnly, newBottomRight);

    canvas.drawPath(finalLogoPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) =>
      oldDelegate.logoColor != logoColor ||
      oldDelegate.animationValue != animationValue;
}
