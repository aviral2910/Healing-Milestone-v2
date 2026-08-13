import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/journey_models.dart';
import '../repositories/journey_repository.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JourneyRepository(apiClient);
});

final myJourneysProvider = FutureProvider.autoDispose<List<JourneyModel>>((ref) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getJourneys();
});

final myFloatingMilestonesProvider = FutureProvider.autoDispose<List<JourneyMilestoneModel>>((ref) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getMilestones(isFloating: true);
});

final journeyMilestonesProvider = FutureProvider.autoDispose.family<List<JourneyMilestoneModel>, String>((ref, journeyId) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getMilestones(journeyId: journeyId);
});

final togetherFeedProvider = FutureProvider.autoDispose<List<JourneyMilestoneModel>>((ref) async {
  final repository = ref.watch(journeyRepositoryProvider);
  return repository.getPublicMilestones();
});
