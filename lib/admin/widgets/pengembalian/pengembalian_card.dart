import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PengembalianCard extends StatefulWidget {
  final String id;
  final String nama;
  final String tglPinjam;
  final String tglKembali;
  final String tglPengembalian;
  final String kondisi;
  final String? catatan;
  final VoidCallback? onRefresh;

  const PengembalianCard({
    super.key,
    required this.id,
    required this.nama,
    required this.tglPinjam,
    required this.tglKembali,
    required this.tglPengembalian,
    required this.kondisi,
    this.catatan,
    this.onRefresh,
  });

  @override
  State<PengembalianCard> createState() => _PengembalianCardState();
}

class _PengembalianCardState extends State<PengembalianCard> {
  bool _isExpanded = false;
  int? totalDenda;

  @override
  void initState() {
    super.initState();
    _loadDendaFromSupabase();
  }

  Future<void> _loadDendaFromSupabase() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('pengembalian')
        .select('total_denda')
        .eq('id_pengembalian', widget.id)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      totalDenda = (data?['total_denda'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF7A00);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFD8D8D8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 3),
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
                "ID : ${widget.id}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFBE4A31),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Kembalikan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 24),
                    offset: Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPengembalianDialog(context);
                      } else if (value == 'detail') {
                        setState(() => _isExpanded = !_isExpanded);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: primaryOrange, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
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

          SizedBox(height: 10),

          Text(
            widget.nama,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            "Pinjam : ${widget.tglPinjam}",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),

          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      "Kembali : ${widget.tglKembali}",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      "Dikembalikan : ${widget.tglPengembalian}",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.red,
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Kondisi: ${widget.kondisi}",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.catatan != null && widget.catatan!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.blueGrey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Catatan: ${widget.catatan}",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 16,
                      color: Colors.red,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Rincian denda : ${totalDenda ?? 'Menghitung...'}",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  void _showEditPengembalianDialog(BuildContext context) {
    const primaryOrange = Color(0xFFFF7A00);

    showDialog(
      context: context,
      builder: (dialogContext) {
        DateTime tglISO;

        try {
          tglISO = DateTime.parse(widget.tglPengembalian);
        } catch (_) {
          final p = widget.tglPengembalian.split('/');
          tglISO = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }

        final tglController = TextEditingController(text: _formatIndo(tglISO));

        String? selectedKondisi = widget.kondisi;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: primaryOrange, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Pengembalian',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: tglController,
                  readOnly: true,
                  decoration: _inputDecoration().copyWith(
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: primaryOrange,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: tglISO,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      tglISO = picked;
                      tglController.text = _formatIndo(picked);
                    }
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String?>(
                  value: selectedKondisi,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: "Baik", child: Text("Baik")),
                    DropdownMenuItem(
                      value: "Rusak Ringan",
                      child: Text("Rusak Ringan"),
                    ),
                    DropdownMenuItem(
                      value: "Rusak Sedang",
                      child: Text("Rusak Sedang"),
                    ),
                    DropdownMenuItem(
                      value: "Rusak Berat",
                      child: Text("Rusak Berat"),
                    ),
                    DropdownMenuItem(value: "Hilang", child: Text("Hilang")),
                  ],
                  onChanged: (v) => selectedKondisi = v,
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client
                          .from('pengembalian')
                          .update({
                            "tanggal_pengembalian": tglISO.toIso8601String(),
                            "kondisi_setelah": selectedKondisi,
                          })
                          .eq('id_pengembalian', widget.id);

                      Navigator.pop(dialogContext);

                      if (mounted) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message: "Pengembalian berhasil diperbarui!",
                          ),
                        );
                      }

                      widget.onRefresh?.call();
                      _loadDendaFromSupabase();
                    } catch (e) {
                      print("ERROR edit pengembalian: $e");
                      if (mounted) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(message: "Gagal mengedit: $e"),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Edit"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatIndo(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFFF7A00)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFFF7A00), width: 2),
    ),
  );
}
