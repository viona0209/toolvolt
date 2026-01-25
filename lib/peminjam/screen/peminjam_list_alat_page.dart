import 'package:flutter/material.dart';
import 'package:toolvolt/peminjam/screen/peminjam_dashboard_page.dart';
import '../widgets/alat_card.dart';
import '../widgets/peminjam_bottom_nav.dart';
import 'peminjam_peminjaman_page.dart';
import 'peminjam_pengembalian_page.dart';

class PeminjamListAlatPage extends StatefulWidget {
  const PeminjamListAlatPage({super.key});

  @override
  State<PeminjamListAlatPage> createState() => _PeminjamListAlatPageState();
}

class _PeminjamListAlatPageState extends State<PeminjamListAlatPage> {
  int _currentIndex = 0;

  static const Color primaryColor = Color(0xFFFF8E01);

  TextEditingController searchController = TextEditingController();
  String selectedKategori = 'Kategori';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedKategori,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Kategori',
                                child: Text(
                                  'Kategori',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Alat Ukur',
                                child: Text(
                                  'Alat Ukur',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Alat Tangan',
                                child: Text(
                                  'Alat Tangan',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Alat Listrik',
                                child: Text(
                                  'Alat Listrik',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedKategori = value!;
                              });
                            },
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
                children: [
                  AlatCard(
                    namaAlat: 'Multimeter Digital',
                    kategori: 'Alat Ukur',
                    kondisi: 'Baik',
                    jumlahKondisiBaik: 13,
                    totalItem: 15,
                    imageAsset: 'assets/image/multimeter.png',
                  ),

                  AlatCard(
                    namaAlat: 'Tang Potong',
                    kategori: 'Alat Tangan',
                    kondisi: 'Baik',
                    totalItem: 5,
                    imageAsset: 'assets/image/tangpotong.png',
                  ),

                  AlatCard(
                    namaAlat: 'Solder Listrik',
                    kategori: 'Alat Listrik',
                    kondisi: 'Baik',
                    jumlahKondisiBaik: 10,
                    totalItem: 10,
                    imageAsset: 'assets/image/solderlistrik.png',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: PeminjamBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          Widget? page;
          switch (index) {
            case 0:
              page = const PeminjamListAlatPage();
              break;
            case 1:
              page = const PeminjamPeminjamanPage();
              break;
            case 2:
              page = const PeminjamDashboardPage();
              break;
            case 3:
              page = const PeminjamPengembalianPage();
              break;
            default:
              return;
          }
          if (page != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => page!),
            );
          }
        },
      ),
    );
  }
}
