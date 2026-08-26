import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

// Because Firestore returns Timestamps and we want DateTime, we need a custom converter
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    return DateTime.now();
  }

  @override
  Object toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}

@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    @Default([]) List<String> participants,
    required String type, // "peer" or "support"
    required String status, // "pending", "accepted", "declined"
    required String initiatorId,
    @Default("") String lastMessageText,
    @TimestampConverter() DateTime? lastMessageTime,
    @Default({}) Map<String, int> unreadCount,
    @TimestampConverter() DateTime? createdAt,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ChatRoom.fromJson(data);
  }
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    String? text,
    String? imageUrl,
    String? sharedJourneyId,
    String? sharedStoryId,
    @TimestampConverter() DateTime? createdAt,
    @Default([]) List<String> readBy,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ChatMessage.fromJson(data);
  }
}
