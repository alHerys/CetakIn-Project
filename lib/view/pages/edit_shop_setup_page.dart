import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../core/colors.dart';
import '../widgets/auth_text_field.dart';

class EditShopSetupPage extends StatefulWidget {
  const EditShopSetupPage({super.key});

  @override
  State<EditShopSetupPage> createState() => _EditShopSetupPageState();
}

class _EditShopSetupPageState extends State<EditShopSetupPage> {
  final _servicesFormKey = GlobalKey<FormState>();
  final _pricingFormKey = GlobalKey<FormState>();

  // Services State
  List<String> _paperSizes = [];
  List<String> _colorModes = [];
  List<String> _sides = [];
  List<String> _bindings = [];

  // Pricing Controllers
  late TextEditingController _bwController;
  late TextEditingController _colorController;
  late TextEditingController _doubleSideController;
  late TextEditingController _bindingNoneController;
  late TextEditingController _bindingStapleController;
  late TextEditingController _bindingSpiralController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final service = state.user.shop?.shopService;
      _paperSizes = List.from(service?.paperSizes ?? []);
      _colorModes = List.from(service?.colorModes ?? []);
      _sides = List.from(service?.sides ?? []);
      _bindings = List.from(service?.bindings ?? []);

      String formatCurrency(int? value) {
        if (value == null) return '';
        final chars = value.toString().split('').reversed.toList();
        final result = <String>[];
        for (int i = 0; i < chars.length; i++) {
          if (i % 3 == 0 && i != 0) result.add('.');
          result.add(chars[i]);
        }
        return result.reversed.join('');
      }

      final pricing = state.user.shop?.shopPricing;
      _bwController = TextEditingController(text: formatCurrency(pricing?.blackAndWhitePerPage));
      _colorController = TextEditingController(text: formatCurrency(pricing?.fullColorPerPage));
      _doubleSideController = TextEditingController(text: formatCurrency(pricing?.doubleSideSurcharge));
      
      final bp = pricing?.bindingPrices;
      _bindingNoneController = TextEditingController(text: formatCurrency(bp?['none']));
      _bindingStapleController = TextEditingController(text: formatCurrency(bp?['staple']));
      _bindingSpiralController = TextEditingController(text: formatCurrency(bp?['spiral']));
    } else {
      _bwController = TextEditingController();
      _colorController = TextEditingController();
      _doubleSideController = TextEditingController();
      _bindingNoneController = TextEditingController();
      _bindingStapleController = TextEditingController();
      _bindingSpiralController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _bwController.dispose();
    _colorController.dispose();
    _doubleSideController.dispose();
    _bindingNoneController.dispose();
    _bindingStapleController.dispose();
    _bindingSpiralController.dispose();
    super.dispose();
  }

  void _handleSaveServices() {
    if (_servicesFormKey.currentState!.validate()) {
      if (_paperSizes.isEmpty || _colorModes.isEmpty || _sides.isEmpty || _bindings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one option for each service category')),
        );
        return;
      }

      context.read<ProfileBloc>().add(
        ProfileUpdateShopServicesRequested(
          paperSizes: _paperSizes,
          colorModes: _colorModes,
          sides: _sides,
          bindings: _bindings,
        ),
      );
    }
  }

  void _handleSavePricing() {
    if (_pricingFormKey.currentState!.validate()) {
      int parseCurrency(String value) {
        return int.tryParse(value.replaceAll('.', '')) ?? 0;
      }

      final bindingPrices = <String, int>{};
      if (_bindingNoneController.text.isNotEmpty) {
        bindingPrices['none'] = parseCurrency(_bindingNoneController.text);
      }
      if (_bindingStapleController.text.isNotEmpty) {
        bindingPrices['staple'] = parseCurrency(_bindingStapleController.text);
      }
      if (_bindingSpiralController.text.isNotEmpty) {
        bindingPrices['spiral'] = parseCurrency(_bindingSpiralController.text);
      }

      context.read<ProfileBloc>().add(
        ProfileUpdateShopPricingRequested(
          blackAndWhitePerPage: parseCurrency(_bwController.text),
          fullColorPerPage: parseCurrency(_colorController.text),
          doubleSideSurcharge: parseCurrency(_doubleSideController.text),
          bindingPrices: bindingPrices,
        ),
      );
    }
  }

  Widget _buildCheckboxGroup(String title, Map<String, String> options, List<String> selectedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: options.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.value),
                value: selectedList.contains(entry.key),
                activeColor: AppColors.primary,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedList.add(entry.key);
                    } else {
                      selectedList.remove(entry.key);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdateLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: AppColors.textHeading),
              title: const Text(
                'Shop Setup',
                style: TextStyle(color: AppColors.textHeading),
              ),
              bottom: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Services'),
                  Tab(text: 'Pricing'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // SERVICES TAB
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _servicesFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCheckboxGroup(
                          'Paper Sizes',
                          {'A4': 'A4', 'A3': 'A3', 'F4': 'F4'},
                          _paperSizes,
                        ),
                        _buildCheckboxGroup(
                          'Color Modes',
                          {'black_and_white': 'Black & White', 'full_color': 'Full Color'},
                          _colorModes,
                        ),
                        _buildCheckboxGroup(
                          'Print Sides',
                          {'single': 'Single Side', 'double': 'Double Side'},
                          _sides,
                        ),
                        _buildCheckboxGroup(
                          'Bindings',
                          {'none': 'No Binding', 'staple': 'Staple', 'spiral': 'Spiral'},
                          _bindings,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleSaveServices,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Save Services', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                // PRICING TAB
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _pricingFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Print Pricing (per page)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _bwController,
                          labelText: 'Black & White',
                          hintText: 'e.g. 500',
                          icon: Icons.print,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _colorController,
                          labelText: 'Full Color',
                          hintText: 'e.g. 1.000',
                          icon: Icons.color_lens,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _doubleSideController,
                          labelText: 'Double Side Surcharge',
                          hintText: 'e.g. 200',
                          icon: Icons.flip,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Binding Pricing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _bindingNoneController,
                          labelText: 'No Binding (None)',
                          hintText: 'e.g. 0',
                          icon: Icons.book,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _bindingStapleController,
                          labelText: 'Staple',
                          hintText: 'e.g. 2.000',
                          icon: Icons.book,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _bindingSpiralController,
                          labelText: 'Spiral',
                          hintText: 'e.g. 5.000',
                          icon: Icons.book,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleSavePricing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Save Pricing', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
      final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      
      if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

      final chars = digitsOnly.split('').reversed.toList();
      final newString = <String>[];
      for (int i = 0; i < chars.length; i++) {
        if (i % 3 == 0 && i != 0) newString.add('.');
        newString.add(chars[i]);
      }
      final result = newString.reversed.join('');
      
      // Calculate new cursor position
      int newSelectionEnd = result.length - selectionIndexFromTheRight;
      if (newSelectionEnd < 0) newSelectionEnd = 0;
      
      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: newSelectionEnd),
      );
    } else {
      return newValue;
    }
  }
}
