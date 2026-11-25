import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/awareness_providers.dart';
import '../../data/awareness_readiness.dart';
import '../../data/emergency_guides_data.dart';
import '../../domain/emergency_guide_model.dart';
import 'emergency_guide_detail_screen.dart';

class EmergencyReadinessScreen extends ConsumerWidget {
  const EmergencyReadinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final state = ref.watch(awarenessProvider);
    final lang = state.language;
    final isHi = lang == AwarenessLanguage.hi;

    final guides = getEmergencyGuides(lang);
    final total = guides.length;
    final completed = state.completedGuideIds.length;
    final progress = total > 0 ? completed / total : 0.0;
    final tier = getReadinessTier(completed, total, lang);

    final nextGuide = guides.cast<EmergencyGuide?>().firstWhere(
          (g) => !state.completedGuideIds.contains(g!.id),
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(isHi ? 'आपातकालीन तैयारी' : 'Emergency Readiness'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Readiness Progress Ring Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 82,
                  height: 82,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 82,
                        height: 82,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 7,
                          backgroundColor: theme.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                      Text(
                        '$completed/$total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHi ? 'वर्तमान स्तर' : 'CURRENT TIER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHi
                            ? 'बैज अनलॉक करने के लिए प्रत्येक गाइड की परीक्षा 100% अंकों से पास करें।'
                            : 'Pass each guide\'s quiz with 100% to unlock mastery badges.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Text(
            isHi ? 'दक्षता बैज' : 'Mastery Badges',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: readinessBadges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.18,
            ),
            itemBuilder: (context, index) {
              final badge = readinessBadges[index];
              final done = badge.completedCount(state.completedGuideIds);
              final totalInBadge = badge.guideIds.length;
              final unlocked = badge.isUnlocked(state.completedGuideIds);

              final remaining = totalInBadge - done;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _showBadgeDetailsSheet(
                  context,
                  badge: badge,
                  guides: guides,
                  completedIds: state.completedGuideIds,
                  lang: lang,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? primary.withValues(alpha: 0.10)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: unlocked
                          ? primary.withValues(alpha: 0.45)
                          : theme.dividerColor,
                      width: unlocked ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: unlocked
                                      ? LinearGradient(
                                          colors: [
                                            Color.lerp(primary, Colors.white,
                                                    0.35) ??
                                                primary,
                                            primary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: unlocked
                                      ? null
                                      : theme.scaffoldBackgroundColor,
                                  border: Border.all(
                                    color: unlocked
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : theme.dividerColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  badge.icon,
                                  size: 20,
                                  color: unlocked
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                              if (!unlocked)
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: theme.dividerColor),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      size: 10,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (unlocked)
                            Icon(Icons.verified_rounded,
                                color: primary, size: 18)
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Text(
                                '$done/$totalInBadge',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        badge.title(lang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: unlocked ? primary : null,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unlocked
                            ? (isHi ? 'अनलॉक' : 'Unlocked')
                            : (isHi ? '$remaining शेष' : '$remaining left'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: unlocked
                              ? primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalInBadge > 0 ? done / totalInBadge : 0,
                          minHeight: 4,
                          backgroundColor: theme.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (nextGuide != null) ...[
            const SizedBox(height: 22),
            Text(
              isHi ? 'अगला सुझाव' : 'Recommended Next',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EmergencyGuideDetailScreen(guide: nextGuide),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        nextGuide.category.icon,
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextGuide.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nextGuide.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBadgeDetailsSheet(
    BuildContext context, {
    required ReadinessBadge badge,
    required List<EmergencyGuide> guides,
    required Set<String> completedIds,
    required AwarenessLanguage lang,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isHi = lang == AwarenessLanguage.hi;

    final badgeGuides = guides
        .where((g) => badge.guideIds.contains(g.id))
        .toList()
      ..sort((a, b) {
        final aDone = completedIds.contains(a.id) ? 1 : 0;
        final bDone = completedIds.contains(b.id) ? 1 : 0;
        return aDone.compareTo(bDone); // Incomplete first
      });

    final done = badge.completedCount(completedIds);
    final total = badge.guideIds.length;
    final unlocked = done == total;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (unlocked)
                _UnlockedBadgeShowcase(
                  badge: badge,
                  lang: lang,
                  done: done,
                  total: total,
                )
              else
                _LockedBadgeShowcase(
                  badge: badge,
                  lang: lang,
                  done: done,
                  total: total,
                ),
              const SizedBox(height: 16),
              ...badgeGuides.map((guide) {
                final isDone = completedIds.contains(guide.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              EmergencyGuideDetailScreen(guide: guide),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? primary.withValues(alpha: 0.08)
                            : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone
                              ? primary.withValues(alpha: 0.35)
                              : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isDone
                                ? primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  guide.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDone
                                      ? (isHi
                                          ? '100% उत्तीर्ण'
                                          : '100% Passed')
                                      : (isHi
                                          ? 'शुरू करने के लिए टैप करें'
                                          : 'Tap to start'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDone ? primary : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedBadgeShowcase extends StatelessWidget {
  final ReadinessBadge badge;
  final AwarenessLanguage lang;
  final int done;
  final int total;

  const _LockedBadgeShowcase({
    required this.badge,
    required this.lang,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isHi = lang == AwarenessLanguage.hi;

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(104, 104),
                  painter: _HaloRingPainter(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                ),
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.scaffoldBackgroundColor,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    badge.icon,
                    size: 34,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              isHi
                  ? 'प्रगति में • $done/$total'
                  : 'IN PROGRESS • $done OF $total',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title(lang),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? done / total : 0,
              minHeight: 5,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedBadgeShowcase extends StatefulWidget {
  final ReadinessBadge badge;
  final AwarenessLanguage lang;
  final int done;
  final int total;

  const _UnlockedBadgeShowcase({
    required this.badge,
    required this.lang,
    required this.done,
    required this.total,
  });

  @override
  State<_UnlockedBadgeShowcase> createState() => _UnlockedBadgeShowcaseState();
}

class _UnlockedBadgeShowcaseState extends State<_UnlockedBadgeShowcase>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _ambientController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _scale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final highlight = Color.lerp(primary, Colors.white, 0.35) ?? primary;
    final isHi = widget.lang == AwarenessLanguage.hi;

    return Center(
      child: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([
                _entranceController,
                _ambientController,
              ]),
              builder: (context, _) {
                final breath = 0.5 +
                    0.5 * math.sin(_ambientController.value * 2 * math.pi);
                return Transform.scale(
                  scale: _scale.value,
                  child: SizedBox(
                    width: 132,
                    height: 132,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle breathing outer aura
                        Container(
                          width: 112 + (8 * breath),
                          height: 112 + (8 * breath),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(
                                  alpha: 0.22 + (0.14 * breath),
                                ),
                                blurRadius: 28 + (10 * breath),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        // Rotating segmented halo ring
                        Transform.rotate(
                          angle: _ambientController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(118, 118),
                            painter: _HaloRingPainter(color: primary),
                          ),
                        ),
                        // Crafted metallic medallion
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [highlight, primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.onPrimary
                                      .withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                widget.badge.icon,
                                size: 38,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        // Sparkle accents
                        Positioned(
                          top: 10,
                          right: 16,
                          child: Opacity(
                            opacity: 0.5 + 0.5 * breath,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: highlight,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 14,
                          child: Opacity(
                            opacity: 1.0 - 0.5 * breath,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.35)),
              ),
              child: Text(
                isHi ? 'बैज अनलॉक' : 'BADGE UNLOCKED',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primary,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.badge.title(widget.lang),
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 23),
            ),
            const SizedBox(height: 2),
            Text(
              isHi
                  ? '${widget.done} / ${widget.total} गाइड पूर्ण'
                  : '${widget.done} of ${widget.total} guides completed',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HaloRingPainter extends CustomPainter {
  final Color color;

  _HaloRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const dashCount = 12;
    const sweep = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep * 0.52,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HaloRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
