import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolvolt/petugas/service/supabase_peminjaman_service.dart' show PeminjamanService;
import '../widgets/history_card.dart';
import '../widgets/persetujuan_card.dart';
import '../widgets/petugas_bottom_nav.dart';
import 'petugas_dashboard.dart';
import 'petugas_laporan_page.dart';
import 'petugas_pengembalian_page.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PetugasPeminjamanPage extends StatefulWidget {
  const PetugasPeminjamanPage({super.key});

  @override
  State<PetugasPeminjamanPage> createState() => _PetugasPeminjamanPageState();
}

class _PetugasPeminjamanPageState extends State<PetugasPeminjamanPage> {
  int _currentIndex = 0;
  final PeminjamanService _service = PeminjamanService();
  List<Map<String, dynamic>> _allPeminjaman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    final data = await _service.getAllPeminjaman();
    data.sort(
      (a, b) => int.parse(a['id_peminjaman'].toString())
          .compareTo(int.parse(b['id_peminjaman'].toString())),
    );

    setState(() {
      _allPeminjaman = data;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await Supabase.instance.client
          .from('peminjaman')
          .update({'status': status})
          .eq('id_peminjaman', id);

      final index = _allPeminjaman.indexWhere((p) => p['id_peminjaman'] == id);
      if (index != -1) {
        setState(() {
          _allPeminjaman[index]['status'] = status;
        });
      }
    } catch (e) {
      _showTopSnackBar('Gagal mengupdate status: $e', isError: true);
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
              Icon(
                isError ? Icons.error : Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFBE4A31)),
        ),
      );
    }
    final menunggu =
        _allPeminjaman.where((p) => p['status'] == 'Menunggu').toList();
    final riwayat =
        _allPeminjaman.where((p) => p['status'] != 'Menunggu').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/image/logo1remove.png',
                  width: MediaQuery.of(context).size.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Menunggu Persetujuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              if (menunggu.isEmpty)
                const Text(
                  "Tidak ada peminjaman yang menunggu persetujuan.",
                  style: TextStyle(color: Colors.grey),
                ),

              ...menunggu.map((p) {
                final List details = p['detail_peminjaman'];
                if (details.isEmpty) return const SizedBox();
                final detail = details.first;

                return ApprovalCard(
                  id: p['id_peminjaman'].toString(),
                  nama: p['pengguna']['nama'] ?? '-',
                  tanggalPinjam: p['tanggal_pinjam'] ?? '',
                  tanggalKembali: p['tanggal_kembali'] ?? '',
                  alat: detail['alat']['nama_alat'] ?? '-',
                  jumlah: detail['jumlah'] ?? 0,
                  onApproved: () async {
                    await _updateStatus(p['id_peminjaman'], 'dipinjam');
                    _showTopSnackBar(
                        'Peminjaman disetujui & sedang dipinjam');
                  },
                  onRejected: () async {
                    await _updateStatus(p['id_peminjaman'], 'ditolak');
                    _showTopSnackBar('Peminjaman ditolak', isError: true);
                  },
                );
              }).toList(),

              const SizedBox(height: 30),
              const Text(
                'Riwayat Peminjaman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              ...riwayat.map((p) {
                final List details = p['detail_peminjaman'];
                if (details.isEmpty) return const SizedBox();
                final detail = details.first;

                Color statusColor = Colors.orange;
                switch (p['status']) {
                  case 'dikembalikan':
                    statusColor = Colors.green;
                    break;
                  case 'ditolak':
                    statusColor = Colors.red;
                    break;
                  case 'disetujui':
                    statusColor = Colors.green;
                    break;
                  case 'dipinjam':
                    statusColor = Colors.blue;
                    break;
                }

                return HistoryCard(
                  id: p['id_peminjaman'].toString(),
                  nama: p['pengguna']['nama'] ?? '',
                  tanggalPinjam: p['tanggal_pinjam'] ?? '',
                  tanggalKembali: p['tanggal_kembali'] ?? '-',
                  alat: detail['alat']['nama_alat'] ?? '-',
                  jumlah: detail['jumlah'] ?? 0,
                  status: p['status'],
                  statusColor: statusColor,
                );
              }).toList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          switch (index) {
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
