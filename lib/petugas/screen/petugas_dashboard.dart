import 'package:flutter/material.dart';
import 'package:toolvolt/admin/services/supabase_dashboard_service.dart';
import 'package:toolvolt/admin/widgets/dashboard/info_card.dart';
import 'package:toolvolt/admin/widgets/dashboard/activity_item.dart';
import 'package:toolvolt/petugas/screen/petugas_laporan_page.dart';
import 'package:toolvolt/petugas/screen/petugas_peminjaman_page.dart';
import 'package:toolvolt/petugas/screen/petugas_pengembalian_page.dart';
import 'package:toolvolt/petugas/widgets/petugas_bottom_nav.dart';

class PetugasDashboard extends StatefulWidget {
  const PetugasDashboard({super.key});

  @override
  State<PetugasDashboard> createState() => _PetugasDashboardState();
}

class _PetugasDashboardState extends State<PetugasDashboard> {
  final SupabaseDashboardService _service = SupabaseDashboardService();

  int _currentIndex = 2;

  int totalAlat = 0;
  int alatTersedia = 0;
  int pinjamAktif = 0;
  int kembaliHariIni = 0;

  List<Map<String, dynamic>> aktivitas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final results = await Future.wait([
        _service.totalAlat(),
        _service.alatTersedia(),
        _service.pinjamAktif(),
        _service.kembaliHariIni(),
        _service.fetchAktivitasTerbaru(),
      ]);

      setState(() {
        totalAlat = results[0] as int;
        alatTersedia = results[1] as int;
        pinjamAktif = results[2] as int;
        kembaliHariIni = results[3] as int;
        aktivitas = results[4] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
    }
  }

  String ringkasAktivitas(String text) {
    final t = text.toLowerCase();

    if (t.contains('tambah') || t.contains('insert')) {
      return 'Menambah data';
    }
    if (t.contains('edit') || t.contains('update')) {
      return 'Mengubah data';
    }
    if (t.contains('hapus') || t.contains('delete')) {
      return 'Menghapus data';
    }
    if (t.contains('ajukan')) {
      return 'Mengajukan peminjaman';
    }
    if (t.contains('setujui')) {
      return 'Menyetujui peminjaman';
    }
    if (t.contains('tolak')) {
      return 'Menolak peminjaman';
    }
    if (t.contains('kembali')) {
      return 'Mengembalikan alat';
    }
    return text.length > 35 ? '${text.substring(0, 35)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: MediaQuery.of(context).size.height * 0.06,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hallo Petugas',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selamat Datang !',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      children: [
                        InfoCard(
                          icon: Icons.build_outlined,
                          title: 'Total Alat',
                          value: totalAlat.toString(),
                          subtitle: 'Semua Peralatan',
                        ),
                        InfoCard(
                          icon: Icons.check_box_outlined,
                          title: 'Alat Tersedia',
                          value: alatTersedia.toString(),
                          subtitle: 'Siap Dipinjam',
                        ),
                        InfoCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Pinjam Aktif',
                          value: pinjamAktif.toString(),
                          subtitle: 'Sedang Dipinjam',
                        ),
                        InfoCard(
                          icon: Icons.timer_outlined,
                          title: 'Kembali Hari Ini',
                          value: kembaliHariIni.toString(),
                          subtitle: 'Jadwal Kembali',
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ...aktivitas.map((log) {
                      final user = log['pengguna']?['nama'] ?? 'Sistem';
                      final waktu = DateTime.parse(log['waktu']).toLocal();

                      return ActivityItem(
                        title: ringkasAktivitas(log['aktivitas']),
                        user: user,
                        qty: '-',
                        date: '${waktu.day}/${waktu.month}/${waktu.year}',
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);

          Widget page;
          switch (index) {
            case 0:
              page = const PetugasPeminjamanPage();
              break;
            case 1:
              page = const PetugasPengembalianPage();
              break;
            case 2:
              page = const PetugasDashboard();
              break;
            case 3:
              page = const PetugasLaporanPage();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}
