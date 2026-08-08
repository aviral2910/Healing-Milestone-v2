// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_creation_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostCreationController)
final postCreationControllerProvider = PostCreationControllerProvider._();

final class PostCreationControllerProvider
    extends $NotifierProvider<PostCreationController, PostCreationState> {
  PostCreationControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postCreationControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postCreationControllerHash();

  @$internal
  @override
  PostCreationController create() => PostCreationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostCreationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostCreationState>(value),
    );
  }
}

String _$postCreationControllerHash() =>
    r'e4167a9e962e8986555e01fd3ddcac0d5d27544c';

abstract class _$PostCreationController extends $Notifier<PostCreationState> {
  PostCreationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PostCreationState, PostCreationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PostCreationState, PostCreationState>,
        PostCreationState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
