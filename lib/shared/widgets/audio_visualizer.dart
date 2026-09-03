import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    required this.color,
    this.barCount = 30,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}


class _AudioVisualizerState extends State<AudioVisualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    final heights = [
      14.0,
      22.0,
      10.0,
      30.0,
      18.0,
      25.0,
      12.0,
      20.0,
      28.0,
      16.0,
      35.0,
      18.0,
      24.0,
      14.0,
      22.0,
      12.0,
      28.0,
      15.0,
      32.0,
      20.0,
      10.0,
      26.0,
      14.0,
      18.0,
      22.0,
      30.0,
      16.0,
      24.0,
      12.0,
      20.0,
    ];

    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index % 5) * 80),
        vsync: this,
      ),
    );

    _animations = List.generate(widget.barCount, (index) {
      return Tween<double>(
        begin: 3.0,
        end: heights[index % heights.length],
      ).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      );
    });

    if (widget.isPlaying) {
      for (var c in _controllers) c.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        for (var c in _controllers) c.repeat(reverse: true);
      } else {
        for (var c in _controllers)
          c.animateTo(0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              return Container(
                width: 3,
                height: widget.isPlaying ? _animations[index].value : 3.0,
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: widget.isPlaying ? 0.8 : 0.2,
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
