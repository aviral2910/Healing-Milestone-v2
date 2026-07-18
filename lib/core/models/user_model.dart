enum UserRole {
  member,
  healthcareProfessional,
  organization,
}

class UserModel {
  final String userId;
  final String email;
  final String? phoneNumber;
  final List<String> likedStories;
  final List<String> bookmarkedStories;
  final List<String> taggedStories;
  final List<String> comments;
  final List<String> ownStories;
  final bool isVerified;
  final String? profilePicture;
  final int followersCount;
  final int followingCount;
  final List<String> followersList;
  final List<String> followingList;
  final String displayName;
  final String? username;
  final UserRole role;
  
  // Professional fields
  final String? specialty;
  final String? licenseNumber;
  
  // Organization fields
  final String? services;
  final String? registrationNumber;
  
  final bool appliedForVerification;

  UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    this.username,
    this.role = UserRole.member,
    this.phoneNumber,
    this.likedStories = const [],
    this.bookmarkedStories = const [],
    this.taggedStories = const [],
    this.comments = const [],
    this.ownStories = const [],
    this.isVerified = false,
    this.profilePicture,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followersList = const [],
    this.followingList = const [],
    this.specialty,
    this.licenseNumber,
    this.services,
    this.registrationNumber,
    this.appliedForVerification = false,
  });

  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    List<String>? likedStories,
    List<String>? bookmarkedStories,
    List<String>? taggedStories,
    List<String>? comments,
    List<String>? ownStories,
    bool? isVerified,
    String? profilePicture,
    int? followersCount,
    int? followingCount,
    List<String>? followersList,
    List<String>? followingList,
    String? displayName,
    String? username,
    UserRole? role,
    String? specialty,
    String? licenseNumber,
    String? services,
    String? registrationNumber,
    bool? appliedForVerification,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      likedStories: likedStories ?? this.likedStories,
      bookmarkedStories: bookmarkedStories ?? this.bookmarkedStories,
      taggedStories: taggedStories ?? this.taggedStories,
      comments: comments ?? this.comments,
      ownStories: ownStories ?? this.ownStories,
      isVerified: isVerified ?? this.isVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      services: services ?? this.services,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      appliedForVerification: appliedForVerification ?? this.appliedForVerification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'likedStories': likedStories,
      'bookmarkedStories': bookmarkedStories,
      'taggedStories': taggedStories,
      'comments': comments,
      'ownStories': ownStories,
      'isVerified': isVerified,
      'profilePicture': profilePicture,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'followersList': followersList,
      'followingList': followingList,
      'displayName': displayName,
      'username': username,
      'role': role.name,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'services': services,
      'registrationNumber': registrationNumber,
      'appliedForVerification': appliedForVerification,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      likedStories: List<String>.from(map['likedStories'] ?? []),
      bookmarkedStories: List<String>.from(map['bookmarkedStories'] ?? []),
      taggedStories: List<String>.from(map['taggedStories'] ?? []),
      comments: List<String>.from(map['comments'] ?? []),
      ownStories: List<String>.from(map['ownStories'] ?? []),
      isVerified: map['isVerified'] ?? false,
      profilePicture: map['profilePicture'],
      followersCount: map['followersCount']?.toInt() ?? 0,
      followingCount: map['followingCount']?.toInt() ?? 0,
      followersList: List<String>.from(map['followersList'] ?? []),
      followingList: List<String>.from(map['followingList'] ?? []),
      displayName: map['displayName'] ?? '',
      username: map['username'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      specialty: map['specialty'],
      licenseNumber: map['licenseNumber'],
      services: map['services'],
      registrationNumber: map['registrationNumber'],
      appliedForVerification: map['appliedForVerification'] ?? false,
    );
  }
}
