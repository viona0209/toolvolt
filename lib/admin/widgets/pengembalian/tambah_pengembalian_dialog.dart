import 'package:flutter/material.dart';

class TambahPengembalianDialog extends StatelessWidget {
  final VoidCallback? onSuccess;

  const TambahPengembalianDialog({
    super.key,
    this.onSuccess,
  });

  static const primaryOrange = Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: primaryOrange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setState) {
            String? selectedPeminjaman;
            String? selectedKondisi = 'Baik';
            final catatanController = TextEditingController();

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Tambah Pengembalian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Pilih peminjaman'),
                  DropdownButtonFormField<String?>(
                    value: selectedPeminjaman,
                    isExpanded: true,
                    hint: const Text('Pilih ID / Nama peminjam'),
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: '1 - Dewi Lestari', child: Text('1 - Dewi Lestari')),
                      DropdownMenuItem(value: '2 - Ahmad Rizky', child: Text('2 - Ahmad Rizky')),
                      DropdownMenuItem(value: '3 - Budi Santoso', child: Text('3 - Budi Santoso')),
                    ],
                    onChanged: (val) => setState(() => selectedPeminjaman = val),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Kondisi alat'),
                            DropdownButtonFormField<String?>(
                              value: selectedKondisi,
                              isExpanded: true,
                              decoration: _inputDecoration(),
                              items: const [
                                DropdownMenuItem(value: 'Baik', child: Text('Baik')),
                                DropdownMenuItem(value: 'Rusak Ringan', child: Text('Rusak Ringan')),
                                DropdownMenuItem(value: 'Rusak Berat', child: Text('Rusak Berat')),
                                DropdownMenuItem(value: 'Hilang', child: Text('Hilang')),
                              ],
                              onChanged: (val) => setState(() => selectedKondisi = val),
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
                            _buildLabel('Kondisi'),
                            Container(
                              height: 56,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryOrange),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                selectedKondisi ?? '-',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Catatan (opsional)'),
                  TextField(
                    controller: catatanController,
                    maxLines: 3,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryOrange, width: 1.5),
                          foregroundColor: primaryOrange,
                          minimumSize: const Size(110, 46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedPeminjaman == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih peminjaman terlebih dahulu')),
                            );
                            return;
                          }

                          // TODO: Nanti di sini tambahkan insert ke Supabase
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengembalian berhasil ditambahkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          onSuccess?.call(); // Refresh list di screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(130, 46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Tambah'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF7A00)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 2),
        ),
      );
}