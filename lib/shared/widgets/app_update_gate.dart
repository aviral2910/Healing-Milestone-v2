import 'dart:ui';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_update_service.dart';
import '../../core/theme/theme_provider.dart';

class AppUpdateGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppUpdateGate({super.key, required this.child});

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  AppUpdateInfo _updateInfo = AppUpdateInfo.none;
  bool _softDismissedInSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAndEvaluate();
    }
  }

  Future<void> _refreshAndEvaluate() async {
    try {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
    } catch (_) {}
    await _evaluateUpdate();
  }

  Future<void> _evaluateUpdate() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final info = await AppUpdateService.checkForUpdate(prefs);
    if (!mounted) return;
    setState(() {
      _updateInfo = info;
      if (info.type == AppUpdateType.hard) {
        _softDismissedInSession = false;
      }
    });
  }

  Future<void> _handleLater() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await AppUpdateService.dismissSoftUpdate(prefs, _updateInfo.targetVersion);
    if (!mounted) return;
    setState(() => _softDismissedInSession = true);
  }

  @override
  Widget build(BuildContext context) {
    final showHard = _updateInfo.type == AppUpdateType.hard;
    final showSoft =
        _updateInfo.type == AppUpdateType.soft && !_softDismissedInSession;

    if (!showHard && !showSoft) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final buttonFg = theme.colorScheme.primary.computeLuminance() > 0.25
        ? Colors.black
        : Colors.white;

    return PopScope(
      canPop: !showHard,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: showHard ? 0.82 : 0.65),
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Material(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        elevation: 8,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                                child: Icon(
                                  showHard
                                      ? Icons.system_update_rounded
                                      : Icons.auto_awesome_rounded,
                                  size: 42,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'v${_updateInfo.targetVersion}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _updateInfo.title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _updateInfo.message,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () => AppUpdateService.openStore(
                                    _updateInfo.storeUrl,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: buttonFg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Update Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (!showHard) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: TextButton(
                                    onPressed: _handleLater,
                                    child: Text(
                                      'Later',
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
