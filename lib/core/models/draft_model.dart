import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/models/user_model.dart';

class DraftModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final StoryType type;
  final bool isAnonymous;
  final String? imagePath;
  final List<UserModel> selectedUsers;
  final DateTime lastSaved;

  DraftModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.type,
    required this.isAnonymous,
    this.imagePath,
    required this.selectedUsers,
    required this.lastSaved,
  });

  DraftModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    StoryType? type,
    bool? isAnonymous,
    String? imagePath,
    List<UserModel>? selectedUsers,
    DateTime? lastSaved,
  }) {
    return DraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      imagePath: imagePath ?? this.imagePath,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'type': type.name,
      'isAnonymous': isAnonymous,
      'imagePath': imagePath,
      'selectedUsers': selectedUsers.map((u) => u.toMap()).toList(),
      'lastSaved': lastSaved.toIso8601String(),
    };
  }

  factory DraftModel.fromMap(Map<String, dynamic> map) {
    return DraftModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      type: StoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => StoryType.story,
      ),
      isAnonymous: map['isAnonymous'] ?? false,
      imagePath: map['imagePath'],
      selectedUsers: (map['selectedUsers'] as List<dynamic>?)
              ?.map((e) => UserModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastSaved: map['lastSaved'] != null
          ? DateTime.parse(map['lastSaved'])
          : DateTime.now(),
    );
  }
}
