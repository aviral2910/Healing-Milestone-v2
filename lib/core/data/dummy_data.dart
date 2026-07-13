import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/story_model.dart';
import '../models/category_model.dart';
import '../models/educational_content_model.dart';

final dummyUserProvider = Provider<UserModel>((ref) {
  return UserModel(
    userId: 'u1',
    email: 'user@example.com',
    userName: 'Aviral Dixit',
    phoneNumber: '+1234567890',
    isVerified: true,
    ownStories: ['s1'],
    likedStories: [],
    taggedStories: ['s2', 's3', 's5'],
    bookmarkedStories: ['s4'],
    followersCount: 1205,
    followingCount: 84,
    followersList: ['user_x', 'user_y', 'user_z'],
    followingList: ['user_a', 'user_b'],
    role: UserRole.author,
  );
});

final dummyStoriesProvider = Provider<List<StoryModel>>((ref) {
  return [
    StoryModel(
      storyId: 's1',
      heading: 'The First Steps After Surgery',
      description:
          'They told me I might not walk again without assistance. The first few days after the surgery were a blur of pain medication and sheer exhaustion. Every single movement felt like trying to lift a boulder. But on day four, my physical therapist, Sarah, came in and said, "Today, we try." \n\nI managed exactly three steps. It doesn\'t sound like much, but when you\'ve spent weeks staring at a ceiling wondering if your life as you knew it was over, three steps feel like running a marathon. I am documenting this so I never forget how those three steps felt.',
      shortDescription: 'Taking my first steps against all odds.',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      mainImage: 'https://picsum.photos/seed/s1/400/600',
      authorId: 'a1',
      qrId: 'qr1',
      readingTime: 3,
      hashtagsList: ['recovery', 'milestone', 'surgery', 'physicaltherapy', 'nevergiveup', 'healingjourney', 'dayfour'],
      verifierId: 'v1',
      isVerifiedStory: true,
      authorRole: UserRole.author,
      isAuthorVerified: true,
    ),
    StoryModel(
      storyId: 's2',
      heading: 'Finding Light in the Darkness',
      description:
          '"Healing is not a straight line; it is a spiral. You will touch the same painful points again, but from a different perspective." \n\nI read this quote a year ago when my diagnosis was fresh, and I was consumed by anger. Today, I finally understand it. The bad days still come, but they don\'t consume me anymore. I have learned to sit with the discomfort instead of fighting it. To anyone currently in the darkest part of their spiral: hold on. The view from higher up is worth the climb.',
      shortDescription: 'Embracing the spiral of healing.',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      mainImage: 'https://picsum.photos/seed/s2/400/600',
      authorId: 'a2',
      qrId: 'qr2',
      readingTime: 4,
      hashtagsList: ['mentalhealth', 'chronicillness', 'hope'],
      verifierId: 'v1',
      isVerifiedStory: true,
      authorRole: UserRole.healthcareProfessional,
      isAuthorVerified: true,
      type: StoryType.finding,
    ),
    StoryModel(
      storyId: 's3',
      heading: 'One Year Remission Anniversary',
      description:
          'Exactly one year ago today, I got the phone call that changed everything: "The scans are clear." I remember collapsing on the kitchen floor and just sobbing until I couldn\'t breathe. \n\nThe year since has been about rebuilding. Cancer doesn\'t just attack your body; it dismantles your sense of safety in the world. I\'ve had to relearn how to trust my own body, how to plan for a future I was previously terrified to imagine, and how to live without holding my breath for the next shoe to drop. Today, I am breathing deeply.',
      shortDescription: 'Rebuilding life one year after remission.',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      mainImage: 'https://picsum.photos/seed/s3/400/600',
      authorId: 'a3',
      qrId: 'qr3',
      readingTime: 5,
      hashtagsList: ['cancer', 'remission', 'anniversary'],
      verifierId: 'v1',
      isVerifiedStory: true,
      authorRole: UserRole.organization,
      isAuthorVerified: true,
      type: StoryType.awareness,
    ),
    StoryModel(
      storyId: 's4',
      heading: 'The Silent Battle of Chronic Illness',
      description:
          'Living with an invisible illness means spending half your energy managing symptoms and the other half convincing people you actually have them. The exhaustion is profound.\n\nBut this community has been a lifeline. Knowing that there are others out there who understand exactly what it means to calculate the "energy cost" of taking a shower has made me feel so much less alone. We might be fighting invisible battles, but we see each other.',
      shortDescription: 'The hidden exhaustion of chronic illness.',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      mainImage: 'https://picsum.photos/seed/s4/400/600',
      authorId: 'a4',
      qrId: 'qr4',
      readingTime: 3,
      hashtagsList: ['invisibleillness', 'spoonie', 'community'],
      verifierId: 'v1',
      isVerifiedStory: false,
      authorRole: UserRole.reader,
      isAuthorVerified: false,
    ),
    StoryModel(
      storyId: 's5',
      heading: 'A Thought on Healing (Text Only)',
      description:
          'Sometimes, you don\'t need a picture to capture how you feel. Today was a quiet day, filled with small, unseen victories. I managed to sit outside for 10 minutes without feeling overwhelmed. It\'s not much, but to me, it\'s a mountain conquered.\n\nHere\'s to the small wins that don\'t make for glamorous photos, but build the foundation of our recovery.',
      shortDescription: 'Celebrating small, unseen victories.',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      mainImage: '',
      imageAssets: [],
      authorId: 'a1', // Same author as s1 to test journey series
      qrId: 'qr5',
      readingTime: 2,
      hashtagsList: ['smallwins', 'healingjourney', 'mentalhealth'],
      verifierId: 'v1',
      isVerifiedStory: false,
      authorRole: UserRole.author,
      isAuthorVerified: true,
    ),
  ];
});

