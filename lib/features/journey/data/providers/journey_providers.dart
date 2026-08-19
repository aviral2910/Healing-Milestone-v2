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
  return repository.getMilestones(isFloating: true, limit: 10);
});






class PaginatedMilestonesNotifier extends StateNotifier<AsyncValue<OffsetPaginatedState<JourneyMilestoneModel>>> {
  final Ref ref;
  final String journeyId;
  final bool isPublic;
  static const int _limit = 20;
  bool _isFetchingMore = false;

  PaginatedMilestonesNotifier(this.ref, this.journeyId, {this.isPublic = false}) : super(const AsyncValue.loading()) {
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    try {
      final repository = ref.read(journeyRepositoryProvider);
      final items = await repository.getMilestones(journeyId: journeyId, isPublic: isPublic, skip: 0, limit: _limit);
      state = AsyncValue.data(OffsetPaginatedState(
        items: items,
        skip: _limit,
        isEnd: items.length < _limit,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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

      state = AsyncValue.data(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        skip: currentState.skip + _limit,
        isEnd: newItems.length < _limit,
      ));
    } catch (e) {
      print('Error fetching next page: $e');
    } finally {
      _isFetchingMore = false;
    }
  }
}

final journeyMilestonesProvider = StateNotifierProvider.autoDispose.family<PaginatedMilestonesNotifier, AsyncValue<OffsetPaginatedState<JourneyMilestoneModel>>, String>((ref, journeyId) {
  return PaginatedMilestonesNotifier(ref, journeyId, isPublic: false);
});

final publicJourneyMilestonesProvider = StateNotifierProvider.autoDispose.family<PaginatedMilestonesNotifier, AsyncValue<OffsetPaginatedState<JourneyMilestoneModel>>, String>((ref, journeyId) {
  return PaginatedMilestonesNotifier(ref, journeyId, isPublic: true);
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

class AllCheckinsNotifier extends AsyncNotifier<OffsetPaginatedState<JourneyMilestoneModel>> {
  bool _isFetchingMore = false;
  static const int _limit = 10;

  @override
  Future<OffsetPaginatedState<JourneyMilestoneModel>> build() async {
    final repository = ref.watch(journeyRepositoryProvider);
    final items = await repository.getMilestones(isFloating: true, skip: 0, limit: _limit);
    return OffsetPaginatedState(
      items: items,
      isEnd: items.length < _limit,
      skip: _limit,
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
        isFloating: true,
        skip: currentState.skip,
        limit: _limit,
      );
      
      state = AsyncValue.data(
        OffsetPaginatedState(
          items: [...currentState.items, ...newItems],
          isEnd: newItems.length < _limit,
          skip: currentState.skip + _limit,
        ),
      );
    } catch (e, st) {
      // Don't overwrite state with error so we keep old items,
      // but maybe handle error UI state if needed
    } finally {
      _isFetchingMore = false;
    }
  }
}

final allCheckinsProvider = AsyncNotifierProvider<AllCheckinsNotifier, OffsetPaginatedState<JourneyMilestoneModel>>(() {
  return AllCheckinsNotifier();
});
