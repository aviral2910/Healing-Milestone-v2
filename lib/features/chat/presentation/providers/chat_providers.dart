import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/chat/data/chat_repository.dart';
import 'package:healing_milestones/features/chat/data/models/chat_models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
    apiClient,
  );
});

final activeChatsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.userId == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).watchActiveChats(user.userId!);
});

final pendingRequestsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.userId == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).watchPendingRequests(user.userId!);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).watchMessages(roomId);
});
