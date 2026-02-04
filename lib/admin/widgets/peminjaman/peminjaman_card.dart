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
  final List<Map<String, dynamic>>? items;
  final String? alat;
  final int? jumlah;
  final VoidCallback? onRefresh;

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
  static const yellowBorder = Color(0xFFFFC107);

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

    final List<Map<String, dynamic>> alatList =
        widget.items != null && widget.items!.isNotEmpty
        ? List<Map<String, dynamic>>.from(widget.items!)
        : [];

    if (alatList.isEmpty && widget.alat != null && widget.jumlah != null) {
      alatList.add({'nama_alat': widget.alat, 'jumlah': widget.jumlah});
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: yellowBorder, width: 2),
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "ID: ${widget.id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                          if (value == 'edit') _showEditDialog(context);
                          if (value == 'delete') _confirmDelete(context);
                          if (value == 'detail')
                            setState(() => _isExpanded = !_isExpanded);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: primaryOrange),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Hapus'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'detail',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.blueGrey),
                                SizedBox(width: 12),
                                Text('Detail'),
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
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.nama,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
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
                  Expanded(
                    child: Text(
                      "Kembali: ${widget.tglKembali}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text("$approvalText: $approvalName")),
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
                const Text(
                  "Tidak ada alat",
                  style: TextStyle(color: Colors.grey),
                )
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
      },
    );
  }

  Widget _buildItemAlat(String namaAlat, int jumlah) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
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
              border: Border.all(color: Colors.amber, width: 1),
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

    DateTime tglPinjam = DateTime.now();
    DateTime tglKembali = DateTime.now().add(const Duration(days: 7));

    List<Map<String, dynamic>> editableItems = [];

    try {
      tglPinjam =
          DateFormat('dd/MM/yyyy').tryParse(widget.tglPinjam) ?? DateTime.now();
      tglKembali =
          DateFormat('dd/MM/yyyy').tryParse(widget.tglKembali) ??
          tglPinjam.add(const Duration(days: 7));

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
        orElse: () => {'id_pengguna': null},
      );
      selectedPenggunaId = currentPengguna['id_pengguna'] as int?;

      final sourceList = widget.items ?? [];
      for (final item in sourceList) {
        final alatMatch = daftarAlat.firstWhere(
          (a) => a['nama_alat'] == item['nama_alat'],
          orElse: () => {'id_alat': null, 'jumlah_tersedia': 0},
        );
        if (alatMatch['id_alat'] != null) {
          editableItems.add({
            'id_alat': alatMatch['id_alat'],
            'nama_alat': alatMatch['nama_alat'],
            'jumlah': item['jumlah'] ?? 1,
            'stok_tersedia': alatMatch['jumlah_tersedia'],
          });
        }
      }

      // fallback jika hanya ada alat & jumlah tunggal
      if (editableItems.isEmpty &&
          widget.alat != null &&
          widget.jumlah != null) {
        final alatMatch = daftarAlat.firstWhere(
          (a) => a['nama_alat'] == widget.alat,
          orElse: () => {'id_alat': null, 'jumlah_tersedia': 0},
        );
        if (alatMatch['id_alat'] != null) {
          editableItems.add({
            'id_alat': alatMatch['id_alat'],
            'nama_alat': alatMatch['nama_alat'],
            'jumlah': widget.jumlah,
            'stok_tersedia': alatMatch['jumlah_tersedia'],
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
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
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          'Edit Peminjaman',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

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
                            value: p['id_pengguna'] as int?,
                            child: Text(p['nama'] ?? 'Tidak diketahui'),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedPenggunaId = val),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Alat yang Dipinjam',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      ...editableItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final stok = item['stok_tersedia'] as int? ?? 0;
                        final qty = item['jumlah'] as int? ?? 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: item['id_alat'] as int?,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: daftarAlat.map((a) {
                                    return DropdownMenuItem<int>(
                                      value: a['id_alat'] as int,
                                      child: Text(
                                        "${a['nama_alat']} (tersedia: ${a['jumlah_tersedia']})",
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    final newAlat = daftarAlat.firstWhere(
                                      (a) => a['id_alat'] == val,
                                    );
                                    setDialogState(() {
                                      editableItems[index] = {
                                        'id_alat': val,
                                        'nama_alat': newAlat['nama_alat'],
                                        'jumlah': qty,
                                        'stok_tersedia':
                                            newAlat['jumlah_tersedia'],
                                      };
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  initialValue: qty.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    labelText: 'Jumlah',
                                    errorText: qty > stok
                                        ? 'Melebihi stok'
                                        : null,
                                  ),
                                  onChanged: (val) {
                                    final newQty = int.tryParse(val) ?? 1;
                                    setDialogState(() {
                                      editableItems[index]['jumlah'] = newQty
                                          .clamp(1, 9999);
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () => setDialogState(
                                  () => editableItems.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      if (editableItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Belum ada alat yang dipilih",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),

                      TextButton.icon(
                        onPressed: daftarAlat.isEmpty
                            ? null
                            : () {
                                final defaultAlat = daftarAlat.first;
                                setDialogState(() {
                                  editableItems.add({
                                    'id_alat': defaultAlat['id_alat'],
                                    'nama_alat': defaultAlat['nama_alat'],
                                    'jumlah': 1,
                                    'stok_tersedia':
                                        defaultAlat['jumlah_tersedia'],
                                  });
                                });
                              },
                        icon: Icon(Icons.add_circle, color: primaryOrange),
                        label: const Text('Tambah Alat'),
                      ),

                      const SizedBox(height: 24),
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
                                    ).format(tglPinjam),
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
                                      context: dialogContext,
                                      initialDate: tglPinjam,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null && mounted) {
                                      setDialogState(() => tglPinjam = picked);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                    ).format(tglKembali),
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
                                      context: dialogContext,
                                      initialDate: tglKembali,
                                      firstDate: tglPinjam,
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null && mounted) {
                                      setDialogState(() => tglKembali = picked);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                // Validasi
                                if (selectedPenggunaId == null) {
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    const CustomSnackBar.error(
                                      message:
                                          "Pilih nama peminjam terlebih dahulu",
                                    ),
                                  );
                                  return;
                                }

                                if (editableItems.isEmpty) {
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    const CustomSnackBar.error(
                                      message: "Minimal harus memilih 1 alat",
                                    ),
                                  );
                                  return;
                                }

                                if (tglKembali.isBefore(tglPinjam)) {
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    const CustomSnackBar.error(
                                      message:
                                          "Tanggal kembali tidak boleh sebelum tanggal pinjam",
                                    ),
                                  );
                                  return;
                                }

                                // Validasi stok
                                for (var item in editableItems) {
                                  final qty = item['jumlah'] as int;
                                  final stok =
                                      item['stok_tersedia'] as int? ?? 0;
                                  if (qty > stok) {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message:
                                            "Jumlah ${item['nama_alat']} (${qty}) melebihi stok tersedia (${stok})",
                                      ),
                                    );
                                    return;
                                  }
                                }

                                try {
                                  await supabase
                                      .from('peminjaman')
                                      .update({
                                        'id_pengguna': selectedPenggunaId,
                                        'tanggal_pinjam': DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(tglPinjam),
                                        'tanggal_kembali': DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(tglKembali),
                                      })
                                      .eq('id_peminjaman', idPeminjaman);
                                  await supabase
                                      .from('detail_peminjaman')
                                      .delete()
                                      .eq('id_peminjaman', idPeminjaman);
                                  for (var item in editableItems) {
                                    await supabase
                                        .from('detail_peminjaman')
                                        .insert({
                                          'id_peminjaman': idPeminjaman,
                                          'id_alat': item['id_alat'],
                                          'jumlah': item['jumlah'],
                                        });
                                  }

                                  if (!mounted) return;
                                  Navigator.pop(dialogContext);
                                  widget.onRefresh?.call();

                                  showTopSnackBar(
                                    Overlay.of(context),
                                    Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Perubahan berhasil disimpan',
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
                                } catch (e) {
                                  if (!mounted) return;
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.error(
                                      message: "Gagal menyimpan perubahan: $e",
                                    ),
                                  );
                                }
                              },
                              child: const Text('Simpan'),
                            ),
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.orange, width: 2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Apakah Anda yakin ingin menghapus data peminjaman ini?\nTindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await supabase
          .from('detail_peminjaman')
          .delete()
          .eq('id_peminjaman', idPeminjaman);

      await supabase
          .from('peminjaman')
          .delete()
          .eq('id_peminjaman', idPeminjaman);

      widget.onRefresh?.call();

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
                    'Peminjaman berhasil dihapus',
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
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "Gagal menghapus: $e"),
      );
    }
  }
}
