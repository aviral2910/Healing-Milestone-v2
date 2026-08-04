import 'package:flutter/material.dart';
import 'package:healing_milestones/features/posts/data/ai_story_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/post_creation_state.dart';

class PostGuidedScreen extends StatefulHookConsumerWidget {
  const PostGuidedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostGuidedScreen> createState() => _PostGuidedScreenState();
}

class _PostGuidedScreenState extends ConsumerState<PostGuidedScreen> {
  final TextEditingController _struggleController = TextEditingController();
  final TextEditingController _turningPointController = TextEditingController();
  final TextEditingController _hopeController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _struggleController.dispose();
    _turningPointController.dispose();
    _hopeController.dispose();
    _contextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _generateAIStory() async {
    if (_contextController.text.trim().isEmpty ||
        _struggleController.text.trim().isEmpty ||
        _turningPointController.text.trim().isEmpty ||
        _hopeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please answer all the questions to craft the best story.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
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

      final title = generatedData['title'] ?? '';
      final content = generatedData['content'] ?? '';
      
      ref.read(postCreationControllerProvider.notifier).updateTitle(title);
      ref.read(postCreationControllerProvider.notifier).updateContent(content);

      if (mounted) {
        context.pushReplacement(AppRoutes.createPostManual);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Guided Story',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isGenerating ? _buildGeneratingState(theme) : _buildQuestionsForm(theme),
        ),
      ),
    );
  }

  Widget _buildGeneratingState(ThemeData theme) {
    return Center(
      key: const ValueKey('generating'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: null,
                      strokeWidth: 4,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
              ),
              Icon(Icons.auto_awesome, size: 40, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'Weaving your journey...',
            style: theme.textTheme.headlineSmall?.copyWith(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Turning your feelings into a beautiful story.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsForm(ThemeData theme) {
    Widget _buildSubtleDivider() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        child: Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1), height: 1),
      );
    }

    return AnimationLimiter(
      key: const ValueKey('form'),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            _buildMainContextField(theme),
            const SizedBox(height: 48),
            Text(
              'Deepen the Narrative',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Answer these to help the AI structure your story better.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuestionCard(
              theme: theme,
              controller: _struggleController,
              number: '01',
              title: 'The Struggle',
              question: 'What was the hardest part?',
              hint: 'e.g. I felt completely overwhelmed and alone...',
              icon: Icons.terrain,
            ),
            _buildSubtleDivider(),
            _buildQuestionCard(
              theme: theme,
              controller: _turningPointController,
              number: '02',
              title: 'The Turning Point',
              question: 'What helped you get through it?',
              hint: 'e.g. My friend called me, or I finally decided to...',
              icon: Icons.lightbulb_outline,
            ),
            _buildSubtleDivider(),
            _buildQuestionCard(
              theme: theme,
              controller: _hopeController,
              number: '03',
              title: 'The Lesson',
              question: 'What would you tell yourself looking back?',
              hint: 'e.g. It gets better, just hold on...',
              icon: Icons.volunteer_activism,
            ),
            const SizedBox(height: 48),
            _buildSubmitButton(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContextField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The Main Story',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share the background or context of your story...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contextController,
                  maxLines: 8,
                  minLines: 4,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g. I was going through a period where I felt lost. Everything seemed to be going wrong at work, and my personal life was struggling...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      height: 1.6,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about it',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.edit_note, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Don\'t worry about grammar or spelling. Just answer honestly and let the magic happen.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard({
    required ThemeData theme,
    required TextEditingController controller,
    required String number,
    required String title,
    required String question,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    number,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: 'Outfit',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Icon(icon, color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 2,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      height: 1.5,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _generateAIStory,
        icon: Icon(Icons.auto_awesome, color: theme.colorScheme.onPrimary),
        label: Text(
          'Bring My Story to Life',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            color: theme.colorScheme.onPrimary,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
