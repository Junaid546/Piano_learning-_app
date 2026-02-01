import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _learningGoalController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String _skillLevel = 'beginner';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(authProvider).userModel;
    final displayName = user?.displayName;
    if (displayName != null) {
      _nameController.text = displayName;
      // Load other fields from Firestore if available
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _learningGoalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileActions = ref.read(profileActionsProvider);

      // Upload profile picture if selected
      if (_selectedImage != null) {
        await profileActions.uploadProfilePicture(_selectedImage!);
      }

      // Update profile information
      await profileActions.updateProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        learningGoal: _learningGoalController.text.trim(),
        skillLevel: _skillLevel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (user?.profileImageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              user!.profileImageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                            ),
                            child:
                                _selectedImage == null &&
                                    user?.profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Display Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Display Name',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email (read-only)
                    CustomTextField(
                      initialValue: user?.email ?? '',
                      label: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    CustomTextField(
                      controller: _bioController,
                      label: 'Bio (Optional)',
                      prefixIcon: const Icon(Icons.info),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Learning Goal
                    CustomTextField(
                      controller: _learningGoalController,
                      label: 'Learning Goal (Optional)',
                      prefixIcon: const Icon(Icons.flag),
                    ),

                    const SizedBox(height: 16),

                    // Skill Level
                    DropdownButtonFormField<String>(
                      initialValue: _skillLevel,
                      decoration: InputDecoration(
                        labelText: 'Skill Level',
                        prefixIcon: const Icon(Icons.star),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'beginner',
                          child: Text('Beginner'),
                        ),
                        DropdownMenuItem(
                          value: 'intermediate',
                          child: Text('Intermediate'),
                        ),
                        DropdownMenuItem(
                          value: 'advanced',
                          child: Text('Advanced'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _skillLevel = value);
                        }
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _saveProfile,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
