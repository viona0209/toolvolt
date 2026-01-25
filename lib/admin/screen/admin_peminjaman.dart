import 'package:flutter/material.dart';
import 'package:toolvolt/admin/screen/admin_alat_page.dart';
import 'package:toolvolt/admin/screen/admin_pengaturan.dart';
import 'package:toolvolt/admin/screen/admin_pengembalian.dart';
import 'package:toolvolt/admin/widgets/peminjaman_card.dart';
import 'package:toolvolt/admin/widgets/admin_bottom_nav.dart';
import 'admin_dashboard.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  int _currentIndex = 1;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminAlatPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeminjamanPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PengembalianPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PengaturanPage()),
        );
        break;
    }
  }

  void _showTambahPeminjamanDialog() {
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
                final namaController = TextEditingController();
                String? selectedAlat;
                final jumlahController = TextEditingController();
                final tglPinjamController = TextEditingController();
                final tglKembaliController = TextEditingController();
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
                  'Tang Ampere',
                ];

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Tambah Peminjaman',
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
                                    // TODO: Implement date picker
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
                                    // TODO: Implement date picker
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
                              if (namaController.text.trim().isEmpty ||
                                  selectedAlat == null ||
                                  jumlahController.text.trim().isEmpty ||
                                  tglPinjamController.text.trim().isEmpty ||
                                  tglKembaliController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lengkapi semua field'),
                                  ),
                                );
                                return;
                              }

                              // TODO: Simpan ke Supabase / list
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Peminjaman berhasil ditambahkan',
                                  ),
                                ),
                              );
                            },
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Image.asset(
                  "assets/image/logo1remove.png",
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "List Peminjaman",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              PeminjamanCard(
                id: '1',
                nama: 'Dewi Lestari',
                tglPinjam: '16/1/2026',
                tglKembali: '23/1/2026',
                alat: 'Tang Potong',
                jumlah: 1,
                status: 'Dipinjam',
                statusColor: Colors.orange,
                disetujuiOleh: 'Petugas 1',
              ),
              PeminjamanCard(
                id: '2',
                nama: 'Ahmad Rizky',
                tglPinjam: '10/1/2026',
                tglKembali: '17/1/2026',
                alat: 'Tang Ampere',
                jumlah: 1,
                status: 'Dikembalikan',
                statusColor: Colors.green,
                dikembalikanOleh: 'Petugas 2',
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7A00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _showTambahPeminjamanDialog,
        child: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
      ),

      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
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
