import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final String messageType;
  final String? fileUrl;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.messageType = 'text',
    this.fileUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? map['sender_id'] ?? '',
      timestamp: map['timestamp'] is Timestamp 
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] ?? map['created_at']) is String 
              ? DateTime.tryParse(map['timestamp'] ?? map['created_at']) ?? DateTime.now()
              : DateTime.now(),
      messageType: map['messageType'] ?? map['message_type'] ?? 'text',
      fileUrl: map['fileUrl'] ?? map['file_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'fileUrl': fileUrl,
    };
  }

  MessageModel copyWith({
    String? id,
    String? text,
    String? senderId,
    DateTime? timestamp,
    String? messageType,
    String? fileUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}
