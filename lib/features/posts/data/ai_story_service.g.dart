// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_story_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiStoryService)
final aiStoryServiceProvider = AiStoryServiceProvider._();

final class AiStoryServiceProvider
    extends $FunctionalProvider<AiStoryService, AiStoryService, AiStoryService>
    with $Provider<AiStoryService> {
  AiStoryServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'aiStoryServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$aiStoryServiceHash();

  @$internal
  @override
  $ProviderElement<AiStoryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiStoryService create(Ref ref) {
    return aiStoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiStoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiStoryService>(value),
    );
  }
}

String _$aiStoryServiceHash() => r'8e336fabc8f935a402160433c69978a65e472d7e';