final dummyCategoriesProvider = Provider<List<CategoryListModel>>((ref) {
  return [
    CategoryListModel(
      categoryId: 'c1',
      categoryName: 'Trending Stories',
      storyCount: 2,
      storiesList: ['s1', 's2'],
    ),
    CategoryListModel(
      categoryId: 'c2',
      categoryName: 'Miracle Recoveries',
      storyCount: 2,
      storiesList: ['s3', 's4'],
    ),
  ];
});

final dummyEduContentProvider = Provider<List<EducationalContentModel>>((ref) {
  return [
    EducationalContentModel(
      contentId: 'e1',
      title: 'Managing Post-Surgery Pain',
      description: 'A comprehensive guide on managing pain after major surgeries.',
      type: EducationalContentType.video,
      url: 'https://example.com/video1',
      doctorId: 'd1',
      doctorName: 'Dr. Sarah Jenkins',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      thumbnailUrl: 'https://picsum.photos/seed/e1/400/300',
    ),
    EducationalContentModel(
      contentId: 'e2',
      title: 'Nutrition for Recovery',
      description: 'PDF guide on essential nutrients for healing tissues.',
      type: EducationalContentType.pdf,
      url: 'https://example.com/pdf1',
      doctorId: 'd2',
      doctorName: 'Dr. Robert Chen',
      publishedAt: DateTime.now().subtract(const Duration(days: 10)),
      thumbnailUrl: 'https://picsum.photos/seed/e2/400/300',
    ),
    EducationalContentModel(
      contentId: 'e3',
      title: 'Mental Health in Chronic Illness',
      description: 'Live webinar recording discussing mental health strategies.',
      type: EducationalContentType.webinar,
      url: 'https://example.com/webinar1',
      doctorId: 'd3',
      doctorName: 'Dr. Emily Santos',
      publishedAt: DateTime.now().subtract(const Duration(days: 12)),
      thumbnailUrl: 'https://picsum.photos/seed/e3/400/300',
    ),
  ];
});
