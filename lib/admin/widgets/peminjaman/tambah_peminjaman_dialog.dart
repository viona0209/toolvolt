import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class TambahPeminjamanDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const TambahPeminjamanDialog({
    super.key,
    required this.onSuccess,
  });

  @override
  State<TambahPeminjamanDialog> createState() => _TambahPeminjamanDialogState();
}

class _TambahPeminjamanDialogState extends State<TambahPeminjamanDialog> {
  List<Map<String, dynamic>> daftarPengguna = [];
  List<Map<String, dynamic>> daftarAlat = [];

  int? selectedPenggunaId;
  final List<Map<String, dynamic>> selectedItems = [];

  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;

  bool isLoading = true;

  static const primaryOrange = Color(0xFFFF8E01);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final penggunaRes = await supabase
          .from('pengguna')
          .select('id_pengguna, nama')
          .order('nama');

      final alatRes = await supabase
          .from('alat')
          .select('id_alat, nama_alat, jumlah_tersedia')
          .gt('jumlah_tersedia', 0)
          .order('nama_alat');

      if (mounted) {
        setState(() {
          daftarPengguna = List<Map<String, dynamic>>.from(penggunaRes);
          daftarAlat = List<Map<String, dynamic>>.from(alatRes);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(bool isPinjam) async {
    final initialDate = isPinjam
        ? DateTime.now()
        : (tanggalPinjam ?? DateTime.now()).add(const Duration(days: 7));

    final firstDate = isPinjam
        ? DateTime.now().subtract(const Duration(days: 365))
        : (tanggalPinjam ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = picked;
          // Reset tanggal kembali jika lebih awal dari pinjam
          if (tanggalKembali != null && tanggalKembali!.isBefore(picked)) {
            tanggalKembali = null;
          }
        } else {
          tanggalKembali = picked;
        }
      });
    }
  }

  void _addItem() {
    if (daftarAlat.isEmpty) return;
    final defaultAlat = daftarAlat.first;
    setState(() {
      selectedItems.add({
        'id_alat': defaultAlat['id_alat'],
        'nama_alat': defaultAlat['nama_alat'],
        'jumlah': 1,
        'stok_tersedia': defaultAlat['jumlah_tersedia'],
      });
    });
  }

  Future<void> _savePeminjaman() async {
    if (selectedPenggunaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih peminjam terlebih dahulu')),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu alat')),
      );
      return;
    }

    if (tanggalPinjam == null || tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi tanggal pinjam dan kembali')),
      );
      return;
    }

    for (var item in selectedItems) {
      if (item['jumlah'] > item['stok_tersedia']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jumlah ${item['nama_alat']} melebihi stok tersedia'),
          ),
        );
        return;
      }
    }

    try {
      final peminjamanRes = await supabase.from('peminjaman').insert({
        'id_pengguna': selectedPenggunaId,
        'tanggal_pinjam': DateFormat('yyyy-MM-dd').format(tanggalPinjam!),
        'tanggal_kembali': DateFormat('yyyy-MM-dd').format(tanggalKembali!),
        'status': 'dipinjam',
      }).select('id_peminjaman').single();

      final idPeminjaman = peminjamanRes['id_peminjaman'] as int;

      for (var item in selectedItems) {
        await supabase.from('detail_peminjaman').insert({
          'id_peminjaman': idPeminjaman,
          'id_alat': item['id_alat'],
          'jumlah': item['jumlah'],
        });
      }

      Navigator.pop(context);
      widget.onSuccess();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Text(
                'Tambah Peminjaman Baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 28),

            // Bagian 1: Peminjam
            _buildSectionLabel('Peminjam'),
            DropdownButtonFormField<int?>(
              value: selectedPenggunaId,
              hint: const Text('Pilih nama peminjam'),
              isExpanded: true,
              decoration: _inputStyle(),
              items: daftarPengguna.map((p) {
                return DropdownMenuItem<int>(
                  value: p['id_pengguna'],
                  child: Text(p['nama'] ?? '-'),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedPenggunaId = val),
            ),
            const SizedBox(height: 24),

            // Bagian 2: Daftar Alat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel('Alat yang Dipinjam'),
                if (selectedItems.length < 5)
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: primaryOrange),
                    label: const Text('Tambah alat', style: TextStyle(color: primaryOrange)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (selectedItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada alat yang dipilih',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    return _buildAlatItem(index, item, screenWidth);
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Bagian 3: Tanggal
            _buildSectionLabel('Periode Pinjam'),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Pinjam',
                    value: tanggalPinjam,
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Kembali',
                    value: tanggalKembali,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrange, width: 1.5),
                    foregroundColor: primaryOrange,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _savePeminjaman,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Peminjaman'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAlatItem(int index, Map<String, dynamic> item, double screenWidth) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: item['id_alat'],
                    isExpanded: true,
                    decoration: _inputStyle().copyWith(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: daftarAlat.map((a) {
                      return DropdownMenuItem<int>(
                        value: a['id_alat'],
                        child: Text(
                          '${a['nama_alat']} (stok: ${a['jumlah_tersedia']})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      final newAlat = daftarAlat.firstWhere((a) => a['id_alat'] == newId);
                      setState(() {
                        selectedItems[index] = {
                          'id_alat': newId,
                          'nama_alat': newAlat['nama_alat'],
                          'jumlah': item['jumlah'],
                          'stok_tersedia': newAlat['jumlah_tersedia'],
                        };
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    setState(() => selectedItems.removeAt(index));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Jumlah: ', style: TextStyle(fontSize: 14)),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    initialValue: item['jumlah'].toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: _inputStyle().copyWith(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (val) {
                      final qty = int.tryParse(val) ?? 1;
                      setState(() {
                        selectedItems[index]['jumlah'] = qty.clamp(1, item['stok_tersedia']);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'dari ${item['stok_tersedia']} tersedia',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: _inputStyle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? DateFormat('dd MMM yyyy').format(value) : 'Pilih tanggal',
                  style: TextStyle(
                    color: value != null ? Colors.black87 : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20, color: primaryOrange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputStyle() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}