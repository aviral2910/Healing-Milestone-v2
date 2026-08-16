import 'package:flutter/material.dart';
import 'dart:math' as math;

class GratitudeTree extends StatefulWidget {
  final int gratitudeScore;

  const GratitudeTree({super.key, required this.gratitudeScore});

  @override
  State<GratitudeTree> createState() => _GratitudeTreeState();
}

class _GratitudeTreeState extends State<GratitudeTree>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 300),
          painter: _OakTreePainter(
            health: (widget.gratitudeScore.clamp(0, 100)) / 100.0,
            breath: _breathController.value,
          ),
        );
      },
    );
  }
}

class _OakTreePainter extends CustomPainter {
  final double health;
  final double breath;

  _OakTreePainter({required this.health, required this.breath});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 8;
    final sway = math.sin(breath * math.pi * 2);

    // Grass at base
    _drawGrass(canvas, cx, baseY);

    // Global sway
    canvas.save();
    canvas.translate(cx, baseY);
    canvas.rotate(sway * 0.012);
    canvas.translate(-cx, -baseY);

    // 1) Draw BACK foliage layer first (behind branches)
    if (health > 0) {
      _drawFoliageLayer(canvas, cx, baseY, health, sway, isBack: true);
    }

    // 2) Trunk and branches (drawn ON TOP of back foliage)
    _drawTrunk(canvas, cx, baseY);
    _drawBranches(canvas, cx, baseY);

    // 3) Draw FRONT foliage layer (on top of branches)
    if (health > 0) {
      _drawFoliageLayer(canvas, cx, baseY, health, sway, isBack: false);
    }

