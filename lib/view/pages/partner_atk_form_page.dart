import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../bloc/atk/partner/partner_atk_bloc.dart';
import '../../../bloc/atk/partner/partner_atk_event.dart';
import '../../../bloc/atk/partner/partner_atk_state.dart';
import '../../../data/models/atk/atk_product_model.dart';
import '../core/colors.dart';

class PartnerAtkFormPage extends StatefulWidget {
  final AtkProductModel? product;

  const PartnerAtkFormPage({super.key, this.product});

  @override
  State<PartnerAtkFormPage> createState() => _PartnerAtkFormPageState();
}

class _PartnerAtkFormPageState extends State<PartnerAtkFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isAvailable = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name ?? '';
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price?.toString() ?? '';
      _stockController.text = widget.product!.stock?.toString() ?? '';
      _isAvailable = widget.product!.isAvailable ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      MultipartFile? photoFile;
      if (_selectedImage != null) {
        photoFile = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        );
      }

      if (!mounted) return;

      if (widget.product == null) {
        context.read<PartnerAtkBloc>().add(
          PartnerAtkCreateRequested(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: int.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
            stock: int.parse(_stockController.text.replaceAll(RegExp(r'[^0-9]'), '')),
            isAvailable: _isAvailable,
            photo: photoFile,
          ),
        );
      } else {
        context.read<PartnerAtkBloc>().add(
          PartnerAtkUpdateRequested(
            id: widget.product!.id!,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: int.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
            stock: int.parse(_stockController.text.replaceAll(RegExp(r'[^0-9]'), '')),
            isAvailable: _isAvailable,
            photo: photoFile,
          ),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PartnerAtkBloc>().add(PartnerAtkDeleteRequested(widget.product!.id!));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk ATK' : 'Tambah Produk ATK', style: const TextStyle(color: AppColors.textHeading)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: BlocListener<PartnerAtkBloc, PartnerAtkState>(
        listener: (context, state) {
          if (state is PartnerAtkActionSuccess) {
            Navigator.pop(context); // Go back to catalog
          } else if (state is PartnerAtkFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Produk',
                  icon: Icons.inventory_2_outlined,
                  validator: (value) => value == null || value.isEmpty ? 'Nama produk wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi Produk (Opsional)',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _priceController,
                        label: 'Harga (Rp)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Harga wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _stockController,
                        label: 'Stok',
                        icon: Icons.layers_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Stok wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Status Ketersediaan', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHeading)),
                  subtitle: Text(_isAvailable ? 'Produk dapat dibeli' : 'Produk sedang kosong', style: const TextStyle(color: AppColors.textSecondary)),
                  value: _isAvailable,
                  activeThumbColor: AppColors.primary,
                  onChanged: (bool value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 40),
                BlocBuilder<PartnerAtkBloc, PartnerAtkState>(
                  builder: (context, state) {
                    final isLoading = state is PartnerAtkActionLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _selectedImage != null
              ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)
              : (widget.product?.photoUrl != null
                  ? Image.network(widget.product!.photoUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Upload Foto Produk', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                        const SizedBox(height: 4),
                        const Text('Format JPG/PNG, Maks. 5MB', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    )),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.primary) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }


}
