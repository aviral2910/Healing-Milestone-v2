import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../../auth/data/auth_provider.dart';

final supportChatIdProvider = FutureProvider.autoDispose<String>((ref) async {
  final userId = ref.watch(currentUserProvider.select((user) => user?.userId));
  if (userId == null) throw Exception('User not logged in');
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getOrCreateSupportChat(userId);
});

final supportChatStreamProvider = StreamProvider.autoDispose.family<ChatModel?, String>((ref, String chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatStream(chatId);
});

final supportChatMessagesProvider = StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, String chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessagesStream(chatId);
});
