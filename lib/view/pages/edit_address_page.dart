import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../core/colors.dart';
import '../widgets/auth_text_field.dart';
import 'location_picker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final user = state is ProfileLoaded ? state.user : null;
    
    _addressController = TextEditingController(
      text: user?.role == 'partner' ? user?.shop?.shopAddress : '',
    );
    if (user?.role == 'partner') {
      _latitude = user?.shop?.latitude;
      _longitude = user?.shop?.longitude;
    } else {
      _loadLocalCustomerAddress();
    }
  }

  Future<void> _loadLocalCustomerAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('user_home_address');
    if (address != null && address.isNotEmpty) {
      setState(() {
        _addressController.text = address;
        _latitude = prefs.getDouble('user_home_lat');
        _longitude = prefs.getDouble('user_home_lng');
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded && state.user.role == 'user') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_home_address', _addressController.text);
        if (_latitude != null) await prefs.setDouble('user_home_lat', _latitude!);
        if (_longitude != null) await prefs.setDouble('user_home_lng', _longitude!);
      }

      if (!mounted) return;
      context.read<ProfileBloc>().add(
            ProfileUpdateAddressRequested(
              address: _addressController.text,
              latitude: _latitude,
              longitude: _longitude,
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
          Navigator.pop(context); // Go back after success
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
              title: const Text(
                'Edit Address',
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
                      'Address Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _addressController,
                      labelText: isPartner ? 'Shop Address' : 'Home Address',
                      hintText: 'Enter your full address',
                      icon: Icons.location_on_outlined,
                      validator: (val) => val == null || val.isEmpty ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationPickerPage(
                              initialLat: _latitude,
                              initialLng: _longitude,
                            ),
                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _latitude = result['lat'];
                            _longitude = result['lng'];
                            _addressController.text = result['address'];
                          });
                        }
                      },
                      icon: const Icon(Icons.map, color: AppColors.primary),
                      label: Text(
                        _latitude != null ? 'Ubah dari Peta' : 'Pilih dari Peta',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: Make sure your address is accurate for better service.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
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
                              'Save Address',
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