    canvas.restore();
  }

  void _drawGrass(Canvas canvas, double cx, double baseY) {
    final grassPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final data in [
      [-30.0, -18.0, -8.0],
      [-20.0, -22.0, -3.0],
      [-10.0, -16.0, 2.0],
      [0.0, -20.0, 5.0],
      [10.0, -18.0, 3.0],
      [20.0, -14.0, 8.0],
      [30.0, -20.0, 5.0],
      [40.0, -16.0, 10.0],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(cx + data[0], baseY)
          ..quadraticBezierTo(
            cx + data[0] + data[2] * 0.3,
            baseY + data[1] * 0.6,
            cx + data[0] + data[2],
            baseY + data[1],
          ),
        grassPaint,
      );
    }
    // Darker grass
    grassPaint.color = const Color(0xFF388E3C);
    for (final data in [
      [-25.0, -14.0, -5.0],
      [-5.0, -12.0, 4.0],
      [15.0, -15.0, 6.0],
      [35.0, -12.0, 7.0],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(cx + data[0], baseY)
          ..quadraticBezierTo(
            cx + data[0] + data[2] * 0.3,
            baseY + data[1] * 0.6,
            cx + data[0] + data[2],
            baseY + data[1],
          ),
        grassPaint,
      );
    }
  }

  void _drawTrunk(Canvas canvas, double cx, double baseY) {
    // Thick warm brown trunk with flared base
    final trunk = Path();
    // Left edge
    trunk.moveTo(cx - 22, baseY);
    trunk.cubicTo(
      cx - 28,
      baseY - 30,
      cx - 16,
      baseY - 100,
      cx - 8,
      baseY - 145,
    );
    // Top narrow part
    trunk.lineTo(cx + 6, baseY - 145);
    // Right edge
    trunk.cubicTo(cx + 14, baseY - 100, cx + 26, baseY - 30, cx + 20, baseY);
    trunk.close();

    // Base fill — warm brown
    canvas.drawPath(trunk, Paint()..color = const Color(0xFF8B6914));

    // Light stripe down center for bark highlight
    final highlight = Path();
    highlight.moveTo(cx - 5, baseY);
    highlight.cubicTo(cx - 3, baseY - 50, cx, baseY - 100, cx + 2, baseY - 140);
    highlight.lineTo(cx + 6, baseY - 140);
    highlight.cubicTo(cx + 8, baseY - 100, cx + 10, baseY - 50, cx + 10, baseY);
    highlight.close();
    canvas.drawPath(highlight, Paint()..color = const Color(0xFFBE9B4C));

    // Dark left edge for depth
    final shadow = Path();
    shadow.moveTo(cx - 22, baseY);
    shadow.cubicTo(
      cx - 28,
      baseY - 30,
      cx - 16,
      baseY - 100,
      cx - 8,
      baseY - 145,
    );
    shadow.lineTo(cx - 3, baseY - 145);
    shadow.cubicTo(cx - 10, baseY - 100, cx - 18, baseY - 30, cx - 12, baseY);
    shadow.close();
    canvas.drawPath(shadow, Paint()..color = const Color(0xFF5D4037));

    // Bark texture lines
    final barkPaint = Paint()
      ..color = const Color(0xFF4E3524).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    _curve(
      canvas,
      barkPaint,
      cx - 15,
      baseY - 5,
      cx - 6,
      baseY - 80,
      cx - 12,
      baseY - 40,
    );
    _curve(
      canvas,
      barkPaint,
      cx - 8,
      baseY - 10,
      cx - 3,
      baseY - 120,
      cx - 5,
      baseY - 60,
    );
    _curve(
      canvas,
      barkPaint,
      cx + 5,
      baseY - 5,
      cx + 4,
      baseY - 100,
      cx + 6,
      baseY - 50,
    );
    _curve(
      canvas,
      barkPaint,
      cx + 14,
      baseY - 10,
      cx + 7,
      baseY - 90,
      cx + 12,
      baseY - 45,
    );
  }

  void _drawBranches(Canvas canvas, double cx, double baseY) {
    final branchColor = const Color(0xFF5D4037);

    // Main left sweep
    _filledBranch(
      canvas,
      cx - 6,
      baseY - 130,
      cx - 85,
      baseY - 155,
      cx - 45,
      baseY - 125,
      9,
      3,
      branchColor,
    );
    // Left sub-branches
    _filledBranch(
      canvas,
      cx - 45,
      baseY - 138,
      cx - 110,
      baseY - 120,
      cx - 80,
      baseY - 120,
      5,
      1.5,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx - 60,
      baseY - 145,
      cx - 120,
      baseY - 175,
      cx - 95,
      baseY - 150,
      4,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx - 75,
      baseY - 152,
      cx - 105,
      baseY - 210,
      cx - 95,
      baseY - 180,
      3.5,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx - 30,
      baseY - 133,
      cx - 65,
      baseY - 210,
      cx - 45,
      baseY - 170,
      5,
      1.5,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx - 45,
      baseY - 178,
      cx - 85,
      baseY - 235,
      cx - 70,
      baseY - 205,
      3,
      1,
      branchColor,
    );

    // Center branches going up
    _filledBranch(
      canvas,
      cx - 4,
      baseY - 140,
      cx - 20,
      baseY - 240,
      cx - 15,
      baseY - 190,
      6,
      2,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx - 15,
      baseY - 205,
      cx - 50,
      baseY - 260,
      cx - 35,
      baseY - 230,
      3,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx,
      baseY - 140,
      cx + 20,
      baseY - 255,
      cx + 10,
      baseY - 195,
      5,
      1.5,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 12,
      baseY - 215,
      cx + 40,
      baseY - 265,
      cx + 30,
      baseY - 240,
      2.5,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 15,
      baseY - 230,
      cx + 5,
      baseY - 270,
      cx + 8,
      baseY - 250,
      2,
      0.8,
      branchColor,
    );

    // Main right sweep
    _filledBranch(
      canvas,
      cx + 4,
      baseY - 120,
      cx + 100,
      baseY - 140,
      cx + 55,
      baseY - 110,
      8,
      3,
      branchColor,
    );
    // Right sub-branches
    _filledBranch(
      canvas,
      cx + 55,
      baseY - 128,
      cx + 115,
      baseY - 180,
      cx + 90,
      baseY - 140,
      5,
      1.5,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 80,
      baseY - 138,
      cx + 140,
      baseY - 125,
      cx + 115,
      baseY - 120,
      4,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 90,
      baseY - 155,
      cx + 135,
      baseY - 185,
      cx + 118,
      baseY - 160,
      3,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 60,
      baseY - 132,
      cx + 75,
      baseY - 195,
      cx + 68,
      baseY - 160,
      3.5,
      1,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 40,
      baseY - 120,
      cx + 65,
      baseY - 85,
      cx + 50,
      baseY - 95,
      4,
      1.5,
      branchColor,
    );
    _filledBranch(
      canvas,
      cx + 55,
      baseY - 88,
      cx + 90,
      baseY - 80,
      cx + 75,
      baseY - 78,
      3,
      1,
      branchColor,
    );
  }

  void _filledBranch(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    double ctrlX,
    double ctrlY,
    double wStart,
    double wEnd,
    Color color,
  ) {
    final path = Path();
    const n = 24;
    final top = <Offset>[];
    final bot = <Offset>[];

    for (int i = 0; i <= n; i++) {
      final t = i / n;
      final omt = 1 - t;
      final px = omt * omt * x1 + 2 * omt * t * ctrlX + t * t * x2;
      final py = omt * omt * y1 + 2 * omt * t * ctrlY + t * t * y2;
      final tx = 2 * omt * (ctrlX - x1) + 2 * t * (x2 - ctrlX);
      final ty = 2 * omt * (ctrlY - y1) + 2 * t * (y2 - ctrlY);
      final len = math.sqrt(tx * tx + ty * ty);
      if (len == 0) continue;
      final nx = -ty / len;
      final ny = tx / len;
      final w = (wStart + (wEnd - wStart) * t) / 2;
      top.add(Offset(px + nx * w, py + ny * w));
      bot.add(Offset(px - nx * w, py - ny * w));
    }
    if (top.isEmpty) return;

    path.moveTo(top.first.dx, top.first.dy);
    for (int i = 1; i < top.length; i++) {
      path.lineTo(top[i].dx, top[i].dy);
    }
    for (int i = bot.length - 1; i >= 0; i--) {
      path.lineTo(bot[i].dx, bot[i].dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _curve(
    Canvas canvas,
    Paint p,
    double x1,
    double y1,
    double x2,
    double y2,
    double cx,
    double cy,
  ) {
    canvas.drawPath(
      Path()
        ..moveTo(x1, y1)
        ..quadraticBezierTo(cx, cy, x2, y2),
      p,
    );
  }

  // ================================================================
  // FOLIAGE — clusters of individually visible leaf shapes
  // ================================================================

  void _drawFoliageLayer(
    Canvas canvas,
    double cx,
    double baseY,
    double health,
    double sway, {
    required bool isBack,
  }) {
    // Back layer = darker shadow foliage behind branches
    // Front layer = bright highlight foliage in front of branches
    final clusters = isBack
        ? _backClusters(cx, baseY)
        : _frontClusters(cx, baseY);

    for (final c in clusters) {
      final bloom = ((health - c.delay) / 0.25).clamp(0.0, 1.0);
      if (bloom <= 0) continue;
      final scale = math.sin(bloom * math.pi / 2);
      _drawLeafCluster(
        canvas,
        c.x,
        c.y,
        c.radius * scale,
        c.leafCount,
        c.darkColor,
        c.lightColor,
        sway,
      );
    }
  }

  List<_FoliageCluster> _backClusters(double cx, double baseY) {
    // Dark green shadow foliage behind the branches
    const dark = Color(0xFF2E7D32);
    const mid = Color(0xFF43A047);
    return [
      _FoliageCluster(cx - 95, baseY - 125, 28, 10, dark, mid, 0.10),
      _FoliageCluster(cx - 110, baseY - 165, 25, 9, dark, mid, 0.20),
      _FoliageCluster(cx - 85, baseY - 200, 30, 11, dark, mid, 0.30),
      _FoliageCluster(cx - 55, baseY - 225, 28, 10, dark, mid, 0.40),
      _FoliageCluster(cx - 25, baseY - 245, 25, 9, dark, mid, 0.50),
      _FoliageCluster(cx + 10, baseY - 250, 28, 10, dark, mid, 0.55),
      _FoliageCluster(cx + 40, baseY - 240, 25, 9, dark, mid, 0.50),
      _FoliageCluster(cx + 65, baseY - 200, 28, 10, dark, mid, 0.40),
      _FoliageCluster(cx + 95, baseY - 170, 30, 11, dark, mid, 0.30),
      _FoliageCluster(cx + 120, baseY - 140, 25, 9, dark, mid, 0.20),
      _FoliageCluster(cx + 70, baseY - 90, 22, 8, dark, mid, 0.15),
      _FoliageCluster(cx - 50, baseY - 165, 22, 8, dark, mid, 0.25),
      _FoliageCluster(cx + 30, baseY - 180, 22, 8, dark, mid, 0.35),
      _FoliageCluster(cx - 15, baseY - 190, 22, 8, dark, mid, 0.45),
    ];
  }

  List<_FoliageCluster> _frontClusters(double cx, double baseY) {
    // Bright yellow-green highlight foliage in front of branches
    const mid = Color(0xFF7CB342);
    const bright = Color(0xFFCDDC39);
    const pale = Color(0xFFE6EE9C);
    return [
      _FoliageCluster(cx - 100, baseY - 140, 26, 10, mid, bright, 0.15),
      _FoliageCluster(cx - 75, baseY - 185, 24, 9, mid, bright, 0.25),
      _FoliageCluster(cx - 90, baseY - 215, 22, 8, mid, pale, 0.35),
      _FoliageCluster(cx - 60, baseY - 240, 26, 10, mid, bright, 0.45),
      _FoliageCluster(cx - 30, baseY - 260, 24, 9, mid, pale, 0.55),
      _FoliageCluster(cx, baseY - 265, 26, 10, mid, bright, 0.60),
      _FoliageCluster(cx + 25, baseY - 258, 24, 9, mid, pale, 0.55),
      _FoliageCluster(cx + 50, baseY - 245, 22, 8, mid, bright, 0.50),
      _FoliageCluster(cx + 80, baseY - 195, 26, 10, mid, pale, 0.40),
      _FoliageCluster(cx + 110, baseY - 175, 24, 9, mid, bright, 0.30),
      _FoliageCluster(cx + 130, baseY - 150, 22, 8, mid, pale, 0.25),
      _FoliageCluster(cx + 80, baseY - 80, 20, 7, mid, bright, 0.20),
      _FoliageCluster(cx - 45, baseY - 150, 20, 7, mid, bright, 0.35),
      _FoliageCluster(cx + 15, baseY - 200, 20, 7, mid, pale, 0.45),
      _FoliageCluster(cx - 15, baseY - 215, 20, 7, mid, bright, 0.50),
      _FoliageCluster(cx + 45, baseY - 210, 20, 7, mid, pale, 0.40),
      // Extra filler at edges
      _FoliageCluster(cx - 120, baseY - 110, 18, 7, mid, bright, 0.60),
      _FoliageCluster(cx + 55, baseY - 100, 18, 7, mid, bright, 0.65),
    ];
  }

  /// Draws a cluster of clearly visible individual leaves arranged in a rosette.
  /// Each leaf is a distinct teardrop shape radiating outward from the center,
  /// so you can see every single leaf at the edges — NOT a blob.
  void _drawLeafCluster(
    Canvas canvas,
    double x,
    double y,
    double radius,
    int leafCount,
    Color darkColor,
    Color lightColor,
    double sway,
  ) {
    if (radius < 2) return;

    canvas.save();
    canvas.translate(x, y);

    final leafSize = radius * 0.75;

    // Draw leaves radiating outward like a rosette
    for (int i = 0; i < leafCount; i++) {
      final angle = (i / leafCount) * math.pi * 2 + sway * 0.04;
      final dist = radius * 0.35; // How far from center the leaf base sits

      canvas.save();
      canvas.translate(math.cos(angle) * dist, math.sin(angle) * dist);
      canvas.rotate(angle);

      // Each leaf is a clear almond/teardrop shape
      final leafPath = Path();
      leafPath.moveTo(0, 0);
      leafPath.quadraticBezierTo(leafSize * 0.5, -leafSize * 0.35, leafSize, 0);
      leafPath.quadraticBezierTo(leafSize * 0.5, leafSize * 0.35, 0, 0);

      // Top half — lighter color
      final topHalf = Path();
      topHalf.moveTo(0, 0);
      topHalf.quadraticBezierTo(leafSize * 0.5, -leafSize * 0.35, leafSize, 0);
      topHalf.lineTo(0, 0);
      canvas.drawPath(topHalf, Paint()..color = lightColor);

      // Bottom half — darker color
      final bottomHalf = Path();
      bottomHalf.moveTo(0, 0);
      bottomHalf.quadraticBezierTo(
        leafSize * 0.5,
        leafSize * 0.35,
        leafSize,
        0,
      );
      bottomHalf.lineTo(0, 0);
      canvas.drawPath(bottomHalf, Paint()..color = darkColor);

      // Center vein
      canvas.drawLine(
        Offset.zero,
        Offset(leafSize * 0.85, 0),
        Paint()
          ..color = const Color(0xFF1B5E20).withValues(alpha: 0.3)
          ..strokeWidth = 0.6,
      );

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OakTreePainter oldDelegate) => true;
}

class _FoliageCluster {
  final double x, y, radius;
  final int leafCount;
  final Color darkColor, lightColor;
  final double delay;
  const _FoliageCluster(
    this.x,
    this.y,
    this.radius,
    this.leafCount,
    this.darkColor,
    this.lightColor,
    this.delay,
  );
}
