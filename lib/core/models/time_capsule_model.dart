class TimeCapsuleModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? mediaUrl;
  final String? audioUrl;
  final DateTime unlockDate;
  final DateTime createdAt;
  final bool isOpened;

  TimeCapsuleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.audioUrl,
    required this.unlockDate,
    required this.createdAt,
    required this.isOpened,
  });

  factory TimeCapsuleModel.fromJson(Map<String, dynamic> json) {
    return TimeCapsuleModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? 'Untitled Capsule',
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      unlockDate: DateTime.parse(json['unlockDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOpened: json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'mediaUrl': mediaUrl,
      'audioUrl': audioUrl,
      'unlockDate': unlockDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isOpened': isOpened,
    };
  }

  bool get isLocked => DateTime.now().isBefore(unlockDate);
}
