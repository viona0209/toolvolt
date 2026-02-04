import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TambahPengembalianDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const TambahPengembalianDialog({super.key, this.onSuccess});

  @override
  State<TambahPengembalianDialog> createState() =>
      _TambahPengembalianDialogState();
}

class _TambahPengembalianDialogState extends State<TambahPengembalianDialog> {
  static const primaryOrange = Color(0xFFFF7A00);

  String? selectedPeminjaman;
  String? selectedKondisi = 'Baik';

  List<Map<String, dynamic>> listPeminjaman = [];

  final catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    final response = await Supabase.instance.client
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          pengguna:pengguna(id_pengguna, nama)
        ''')
        .eq('status', 'dipinjam');

    setState(() {
      listPeminjaman = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _submit() async {
    if (selectedPeminjaman == null) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: "Pilih peminjaman terlebih dahulu"),
      );
      return;
    }

    final int idPeminjaman = int.parse(selectedPeminjaman!);

    try {
      await Supabase.instance.client.from('pengembalian').insert({
        'id_peminjaman': idPeminjaman,
        'tanggal_pengembalian': DateTime.now().toIso8601String(),
        'kondisi_setelah': selectedKondisi,
        'catatan': catatanController.text,
      });

      await Supabase.instance.client
          .from('peminjaman')
          .update({'status': 'dikembalikan'})
          .eq('id_peminjaman', idPeminjaman);

      Navigator.pop(context);

      showTopSnackBar(
        Overlay.of(context),
        Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pengembalian berhasil ditambahkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      widget.onSuccess?.call();
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "Gagal menambah pengembalian: $e"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: primaryOrange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Tambah Pengembalian',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel('Pilih peminjaman'),
              DropdownButtonFormField<String?>(
                value: selectedPeminjaman,
                isExpanded: true,
                hint: const Text('Pilih ID / Nama peminjam'),
                decoration: _inputDecoration(),
                items: listPeminjaman.map((p) {
                  final id = p['id_peminjaman'];
                  final nama = p['pengguna']['nama'];
                  final tgl = p['tanggal_pinjam'] ?? '-';

                  return DropdownMenuItem(
                    value: "$id",
                    child: Text("$id - $nama (Pinjam: $tgl)"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedPeminjaman = val),
              ),
              const SizedBox(height: 20),
              _buildLabel('Kondisi alat setelah dikembalikan'),
              DropdownButtonFormField<String?>(
                value: selectedKondisi,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'Baik', child: Text('Baik')),
                  DropdownMenuItem(
                    value: 'Rusak Ringan',
                    child: Text('Rusak Ringan'),
                  ),
                  DropdownMenuItem(
                    value: 'Rusak Sedang',
                    child: Text('Rusak Sedang'),
                  ),
                  DropdownMenuItem(
                    value: 'Rusak Berat',
                    child: Text('Rusak Berat'),
                  ),
                  DropdownMenuItem(value: 'Hilang', child: Text('Hilang')),
                ],
                onChanged: (val) => setState(() => selectedKondisi = val),
              ),

              const SizedBox(height: 16),

              _buildLabel('Catatan (opsional)'),
              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange, width: 1.5),
                      foregroundColor: primaryOrange,
                      minimumSize: const Size(110, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(130, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tambah'),
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
