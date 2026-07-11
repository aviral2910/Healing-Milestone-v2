class UserModel {
  final String userId;
  final String email;
  final String? phoneNumber;
  final List<String> likedStories;
  final List<String> bookmarkedStories;
  final List<String> comments;
  final List<String> ownStories;
  final bool isVerified;
  final String? profilePicture;
  final int followersCount;
  final int followingCount;
  final List<String> followersList;
  final List<String> followingList;
  final String userName;

  UserModel({
    required this.userId,
    required this.email,
    required this.userName,
    this.phoneNumber,
    this.likedStories = const [],
    this.bookmarkedStories = const [],
    this.comments = const [],
    this.ownStories = const [],
    this.isVerified = false,
    this.profilePicture,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followersList = const [],
    this.followingList = const [],
  });

  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    List<String>? likedStories,
    List<String>? bookmarkedStories,
    List<String>? comments,
    List<String>? ownStories,
    bool? isVerified,
    String? profilePicture,
    int? followersCount,
    int? followingCount,
    List<String>? followersList,
    List<String>? followingList,
    String? userName,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      likedStories: likedStories ?? this.likedStories,
      bookmarkedStories: bookmarkedStories ?? this.bookmarkedStories,
      comments: comments ?? this.comments,
      ownStories: ownStories ?? this.ownStories,
      isVerified: isVerified ?? this.isVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
    );
  }
}
