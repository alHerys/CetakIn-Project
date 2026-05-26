import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../core/colors.dart';
import '../core/validator.dart';
import '../widgets/auth_text_field.dart';

class PartnerRegisterPage extends StatefulWidget {
  const PartnerRegisterPage({super.key});

  @override
  State<PartnerRegisterPage> createState() => _PartnerRegisterPageState();
}

class _PartnerRegisterPageState extends State<PartnerRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // User details
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Shop details
  final shopNameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final shopPhoneController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  
  final List<String> _days = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];
  final List<String> _selectedDays = [];

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    shopNameController.dispose();
    shopAddressController.dispose();
    shopPhoneController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hour:$minute';
      });
    }
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one operating day')),
        );
        return;
      }

      context.read<AuthBloc>().add(
            AuthRegisterPartnerRequested(
              name: fullnameController.text,
              email: emailController.text,
              phone: phoneController.text,
              password: passwordController.text,
              passwordConfirmation: confirmPasswordController.text,
              shopName: shopNameController.text,
              shopAddress: shopAddressController.text,
              shopPhone: shopPhoneController.text,
              openTime: openTimeController.text,
              closeTime: closeTimeController.text,
              operatingDays: _selectedDays,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
          'Partner Registration',
          style: TextStyle(color: AppColors.textHeading),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.read<ProfileBloc>().add(
              ProfileLoadRequested(user: state.user, token: state.token),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Awaiting approval.'),
              ),
            );
            // Navigate to Home or Login
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: fullnameController,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      validator: AppValidator.validateFullName,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: emailController,
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidator.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: phoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Phone number is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: AppValidator.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      icon: Icons.lock_clock_outlined,
                      isPassword: true,
                      validator: (value) =>
                          AppValidator.validateConfirmPassword(
                            value,
                            passwordController.text,
                          ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Shop Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: shopNameController,
                      labelText: 'Shop Name',
                      hintText: 'Enter your shop name',
                      icon: Icons.storefront_outlined,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Shop name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: shopAddressController,
                      labelText: 'Shop Address',
                      hintText: 'Enter your full shop address',
                      icon: Icons.location_on_outlined,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Shop address is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: shopPhoneController,
                      labelText: 'Shop Phone Number',
                      hintText: 'Enter your shop phone number',
                      icon: Icons.phone_in_talk_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Shop phone number is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AuthTextField(
                            controller: openTimeController,
                            labelText: 'Open Time',
                            hintText: '08:00',
                            icon: Icons.access_time,
                            readOnly: true,
                            onTap: () => _selectTime(context, openTimeController),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AuthTextField(
                            controller: closeTimeController,
                            labelText: 'Close Time',
                            hintText: '17:00',
                            icon: Icons.access_time_filled,
                            readOnly: true,
                            onTap: () => _selectTime(context, closeTimeController),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Operating Days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _days.map((day) {
                        final isSelected = _selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day[0].toUpperCase() + day.substring(1)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Register as Partner',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
