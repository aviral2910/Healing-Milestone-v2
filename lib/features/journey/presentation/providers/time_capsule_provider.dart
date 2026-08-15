import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/models/time_capsule_model.dart';
import 'package:healing_milestones/features/journey/data/time_capsule_repository.dart';

final myTimeCapsulesProvider = AsyncNotifierProvider<MyTimeCapsulesNotifier, List<TimeCapsuleModel>>(() {
  return MyTimeCapsulesNotifier();
});

class MyTimeCapsulesNotifier extends AsyncNotifier<List<TimeCapsuleModel>> {
  @override
  Future<List<TimeCapsuleModel>> build() async {
    return _fetchCapsules();
  }

  Future<List<TimeCapsuleModel>> _fetchCapsules() async {
    final repo = ref.read(timeCapsuleRepositoryProvider);
    return repo.getMyTimeCapsules();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCapsules());
  }

  Future<void> addCapsule(String content, DateTime unlockDate) async {
    final repo = ref.read(timeCapsuleRepositoryProvider);
    
    // Optimistic / Load state can be managed directly on the creation screen,
    // here we just make the API call and refresh the list.
    await repo.createTimeCapsule(content: content, unlockDate: unlockDate);
    await refresh();
  }

  Future<void> openCapsule(String capsuleId) async {
    final repo = ref.read(timeCapsuleRepositoryProvider);
    await repo.openTimeCapsule(capsuleId);
    await refresh();
  }
}
