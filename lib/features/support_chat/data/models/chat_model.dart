import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String type;
  final String lastMessage;
  final DateTime lastUpdated;
  final Map<String, int> unreadCount;
  final Map<String, bool> typingStatus;

  ChatModel({
    required this.id,
    required this.participants,
    required this.type,
    required this.lastMessage,
    required this.lastUpdated,
    required this.unreadCount,
    required this.typingStatus,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      type: map['type'] ?? 'support',
      lastMessage: map['lastMessage'] ?? '',
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : map['lastUpdated'] is String
              ? DateTime.tryParse(map['lastUpdated']) ?? DateTime.now()
              : DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      typingStatus: Map<String, bool>.from(map['typingStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'type': type,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated.toIso8601String(),
      'unreadCount': unreadCount,
      'typingStatus': typingStatus,
    };
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? type,
    String? lastMessage,
    DateTime? lastUpdated,
    Map<String, int>? unreadCount,
    Map<String, bool>? typingStatus,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      type: type ?? this.type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      unreadCount: unreadCount ?? this.unreadCount,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }
}
