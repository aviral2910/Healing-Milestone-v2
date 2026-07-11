class StoryModel {
  final String storyId;
  final String heading;
  final String description;
  final bool isVerifiedStory;
  final DateTime publishedAt;
  final DateTime? verifiedAt;
  final String shortDescription;
  final List<String> imageAssets;
  final String mainImage;
  final int likesCount;
  final List<String> likesList;
  final int commentCount;
  final List<String> comments;
  final String authorId;
  final String qrId;
  final int readingTime;
  final List<String> hashtagsList;
  final String verifierId;
  final bool displayAuthorName;
  final List<String> taggedPeople;


  StoryModel({
    required this.storyId,
    required this.heading,
    required this.description,
    this.isVerifiedStory = false,
    required this.publishedAt,
    this.verifiedAt,
    required this.shortDescription,
    this.imageAssets = const [],
    required this.mainImage,
    this.likesCount = 0,
    this.likesList = const [],
    this.commentCount = 0,
    this.comments = const [],
    required this.authorId,
    required this.qrId,
    required this.readingTime,
    this.hashtagsList = const [],
    required this.verifierId,
    this.displayAuthorName = true,
    this.taggedPeople = const [],
  });

  StoryModel copyWith({
    String? storyId,
    String? heading,
    String? description,
    bool? isVerifiedStory,
    DateTime? publishedAt,
    DateTime? verifiedAt,
    String? shortDescription,
    List<String>? imageAssets,
    String? mainImage,
    int? likesCount,
    List<String>? likesList,
    int? commentCount,
    List<String>? comments,
    String? authorId,
    String? qrId,
    int? readingTime,
    List<String>? hashtagsList,
    String? verifierId,
    bool? displayAuthorName,
    List<String>? taggedPeople,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      heading: heading ?? this.heading,
      description: description ?? this.description,
      isVerifiedStory: isVerifiedStory ?? this.isVerifiedStory,
      publishedAt: publishedAt ?? this.publishedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      shortDescription: shortDescription ?? this.shortDescription,
      imageAssets: imageAssets ?? this.imageAssets,
      mainImage: mainImage ?? this.mainImage,
      likesCount: likesCount ?? this.likesCount,
      likesList: likesList ?? this.likesList,
      commentCount: commentCount ?? this.commentCount,
      comments: comments ?? this.comments,
      authorId: authorId ?? this.authorId,
      qrId: qrId ?? this.qrId,
      readingTime: readingTime ?? this.readingTime,
      hashtagsList: hashtagsList ?? this.hashtagsList,
      verifierId: verifierId ?? this.verifierId,
      displayAuthorName: displayAuthorName ?? this.displayAuthorName,
      taggedPeople: taggedPeople ?? this.taggedPeople,
    );
  }
}
