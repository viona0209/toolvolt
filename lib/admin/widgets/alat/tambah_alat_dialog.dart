import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../overlay_message.dart' show OverlayMessage;
import '../../services/supabase_alat_service.dart';

class TambahAlatDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const TambahAlatDialog({
    super.key,
    required this.onSuccess,
  });

  @override
  State<TambahAlatDialog> createState() => _TambahAlatDialogState();
}

class _TambahAlatDialogState extends State<TambahAlatDialog> {
  final _service = SupabaseAlatService();

  final namaCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final kondisiCtrl = TextEditingController(text: 'Baik');
  final tersediaCtrl = TextEditingController();

  String? selectedKategori;
  File? selectedImageMobile;
  Uint8List? selectedImageBytesWeb;

  bool isLoadingKategori = true;
  List<Map<String, dynamic>> kategoriList = [];

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    try {
      final data = await _service.fetchKategori();
      setState(() {
        kategoriList = data;
        isLoadingKategori = false;
        if (data.isNotEmpty) {
          selectedKategori = data.first['nama_kategori'] as String;
        }
      });
    } catch (e) {
      setState(() => isLoadingKategori = false);
      if (mounted) {
        OverlayMessage.show(
          context: context,
          message: 'Gagal memuat kategori: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      selectedImageMobile = File(img.path);
    });

    if (kIsWeb) {
      final bytes = await img.readAsBytes();
      setState(() => selectedImageBytesWeb = bytes);
    }
  }

  Future<void> _submit() async {
    final nama = namaCtrl.text.trim();
    final total = int.tryParse(totalCtrl.text) ?? 0;
    final tersedia = int.tryParse(tersediaCtrl.text) ?? 0;
    final kondisi = kondisiCtrl.text.trim().isEmpty ? 'Baik' : kondisiCtrl.text.trim();

    if (nama.isEmpty ||
        total <= 0 ||
        tersedia < 0 ||
        tersedia > total ||
        selectedKategori == null) {
      OverlayMessage.show(
        context: context,
        message: 'Lengkapi semua data dengan benar',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      String? imageUrl;

      if (selectedImageMobile != null || selectedImageBytesWeb != null) {
        imageUrl = await _service.uploadImage(
          mobileFile: selectedImageMobile,
          webBytes: selectedImageBytesWeb,
        );
      }

      final success = await _service.insertAlat(
        nama: nama,
        idKategoriNama: selectedKategori!,
        kondisi: kondisi,
        total: total,
        tersedia: tersedia,
        imageUrl: imageUrl,
      );

      if (success && mounted) {
  Navigator.pop(context); // tutup dialog dulu
  OverlayMessage.show(
    context: context,
    message: 'Alat berhasil ditambahkan!',
  );
  widget.onSuccess(); // baru reload data
}
    } catch (e) {
      if (mounted) {
        OverlayMessage.show(
          context: context,
          message: 'Gagal menambah alat: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF7A00)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Alat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Nama Alat
              _buildLabel('Nama Alat'),
              TextField(controller: namaCtrl),
              const SizedBox(height: 14),

              // Kategori + Total
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kategori'),
                        if (isLoadingKategori)
                          const Center(child: CircularProgressIndicator())
                        else if (kategoriList.isEmpty)
                          const Text('Tidak ada kategori', style: TextStyle(color: Colors.red))
                        else
                          DropdownButtonFormField<String>(
                            value: selectedKategori,
                            hint: const Text('Pilih kategori'),
                            isExpanded: true,
                            items: kategoriList.map((kat) {
                              final name = kat['nama_kategori'] as String;
                              return DropdownMenuItem(value: name, child: Text(name));
                            }).toList(),
                            onChanged: (v) => setState(() => selectedKategori = v),
                            decoration: _inputDecoration(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Total'),
                        TextField(
                          controller: totalCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Kondisi + Tersedia
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kondisi'),
                        TextField(controller: kondisiCtrl),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tersedia'),
                        TextField(
                          controller: tersediaCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Gambar
              _buildLabel('Gambar Alat'),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF7A00)),
                  ),
                  child: _buildImagePreview(),
                ),
              ),

              const SizedBox(height: 24),

              // Tombol
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF7A00)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    child: const Text('Batal', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    child: const Text('Tambah', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (selectedImageMobile == null && selectedImageBytesWeb == null) {
      return const Center(
        child: Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: kIsWeb
          ? (selectedImageBytesWeb != null
              ? Image.memory(selectedImageBytesWeb!, fit: BoxFit.cover)
              : const Center(child: CircularProgressIndicator()))
          : Image.file(selectedImageMobile!, fit: BoxFit.cover),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF7A00)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 1.5),
      ),
    );
  }
}
