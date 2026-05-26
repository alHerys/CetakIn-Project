import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../bloc/order/customer/customer_order_bloc.dart';
import '../../bloc/order/customer/customer_order_event.dart';
import '../../bloc/order/customer/customer_order_state.dart';
import '../core/colors.dart';
import 'order_success_page.dart';

class PrintCheckoutPage extends StatefulWidget {
  final String shopId;

  const PrintCheckoutPage({super.key, required this.shopId});

  @override
  State<PrintCheckoutPage> createState() => _PrintCheckoutPageState();
}

class _PrintCheckoutPageState extends State<PrintCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  String? _filePath;
  String? _fileName;
  
  String _paperSize = 'A4';
  String _colorMode = 'black_and_white';
  String _sides = 'single';
  String _binding = 'none';
  
  int _copies = 1;
  int _totalPages = 1;
  final TextEditingController _notesController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      if (_filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih dokumen PDF terlebih dahulu')),
        );
        return;
      }

      context.read<CustomerOrderBloc>().add(
        CustomerOrderCreateRequested(
          shopId: widget.shopId,
          filePath: _filePath!,
          paperSize: _paperSize,
          colorMode: _colorMode,
          sides: _sides,
          binding: _binding,
          copies: _copies,
          totalPages: _totalPages,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Pesanan Cetak', style: TextStyle(color: AppColors.textHeading)),
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      body: BlocConsumer<CustomerOrderBloc, CustomerOrderState>(
        listener: (context, state) {
          if (state is CustomerOrderActionSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrderSuccessPage(order: state.order!),
              ),
            );
          } else if (state is CustomerOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CustomerOrderActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('1. Pilih Dokumen'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: isLoading ? null : _pickFile,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _filePath != null ? AppColors.primary : AppColors.border,
                          width: _filePath != null ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _filePath != null ? Icons.picture_as_pdf : Icons.upload_file,
                            size: 48,
                            color: _filePath != null ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _fileName ?? 'Pilih file PDF (Maks 10MB)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _filePath != null ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: _filePath != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('2. Spesifikasi Cetak'),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    'Ukuran Kertas',
                    _paperSize,
                    ['A4', 'A3', 'F4'],
                    (val) => setState(() => _paperSize = val!),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    'Mode Warna',
                    _colorMode,
                    ['black_and_white', 'full_color'],
                    (val) => setState(() => _colorMode = val!),
                    labels: {'black_and_white': 'Hitam Putih', 'full_color': 'Berwarna'},
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    'Sisi Cetak',
                    _sides,
                    ['single', 'double'],
                    (val) => setState(() => _sides = val!),
                    labels: {'single': 'Satu Sisi', 'double': 'Bolak Balik'},
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownRow(
                    'Penjilidan',
                    _binding,
                    ['none', 'staple', 'spiral'],
                    (val) => setState(() => _binding = val!),
                    labels: {'none': 'Tidak Dijilid', 'staple': 'Staples', 'spiral': 'Jilid Spiral'},
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('3. Kuantitas'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _copies.toString(),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Jumlah Salinan (Copy)'),
                          onChanged: (val) => _copies = int.tryParse(val) ?? 1,
                          validator: (val) => (int.tryParse(val ?? '') ?? 0) < 1 ? 'Minimal 1' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _totalPages.toString(),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Total Halaman PDF'),
                          onChanged: (val) => _totalPages = int.tryParse(val) ?? 1,
                          validator: (val) => (int.tryParse(val ?? '') ?? 0) < 1 ? 'Minimal 1' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('4. Catatan Tambahan (Opsional)'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _inputDecoration('Contoh: Tolong jilid pakai cover warna biru...'),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: isLoading ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Pesan Sekarang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textHeading,
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> items, ValueChanged<String?> onChanged, {Map<String, String>? labels}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(labels != null ? labels[item]! : item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
