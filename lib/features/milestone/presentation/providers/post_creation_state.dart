import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/story_model.dart';
import '../../../../core/models/draft_model.dart';

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
  @override
  PostCreationState build() {
    return const PostCreationState();
  }

  void initializeWithStory(StoryModel story) {
    state = PostCreationState.fromStory(story);
  }

  void initializeWithDraft(DraftModel draft) {
    state = PostCreationState.fromDraft(draft);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void updateUsers(List<UserModel> users) {
    state = state.copyWith(selectedUsers: users);
  }

  void updateImagePath(String? path) {
    state = state.copyWith(imagePath: path);
  }

  void toggleAnonymous(bool isAnon) {
    state = state.copyWith(isAnonymous: isAnon);
  }

  void updateType(StoryType type) {
    state = state.copyWith(type: type);
  }

  void reset() {
    state = const PostCreationState();
  }
}
