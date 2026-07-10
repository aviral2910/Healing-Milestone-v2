import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/milestone/presentation/screens/post_creation_screen.dart';
import '../../features/milestone/presentation/screens/story_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const PostCreationScreen(),
      ),
      GoRoute(
        path: '/story/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StoryDetailScreen(milestoneId: id);
        },
      ),
    ],
  );
});
