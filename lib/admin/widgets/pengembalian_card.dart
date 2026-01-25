import 'package:flutter/material.dart';

class PengembalianCard extends StatefulWidget {
  final String id;
  final String nama;
  final String tglPinjam;
  final String tglKembali;
  final String kondisi;
  final String? denda;

  const PengembalianCard({
    super.key,
    required this.id,
    required this.nama,
    required this.tglPinjam,
    required this.tglKembali,
    required this.kondisi,
    this.denda = "Rp 50.000 - Rusak",
  });

  @override
  State<PengembalianCard> createState() => _PengembalianCardState();
}

class _PengembalianCardState extends State<PengembalianCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8D8D8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBE4A31),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Kembalikan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 24),
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 6,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPengembalianDialog(context);
                      } else if (value == 'detail') {
                        setState(() => _isExpanded = true);
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: primaryOrange, size: 20),
                            const SizedBox(width: 12),
                            const Text('Edit', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Detail',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            widget.nama,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          Text(
            "Pinjam : ${widget.tglPinjam}",
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Kembali : ${widget.tglKembali}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Kondisi: ${widget.kondisi}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_outlined,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Rincian denda : ${widget.denda ?? 'Tidak ada denda'}",
                      style: const TextStyle(
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
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  void _showEditPengembalianDialog(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final tglKembaliController = TextEditingController(
          text: widget.tglKembali,
        );
        String? selectedKondisi = widget.kondisi;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: primaryOrange, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // <-- Rata kiri keseluruhan
              children: [
                const Center(
                  child: Text(
                    'Edit Pengembalian',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Tanggal dikembalikan'),
                TextField(
                  controller: tglKembaliController,
                  decoration: _inputDecoration().copyWith(
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: primaryOrange,
                    ),
                  ),
                  readOnly: true,
                  onTap: () {
                    // TODO: showDatePicker
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Kondisi alat'),
                DropdownButtonFormField<String?>(
                  value: selectedKondisi,
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: "Baik", child: Text("Baik")),
                    DropdownMenuItem(value: "Rusak", child: Text("Rusak")),
                    DropdownMenuItem(
                      value: "Rusak Ringan",
                      child: Text("Rusak Ringan"),
                    ),
                    DropdownMenuItem(value: "Hilang", child: Text("Hilang")),
                  ],
                  onChanged: (val) {
                    selectedKondisi = val;
                  },
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
                        minimumSize: const Size(110, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      borderSide: const BorderSide(color: Color(0xFFFF8E01)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF8E01), width: 2),
    ),
  );
}
