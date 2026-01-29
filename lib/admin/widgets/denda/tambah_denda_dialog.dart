import 'package:flutter/material.dart';

class TambahDendaDialog extends StatelessWidget {
  final Function(String, int) onTambah;

  const TambahDendaDialog({
    super.key,
    required this.onTambah,
  });

  static const primaryOrange = Color(0xFFFF7733);

  @override
  Widget build(BuildContext context) {
    final namaController = TextEditingController();
    final biayaController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: primaryOrange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah Denda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            _buildLabel('Nama Denda'),
            TextField(
              controller: namaController,
              decoration: _inputDecoration(),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            _buildLabel('Biaya'),
            TextField(
              controller: biayaController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration().copyWith(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(color: Colors.black54),
              ),
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
                    final nama = namaController.text.trim();
                    final biayaText = biayaController.text.trim().replaceAll('.', '');
                    final biaya = int.tryParse(biayaText) ?? 0;

                    if (nama.isNotEmpty && biaya > 0) {
                      onTambah(nama, biaya);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lengkapi nama dan biaya dengan benar')),
                      );
                    }
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
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      );

  InputDecoration _inputDecoration() => InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF7733)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF7733), width: 2),
        ),
      );
}