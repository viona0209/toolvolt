import 'package:flutter/material.dart';
import 'package:toolvolt/petugas/service/pengembalian_service.dart';
import '../widgets/pengembalian_card.dart';
import '../widgets/riwayat_pengembalian_card.dart';
import '../widgets/petugas_bottom_nav.dart';
import 'petugas_dashboard.dart';
import 'petugas_laporan_page.dart';
import 'petugas_peminjaman_page.dart';

class PetugasPengembalianPage extends StatefulWidget {
  const PetugasPengembalianPage({super.key});

  @override
  State<PetugasPengembalianPage> createState() =>
      _PetugasPengembalianPageState();
}

class _PetugasPengembalianPageState extends State<PetugasPengembalianPage> {
  int _currentIndex = 1;

  final PengembalianService _service = PengembalianService();

  List<Map<String, dynamic>> belumKembali = [];
  List<Map<String, dynamic>> riwayat = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final dataBelum = await _service.getBelumDikembalikan();

    final dataRiwayat = await _service.getRiwayatPengembalian();

    setState(() {
      belumKembali = dataBelum;
      riwayat = dataRiwayat;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                        'Pengembalian Alat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// LIST PEMINJAMAN YANG BELUM MENGEMBALIKAN
                      for (var item in belumKembali)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PengembalianCard(
                            id: item['id_peminjaman'].toString(),
                            nama: item['pengguna']['nama'] ?? '-',
                            tanggalPinjam:
                                item['tanggal_pinjam']?.toString() ?? '-',
                            onUpdated:
                                loadData, // refresh otomatis setelah pengembalian
                          ),
                        ),

                      const SizedBox(height: 25),

                      const Text(
                        'Riwayat Pengembalian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// LIST RIWAYAT
                      for (var r in riwayat)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RiwayatPengembalianCard(
                            id: r['id_pengembalian'].toString(),
                            nama: r['peminjaman']['pengguna']['nama'] ?? '-',
                            tanggalKembali: r['tanggal_pengembalian']!
                                .toString(),
                            denda: r['total_denda'].toString(),
                            kondisiSetelah:
                                r['kondisi_setelah'] ??
                                '-', // ambil dari Supabase
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),

      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetugasPeminjamanPage(),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetugasPengembalianPage(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PetugasDashboard()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PetugasLaporanPage()),
              );
              break;
          }
        },
      ),
    );
  }
}
