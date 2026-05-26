import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../core/colors.dart';
import '../widgets/auth_text_field.dart';

class EditShopInfoPage extends StatefulWidget {
  const EditShopInfoPage({super.key});

  @override
  State<EditShopInfoPage> createState() => _EditShopInfoPageState();
}

class _EditShopInfoPageState extends State<EditShopInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _shopNameController;
  late TextEditingController _shopPhoneController;
  late TextEditingController _shopDescriptionController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final user = state is ProfileLoaded ? state.user : null;

    _shopNameController = TextEditingController(text: user?.shop?.shopName);
    _shopPhoneController = TextEditingController(text: user?.shop?.shopPhone);
    _shopDescriptionController =
        TextEditingController(text: user?.shop?.shopDescription);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopPhoneController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        context.read<ProfileBloc>().add(
              ProfileUpdateProfileAndShopRequested(
                name: state.user.name ?? '',
                email: state.user.email ?? '',
                phone: state.user.phone ?? '',
                shopName: _shopNameController.text.isNotEmpty
                    ? _shopNameController.text
                    : null,
                shopPhone: _shopPhoneController.text.isNotEmpty
                    ? _shopPhoneController.text
                    : null,
                shopDescription: _shopDescriptionController.text.isNotEmpty
                    ? _shopDescriptionController.text
                    : null,
              ),
            );
      }
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
          Navigator.pop(context); // Go back after success
        } else if (state is ProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final isLoading = state is ProfileUpdateLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(),
              title: const Text(
                'Edit Informasi Toko',
                style: TextStyle(color: AppColors.textHeading),
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
                      'Informasi Dasar Toko',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                              'Simpan Perubahan',
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
