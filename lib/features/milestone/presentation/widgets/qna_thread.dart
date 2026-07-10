import 'package:flutter/material.dart';
import '../../../../core/models/milestone.dart';

class QnAThread extends StatelessWidget {
  final Milestone milestone;

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
                  backgroundColor: const Color(0xFF242424),
                  child: Text(q['asker']![0], style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF242424),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q['asker']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00F0FF))),
                        const SizedBox(height: 4),
                        Text(q['question']!, style: const TextStyle(color: Colors.white)),
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
                          color: const Color(0xFF00FF88).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
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
                            const Text('Author', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00FF88))),
                            const SizedBox(height: 4),
                            Text(q['reply']!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.right),
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
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: const Icon(Icons.send, color: Color(0xFF00F0FF)),
                    filled: true,
                    fillColor: const Color(0xFF141414),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
