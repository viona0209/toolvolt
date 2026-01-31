import 'package:flutter/material.dart';
import '../services/supabase_alat_service.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/alat/alat_card.dart';
import '../widgets/alat/tambah_alat_dialog.dart';
import 'admin_dashboard.dart';
import 'admin_peminjaman.dart';
import 'admin_pengaturan.dart';
import 'admin_pengembalian.dart';

class AdminAlatScreen extends StatefulWidget {
  const AdminAlatScreen({super.key});

  @override
  State<AdminAlatScreen> createState() => _AdminAlatScreenState();
}

class _AdminAlatScreenState extends State<AdminAlatScreen> {
  int _currentIndex = 0;

  String selectedKategori = 'Semua';
  bool isLoading = true;
  List<Map<String, dynamic>> alatList = [];
  List<String> kategoriOptions = ['Semua'];

  final SupabaseAlatService _service = SupabaseAlatService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final alatFuture = _service.fetchAllAlat();
      final kategoriFuture = _service.fetchKategoriNames();

      final alat = await alatFuture;
      final kategori = await kategoriFuture;

      setState(() {
        alatList = alat;
        kategoriOptions = ['Semua', ...kategori];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  void _showAddAlatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TambahAlatDialog(
        onSuccess: () {
          _loadData(); // reload list setelah berhasil tambah alat
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/image/logo1remove.png',
                width: MediaQuery.of(context).size.width * 0.55,
              ),
            ),
            const SizedBox(height: 35),

            // Search + Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 22, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8D8D8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) =>
                          setState(() => selectedKategori = value),
                      itemBuilder: (context) => kategoriOptions
                          .map((k) => PopupMenuItem(value: k, child: Text(k)))
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8D8D8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedKategori,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : alatList.isEmpty
                  ? const Center(child: Text('Belum ada data alat'))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: alatList
                            .where(
                              (a) =>
                                  selectedKategori == 'Semua' ||
                                  a['kategori'] == selectedKategori,
                            )
                            .map(
                              (alat) => AlatCard(
                                idAlat: alat['id'],
                                nama: alat['nama'],
                                kategori: alat['kategori'],
                                kondisi: alat['kondisi'],
                                total: alat['total'],
                                tersedia: alat['tersedia'],
                                dipinjam: alat['dipinjam'],
                                imagePath: alat['image'],
                                onRefresh: _loadData,
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7A00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _showAddAlatDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminAlatScreen()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeminjamanScreen()),
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
          MaterialPageRoute(builder: (_) => const PengembalianScreen()),
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
}
