import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';

final draftAutoSaveProvider = NotifierProvider<DraftAutoSaveNotifier, bool>(() {
  return DraftAutoSaveNotifier();
});

class DraftAutoSaveNotifier extends Notifier<bool> {
  String? _userId;

  String get _autoSaveKey => _userId != null ? 'draft_auto_save_enabled_$_userId' : 'draft_auto_save_enabled';

  @override
  bool build() {
    _userId = ref.watch(currentUserProvider)?.userId;
    _loadPreference();
    return false;
  }

  Future<void> _loadPreference() async {
    if (_userId == null) {
      state = false;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_autoSaveKey) ?? false;
  }

  Future<void> toggleAutoSave(bool isEnabled) async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, isEnabled);
    state = isEnabled;
  }
}
