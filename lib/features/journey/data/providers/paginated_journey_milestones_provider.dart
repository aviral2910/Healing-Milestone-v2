import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:healing_milestones/features/journey/data/models/journey_models.dart';
import 'package:healing_milestones/core/models/offset_paginated_state.dart';
import 'package:healing_milestones/features/journey/data/providers/journey_providers.dart';

part 'paginated_journey_milestones_provider.g.dart';

@riverpod
class PaginatedJourneyMilestones extends _$PaginatedJourneyMilestones {
  bool _isFetchingMore = false;
  static const int _limit = 20;

  @override
  Future<OffsetPaginatedState<JourneyMilestoneModel>> build(String journeyId, {bool isPublic = false}) async {
    final repository = ref.watch(journeyRepositoryProvider);
    final items = await repository.getMilestones(journeyId: journeyId, isPublic: isPublic, skip: 0, limit: _limit);
    return OffsetPaginatedState(
      items: items,
      skip: _limit,
      isEnd: items.length < _limit,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingMore) return;
    final currentState = state.value;
    if (currentState == null || currentState.isEnd) return;

    _isFetchingMore = true;
    try {
      final repository = ref.read(journeyRepositoryProvider);
      final newItems = await repository.getMilestones(
        journeyId: journeyId,
        isPublic: isPublic,
        skip: currentState.skip,
        limit: _limit,
      );
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        skip: currentState.skip + _limit,
        isEnd: newItems.length < _limit,
      ));
    } finally {
      _isFetchingMore = false;
    }
  }
}
