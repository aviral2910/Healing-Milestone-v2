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
    // You can test different loaders by changing this single line to:
    // _ThreeDotWaveLoader, _DualArcSpinner, or _ZenRippleLoader
    return Center(
      child: _ThreeDotWaveLoader(
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
              const SizedBox(height: 24),
              Text(
                text!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// LOADER OPTION 1: Ultra-Clean 3-Dot Wave (Modern/Minimalist)
// ---------------------------------------------------------
class _ThreeDotWaveLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _ThreeDotWaveLoader({required this.color, this.size = 40.0});

  @override
  State<_ThreeDotWaveLoader> createState() => _ThreeDotWaveLoaderState();
}

class _ThreeDotWaveLoaderState extends State<_ThreeDotWaveLoader>
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

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double offset = index * 0.2;
        double progress = _controller.value - offset;
        if (progress < 0) progress += 1.0;

        double scale = 1.0;
        double opacity = 0.3;
        
        // Scale and fade up for first 30%, down for next 30%
        if (progress < 0.3) {
          final t = progress / 0.3;
          scale = 1.0 + (math.sin(t * math.pi / 2) * 0.4); 
          opacity = 0.3 + (0.7 * t);
        } else if (progress < 0.6) {
          final t = (progress - 0.3) / 0.3;
          scale = 1.4 - (math.sin(t * math.pi / 2) * 0.4);
          opacity = 1.0 - (0.7 * t);
        }

        final dotSize = widget.size * 0.25;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.size * 0.06),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    if (opacity > 0.6)
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(0),
          _buildDot(1),
          _buildDot(2),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// LOADER OPTION 2: Dual Spinning Arcs (Tech/Sleek)
// ---------------------------------------------------------
class _DualArcSpinner extends StatefulWidget {
  final Color color;
  final double size;

  const _DualArcSpinner({required this.color, this.size = 40.0});

  @override
  State<_DualArcSpinner> createState() => _DualArcSpinnerState();
}

class _DualArcSpinnerState extends State<_DualArcSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
          painter: _DualArcPainter(color: widget.color),
        ),
      ),
    );
  }
}

class _DualArcPainter extends CustomPainter {
  final Color color;
  _DualArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    // Draw two opposite arcs
    canvas.drawArc(rect.deflate(2.0), 0, math.pi / 2, false, paint);
    canvas.drawArc(rect.deflate(2.0), math.pi, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
