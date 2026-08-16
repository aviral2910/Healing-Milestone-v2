import 'package:flutter/material.dart';

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
      child: _ZenRippleLoader(
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 45.0,
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

class _ZenRippleLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _ZenRippleLoader({required this.color, this.size = 45.0});

  @override
  State<_ZenRippleLoader> createState() => _ZenRippleLoaderState();
}

class _ZenRippleLoaderState extends State<_ZenRippleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // A nice slow 2-second cycle for a calm, breathing ripple
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        var phase = _controller.value - delay;
        if (phase < 0) phase += 1.0;

        // Easing function for smoother expansion
        final curve = Curves.easeOutCubic;
        final scale = curve.transform(phase);
        
        // Opacity fades out gently as it expands
        final opacity = (1.0 - phase) * 0.8;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.15),
                border: Border.all(
                  color: widget.color,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: opacity * 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
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
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRipple(0.0),
          _buildRipple(0.33),
          _buildRipple(0.66),
          // Central glowing seed/droplet
          Container(
            width: widget.size * 0.2,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.8),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
