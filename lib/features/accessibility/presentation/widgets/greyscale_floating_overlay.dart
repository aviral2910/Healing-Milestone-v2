import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/accessibility_providers.dart';

class GreyscaleFloatingOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GreyscaleFloatingOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<GreyscaleFloatingOverlay> createState() =>
      _GreyscaleFloatingOverlayState();
}

class _GreyscaleFloatingOverlayState
    extends ConsumerState<GreyscaleFloatingOverlay>
    with SingleTickerProviderStateMixin {
  Offset? _position;
  bool _isDragging = false;
  bool _isHoveringClose = false;
  bool? _wasShowing;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final double _buttonSize = 36.0;
  final double _closeZoneRadius = 60.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityState = ref.watch(accessibilityProvider);

    final isShowingNow = accessibilityState.showGreyscaleFloatingIcon;

    if (_wasShowing != null && isShowingNow && !_wasShowing!) {
      // It was just re-triggered during the session.
      // Animate it popping out of the edge panel.
      final screenSize = MediaQuery.of(context).size;
      
      // Start position: Right edge, middle of screen (where the edge panel handle is)
      _position = Offset(screenSize.width - 10.0, screenSize.height / 2);

      // Final target position
      final targetPosition = Offset(
          screenSize.width - _buttonSize - 16.0, screenSize.height * 0.25);

      // Animate to target position in the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _position = targetPosition;
          });
          ref
              .read(accessibilityProvider.notifier)
              .updateFloatingIconPosition(targetPosition.dx, targetPosition.dy);
        }
      });
    }
    _wasShowing = isShowingNow;

    if (!isShowingNow) {
      return widget.child;
    }

    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    final minX = 16.0;
    final maxX = screenSize.width - _buttonSize - 16.0;
    final minY = 16.0;
    final maxY = screenSize.height - safePadding.bottom - _buttonSize - 40.0;

    // Load saved position if not set yet
    if (_position == null) {
      if (accessibilityState.floatingIconDx != -1.0 &&
          accessibilityState.floatingIconDy != -1.0) {
        _position = Offset(accessibilityState.floatingIconDx,
            accessibilityState.floatingIconDy);
      } else {
        _position = Offset(
            screenSize.width - _buttonSize - 16.0, screenSize.height * 0.25);
      }
    }

    // Fallback safe position on first render or screen resize
    if (_position!.dx > maxX ||
        _position!.dy > maxY ||
        _position!.dx < minX ||
        _position!.dy < minY) {
      _position = Offset(
          _position!.dx.clamp(minX, maxX), _position!.dy.clamp(minY, maxY));
    }

    final closeZoneCenter = Offset(
      screenSize.width / 2,
      screenSize.height - 80,
    );

    return Stack(
      children: [
        widget.child,
        AnimatedOpacity(
          opacity: _isDragging ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: safePadding.bottom + 20),
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isHoveringClose
                      ? _closeZoneRadius * 1.2
                      : _closeZoneRadius,
                  height: _isHoveringClose
                      ? _closeZoneRadius * 1.2
                      : _closeZoneRadius,
                  decoration: BoxDecoration(
                    color: _isHoveringClose
                        ? Colors.red
                        : Colors.red.withOpacity(0.4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: _isHoveringClose
                        ? Colors.white
                        : Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration:
              _isDragging ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: _position!.dx,
          top: _position!.dy,
          child: GestureDetector(
            onTap: () {
              ref.read(accessibilityProvider.notifier).toggleGreyscaleMode();
            },
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
              });
              _pulseController.repeat(reverse: true);
            },
            onPanUpdate: (details) {
              setState(() {
                _position = _position! + details.delta;

                // Clamp to screen safe bounds
                _position = Offset(
                  _position!.dx.clamp(minX, maxX),
                  _position!.dy.clamp(minY, maxY),
                );

                // Check distance to close zone
                final buttonCenter = Offset(
                  _position!.dx + _buttonSize / 2,
                  _position!.dy + _buttonSize / 2,
                );

                final distance = (buttonCenter - closeZoneCenter).distance;
                _isHoveringClose = distance < _closeZoneRadius;
              });
            },
            onPanEnd: (details) {
              if (_isHoveringClose) {
                ref
                    .read(accessibilityProvider.notifier)
                    .toggleFloatingIcon(false);
              } else {
                // Snap to edge
                final isLeft = _position!.dx < screenSize.width / 2;
                _position = Offset(
                  isLeft ? 16.0 : screenSize.width - _buttonSize - 16.0,
                  _position!.dy,
                );
                // Save position
                ref
                    .read(accessibilityProvider.notifier)
                    .updateFloatingIconPosition(_position!.dx, _position!.dy);
              }

              setState(() {
                _isDragging = false;
                _isHoveringClose = false;
              });
              _pulseController.stop();
              _pulseController.value = 0.0;
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isDragging ? 1.0 : 0.65,
              child: SafeArea(
                left: false,
                right: false,
                child: Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: BoxDecoration(
                    color: accessibilityState.isGreyscaleMode
                        ? Colors.grey[900]
                        : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accessibilityState.isGreyscaleMode
                          ? Colors.grey[700]!
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: _isDragging
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    accessibilityState.isGreyscaleMode
                        ? Icons.auto_stories_rounded
                        : Icons.auto_stories_outlined,
                    color: accessibilityState.isGreyscaleMode
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
