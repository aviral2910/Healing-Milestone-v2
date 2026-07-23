import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healing_milestones/core/models/draft_model.dart';

import 'package:healing_milestones/features/auth/data/auth_provider.dart';

final draftsProvider = StateNotifierProvider<DraftsNotifier, List<DraftModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  return DraftsNotifier(userId: user?.userId);
});

class DraftsNotifier extends StateNotifier<List<DraftModel>> {
  final String? userId;
  
  String get _draftsKey => userId != null ? 'saved_drafts_$userId' : 'saved_drafts';

  DraftsNotifier({this.userId}) : super([]) {
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    if (userId == null) {
      state = [];
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getStringList(_draftsKey) ?? [];
      final loadedDrafts = draftsJson
          .map((jsonStr) => DraftModel.fromMap(jsonDecode(jsonStr)))
          .toList();
      loadedDrafts.sort((a, b) => b.lastSaved.compareTo(a.lastSaved));
      state = loadedDrafts;
    } catch (e) {
      print('Error loading drafts: $e');
    }
  }

  Future<void> saveDraft(DraftModel draft) async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    
    final updatedDrafts = List<DraftModel>.from(state);
    final index = updatedDrafts.indexWhere((d) => d.id == draft.id);
    
    if (index >= 0) {
      updatedDrafts[index] = draft;
    } else {
      updatedDrafts.insert(0, draft);
    }
    
    updatedDrafts.sort((a, b) => b.lastSaved.compareTo(a.lastSaved));
    
    final draftsJson = updatedDrafts
        .map((d) => jsonEncode(d.toMap()))
        .toList();
    
    await prefs.setStringList(_draftsKey, draftsJson);
    state = updatedDrafts;
  }

  Future<void> deleteDraft(String id) async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    
    final updatedDrafts = List<DraftModel>.from(state)..removeWhere((d) => d.id == id);
    
    final draftsJson = updatedDrafts
        .map((d) => jsonEncode(d.toMap()))
        .toList();
    
    await prefs.setStringList(_draftsKey, draftsJson);
    state = updatedDrafts;
  }

  Future<void> deleteDrafts(Set<String> ids) async {
    if (userId == null || ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    
    final updatedDrafts = List<DraftModel>.from(state)..removeWhere((d) => ids.contains(d.id));
    
    final draftsJson = updatedDrafts
        .map((d) => jsonEncode(d.toMap()))
        .toList();
    
    await prefs.setStringList(_draftsKey, draftsJson);
    state = updatedDrafts;
  }
}
