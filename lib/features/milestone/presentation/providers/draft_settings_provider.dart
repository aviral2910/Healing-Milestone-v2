import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';

final draftAutoSaveProvider = StateNotifierProvider<DraftAutoSaveNotifier, bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return DraftAutoSaveNotifier(userId: user?.userId);
});

class DraftAutoSaveNotifier extends StateNotifier<bool> {
  final String? userId;

  String get _autoSaveKey => userId != null ? 'draft_auto_save_enabled_$userId' : 'draft_auto_save_enabled';

  DraftAutoSaveNotifier({this.userId}) : super(false) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    if (userId == null) {
      state = false;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_autoSaveKey) ?? false;
  }

  Future<void> toggleAutoSave(bool isEnabled) async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, isEnabled);
    state = isEnabled;
  }
}
