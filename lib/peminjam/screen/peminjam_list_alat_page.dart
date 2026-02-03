import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/alat_service.dart';
import '../widgets/alat_card.dart';
import '../widgets/peminjam_bottom_nav.dart';
import 'peminjam_dashboard_page.dart';
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

  final TextEditingController searchController = TextEditingController();
  String selectedKategori = 'kategori';

  final AlatService _alatService = AlatService();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> alatList = [];
  List<Map<String, dynamic>> filteredList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlat();
  }

  Future<void> fetchAlat() async {
    final data = await _alatService.getAlat();

    setState(() {
      alatList = data;
      filteredList = data;
      isLoading = false;
    });
  }

  void applyFilter() {
    String keyword = searchController.text.toLowerCase();

    setState(() {
      filteredList = alatList.where((item) {
        final nama = item['nama_alat'].toString().toLowerCase();
        final kategori = item['kategori']['nama_kategori'].toString();

        final matchSearch = nama.contains(keyword);
        final matchKategori = selectedKategori == 'kategori'
            ? true
            : kategori == selectedKategori;

        return matchSearch && matchKategori;
      }).toList();
    });
  }

  Future<void> ajukanPeminjaman(int idAlat, {int jumlah = 1}) async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userData = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('auth_id', session.user.id)
          .single();

      final int idPeminjam = userData['id_pengguna'];

      final peminjaman = await supabase
          .from('peminjaman')
          .insert({
            'id_pengguna': idPeminjam,
            'tanggal_pinjam': DateTime.now().toIso8601String(),
            'status': 'Menunggu',
          })
          .select()
          .single();

      final int idPeminjaman = peminjaman['id_peminjaman'];

      await supabase.from('detail_peminjaman').insert({
        'id_peminjaman': idPeminjaman,
        'id_alat': idAlat,
        'jumlah': jumlah,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan berhasil, menunggu persetujuan petugas'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan peminjaman: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/image/logo1remove.png',
                      width: MediaQuery.of(context).size.width * 0.55,
                    ),
                  ),
                  const SizedBox(height: 25),
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
                            onChanged: (v) => applyFilter(),
                            decoration: InputDecoration(
                              hintText: 'Cari alat...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
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
                            items: const [
                              DropdownMenuItem(
                                value: 'kategori',
                                child: Text('kategori'),
                              ),
                              DropdownMenuItem(
                                value: 'Peralatan Tangan',
                                child: Text('Peralatan Tangan'),
                              ),
                              DropdownMenuItem(
                                value: 'Peralatan Ukur',
                                child: Text('Peralatan Ukur'),
                              ),
                              DropdownMenuItem(
                                value: 'Peralatan Soldering',
                                child: Text('Peralatan Soldering'),
                              ),
                              DropdownMenuItem(
                                value: 'Peralatan Listrik',
                                child: Text('Peralatan Listrik'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedKategori = value!;
                                applyFilter();
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                  ? const Center(child: Text("Tidak ada alat ditemukan"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final alat = filteredList[index];

                        return AlatCard(
                          namaAlat: alat['nama_alat'],
                          kategori: alat['kategori']['nama_kategori'],
                          kondisi: 'Baik',
                          imageAsset: alat['gambar_alat'],
                          jumlahKondisiBaik: alat['jumlah_tersedia'],
                          totalItem: alat['jumlah_total'],
                          ajukanPinjam: () => ajukanPeminjaman(alat['id_alat']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PeminjamBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

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
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page!),
          );
        },
      ),
    );
  }
}
