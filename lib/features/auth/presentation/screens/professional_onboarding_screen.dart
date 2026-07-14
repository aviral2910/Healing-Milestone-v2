import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/core/presentation/widgets/user_badge.dart';

class ProfessionalOnboardingScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const ProfessionalOnboardingScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<ProfessionalOnboardingScreen> createState() => _ProfessionalOnboardingScreenState();
}

class _ProfessionalOnboardingScreenState extends ConsumerState<ProfessionalOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _applyForVerification = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _skip() {
    final authState = ref.read(authProvider).valueOrNull;
    final user = authState?.authUser;

    if (user != null) {
      final newUserModel = UserModel(
        userId: user.uid,
        email: user.email ?? '',
        userName: user.displayName ?? 'New User',
        profilePicture: user.photoUrl,
        role: widget.role,
        isVerified: false,
      );

      ref.read(authProvider.notifier).completeOnboarding(newUserModel);
      context.go('/');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authProvider).valueOrNull;
      final user = authState?.authUser;

      if (user != null) {
        final newUserModel = UserModel(
          userId: user.uid,
          email: user.email ?? '',
          userName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (user.displayName ?? 'New User'),
          profilePicture: user.photoUrl,
          role: widget.role,
          isVerified: false,
          specialty: widget.role == UserRole.healthcareProfessional ? _specialtyController.text.trim() : null,
          licenseNumber: widget.role == UserRole.healthcareProfessional ? (_licenseController.text.trim().isEmpty ? null : _licenseController.text.trim()) : null,
          services: widget.role == UserRole.organization ? _specialtyController.text.trim() : null,
          registrationNumber: widget.role == UserRole.organization ? (_licenseController.text.trim().isEmpty ? null : _licenseController.text.trim()) : null,
          appliedForVerification: _applyForVerification,
        );

        ref.read(authProvider.notifier).completeOnboarding(newUserModel);
        
        if (_applyForVerification) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your application for verification has been submitted.')),
          );
        }
        
        context.go('/');
      }
    }
  }

  InputDecoration _buildInputDecoration(String hint, ThemeData theme, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Premium dark gray
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
        borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOrg = widget.role == UserRole.organization;
    final isMember = widget.role == UserRole.member;

    String titleText = 'Profile Setup';
    if (!isMember) {
      titleText = isOrg ? 'Organization Details' : 'Professional Details';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMember ? Icons.person : (isOrg ? Icons.domain : Icons.medical_services),
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tell us about yourself',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMember 
                        ? 'How would you like to be known in the community?'
                        : 'This information helps us maintain a trustworthy platform.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: _buildInputDecoration(
                      isMember ? 'Display Name' : (isOrg ? 'Organization Name' : 'Full Name with Title'),
                      theme,
                      isOrg ? Icons.domain : Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  if (!isMember) ...[
                    TextFormField(
                      controller: _specialtyController,
                      textInputAction: TextInputAction.next,
                      decoration: _buildInputDecoration(
                        isOrg ? 'Focus Area / Services' : 'Specialty / Field of Practice',
                        theme,
                        isOrg ? Icons.business_center_outlined : Icons.medical_information_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your specialty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _licenseController,
                      textInputAction: TextInputAction.done,
                      decoration: _buildInputDecoration(
                        isOrg ? 'Registration Number (Optional)' : 'Medical License Number (Optional)',
                        theme,
                        Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Compact & Native Verification UI
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _applyForVerification ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              UserBadge(role: widget.role, isVerified: true, iconSize: 26),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Apply for Verified Badge',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Establish trust in the community',
                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _applyForVerification,
                                onChanged: (val) => setState(() => _applyForVerification = val),
                                activeTrackColor: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A verified badge confirms your credentials to the community. You can apply now or later from your profile settings.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Complete Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
