import 'package:flutter/material.dart';
import '../widgets/peminjaman_card.dart';
import '../widgets/peminjam_bottom_nav.dart';
import 'peminjam_dashboard_page.dart';
import 'peminjam_list_alat_page.dart';
import 'peminjam_pengembalian_page.dart';

class PeminjamPeminjamanPage extends StatefulWidget {
  const PeminjamPeminjamanPage({super.key});

  @override
  State<PeminjamPeminjamanPage> createState() => _PeminjamPeminjamanPageState();
}

class _PeminjamPeminjamanPageState extends State<PeminjamPeminjamanPage> {
  int _currentIndex = 1;
  static const Color primaryColor = Color(0xFFBE4A31);

  String selectedStatus = 'Status';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/image/logo1remove.png',
                      width: MediaQuery.of(context).size.width * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Daftar peminjaman',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedStatus,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Status',
                                  child: Text(
                                    'Status',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Dipinjam',
                                  child: Text(
                                    'Dipinjam',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Dikembalikan',
                                  child: Text(
                                    'Dikembalikan',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => selectedStatus = value!);
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () => _showAjukanPeminjamanDialog(context),
                            borderRadius: BorderRadius.circular(20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ajukan Peminjaman',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  PeminjamanPeminjamCard(
                    id: '1',
                    nama: 'Ahmad Rizky',
                    tanggalPinjam: '16/1/2026',
                    tanggalKembali: '23/1/2026',
                    alat: 'Tang Potong',
                    status: 'Dipinjam',
                    statusColor: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  PeminjamanPeminjamCard(
                    id: '3',
                    nama: 'Ahmad Rizky',
                    tanggalPinjam: '10/1/2026',
                    tanggalKembali: '17/1/2026',
                    alat: 'Tang Ampere',
                    status: 'Dikembalikan',
                    statusColor: Colors.green,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: PeminjamBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PeminjamListAlatPage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PeminjamDashboardPage(),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PeminjamPengembalianPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  void _showAjukanPeminjamanDialog(BuildContext context) {
    final TextEditingController tglPinjamCtrl = TextEditingController();
    final TextEditingController tglKembaliCtrl = TextEditingController();

    const Color accentColor = Color(0xFFEF6C01);

    final List<String> daftarAlat = [
      'Pilih alat',
      'Tang Potong',
      'Tang Ampere',
      'Obeng Plus',
      'Obeng Minus',
      'Kunci Inggris',
      'Multimeter',
      'Gergaji',
      'Palu',
    ];

    String selectedAlat = daftarAlat.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
              title: Center(
                child: const Text(
                  'Ajukan peminjaman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'tgl pinjam',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: tglPinjamCtrl,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 25/01/2026',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'tgl kembali',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: tglKembaliCtrl,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 01/02/2026',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: accentColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pilih alat',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedAlat,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: accentColor,
                        ),
                      ),
                      items: daftarAlat.map((String alat) {
                        return DropdownMenuItem<String>(
                          value: alat,
                          child: Text(
                            alat,
                            style: TextStyle(
                              fontSize: 14,
                              color: alat == 'Pilih alat'
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedAlat = newValue ?? daftarAlat.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final pinjam = tglPinjamCtrl.text.trim();
                    final kembali = tglKembaliCtrl.text.trim();

                    if (pinjam.isEmpty ||
                        kembali.isEmpty ||
                        selectedAlat == 'Pilih alat') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lengkapi semua data terlebih dahulu'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // TODO: Logika pengajuan (API, Provider, Firestore, dll)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengajuan berhasil: $selectedAlat'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Ajukan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            );
          },
        );
      },
    ).then((_) {
      tglPinjamCtrl.dispose();
      tglKembaliCtrl.dispose();
    });
  }
}
