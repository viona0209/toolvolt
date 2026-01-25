import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AlatCard extends StatelessWidget {
  final String nama;
  final String kategori;
  final String kondisi;
  final int total;
  final int tersedia;
  final int dipinjam;
  final String imagePath;

  const AlatCard({
    super.key,
    required this.nama,
    required this.kategori,
    required this.kondisi,
    required this.total,
    required this.tersedia,
    required this.dipinjam,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFE2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9B3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kategori,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(thickness: 0.8),
                    ),
                    Row(
                      children: [
                        Expanded(child: Text('Kondisi : $kondisi')),
                        Expanded(child: Text('Tersedia : $tersedia')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: Text('Total : $total')),
                        Expanded(child: Text('Dipinjam : $dipinjam')),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Divider(thickness: 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrange, width: 1.5),
                    foregroundColor: primaryOrange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrange, width: 1.5),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);
    final picker = ImagePicker();

    final nameController = TextEditingController(text: nama);
    final totalController = TextEditingController(text: total.toString());
    final tersediaController = TextEditingController(text: tersedia.toString());
    final kondisiController = TextEditingController(text: kondisi);
    String? selectedKategori = kategori;
    File? newImageFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(
                  color: primaryOrange,
                  width: 2.0,
                ), // <--- BORDER ORANYE DI CONTAINER DIALOG
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Edit Alat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      _buildLabel('Nama Alat'),
                      TextField(
                        controller: nameController,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Kategori'),
                                DropdownButtonFormField<String>(
                                  value: selectedKategori,
                                  isExpanded: true,
                                  decoration: _inputDecoration(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Alat Ukur',
                                      child: Text('Alat Ukur'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Alat Tangan',
                                      child: Text('Alat Tangan'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Alat Listrik',
                                      child: Text('Alat Listrik'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Alat Bengkel',
                                      child: Text('Alat Bengkel'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Alat Laboratorium',
                                      child: Text('Alat Laboratorium'),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => selectedKategori = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Total Stok'),
                                TextField(
                                  controller: totalController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Kondisi'),
                                TextField(
                                  controller: kondisiController,
                                  decoration: _inputDecoration(),
                                ),
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
                                  controller: tersediaController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('Gambar'),
                      GestureDetector(
                        onTap: () async {
                          final img = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img != null) {
                            setState(() => newImageFile = File(img.path));
                          }
                        },
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primaryOrange,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: newImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    newImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : imagePath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap untuk ganti gambar',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: primaryOrange,
                                width: 1.5,
                              ),
                              foregroundColor: primaryOrange,
                              minimumSize: const Size(120, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nama alat tidak boleh kosong',
                                    ),
                                  ),
                                );
                                return;
                              }
                              // TODO: simpan perubahan ke state/provider
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(140, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      totalController.dispose();
      tersediaController.dispose();
      kondisiController.dispose();
    });
  }

  void _showDeleteDialog(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: primaryOrange, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hapus Alat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Apakah kamu yakin ingin menghapus\n$nama ini?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange, width: 1.5),
                      foregroundColor: primaryOrange,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: logic hapus data
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF8E01)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF8E01), width: 2),
    ),
  );
}
