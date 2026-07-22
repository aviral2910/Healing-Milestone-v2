import 'package:flutter/material.dart';
import 'package:healing_milestones/shared/widgets/reaction_picker.dart';

class ReactionCluster extends StatelessWidget {
  final List<ReactionType> topReactions;
  final int totalCount;

  const ReactionCluster({
    Key? key,
    required this.topReactions,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topReactions.isEmpty && totalCount == 0) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topReactions.isNotEmpty)
          SizedBox(
            width: (topReactions.length * 14.0) + 4.0,
            height: 20,
            child: Stack(
              children: List.generate(topReactions.length, (index) {
                return Positioned(
                  left: index * 12.0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        topReactions[index].emoji,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                );
              }).reversed.toList(), // Reverse so first is on top
            ),
          ),
        if (topReactions.isNotEmpty) const SizedBox(width: 4),
        Text(
          totalCount.toString(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
