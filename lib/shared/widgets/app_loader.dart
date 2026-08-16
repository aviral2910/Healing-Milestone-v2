import 'package:flutter/material.dart';
import 'dart:math' as math;

enum AppLoaderType {
  defaultLoader,
  overlay,
  small,
}

class AppLoader extends StatelessWidget {
  final AppLoaderType type;
  final String? text;
  final Color? color;
  final double? size;

  const AppLoader({
    Key? key,
    this.color,
    this.size,
  })  : type = AppLoaderType.defaultLoader,
        text = null,
        super(key: key);

  const AppLoader.overlay({
    Key? key,
    this.text,
    this.color,
    this.size,
  })  : type = AppLoaderType.overlay,
        super(key: key);

  const AppLoader.small({
    Key? key,
    this.color,
  })  : type = AppLoaderType.small,
        text = null,
        size = 16,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppLoaderType.overlay:
        return _buildOverlay(context);
      case AppLoaderType.small:
        return _buildSmall(context);
      case AppLoaderType.defaultLoader:
        return _buildDefault(context);
    }
  }

  Widget _buildDefault(BuildContext context) {
    return Center(
      child: _GlowingRingLoader(
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 40.0,
      ),
    );
  }

  Widget _buildSmall(BuildContext context) {
    return SizedBox(
      width: size ?? 16.0,
      height: size ?? 16.0,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDefault(context),
            if (text != null) ...[
              const SizedBox(height: 16),
              Text(
                text!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlowingRingLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _GlowingRingLoader({required this.color, this.size = 40.0});

  @override
  State<_GlowingRingLoader> createState() => _GlowingRingLoaderState();
}

class _GlowingRingLoaderState extends State<_GlowingRingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _GlowingRingPainter(color: widget.color),
        ),
      ),
    );
  }
}

class _GlowingRingPainter extends CustomPainter {
  final Color color;

  _GlowingRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Base ring (faint)
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(rect.center, size.width / 2 - 2, bgPaint);

    // Glowing animated arc
    final gradient = SweepGradient(
      colors: [
        color.withValues(alpha: 0.0),
        color,
      ],
      stops: const [0.0, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    // Add glow using mask filter
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0); // The glow

    final arcRect = rect.deflate(2.0);
    // Draw glow first, then the actual arc on top
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 1.5, false, glowPaint);
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
