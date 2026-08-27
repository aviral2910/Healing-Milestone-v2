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
  final Map<String, int> reactionCounts;
  final String? currentUserReaction;
  final String authorId;
  final String qrId;
  final int readingTime;
  final List<String> hashtagsList;
  final String verifierId;
  final bool displayAuthorName;
  final List<UserModel> taggedUsers;
  final UserModel? author;
  final UserRole authorRole;
  final bool isAuthorVerified;
  final StoryType type;
  final String verificationStatus; // 'none', 'pending', 'verified', 'rejected'
  final bool isHidden;

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
    this.reactionCounts = const {},
    this.currentUserReaction,
    required this.authorId,
    required this.qrId,
    required this.readingTime,
    this.hashtagsList = const [],
    required this.verifierId,
    this.displayAuthorName = true,
    this.taggedUsers = const [],
    this.author,
    this.authorRole = UserRole.member,
    this.isAuthorVerified = false,
    this.type = StoryType.story,
    this.verificationStatus = 'none',
    this.isHidden = false,
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
    Map<String, int>? reactionCounts,
    String? currentUserReaction,
    String? authorId,
    String? qrId,
    int? readingTime,
    List<String>? hashtagsList,
    String? verifierId,
    bool? displayAuthorName,
    List<UserModel>? taggedUsers,
    UserModel? author,
    UserRole? authorRole,
    bool? isAuthorVerified,
    StoryType? type,
    String? verificationStatus,
    bool? isHidden,
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
      reactionCounts: reactionCounts ?? this.reactionCounts,
      currentUserReaction: currentUserReaction ?? this.currentUserReaction,
      authorId: authorId ?? this.authorId,
      qrId: qrId ?? this.qrId,
      readingTime: readingTime ?? this.readingTime,
      hashtagsList: hashtagsList ?? this.hashtagsList,
      verifierId: verifierId ?? this.verifierId,
      displayAuthorName: displayAuthorName ?? this.displayAuthorName,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      author: author ?? this.author,
      authorRole: authorRole ?? this.authorRole,
      isAuthorVerified: isAuthorVerified ?? this.isAuthorVerified,
      type: type ?? this.type,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isHidden: isHidden ?? this.isHidden,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'heading': heading,
      'description': description,
      'isVerifiedStory': isVerifiedStory,
      'publishedAt': publishedAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'shortDescription': shortDescription,
      'imageAssets': imageAssets,
      'mainImage': mainImage,
      'likesCount': likesCount,
      'likesList': likesList,
      'commentCount': commentCount,
      'comments': comments,
      'reactionCounts': reactionCounts,
      'currentUserReaction': currentUserReaction,
      'authorId': authorId,
      'qrId': qrId,
      'readingTime': readingTime,
      'hashtagsList': hashtagsList,
      'verifierId': verifierId,
      'displayAuthorName': displayAuthorName,
      'taggedUsers': taggedUsers.map((u) => u.toMap()).toList(),
      'author': author?.toMap(),
      'authorRole': authorRole.name,
      'isAuthorVerified': isAuthorVerified,
      'type': type.name,
      'verificationStatus': verificationStatus,
      'isHidden': isHidden,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StoryModel(
      storyId: documentId,
      heading: map['heading'] ?? '',
      description: map['description'] ?? '',
      isVerifiedStory: map['isVerifiedStory'] ?? map['is_verified_story'] ?? false,
      publishedAt: (map['publishedAt'] ?? map['published_at']) is Timestamp ? ((map['publishedAt'] ?? map['published_at']) as Timestamp).toDate() : ((map['publishedAt'] ?? map['published_at']) is String ? (DateTime.tryParse(map['publishedAt'] ?? map['published_at']) ?? DateTime.now()) : DateTime.now()),
      verifiedAt: (map['verifiedAt'] ?? map['verified_at']) is Timestamp ? ((map['verifiedAt'] ?? map['verified_at']) as Timestamp).toDate() : ((map['verifiedAt'] ?? map['verified_at']) is String ? DateTime.tryParse(map['verifiedAt'] ?? map['verified_at']) : null),
      shortDescription: map['shortDescription'] ?? map['short_description'] ?? '',
      imageAssets: List<String>.from(map['imageAssets'] ?? map['image_assets'] ?? []),
      mainImage: map['mainImage'] ?? map['main_image'] ?? '',
      likesCount: map['likesCount'] ?? map['likes_count'] ?? 0,
      likesList: List<String>.from(map['likesList'] ?? map['likes_list'] ?? []),
      commentCount: map['commentCount'] ?? map['comment_count'] ?? 0,
      comments: List<String>.from(map['comments'] ?? []),
      reactionCounts: (map['reactionCounts'] != null || map['reaction_counts'] != null)
          ? ((map['reactionCounts'] ?? map['reaction_counts']) as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as int),
            )
          : {},
      currentUserReaction: map['userReaction'] ?? map['current_user_reaction'] ?? map['user_reaction'],
      authorId: map['authorId'] ?? map['author_id'] ?? '',
      qrId: map['qrId'] ?? map['qr_id'] ?? '',
      readingTime: map['readingTime'] ?? map['reading_time'] ?? 0,
      hashtagsList: List<String>.from(map['hashtagsList'] ?? map['tags'] ?? []),
      verifierId: map['verifierId'] ?? map['verifier_id'] ?? '',
      displayAuthorName: map['displayAuthorName'] ?? map['display_author_name'] ?? true,
      taggedUsers: map['taggedUsers'] != null || map['tagged_users'] != null
          ? List<UserModel>.from(
              (map['taggedUsers'] ?? map['tagged_users'] as List? ?? [])
                  .map((x) => UserModel.fromMap(x as Map<String, dynamic>)))
          : [],
      author: map['author'] != null ? UserModel.fromMap(map['author'] as Map<String, dynamic>) : null,
      authorRole: () {
        final r = map['authorRole'] ?? map['author_role'] ?? (map['author'] != null ? map['author']['role'] : null);
        print("StoryModel Parsing ID: ${map['id']} | Found Role String: $r");
        return UserRole.values.firstWhere(
          (e) => e.name == r,
          orElse: () => UserRole.member,
        );
      }(),
      isAuthorVerified: map['isAuthorVerified'] ?? map['is_author_verified'] ?? (map['author'] != null ? map['author']['is_verified'] : false) ?? false,
      type: StoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => StoryType.story,
      ),
      verificationStatus: map['verificationStatus'] ?? map['verification_status'] ?? 'none',
      isHidden: map['isHidden'] ?? map['is_hidden'] ?? false,
    );
  }
}
