import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
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

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final user = state is AuthSuccess ? state.user : null;

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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthUpdateProfileAndShopRequested(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              shopName: _shopNameController.text.isNotEmpty ? _shopNameController.text : null,
              shopPhone: _shopPhoneController.text.isNotEmpty ? _shopPhoneController.text : null,
              shopDescription: _shopDescriptionController.text.isNotEmpty ? _shopDescriptionController.text : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context); // Go back after success
        } else if (state is AuthUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthSuccess) {
          final isPartner = state.user.role == 'partner';
          final isLoading = state is AuthUpdateLoading;

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
                      validator: (val) => val == null || val.isEmpty ? 'Phone number is required' : null,
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
                        validator: (val) => val == null || val.isEmpty ? 'Shop name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _shopPhoneController,
                        labelText: 'Shop Phone',
                        hintText: 'Enter shop phone number',
                        icon: Icons.phone_in_talk_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Shop phone is required' : null,
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
