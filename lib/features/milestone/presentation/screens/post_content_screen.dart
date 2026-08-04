import 'package:flutter/material.dart';
import 'package:healing_milestones/features/posts/data/ai_story_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/post_creation_state.dart';

class PostContentScreen extends StatefulHookConsumerWidget {
  const PostContentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostContentScreen> createState() => _PostContentScreenState();
}

class _PostContentScreenState extends ConsumerState<PostContentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final TextEditingController _struggleController = TextEditingController();
  final TextEditingController _turningPointController = TextEditingController();
  final TextEditingController _hopeController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  bool _showAIAssistant = false;
  bool _showManualEditor = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(postCreationControllerProvider);
      if (state.title.isNotEmpty || state.content.isNotEmpty) {
        _titleController.text = state.title;
        _contentController.text = state.content;
        setState(() {
          _showManualEditor = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _struggleController.dispose();
    _turningPointController.dispose();
    _hopeController.dispose();
    _contextController.dispose();
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

  Future<void> _generateAIStory() async {
    if (_contextController.text.trim().isEmpty ||
        _struggleController.text.trim().isEmpty ||
        _turningPointController.text.trim().isEmpty ||
        _hopeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please answer the core questions to generate a story.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final aiService = ref.read(aiStoryServiceProvider);
      final generatedData = await aiService.generateStoryFromAnswers(
        struggle: _struggleController.text.trim(),
        turningPoint: _turningPointController.text.trim(),
        hope: _hopeController.text.trim(),
        contextInfo: _contextController.text.trim(),
      );

      _titleController.text = generatedData['title'] ?? '';
      _contentController.text = generatedData['content'] ?? '';
      setState(() {
        _showAIAssistant = false;
        _showManualEditor = true;
      });
      _saveToState();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReadyToProceed =
        _showManualEditor && _contentController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(postCreationControllerProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Text(_showAIAssistant ? 'Guided Story' : 'New Post'),
        actions: [
          if (_showManualEditor)
            TextButton(
              onPressed: isReadyToProceed
                  ? () {
                      _saveToState();
                      context.push(AppRoutes.createPostSettings);
                    }
                  : null,
              child: const Text('Next',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_showAIAssistant) {
      return _buildAIAssistant(theme);
    } else if (_showManualEditor) {
      return _buildManualEditor(theme);
    } else {
      return _buildEntrySelection(theme);
    }
  }

  Widget _buildEntrySelection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How would you like to start?',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a path to begin sharing your milestone.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildChoiceCard(
            theme: theme,
            icon: Icons.edit_note_rounded,
            title: 'Write Freely',
            subtitle:
                'Start with a blank canvas and share your story your way.',
            onTap: () {
              setState(() {
                _showManualEditor = true;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildChoiceCard(
            theme: theme,
            icon: Icons.auto_awesome,
            title: 'Guided Story (AI)',
            subtitle:
                'Answer 3 simple questions and let our AI draft an inspiring story for you.',
            isHighlighted: true,
            onTap: () {
              setState(() {
                _showAIAssistant = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isHighlighted ? theme.colorScheme.primary : theme.dividerColor,
            width: isHighlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isHighlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isHighlighted
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isHighlighted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistant(ThemeData theme) {
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Weaving your journey into a story...',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Tell us about it',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Don\'t worry about grammar or spelling. Just answer honestly.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _buildQuestionField(
          theme: theme,
          controller: _contextController,
          question: 'Share the background or context of your story...',
          hint: 'e.g. I was going through a period where I felt lost...',
        ),
        const SizedBox(height: 32),
        _buildQuestionField(
          theme: theme,
          controller: _struggleController,
          question: '1. What was the hardest part?',
          hint: 'e.g. I felt completely overwhelmed and alone...',
        ),
        const SizedBox(height: 24),
        _buildQuestionField(
          theme: theme,
          controller: _turningPointController,
          question: '2. What helped you get through it?',
          hint: 'e.g. My friend called me, or I finally decided to...',
        ),
        const SizedBox(height: 24),
        _buildQuestionField(
          theme: theme,
          controller: _hopeController,
          question: '3. What would you tell yourself looking back?',
          hint: 'e.g. It gets better, just hold on...',
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: _generateAIStory,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Draft My Story'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionField({
    required ThemeData theme,
    required TextEditingController controller,
    required String question,
    required String hint,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEditor(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Give your milestone a title',
              hintStyle: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
            ),
            onChanged: (_) {
              // trigger rebuild for Next button
              setState(() {});
            },
          ),
          const Divider(),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              decoration: InputDecoration(
                hintText:
                    'Share your journey...\n\nWhat happened? How did you feel? What did you learn?',
                hintStyle: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey.shade400, height: 1.5),
                border: InputBorder.none,
              ),
              onChanged: (_) {
                // trigger rebuild for Next button
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
