import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/post_creation_state.dart';

class PostManualScreen extends StatefulHookConsumerWidget {
  const PostManualScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostManualScreen> createState() => _PostManualScreenState();
}

class _PostManualScreenState extends ConsumerState<PostManualScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(postCreationControllerProvider);
    _titleController.text = state.title;
    _contentController.text = state.content;

    _titleController.addListener(_saveToState);
    _contentController.addListener(_saveToState);
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveToState);
    _contentController.removeListener(_saveToState);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveToState() {
    ref
        .read(postCreationControllerProvider.notifier)
        .updateTitle(_titleController.text);
    ref
        .read(postCreationControllerProvider.notifier)
        .updateContent(_contentController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(postCreationControllerProvider);
    final isEditing = state.isEditing || state.draftId != null;
    final isReadyToProceed = _contentController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            _saveToState();
            context.pop();
          },
        ),
        title: Text(
          isEditing ? 'Edit Post' : 'New Post',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton(
              onPressed: isReadyToProceed
                  ? () {
                      _saveToState();
                      context.push(AppRoutes.createPostSettings);
                    }
                  : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildManualEditor(theme),
      ),
    );
  }

  Widget _buildManualEditor(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Give your milestone a title',
              hintStyle: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
              border: InputBorder.none,
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Share your journey...\n\nWhat happened? How did you feel? What did you learn?',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  height: 1.6,
                  fontSize: 18,
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
