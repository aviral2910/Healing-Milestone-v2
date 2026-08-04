import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/story_model.dart';
import '../../../../core/models/draft_model.dart';
import 'drafts_provider.dart';
import 'draft_settings_provider.dart';

part 'post_creation_state.freezed.dart';
part 'post_creation_state.g.dart';

@freezed
class PostCreationState with _$PostCreationState {
  const factory PostCreationState({
    @Default('') String title,
    @Default('') String content,
    @Default([]) List<String> tags,
    @Default([]) List<UserModel> selectedUsers,
    String? imagePath,
    @Default(false) bool isAnonymous,
    String? draftId,
    @Default(StoryType.story) StoryType type,
    @Default(false) bool isEditing,
    String? originalStoryId,
  }) = _PostCreationState;

  factory PostCreationState.fromStory(StoryModel story) {
    return PostCreationState(
      title: story.heading,
      content: story.description,
      tags: List.from(story.hashtagsList),
      isAnonymous: !story.displayAuthorName,
      type: story.type,
      isEditing: true,
      originalStoryId: story.storyId,
      imagePath: story.mainImage.isNotEmpty ? story.mainImage : null,
    );
  }

  factory PostCreationState.fromDraft(DraftModel draft) {
    return PostCreationState(
      title: draft.title,
      content: draft.content,
      tags: List.from(draft.tags),
      selectedUsers: List.from(draft.selectedUsers),
      isAnonymous: draft.isAnonymous,
      type: draft.type,
      draftId: draft.id,
      imagePath: draft.imagePath,
    );
  }
}

@Riverpod(keepAlive: true)
class PostCreationController extends _$PostCreationController {
  Timer? _debounceTimer;

  @override
  PostCreationState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const PostCreationState();
  }

  void _scheduleSave() {
    if (state.isEditing) return;

    final autoSaveEnabled = ref.read(draftAutoSaveProvider);
    if (!autoSaveEnabled) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final title = state.title.trim();
    final content = state.content.trim();
    if (title.isEmpty && content.isEmpty) return;

    final draftId = state.draftId ?? const Uuid().v4();
    if (state.draftId == null) {
      state = state.copyWith(draftId: draftId);
    }

    final draft = DraftModel(
      id: draftId,
      title: title,
      content: content,
      tags: state.tags,
      type: state.type,
      isAnonymous: state.isAnonymous,
      imagePath: state.imagePath,
      selectedUsers: state.selectedUsers,
      lastSaved: DateTime.now(),
    );

    await ref.read(draftsProvider.notifier).saveDraft(draft);
  }

  Future<void> saveDraftManually() async {
    _debounceTimer?.cancel();
    await _saveDraft();
  }

  void initializeWithStory(StoryModel story) {
    state = PostCreationState.fromStory(story);
  }

  void initializeWithDraft(DraftModel draft) {
    state = PostCreationState.fromDraft(draft);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
    _scheduleSave();
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
    _scheduleSave();
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
    _scheduleSave();
  }

  void updateUsers(List<UserModel> users) {
    state = state.copyWith(selectedUsers: users);
    _scheduleSave();
  }

  void updateImagePath(String? path) {
    state = state.copyWith(imagePath: path);
    _scheduleSave();
  }

  void toggleAnonymous(bool isAnon) {
    state = state.copyWith(isAnonymous: isAnon);
    _scheduleSave();
  }

  void updateType(StoryType type) {
    state = state.copyWith(type: type);
    _scheduleSave();
  }

  void reset() {
    _debounceTimer?.cancel();
    state = const PostCreationState();
  }
}
