import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/features/accessibility/data/accessibility_providers.dart';

class ImmersiveReadingEdgePanel extends ConsumerWidget {
  final bool isEdgePanelOpen;
  final VoidCallback onToggle;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final double textSizeFactor;
  final double textOpacity;
  final ValueChanged<double> onTextSizeChanged;
  final ValueChanged<double> onTextOpacityChanged;
  final VoidCallback onReset;

  const ImmersiveReadingEdgePanel({
    super.key,
    required this.isEdgePanelOpen,
    required this.onToggle,
    required this.onPanUpdate,
    required this.textSizeFactor,
    required this.textOpacity,
    required this.onTextSizeChanged,
    required this.onTextOpacityChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGreyscale = ref.watch(accessibilityProvider).isGreyscaleMode;
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Styling based on requirements
    final handleColor =
        isGreyscale ? Colors.grey[500]! : theme.colorScheme.primary;
    final panelBgColor =
        isGreyscale ? Colors.grey[900]! : theme.colorScheme.surface;
    final borderColor = isGreyscale
        ? Colors.grey[700]!
        : theme.colorScheme.primary.withValues(alpha: 0.3);

    const panelWidth = 120.0;
    final showReadingButton =
        !ref.watch(accessibilityProvider).showGreyscaleFloatingIcon;
    final panelHeight = showReadingButton ? 350.0 : 280.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      right: isEdgePanelOpen ? 0 : -panelWidth,
      top: (screenHeight - 280.0) /
          2, // Anchor top position based on standard height
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Tab
          Padding(
            padding: const EdgeInsets.only(
                top: (280.0 - 48.0) /
                    2), // Keep handle centered relative to 280px portion
            child: GestureDetector(
              onTap: onToggle,
              onPanUpdate: onPanUpdate,
              child: Container(
                width: 16,
                height: 48,
                decoration: BoxDecoration(
                  color: panelBgColor,
                  border: Border(
                    left: BorderSide(color: borderColor, width: 1),
                    top: BorderSide(color: borderColor, width: 1),
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(8)),
                  boxShadow: [
                    if (!isEdgePanelOpen)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(-2, 0),
                      )
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(
                      color: handleColor.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Expanded Panel Content
          Container(
            width: panelWidth,
            height: panelHeight,
            decoration: BoxDecoration(
              color: panelBgColor,
              border: Border(
                left: BorderSide(color: borderColor, width: 1),
                top: BorderSide(color: borderColor, width: 1),
                bottom: BorderSide(color: borderColor, width: 1),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(-4, 0),
                )
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Text Size Column
                      Column(
                        children: [
                          Icon(Icons.format_size_rounded,
                              color: handleColor, size: 20),
                          const SizedBox(height: 8),
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 2,
                                  activeTrackColor: handleColor,
                                  inactiveTrackColor:
                                      handleColor.withValues(alpha: 0.2),
                                  thumbColor: handleColor,
                                  overlayColor:
                                      handleColor.withValues(alpha: 0.1),
                                ),
                                child: Slider(
                                  value: textSizeFactor,
                                  min: 0.8,
                                  max: 2.0,
                                  onChanged: onTextSizeChanged,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Opacity Column
                      Column(
                        children: [
                          Icon(Icons.opacity_rounded,
                              color: handleColor, size: 20),
                          const SizedBox(height: 8),
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 2,
                                  activeTrackColor: handleColor,
                                  inactiveTrackColor:
                                      handleColor.withValues(alpha: 0.2),
                                  thumbColor: handleColor,
                                  overlayColor:
                                      handleColor.withValues(alpha: 0.1),
                                ),
                                child: Slider(
                                  value: textOpacity,
                                  min: 0.3,
                                  max: 1.0,
                                  onChanged: onTextOpacityChanged,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onReset,
                  style: TextButton.styleFrom(
                    foregroundColor: handleColor,
                    minimumSize: const Size(80, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Reset',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (!ref
                    .watch(accessibilityProvider)
                    .showGreyscaleFloatingIcon) ...[
                  const SizedBox(height: 12),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () {
                      final notifier = ref.read(accessibilityProvider.notifier);
                      notifier.toggleFloatingIcon(true);
                      if (!ref.read(accessibilityProvider).isGreyscaleMode) {
                        notifier.toggleGreyscaleMode();
                      }
                    },
                    icon: Icon(Icons.auto_stories_rounded, color: handleColor),
                    tooltip: 'Enable Read Mode',
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
