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

class MyFloatingMilestonesNotifier extends AutoDisposeAsyncNotifier<List<JourneyMilestoneModel>> {
  @override
  Future<List<JourneyMilestoneModel>> build() async {
    final auth = ref.watch(authProvider).value;
    if (auth?.status != AuthStatus.authenticated) return [];
    final repository = ref.watch(journeyRepositoryProvider);
    return repository.getMilestones(isFloating: true, limit: 10);
  }

  void updateMilestoneLocally(JourneyMilestoneModel updated) {
    if (state.value == null) return;
    final items = state.value!;
    final index = items.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      final newItems = List<JourneyMilestoneModel>.from(items);
      newItems[index] = updated;
      state = AsyncValue.data(newItems);
    }
  }
}

final myFloatingMilestonesProvider = AsyncNotifierProvider.autoDispose<MyFloatingMilestonesNotifier, List<JourneyMilestoneModel>>(() {
  return MyFloatingMilestonesNotifier();
});






class RecommendedMilestonesNotifier extends AsyncNotifier<OffsetPaginatedState<JourneyMilestoneModel>> {
  bool _isFetchingMore = false;
  static const int _limit = 20;

  @override
  Future<OffsetPaginatedState<JourneyMilestoneModel>> build() async {
    final auth = ref.watch(authProvider).value;
    if (auth?.status != AuthStatus.authenticated) return OffsetPaginatedState(items: []);
    
    final items = await ref.watch(journeyRepositoryProvider).getRecommendedMilestones(limit: _limit);
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
      final newItems = await ref.read(journeyRepositoryProvider).getRecommendedMilestones(
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
      state = await AsyncValue.guard(() async {
        throw e;
      });
    } finally {
      _isFetchingMore = false;
    }
  }

  void updateMilestoneLocally(JourneyMilestoneModel updated) {
    if (state.value == null) return;
    final items = state.value!.items;
    final index = items.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      final newItems = List<JourneyMilestoneModel>.from(items);
      newItems[index] = updated;
      state = AsyncValue.data(state.value!.copyWith(items: newItems));
    }
  }
}


class FollowingMilestonesNotifier extends AsyncNotifier<OffsetPaginatedState<JourneyMilestoneModel>> {
  bool _isFetchingMore = false;
  static const int _limit = 20;

  @override
  Future<OffsetPaginatedState<JourneyMilestoneModel>> build() async {
    final auth = ref.watch(authProvider).value;
    if (auth?.status != AuthStatus.authenticated) return OffsetPaginatedState(items: []);
    
    final items = await ref.watch(journeyRepositoryProvider).getFollowingMilestones(limit: _limit);
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
      final newItems = await ref.read(journeyRepositoryProvider).getFollowingMilestones(
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
      state = await AsyncValue.guard(() async {
        throw e;
      });
    } finally {
      _isFetchingMore = false;
    }
  }

  void updateMilestoneLocally(JourneyMilestoneModel updated) {
    if (state.value == null) return;
    final items = state.value!.items;
    final index = items.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      final newItems = List<JourneyMilestoneModel>.from(items);
      newItems[index] = updated;
      state = AsyncValue.data(state.value!.copyWith(items: newItems));
    }
  }
}


final recommendedMilestonesProvider = AsyncNotifierProvider<RecommendedMilestonesNotifier, OffsetPaginatedState<JourneyMilestoneModel>>(() {
  return RecommendedMilestonesNotifier();
});

final followingMilestonesProvider = AsyncNotifierProvider<FollowingMilestonesNotifier, OffsetPaginatedState<JourneyMilestoneModel>>(() {
  return FollowingMilestonesNotifier();
});

final recommendedJourneysProvider = FutureProvider.autoDispose<List<JourneyModel>>((ref) async {
  final auth = ref.watch(authProvider).value;
  if (auth?.status != AuthStatus.authenticated) return [];
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getRecommendedJourneys();
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

  void updateMilestoneLocally(JourneyMilestoneModel updated) {
    if (state.value == null) return;
    final items = state.value!.items;
    final index = items.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      final newItems = List<JourneyMilestoneModel>.from(items);
      newItems[index] = updated;
      state = AsyncValue.data(state.value!.copyWith(items: newItems));
    }
  }
}


final allCheckinsProvider = AsyncNotifierProvider<AllCheckinsNotifier, OffsetPaginatedState<JourneyMilestoneModel>>(() {
  return AllCheckinsNotifier();
});
