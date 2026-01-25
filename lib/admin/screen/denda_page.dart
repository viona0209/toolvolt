import 'package:flutter/material.dart';

class DendaPage extends StatefulWidget {
  const DendaPage({super.key});

  @override
  State<DendaPage> createState() => _DendaPageState();
}

class _DendaPageState extends State<DendaPage> {
  final List<Map<String, dynamic>> _dendaList = [
    {'nama': 'Terlambat', 'biaya': 5000},
    {'nama': 'Rusak ringan', 'biaya': 25000},
    {'nama': 'Rusak berat', 'biaya': 100000},
    {'nama': 'Hilang', 'biaya': 500000},
  ];

  void _showTambahDendaDialog() {
    const primaryOrange = Color(0xFFFF7733);
    final namaController = TextEditingController();
    final biayaController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  'Tambah Denda',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                _buildLabel('Name'),
                TextField(
                  controller: namaController,
                  decoration: _inputDecoration(),
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
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryOrange, width: 1.5),
                        foregroundColor: primaryOrange,
                        minimumSize: const Size(110, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (namaController.text.isNotEmpty && biayaController.text.isNotEmpty) {
                          setState(() {
                            _dendaList.add({
                              'nama': namaController.text,
                              'biaya': int.tryParse(biayaController.text) ?? 0,
                            });
                          });
                          Navigator.pop(dialogContext);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lengkapi semua field')),
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
      },
    );
  }

  void _showEditDendaDialog(int index) {
    const primaryOrange = Color(0xFFFF7733);
    final denda = _dendaList[index];
    final namaController = TextEditingController(text: denda['nama']);
    final biayaController = TextEditingController(text: denda['biaya'].toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  'Edit Denda',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                _buildLabel('Name'),
                TextField(
                  controller: namaController,
                  decoration: _inputDecoration(),
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
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryOrange, width: 1.5),
                        foregroundColor: primaryOrange,
                        minimumSize: const Size(110, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dendaList[index] = {
                            'nama': namaController.text,
                            'biaya': int.tryParse(biayaController.text) ?? 0,
                          };
                        });
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  void _showHapusDendaDialog(int index) {
    const primaryOrange = Color(0xFFFF7733);
    final namaDenda = _dendaList[index]['nama'];

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  'Hapus Denda',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  'Apakah kamu yakin ingin menghapus denda "$namaDenda" ini?',
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
                        side: BorderSide(color: primaryOrange, width: 1.5),
                        foregroundColor: primaryOrange,
                        minimumSize: const Size(110, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dendaList.removeAt(index);
                        });
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Denda berhasil dihapus')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7733),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hapus'),
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

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF7733);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        onPressed: _showTambahDendaDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 32, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  "assets/image/logo1remove.png",
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "Denda",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Nama Denda',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Biaya',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                'Aksi',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _dendaList.length,
                          separatorBuilder: (_, __) => Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final denda = _dendaList[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      denda['nama'],
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Rp ${denda['biaya'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                      style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () => _showEditDendaDialog(index),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _showHapusDendaDialog(index),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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