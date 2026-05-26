import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../core/colors.dart';

class EditShopHoursPage extends StatefulWidget {
  const EditShopHoursPage({super.key});

  @override
  State<EditShopHoursPage> createState() => _EditShopHoursPageState();
}

class _EditShopHoursPageState extends State<EditShopHoursPage> {
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  List<String> _operatingDays = [];

  final List<String> _allDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  final Map<String, String> _dayLabels = {
    'monday': 'Senin',
    'tuesday': 'Selasa',
    'wednesday': 'Rabu',
    'thursday': 'Kamis',
    'friday': 'Jumat',
    'saturday': 'Sabtu',
    'sunday': 'Minggu'
  };

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final shop = state.user.shop;
      
      if (shop?.openTime != null) {
        final parts = shop!.openTime!.split(':');
        if (parts.length >= 2) {
          _openTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      if (shop?.closeTime != null) {
        final parts = shop!.closeTime!.split(':');
        if (parts.length >= 2) {
          _closeTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      
      _operatingDays = List.from(shop?.operatingDays ?? []);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final initialTime = isOpenTime
        ? (_openTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (_closeTime ?? const TimeOfDay(hour: 17, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  void _handleSave() {
    if (_openTime == null || _closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih waktu Buka dan Tutup terlebih dahulu.')),
      );
      return;
    }

    if (_operatingDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 hari operasional.')),
      );
      return;
    }

    final openTimeStr = '${_openTime!.hour.toString().padLeft(2, '0')}:${_openTime!.minute.toString().padLeft(2, '0')}';
    final closeTimeStr = '${_closeTime!.hour.toString().padLeft(2, '0')}:${_closeTime!.minute.toString().padLeft(2, '0')}';

    context.read<ProfileBloc>().add(
      ProfileUpdateShopHoursRequested(
        openTime: openTimeStr,
        closeTime: closeTimeStr,
        operatingDays: _operatingDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context);
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
              'Jam Operasional',
              style: TextStyle(color: AppColors.textHeading),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Waktu Buka & Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Buka', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _openTime?.format(context) ?? '--:--',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tutup', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_filled, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _closeTime?.format(context) ?? '--:--',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Hari Beroperasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: _allDays.map((day) {
                      return CheckboxListTile(
                        title: Text(_dayLabels[day]!),
                        value: _operatingDays.contains(day),
                        activeColor: AppColors.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _operatingDays.add(day);
                            } else {
                              _operatingDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
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
                      : const Text('Simpan Jam Operasional', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
