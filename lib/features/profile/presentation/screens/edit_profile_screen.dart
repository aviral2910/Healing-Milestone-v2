import 'package:healing_milestones/core/router/app_routes.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/core/theme/app_theme.dart';
import 'package:healing_milestones/core/presentation/widgets/user_badge.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late TextEditingController _licenseController;
  late TextEditingController _servicesController;
  late TextEditingController _registrationController;

  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  Timer? _debounce;
  String? _originalUsername;
  bool _isUploadingProfilePic = false;

  void _onFieldChanged() {
    setState(() {}); // Trigger rebuild to evaluate _hasChanges
  }

  bool get _hasChanges {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    return _nameController.text.trim() != (user.displayName) ||
        _bioController.text.trim() != (user.bio ?? '') ||
        _phoneController.text.trim() != (user.phoneNumber ?? '') ||
        _specialtyController.text.trim() != (user.specialty ?? '') ||
        _licenseController.text.trim() != (user.licenseNumber ?? '') ||
        _servicesController.text.trim() != (user.services ?? '') ||
        _registrationController.text.trim() != (user.registrationNumber ?? '');
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _originalUsername = user?.username;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _specialtyController = TextEditingController(text: user?.specialty ?? '');
    _licenseController = TextEditingController(text: user?.licenseNumber ?? '');
    _servicesController = TextEditingController(text: user?.services ?? '');
    _registrationController =
        TextEditingController(text: user?.registrationNumber ?? '');

    _nameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _specialtyController.addListener(_onFieldChanged);
    _licenseController.addListener(_onFieldChanged);
    _servicesController.addListener(_onFieldChanged);
    _registrationController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _specialtyController.removeListener(_onFieldChanged);
    _licenseController.removeListener(_onFieldChanged);
    _servicesController.removeListener(_onFieldChanged);
    _registrationController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    _servicesController.dispose();
    _registrationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    final username = value.trim().toLowerCase();

    if (username == _originalUsername) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
      });
      return;
    }

    if (username.isEmpty || username.length < 3) {
      setState(() {
        _isUsernameAvailable = null;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final available =
          await ref.read(authProvider.notifier).isUsernameAvailable(username);
      if (mounted) {
        setState(() {
          _isUsernameAvailable = available;
          _isCheckingUsername = false;
        });
      }
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // (Username check removed since it's read-only)

      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final updatedUser = user.copyWith(
        displayName: _nameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        bio: _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        specialty: _specialtyController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        services: _servicesController.text.trim(),
        registrationNumber: _registrationController.text.trim(),
      );

      await ref.read(authProvider.notifier).updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (pickedFile == null) return;

    setState(() {
      _isUploadingProfilePic = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final file = File(pickedFile.path);
      final storageRepo = ref.read(storageRepositoryProvider);

      final fileName = const Uuid().v4();
      final path = 'profile_pictures/${user.userId}/$fileName';

      final downloadUrl = await storageRepo.uploadImage(path, file);

      final updatedUser = user.copyWith(profilePicture: downloadUrl);
      await ref.read(authProvider.notifier).updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingProfilePic = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      labelText: hint,
      hintStyle:
          TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.accentPrimary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.surfaceLight,
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
        borderSide: const BorderSide(color: AppTheme.accentPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5),
      ),
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLinked = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                AppTheme.accentPrimary.withValues(alpha: isLinked ? 0.6 : 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary
                    .withValues(alpha: isLinked ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.accentPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary),
                      ),
                      if (isLinked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Linked',
                              style: TextStyle(
                                  color: AppTheme.accentPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: isLinked
                            ? AppTheme.accentPrimary
                            : AppTheme.textSecondary,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isLinked)
              const Icon(Icons.check_circle,
                  size: 20, color: AppTheme.accentPrimary)
            else
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider).valueOrNull;
    final authUser = authState?.authUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.accentPrimary)),
      );
    }

    final isOrg = user.role == UserRole.organization;
    final isPro = user.role == UserRole.healthcareProfessional;
    final isMember = user.role == UserRole.member;

    // Check credentials logic
    final hasEmail = authUser?.email != null && authUser!.email!.isNotEmpty;
    final hasPhone =
        authUser?.phoneNumber != null && authUser!.phoneNumber!.isNotEmpty;

    // (Username logic removed since it is read-only)

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profile',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.surface,
        iconTheme: const IconThemeData(color: AppTheme.accentPrimary),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
          child: FilledButton(
            onPressed: _hasChanges ? _saveChanges : null,
            style: FilledButton.styleFrom(
              backgroundColor:
                  _hasChanges ? AppTheme.accentPrimary : AppTheme.surfaceLight,
              foregroundColor: _hasChanges
                  ? AppTheme.surface
                  : AppTheme.textSecondary.withValues(alpha: 0.5),
              disabledBackgroundColor: AppTheme.surfaceLight,
              disabledForegroundColor:
                  AppTheme.textSecondary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture Placeholder
              Center(
                child: GestureDetector(
                  onTap: _isUploadingProfilePic ? null : _pickAndUploadImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        child: user.profilePicture == null
                            ? Icon(Icons.person,
                                size: 50, color: Theme.of(context).textTheme.bodySmall?.color)
                            : null,
                      ),
                      if (_isUploadingProfilePic)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      if (!_isUploadingProfilePic)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPrimary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppTheme.surface, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: AppTheme.surface),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Basic Info Section
              const Text('Basic Information',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentPrimary)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                readOnly: true,
                style: TextStyle(
                    color: AppTheme.textPrimary.withValues(alpha: 0.5)),
                decoration: _buildInputDecoration(
                  'Unique Username (@handle)',
                  Icons.alternate_email,
                  suffixIcon: Icon(Icons.lock_outline,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      size: 20),
                ).copyWith(
                  fillColor: AppTheme.surfaceLight.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: _buildInputDecoration(
                  isOrg ? 'Organization Name' : 'Display Name',
                  isOrg ? Icons.domain : Icons.person_outline,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 3,
                minLines: 1,
                decoration: _buildInputDecoration(
                  'Bio',
                  Icons.info_outline,
                ),
              ),

              const SizedBox(height: 32),

              // Role Specific Section
              if (!isMember) ...[
                const Text('Professional Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentPrimary)),
                const SizedBox(height: 16),
                if (isPro) ...[
                  TextFormField(
                    controller: _specialtyController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _buildInputDecoration(
                        'Specialty', Icons.medical_information_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _licenseController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _buildInputDecoration(
                        'License Number', Icons.badge_outlined),
                  ),
                ],
                if (isOrg) ...[
                  TextFormField(
                    controller: _servicesController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _buildInputDecoration(
                        'Services', Icons.business_center_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _registrationController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _buildInputDecoration(
                        'Registration Number', Icons.badge_outlined),
                  ),
                ],
                const SizedBox(height: 32),
              ],

              // Account Linking Section
              const Text('Account Security',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentPrimary)),
              const SizedBox(height: 16),

              _buildLinkButton(
                icon: Icons.g_mobiledata,
                title: 'Google Account',
                subtitle: hasEmail
                    ? user.email
                    : 'Sign in easily with your Google account',
                isLinked: hasEmail,
                onTap: hasEmail
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(authProvider.notifier)
                              .linkGoogleAccount();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Account linked successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceAll('Exception: ', ''))),
                            );
                          }
                        }
                      },
              ),
              const SizedBox(height: 16),

              _buildLinkButton(
                icon: Icons.phone_android,
                title: 'Phone Number',
                subtitle: hasPhone
                    ? user.phoneNumber ?? ''
                    : 'Secure your account with SMS verification',
                isLinked: hasPhone,
                onTap: hasPhone
                    ? null
                    : () {
                        // Navigate to phone auth screen to link
                        context.push(AppRoutes.phoneAuth);
                      },
              ),
              const SizedBox(height: 16),

              // Verification Badge Section
              if (!user.isVerified) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const UserBadge(
                              role: UserRole.member,
                              isVerified: true,
                              iconSize: 26),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Verification Badge',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.appliedForVerification
                                      ? 'Application under review'
                                      : 'Establish trust in the community',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!user.appliedForVerification) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await ref
                                  .read(authProvider.notifier)
                                  .applyForVerification();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Your application has been submitted.')),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.accentPrimary,
                              side: const BorderSide(
                                  color: AppTheme.accentPrimary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Apply Now',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
