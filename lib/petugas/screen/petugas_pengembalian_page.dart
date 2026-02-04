import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolvolt/petugas/service/pengembalian_service.dart';
import '../widgets/pengembalian_card.dart';
import '../widgets/riwayat_pengembalian_card.dart';
import '../widgets/petugas_bottom_nav.dart';
import 'petugas_dashboard.dart';
import 'petugas_laporan_page.dart';
import 'petugas_peminjaman_page.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final supabase = Supabase.instance.client;

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
  int? currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    await getCurrentUserId();
    await loadData();
  }

  Future<void> getCurrentUserId() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      try {
        final userData = await supabase
            .from('pengguna')
            .select('id_pengguna')
            .eq('auth_id', currentUser.id)
            .single();

        setState(() {
          currentUserId = userData['id_pengguna'];
        });
      } catch (e) {
        _showTopSnackBar('Gagal ambil data user: $e', isError: true);
      }
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final dataBelum = await _service.getBelumDikembalikan();
      final dataRiwayat = await _service.getRiwayatPengembalian();

      dataBelum.sort(
        (a, b) => a['id_peminjaman'].toString()
            .compareTo(b['id_peminjaman'].toString()),
      );

      dataRiwayat.sort(
        (a, b) => a['id_pengembalian'].toString()
            .compareTo(b['id_pengembalian'].toString()),
      );

      setState(() {
        belumKembali = dataBelum;
        riwayat = dataRiwayat;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showTopSnackBar('Gagal load data: $e', isError: true);
    }
  }

  void _showTopSnackBar(String message, {bool isError = false}) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isError ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(isError ? Icons.error : Icons.check_circle,
                  color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      if (currentUserId != null)
                        for (var item in belumKembali)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PengembalianCard(
                              id: item['id_peminjaman'].toString(),
                              nama: item['pengguna']['nama'] ?? '-',
                              tanggalPinjam:
                                  item['tanggal_pinjam']?.toString() ?? '-',
                              idPengguna: currentUserId!,
                              onUpdated: () async {
                                await loadData();
                                _showTopSnackBar(
                                    'Pengembalian berhasil diperbarui');
                              },
                            ),
                          )
                      else
                        const Center(
                            child: Text('Sedang memuat user login...')),
                      const SizedBox(height: 25),
                      const Text(
                        'Riwayat Pengembalian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var r in riwayat)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RiwayatPengembalianCard(
                            id: r['id_pengembalian'].toString(),
                            nama: r['peminjaman']['pengguna']['nama'] ?? '-',
                            tanggalKembali:
                                r['tanggal_pengembalian'].toString(),
                            denda: r['total_denda'].toString(),
                            kondisiSetelah: r['kondisi_setelah'] ?? '-',
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
                    builder: (_) => const PetugasPeminjamanPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const PetugasPengembalianPage()),
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
          }
        },
      ),
    );
  }
}
