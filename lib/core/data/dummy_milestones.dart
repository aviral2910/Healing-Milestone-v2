import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone.dart';

final dummyMilestonesProvider = Provider<List<Milestone>>((ref) {
  return [
    Milestone(
      milestoneId: '1',
      authorId: 'a1',
      title: 'The First Steps After Surgery',
      content:
          'They told me I might not walk again without assistance. The first few days after the surgery were a blur of pain medication and sheer exhaustion. Every single movement felt like trying to lift a boulder. But on day four, my physical therapist, Sarah, came in and said, "Today, we try." \n\nI managed exactly three steps. It doesn\'t sound like much, but when you\'ve spent weeks staring at a ceiling wondering if your life as you knew it was over, three steps feel like running a marathon. I am documenting this so I never forget how those three steps felt.',
      templateStyle: 'minimalist',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Milestone(
      milestoneId: '2',
      authorId: 'a2',
      title: 'Finding Light in the Darkness',
      content:
          '"Healing is not a straight line; it is a spiral. You will touch the same painful points again, but from a different perspective." \n\nI read this quote a year ago when my diagnosis was fresh, and I was consumed by anger. Today, I finally understand it. The bad days still come, but they don\'t consume me anymore. I have learned to sit with the discomfort instead of fighting it. To anyone currently in the darkest part of their spiral: hold on. The view from higher up is worth the climb.',
      templateStyle: 'classicQuote',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Milestone(
      milestoneId: '3',
      authorId: 'a3',
      title: 'One Year Remission Anniversary',
      content:
          'Exactly one year ago today, I got the phone call that changed everything: "The scans are clear." I remember collapsing on the kitchen floor and just sobbing until I couldn\'t breathe. \n\nThe year since has been about rebuilding. Cancer doesn\'t just attack your body; it dismantles your sense of safety in the world. I\'ve had to relearn how to trust my own body, how to plan for a future I was previously terrified to imagine, and how to live without holding my breath for the next shoe to drop. Today, I am breathing deeply.',
      templateStyle: 'glassmorphism',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Milestone(
      milestoneId: '4',
      authorId: 'a4',
      title: 'The Silent Battle of Chronic Illness',
      content:
          'Living with an invisible illness means spending half your energy managing symptoms and the other half convincing people you actually have them. The exhaustion is profound.\n\nBut this community has been a lifeline. Knowing that there are others out there who understand exactly what it means to calculate the "energy cost" of taking a shower has made me feel so much less alone. We might be fighting invisible battles, but we see each other.',
      templateStyle: 'glassmorphism',
      isVerified: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});
