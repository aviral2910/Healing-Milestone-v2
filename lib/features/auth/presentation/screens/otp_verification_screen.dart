import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Are we authenticating or linking?
      // Since the user can be logged in via Google and adding a phone number,
      // we check if they are already authenticated.
      final authState = ref.read(authProvider).value;
      final isAlreadyLoggedIn = authState?.authUser != null;

      if (isAlreadyLoggedIn) {
        await ref.read(authProvider.notifier).linkPhoneNumber(otp);
        if (mounted) {
          context.pop(); // Pop OTP screen
          context.pop(); // Pop Phone Auth screen to return to Edit Profile
        }
      } else {
        await ref.read(authProvider.notifier).verifyOtp(otp);
        if (mounted) {
          // Check if they need onboarding, router might catch it first, but just in case:
          final newState = ref.read(authProvider).value;
          if (newState?.status == AuthStatus.needsOnboarding) {
            context.go(AppRoutes.roleSelection);
          } else {
            context.go(AppRoutes.ascensionTransition);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      if (next is AsyncError) {
        setState(() {
          _error = next.error.toString();
          _isLoading = false;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Enter Verification Code',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We sent a 6-digit code to your phone number.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: (Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.grey),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '------',
                        counterText: '', // hide the max length counter
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                          letterSpacing: 8,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E), // Premium dark gray
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.5),
                              width: 1.5),
                        ),
                      ),
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Theme.of(context).colorScheme.onSurface))
                          : const Text('Verify Code'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
