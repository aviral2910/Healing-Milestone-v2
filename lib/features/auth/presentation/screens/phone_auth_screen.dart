import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../data/auth_provider.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  String _completePhoneNumber = '';
  bool _isLoading = false;
  String _error = '';

  String _getInitialCountryCode() {
    final country = View.of(context).platformDispatcher.locale.countryCode;

    // If device locale is generic English (US) or null, use a smart timezone heuristic
    if (country == null || country == 'US') {
      final offset = DateTime.now().timeZoneOffset.inMinutes;
      if (offset == 330) return 'IN'; // India
      if (offset == 60 || offset == 120) return 'GB'; // Europe/UK
      if (offset >= 480 && offset <= 660) return 'AU'; // Australia/Asia
    }
    return country ?? 'US';
  }

  void _sendOtp() async {
    final phone = _completePhoneNumber;
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await ref.read(authProvider.notifier).verifyPhoneNumber(
        phone,
        onCodeSent: () {
          if (mounted) {
            setState(() => _isLoading = false);
            context.push(AppRoutes.verifyOtp);
          }
        },
      );
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
    final initialCountry = _getInitialCountryCode();

    // Listen for global auth errors
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
                      Icons.phone_iphone_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Continue with Phone',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You will receive a 6-digit code to verify next.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: (Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.grey),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    IntlPhoneField(
                      initialCountryCode: initialCountry,
                      dropdownIcon: Icon(Icons.arrow_drop_down,
                          color: theme.colorScheme.onSurfaceVariant),
                      dropdownTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7)),
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
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                      onCountryChanged: (country) {
                        // Optional: Handle country change if needed
                      },
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
                      onPressed: _isLoading ? null : _sendOtp,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Theme.of(context).colorScheme.onSurface))
                          : const Text('Send Code'),
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
