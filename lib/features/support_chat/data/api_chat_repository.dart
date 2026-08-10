import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'models/chat_model.dart';
import 'models/message_model.dart';

final apiChatRepositoryProvider = Provider<ApiChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiChatRepository(apiClient);
});

class ApiChatRepository {
  final ApiClient _apiClient;
  
  ApiChatRepository(this._apiClient);
  
  Dio get _dio => _apiClient.dio;
  
  String get _wsBaseUrl {
    return 'wss://healing-milestones-api.onrender.com';
  }

  WebSocketChannel? _channel;
  
  final _messagesController = StreamController<List<MessageModel>>.broadcast();
  List<MessageModel> _currentMessages = [];

  Future<String> getOrCreateSupportChat(String userId) async {
    try {
      final response = await _dio.post('/api/chat/start');
      return response.data['chat_id'];
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }

  Stream<ChatModel?> getChatStream(String chatId) async* {
    final fakeChat = ChatModel(
      id: chatId,
      participants: [FirebaseAuth.instance.currentUser?.uid ?? '', 'admin'],
      type: 'support',
      lastMessage: '',
      lastUpdated: DateTime.now(),
      unreadCount: {},
      typingStatus: {},
    );
    yield fakeChat;
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    _fetchInitialMessages(chatId);
    _connectWebSocket(chatId);
    return _messagesController.stream;
  }
  
  Future<void> _fetchInitialMessages(String chatId) async {
    try {
      final response = await _dio.get('/api/chat/$chatId/messages');
      final items = response.data['items'] as List;
      _currentMessages = items.map((json) => MessageModel.fromMap(json, json['id'])).toList();
      _messagesController.add(List.from(_currentMessages));
    } catch (e) {
      print('Error fetching initial messages: $e');
    }
  }
  
  Future<void> _connectWebSocket(String chatId) async {
    _channel?.sink.close();
    
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;
    
    final wsUrl = '$_wsBaseUrl/api/chat/ws/$chatId?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    _channel!.stream.listen((messageData) {
      try {
        final json = jsonDecode(messageData);
        final newMessage = MessageModel.fromMap(json, json['id']);
        
        _currentMessages.insert(0, newMessage);
        _messagesController.add(List.from(_currentMessages));
      } catch (e) {
        print('Error parsing WS message: $e');
      }
    }, onError: (error) {
      print('WebSocket Error: $error');
    }, onDone: () {
      print('WebSocket Closed');
    });
  }

  Future<void> sendMessage(String chatId, MessageModel message, {String? recipientId}) async {
    if (_channel != null) {
      _channel!.sink.add(message.text);
    }
  }

  Future<void> clearUnreadCount(String chatId, String userId) async {}

  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping) async {}

  Future<String> uploadImage(String chatId, File imageFile) async {
    print("Image upload not supported via API yet");
    return "";
  }
  
  void dispose() {
    _channel?.sink.close();
    _messagesController.close();
  }
}
