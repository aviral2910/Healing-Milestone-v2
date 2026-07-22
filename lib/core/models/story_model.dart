import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

enum StoryType {
  story,
  finding,
  awareness,
}

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
  final Map<String, List<String>> reactions;
  final String authorId;
  final String qrId;
  final int readingTime;
  final List<String> hashtagsList;
  final String verifierId;
  final bool displayAuthorName;
  final List<String> taggedPeople;
  final UserRole authorRole;
  final bool isAuthorVerified;
  final StoryType type;

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
    this.reactions = const {},
    required this.authorId,
    required this.qrId,
    required this.readingTime,
    this.hashtagsList = const [],
    required this.verifierId,
    this.displayAuthorName = true,
    this.taggedPeople = const [],
    this.authorRole = UserRole.member,
    this.isAuthorVerified = false,
    this.type = StoryType.story,
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
    Map<String, List<String>>? reactions,
    String? authorId,
    String? qrId,
    int? readingTime,
    List<String>? hashtagsList,
    String? verifierId,
    bool? displayAuthorName,
    List<String>? taggedPeople,
    UserRole? authorRole,
    bool? isAuthorVerified,
    StoryType? type,
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
      reactions: reactions ?? this.reactions,
      authorId: authorId ?? this.authorId,
      qrId: qrId ?? this.qrId,
      readingTime: readingTime ?? this.readingTime,
      hashtagsList: hashtagsList ?? this.hashtagsList,
      verifierId: verifierId ?? this.verifierId,
      displayAuthorName: displayAuthorName ?? this.displayAuthorName,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      authorRole: authorRole ?? this.authorRole,
      isAuthorVerified: isAuthorVerified ?? this.isAuthorVerified,
      type: type ?? this.type,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'heading': heading,
      'description': description,
      'isVerifiedStory': isVerifiedStory,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'shortDescription': shortDescription,
      'imageAssets': imageAssets,
      'mainImage': mainImage,
      'likesCount': likesCount,
      'likesList': likesList,
      'commentCount': commentCount,
      'comments': comments,
      'reactions': reactions,
      'authorId': authorId,
      'qrId': qrId,
      'readingTime': readingTime,
      'hashtagsList': hashtagsList,
      'verifierId': verifierId,
      'displayAuthorName': displayAuthorName,
      'taggedPeople': taggedPeople,
      'authorRole': authorRole.name,
      'isAuthorVerified': isAuthorVerified,
      'type': type.name,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StoryModel(
      storyId: documentId,
      heading: map['heading'] ?? '',
      description: map['description'] ?? '',
      isVerifiedStory: map['isVerifiedStory'] ?? false,
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      shortDescription: map['shortDescription'] ?? '',
      imageAssets: List<String>.from(map['imageAssets'] ?? []),
      mainImage: map['mainImage'] ?? '',
      likesCount: map['likesCount'] ?? 0,
      likesList: List<String>.from(map['likesList'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      comments: List<String>.from(map['comments'] ?? []),
      reactions: map['reactions'] != null 
          ? (map['reactions'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            )
          : {},
      authorId: map['authorId'] ?? '',
      qrId: map['qrId'] ?? '',
      readingTime: map['readingTime'] ?? 0,
      hashtagsList: List<String>.from(map['hashtagsList'] ?? []),
      verifierId: map['verifierId'] ?? '',
      displayAuthorName: map['displayAuthorName'] ?? true,
      taggedPeople: List<String>.from(map['taggedPeople'] ?? []),
      authorRole: UserRole.values.firstWhere(
        (e) => e.name == map['authorRole'],
        orElse: () => UserRole.member,
      ),
      isAuthorVerified: map['isAuthorVerified'] ?? false,
      type: StoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => StoryType.story,
      ),
    );
  }
}
