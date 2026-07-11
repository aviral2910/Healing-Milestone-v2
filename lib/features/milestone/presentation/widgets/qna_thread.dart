import 'package:flutter/material.dart';
import '../../../../core/models/story_model.dart';

class QnAThread extends StatelessWidget {
  final StoryModel milestone;

  const QnAThread({Key? key, required this.milestone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Current user constraint check for replies
    const currentUserId = 'a1';
    final canReply = (currentUserId == milestone.authorId);

    // Dummy Questions
    final dummyQuestions = [
      {
        'asker': 'Sarah',
        'question': 'Did you have physical therapy every day?',
        'reply': 'Yes! It was tough but entirely worth it. 5 days a week.',
      },
      {
        'asker': 'Mike',
        'question': 'How did you manage the pain at night?',
        'reply': null,
      }
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyQuestions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final q = dummyQuestions[index];
        final hasReply = q['reply'] != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Bubble
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1E1E1E),
                  radius: 18,
                  child: Text(q['asker']![0], style: const TextStyle(color: Color(0xFFF5F5F7), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q['asker']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA1A1A6))),
                        const SizedBox(height: 6),
                        Text(q['question']!, style: const TextStyle(color: Color(0xFFF5F5F7), height: 1.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Reply Bubble
            if (hasReply)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Author', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                            const SizedBox(height: 6),
                            Text(q['reply']!, style: const TextStyle(color: Color(0xFFF5F5F7), height: 1.3), textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Reply TextField (Constraint Enforced)
            if (!hasReply && canReply)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 12),
                child: TextField(
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(color: Color(0xFFF5F5F7)),
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    hintStyle: const TextStyle(color: Color(0xFFA1A1A6)),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_upward_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF151515),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24), 
                      borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24), 
                      borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24), 
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
