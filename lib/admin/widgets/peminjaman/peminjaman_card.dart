import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final supabase = Supabase.instance.client;

class PeminjamanCard extends StatefulWidget {
  final String id;
  final String nama;
  final String tglPinjam;
  final String tglKembali;
  final String status;
  final Color statusColor;
  final String? disetujuiOleh;
  final String? dikembalikanOleh;
  final List<Map<String, dynamic>>?
  items; // [{ 'nama_alat': '...', 'jumlah': xx }]
  final String? alat;
  final int? jumlah;
  final VoidCallback? onRefresh; // Untuk refresh list setelah edit/delete

  const PeminjamanCard({
    super.key,
    required this.id,
    required this.nama,
    required this.tglPinjam,
    required this.tglKembali,
    required this.status,
    required this.statusColor,
    this.disetujuiOleh,
    this.dikembalikanOleh,
    this.items,
    this.alat,
    this.jumlah,
    this.onRefresh,
  });

  @override
  State<PeminjamanCard> createState() => _PeminjamanCardState();
}

class _PeminjamanCardState extends State<PeminjamanCard> {
  bool _isExpanded = false;

  static const primaryOrange = Color(0xFFFF8E01);

  @override
  Widget build(BuildContext context) {
    String approvalText = "Belum disetujui";
    String approvalName = "";

    final statusLower = widget.status.toLowerCase();

    if (statusLower == "dipinjam" || statusLower == "on pinjam") {
      if (widget.disetujuiOleh != null && widget.disetujuiOleh!.isNotEmpty) {
        approvalText = "Disetujui oleh";
        approvalName = widget.disetujuiOleh!;
      }
    } else if (statusLower.contains("kembali")) {
      if (widget.dikembalikanOleh != null &&
          widget.dikembalikanOleh!.isNotEmpty) {
        approvalText = "Dikembalikan oleh";
        approvalName = widget.dikembalikanOleh!;
      } else {
        approvalText = "Sudah dikembalikan";
      }
    }

    final List<Map<String, dynamic>> alatList = widget.items ?? [];
    if (alatList.isEmpty && widget.alat != null && widget.jumlah != null) {
      alatList.add({'nama_alat': widget.alat, 'jumlah': widget.jumlah});
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ID: ${widget.id}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _confirmDelete(context);
                      } else if (value == 'detail') {
                        setState(() => _isExpanded = !_isExpanded);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: primaryOrange),
                            const SizedBox(width: 12),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 12),
                            const Text('Hapus'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.blueGrey),
                            const SizedBox(width: 12),
                            const Text('Detail'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(widget.nama, style: const TextStyle(color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "Kembali: ${widget.tglKembali}",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text("$approvalText: $approvalName"),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 16),
          const Text(
            "Alat yang dipinjam:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          if (alatList.isEmpty)
            const Text("Tidak ada alat", style: TextStyle(color: Colors.grey))
          else
            Column(
              children: alatList.map((item) {
                final namaAlat = item['nama_alat'] as String? ?? 'Unknown';
                final jumlah = item['jumlah'] as int? ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildItemAlat(namaAlat, jumlah),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildItemAlat(String namaAlat, int jumlah) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              namaAlat,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              "$jumlah unit",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final idPeminjaman = int.tryParse(widget.id) ?? 0;
    if (idPeminjaman == 0) return;

    List<Map<String, dynamic>> daftarPengguna = [];
    List<Map<String, dynamic>> daftarAlat = [];
    int? selectedPenggunaId;
    DateTime? tglPinjam;
    DateTime? tglKembali;
    List<Map<String, dynamic>> editableItems = [];

    try {
      tglPinjam = DateFormat('dd/MM/yyyy').parse(widget.tglPinjam);
      tglKembali = DateFormat('dd/MM/yyyy').parse(widget.tglKembali);
    } catch (_) {
      tglPinjam = DateTime.now();
      tglKembali = DateTime.now().add(const Duration(days: 7));
    }

    // Items awal
    if (widget.items != null && widget.items!.isNotEmpty) {
      editableItems = List.from(widget.items!);
    } else if (widget.alat != null && widget.jumlah != null) {
      editableItems.add({'nama_alat': widget.alat, 'jumlah': widget.jumlah});
    }

    // Load data dari Supabase
    try {
      final penggunaRes = await supabase
          .from('pengguna')
          .select('id_pengguna, nama')
          .order('nama');
      final alatRes = await supabase
          .from('alat')
          .select('id_alat, nama_alat, jumlah_tersedia')
          .order('nama_alat');

      daftarPengguna = List<Map<String, dynamic>>.from(penggunaRes);
      daftarAlat = List<Map<String, dynamic>>.from(alatRes);

      final currentPengguna = daftarPengguna.firstWhere(
        (p) => p['nama'] == widget.nama,
        orElse: () => {},
      );

      selectedPenggunaId = currentPengguna['id_pengguna'] as int?;
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "Gagal memuat data: $e"),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          'Edit Peminjaman',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ============================
                      //         DROPDOWN USER
                      // ============================
                      const Text(
                        'Nama Peminjam',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      DropdownButtonFormField<int?>(
                        value: selectedPenggunaId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: daftarPengguna.map((p) {
                          return DropdownMenuItem<int?>(
                            value:
                                p['id_pengguna']
                                    as int?, // FIX: casting ke int?
                            child: Text(p['nama'] ?? 'Tidak diketahui'),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedPenggunaId = val),
                      ),

                      const SizedBox(height: 16),

                      // ============================
                      //        LIST ITEM ALAT
                      // ============================
                      const Text(
                        'Alat yang Dipinjam',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ...editableItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        final currentAlatId =
                            daftarAlat.firstWhere(
                                  (a) => a['nama_alat'] == item['nama_alat'],
                                  orElse: () => {'id_alat': null},
                                )['id_alat']
                                as int?;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: currentAlatId,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: daftarAlat.map((a) {
                                    return DropdownMenuItem<int>(
                                      value: a['id_alat'],
                                      child: Text(a['nama_alat']),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    final newAlat = daftarAlat.firstWhere(
                                      (a) => a['id_alat'] == val,
                                    );
                                    setDialogState(() {
                                      editableItems[index] = {
                                        'nama_alat': newAlat['nama_alat'],
                                        'jumlah': item['jumlah'] ?? 1,
                                      };
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: (item['jumlah'] ?? 1)
                                      .toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final qty = int.tryParse(val) ?? 1;
                                    setDialogState(
                                      () =>
                                          editableItems[index]['jumlah'] = qty,
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => setDialogState(
                                  () => editableItems.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Tombol tambah alat
                      TextButton.icon(
                        onPressed: () {
                          if (daftarAlat.isNotEmpty) {
                            final defaultAlat = daftarAlat.first;
                            setDialogState(() {
                              editableItems.add({
                                'nama_alat': defaultAlat['nama_alat'],
                                'jumlah': 1,
                              });
                            });
                          }
                        },
                        icon: Icon(Icons.add, color: primaryOrange),
                        label: const Text('Tambah Alat'),
                      ),
                      const SizedBox(height: 16),

                      // ============================
                      //        TANGGAL PINJAM
                      // ============================
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tgl. Pinjam',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(tglPinjam!),
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: tglPinjam!,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null)
                                      setDialogState(() => tglPinjam = picked);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ============================
                          //        TANGGAL KEMBALI
                          // ============================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tgl. Kembali',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(tglKembali!),
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: tglKembali!,
                                      firstDate: tglPinjam!,
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null)
                                      setDialogState(() => tglKembali = picked);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ============================
                      //      BUTTON SIMPAN / BATAL
                      // ============================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                            ),
                            child: const Text('Simpan'),
                            onPressed: () async {
                              if (selectedPenggunaId == null ||
                                  editableItems.isEmpty) {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(
                                    message: "Lengkapi semua field",
                                  ),
                                );
                                return;
                              }

                              try {
                                // UPDATE peminjaman
                                await supabase
                                    .from('peminjaman')
                                    .update({
                                      'id_pengguna': selectedPenggunaId,
                                      'tanggal_pinjam': DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(tglPinjam!),
                                      'tanggal_kembali': DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(tglKembali!),
                                    })
                                    .eq('id_peminjaman', idPeminjaman);

                                // HAPUS detail lama
                                await supabase
                                    .from('detail_peminjaman')
                                    .delete()
                                    .eq('id_peminjaman', idPeminjaman);

                                // INSERT detail baru
                                for (var item in editableItems) {
                                  final alat = daftarAlat.firstWhere(
                                    (a) => a['nama_alat'] == item['nama_alat'],
                                  );
                                  await supabase
                                      .from('detail_peminjaman')
                                      .insert({
                                        'id_peminjaman': idPeminjaman,
                                        'id_alat': alat['id_alat'],
                                        'jumlah': item['jumlah'],
                                      });
                                }

                                Navigator.pop(dialogContext);
                                widget.onRefresh?.call();

                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.success(
                                    message: "Edit berhasil disimpan",
                                  ),
                                );
                              } catch (e) {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.error(
                                    message: "Gagal edit: $e",
                                  ),
                                );
                              }
                            },
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
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final idPeminjaman = int.tryParse(widget.id) ?? 0;
    if (idPeminjaman == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Peminjaman?'),
        content: const Text(
          'Data peminjaman ini akan dihapus permanen (termasuk detail alat).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // Hapus detail dulu (karena FK)
        await supabase
            .from('detail_peminjaman')
            .delete()
            .eq('id_peminjaman', idPeminjaman);

        // Hapus peminjaman
        await supabase
            .from('peminjaman')
            .delete()
            .eq('id_peminjaman', idPeminjaman);

        widget.onRefresh?.call();

        // 🔥 Top Snackbar Success
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(message: "Peminjaman berhasil dihapus"),
        );
      } catch (e) {
        // 🔥 Top Snackbar Error
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(message: "Gagal hapus: $e"),
        );
      }
    }
  }
}
