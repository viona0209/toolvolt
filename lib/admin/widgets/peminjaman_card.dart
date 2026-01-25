import 'package:flutter/material.dart';

class PeminjamanCard extends StatefulWidget {
  final String id;
  final String nama;
  final String tglPinjam;
  final String tglKembali;
  final String alat;
  final int jumlah;
  final String status;
  final Color statusColor;
  final String? disetujuiOleh;
  final String? dikembalikanOleh;

  const PeminjamanCard({
    super.key,
    required this.id,
    required this.nama,
    required this.tglPinjam,
    required this.tglKembali,
    required this.alat,
    required this.jumlah,
    required this.status,
    required this.statusColor,
    this.disetujuiOleh,
    this.dikembalikanOleh,
  });

  @override
  State<PeminjamanCard> createState() => _PeminjamanCardState();
}

class _PeminjamanCardState extends State<PeminjamanCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    String approvalText = "Belum disetujui";
    String approvalName = "";

    if (widget.status.toLowerCase() == "dipinjam" ||
        widget.status.toLowerCase() == "on pinjam") {
      if (widget.disetujuiOleh != null && widget.disetujuiOleh!.isNotEmpty) {
        approvalText = "Disetujui oleh";
        approvalName = widget.disetujuiOleh!;
      }
    } else if (widget.status.toLowerCase().contains("kembali")) {
      if (widget.dikembalikanOleh != null &&
          widget.dikembalikanOleh!.isNotEmpty) {
        approvalText = "Dikembalikan oleh";
        approvalName = widget.dikembalikanOleh!;
      } else {
        approvalText = "Sudah dikembalikan";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8D8D8), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.07),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 4,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditPeminjamanDialog(context);
                      } else if (value == 'detail') {
                        setState(() {
                          _isExpanded = true;
                        });
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: primaryOrange, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
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

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 6),
              Text(
                widget.nama,
                style: const TextStyle(color: Color(0xFF595959)),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 6),
              Text(
                "Kembali: ${widget.tglKembali}",
                style: const TextStyle(color: Color(0xFF595959)),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 18,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$approvalText: $approvalName",
                    style: const TextStyle(color: Color(0xFF595959)),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          const SizedBox(height: 12),

          const Text(
            "Alat yang dipinjam:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          _buildItemAlat(widget.alat, widget.jumlah),
        ],
      ),
    );
  }

  Widget _buildItemAlat(String namaAlat, int jumlah) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(namaAlat, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text("$jumlah unit"),
          ),
        ],
      ),
    );
  }

  void _showEditPeminjamanDialog(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: primaryOrange, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                final namaController = TextEditingController(text: widget.nama);
                String? selectedAlat = widget.alat;
                final jumlahController = TextEditingController(
                  text: widget.jumlah.toString(),
                );
                final tglPinjamController = TextEditingController(
                  text: widget.tglPinjam,
                );
                final tglKembaliController = TextEditingController(
                  text: widget.tglKembali,
                );

                final List<String> daftarAlat = [
                  'Tang Potong',
                  'Obeng Plus',
                  'Obeng Minus',
                  'Kunci Inggris',
                  'Multimeter',
                  'Oscilloscope',
                  'Power Supply',
                  'Solder',
                  'Mesin Bor Mini',
                  'Tang Potong Kecil',
                ];

                if (selectedAlat != null &&
                    !daftarAlat.contains(selectedAlat)) {
                  selectedAlat = daftarAlat.isNotEmpty
                      ? daftarAlat.first
                      : null;
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Edit Peminjaman',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('Nama'),
                      TextField(
                        controller: namaController,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Pilih Alat'),
                                DropdownButtonFormField<String?>(
                                  value: selectedAlat,
                                  isExpanded: true,
                                  hint: const Text('Pilih alat'),
                                  decoration: _inputDecoration(),
                                  items: daftarAlat.map((alatNama) {
                                    return DropdownMenuItem<String?>(
                                      value: alatNama,
                                      child: Text(alatNama),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => selectedAlat = val);
                                  },
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
                                _buildLabel('Jumlah'),
                                TextField(
                                  controller: jumlahController,
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
                                _buildLabel('Tgl. Pinjam'),
                                TextField(
                                  controller: tglPinjamController,
                                  decoration: _inputDecoration().copyWith(
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    // TODO: date picker
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Tgl. Kembali'),
                                TextField(
                                  controller: tglKembaliController,
                                  decoration: _inputDecoration().copyWith(
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    // TODO: date picker
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
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
                              if (selectedAlat == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pilih alat terlebih dahulu'),
                                  ),
                                );
                                return;
                              }
                              // TODO: simpan ke Supabase
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
                );
              },
            ),
          ),
        );
      },
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
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF8E01)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF8E01), width: 2),
    ),
  );
}
