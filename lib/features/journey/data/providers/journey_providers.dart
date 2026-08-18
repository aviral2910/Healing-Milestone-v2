import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/offset_paginated_state.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/data/auth_provider.dart';
import '../models/journey_models.dart';
import '../repositories/journey_repository.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JourneyRepository(apiClient);
});

final userJourneysProvider = FutureProvider.autoDispose.family<List<JourneyModel>, String>((ref, userId) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getUserJourneys(userId);
});

final myJourneysProvider = FutureProvider.autoDispose<List<JourneyModel>>((ref) async {
  final auth = ref.watch(authProvider).value;
  if (auth?.status != AuthStatus.authenticated) return [];
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getJourneys();
});

final myFloatingMilestonesProvider = FutureProvider.autoDispose<List<JourneyMilestoneModel>>((ref) async {
  final auth = ref.watch(authProvider).value;
  if (auth?.status != AuthStatus.authenticated) return [];
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getMilestones(isFloating: true);
});

final journeyMilestonesProvider = FutureProvider.autoDispose.family<List<JourneyMilestoneModel>, String>((ref, journeyId) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getMilestones(journeyId: journeyId);
});

final publicJourneyMilestonesProvider = FutureProvider.autoDispose.family<List<JourneyMilestoneModel>, String>((ref, journeyId) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getMilestones(journeyId: journeyId, isPublic: true);
});

class TogetherFeedNotifier extends AsyncNotifier<OffsetPaginatedState<JourneyMilestoneModel>> {
  bool _isFetchingMore = false;
  static const int _limit = 20;

  @override
  Future<OffsetPaginatedState<JourneyMilestoneModel>> build() async {
    final auth = ref.watch(authProvider).value;
    if (auth?.status != AuthStatus.authenticated) return OffsetPaginatedState(items: []);
    
    final items = await ref.watch(journeyRepositoryProvider).getPublicMilestones(limit: _limit);
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
      final newItems = await ref.read(journeyRepositoryProvider).getPublicMilestones(
        skip: currentState.skip, 
        limit: _limit
      );
      
      state = AsyncValue.data(
        currentState.copyWith(
          items: [...currentState.items, ...newItems],
          skip: currentState.skip + _limit,
          isEnd: newItems.length < _limit,
        ),
      );
    } catch (e, st) {
      print('Error fetching next page: $e');
      // Use AsyncValue.guard to safely copy with previous state
      state = await AsyncValue.guard(() async {
        throw e;
      });
    } finally {
      _isFetchingMore = false;
    }
  }
}

final togetherFeedProvider = AsyncNotifierProvider<TogetherFeedNotifier, OffsetPaginatedState<JourneyMilestoneModel>>(() {
  return TogetherFeedNotifier();
});

final followingJourneysProvider = FutureProvider.autoDispose<List<JourneyModel>>((ref) async {
  final auth = ref.watch(authProvider).value;
  if (auth?.status != AuthStatus.authenticated) return [];
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getFollowingJourneys();
});
