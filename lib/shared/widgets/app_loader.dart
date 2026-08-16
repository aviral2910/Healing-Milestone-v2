import 'package:flutter/material.dart';

enum AppLoaderType { defaultLoader, overlay, small }

class AppLoader extends StatelessWidget {
  final AppLoaderType type;
  final String? text;
  final Color? color;
  final double? size;

  const AppLoader({Key? key, this.color, this.size})
    : type = AppLoaderType.defaultLoader,
      text = null,
      super(key: key);

  const AppLoader.overlay({Key? key, this.text, this.color, this.size})
    : type = AppLoaderType.overlay,
      super(key: key);

  const AppLoader.small({Key? key, this.color})
    : type = AppLoaderType.small,
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
    // You can test different loaders here by swapping out _BreathingLoader
    // with CircularProgressIndicator, CupertinoActivityIndicator, etc.
    return Center(
      child: _BreathingLoader(
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

class _BreathingLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _BreathingLoader({required this.color, this.size = 40.0});

  @override
  State<_BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<_BreathingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.2),
          border: Border.all(color: widget.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
