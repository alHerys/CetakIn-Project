import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../core/colors.dart';
import '../core/validator.dart';
import '../widgets/auth_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Shop controllers for partner
  late TextEditingController _shopNameController;
  late TextEditingController _shopPhoneController;
  late TextEditingController _shopDescriptionController;

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final user = state is ProfileLoaded ? state.user : null;

    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);

    // Always initialize shop controllers to avoid late initialization errors
    _shopNameController = TextEditingController(text: user?.shop?.shopName);
    _shopPhoneController = TextEditingController(text: user?.shop?.shopPhone);
    _shopDescriptionController =
        TextEditingController(text: user?.shop?.shopDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopPhoneController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
            ProfileUpdateProfileAndShopRequested(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              shopName: _shopNameController.text.isNotEmpty
                  ? _shopNameController.text
                  : null,
              shopPhone: _shopPhoneController.text.isNotEmpty
                  ? _shopPhoneController.text
                  : null,
              shopDescription: _shopDescriptionController.text.isNotEmpty
                  ? _shopDescriptionController.text
                  : null,
              avatarPath: _selectedImage?.path,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          if (state.message == 'Avatar updated successfully') {
            setState(() {
              _selectedImage = null;
            });
          } else {
            Navigator.pop(context); // Go back after profile update success
          }
        } else if (state is ProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final isPartner = state.user.role == 'partner';
          final isLoading = state is ProfileUpdateLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(),
              title: Text(
                isPartner ? 'Edit Shop Info' : 'Edit Profile',
                style: const TextStyle(color: AppColors.textHeading),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Photo Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                  image: _selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(
                                              File(_selectedImage!.path)),
                                          fit: BoxFit.cover,
                                        )
                                      : (state.user.avatarUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  state.user.avatarUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                ),
                                child: _selectedImage == null &&
                                        state.user.avatarUrl == null
                                    ? const Icon(Icons.person,
                                        size: 60, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: isLoading ? null : _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_a_photo_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedImage != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: isLoading ? null : _removeImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      icon: Icons.person_outline,
                      validator: AppValidator.validateFullName,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidator.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Phone number is required'
                          : null,
                    ),

                    if (isPartner) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Shop Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _shopNameController,
                        labelText: 'Shop Name',
                        hintText: 'Enter shop name',
                        icon: Icons.storefront_outlined,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Shop name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _shopPhoneController,
                        labelText: 'Shop Phone',
                        hintText: 'Enter shop phone number',
                        icon: Icons.phone_in_talk_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Shop phone is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _shopDescriptionController,
                        labelText: 'Shop Description',
                        hintText: 'Enter shop description',
                        icon: Icons.description_outlined,
                      ),
                    ],

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
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
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
