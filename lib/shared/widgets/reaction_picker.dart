import 'package:flutter/material.dart';

enum ReactionType {
  heart,
  hugs,
  inspired,
  hearYou,
  proud,
}

extension ReactionTypeExtension on ReactionType {
  String get id => name;

  String get emoji {
    switch (this) {
      case ReactionType.heart:
        return '❤️';
      case ReactionType.hugs:
        return '🤗';
      case ReactionType.inspired:
        return '✨';
      case ReactionType.hearYou:
        return '🫶';
      case ReactionType.proud:
        return '🤍';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.heart:
        return 'Like';
      case ReactionType.hugs:
        return 'Hugs';
      case ReactionType.inspired:
        return 'Inspired';
      case ReactionType.hearYou:
        return 'Support';
      case ReactionType.proud:
        return 'Proud';
    }
  }
}

class ReactionPicker extends StatelessWidget {
  final Function(ReactionType) onReactionSelected;

  const ReactionPicker({Key? key, required this.onReactionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReactionType.values.map((reaction) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onReactionSelected(reaction);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reaction.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reaction.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

void showReactionPicker(BuildContext context, Offset position, Function(ReactionType) onReactionSelected) {
  // Try to constrain the popup to the screen horizontally
  final screenWidth = MediaQuery.of(context).size.width;
  double left = position.dx;
  if (left > screenWidth - 250) {
    left = screenWidth - 250;
  }
  
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          Positioned(
            left: left,
            top: position.dy - 85, // Display above the button
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  alignment: Alignment.bottomLeft,
                  child: ReactionPicker(onReactionSelected: onReactionSelected),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
