import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/peminjam_service.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/peminjaman/peminjaman_card.dart';
import '../widgets/peminjaman/tambah_peminjaman_dialog.dart';
import 'admin_alat_page.dart';
import 'admin_dashboard.dart';
import 'admin_pengaturan.dart';
import 'admin_pengembalian.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  int _currentIndex = 1;
  bool _isLoading = true;
  List<Map<String, dynamic>> _peminjamanList = [];

  final PeminjamanService _service = PeminjamanService();

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final data = await _service.getAllPeminjaman();
      if (mounted) {
        setState(() {
          _peminjamanList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data peminjaman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    Widget? nextPage;
    switch (index) {
      case 0:
        nextPage = const AdminAlatScreen();
        break;
      case 1:
        nextPage = const PeminjamanScreen();
        break;
      case 2:
        nextPage = const AdminDashboard();
        break;
      case 3:
        nextPage = const PengembalianScreen();
        break;
      case 4:
        nextPage = const PengaturanPage();
        break;
    }

    if (nextPage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage!),
      );
    }
  }

  void _showAddPeminjamanDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahPeminjamanDialog(
        onSuccess: () {
          _loadPeminjaman();
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _peminjamanList.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada data peminjaman',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadPeminjaman,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                      ..._peminjamanList.map((data) {
                        final detailList =
                            data['detail_peminjaman'] as List<dynamic>? ?? [];

                        final List<Map<String, dynamic>> items = detailList.map(
                          (d) {
                            final alatMap =
                                d['alat'] as Map<String, dynamic>? ?? {};
                            return {
                              'nama_alat':
                                  alatMap['nama_alat'] as String? ??
                                  'Alat tidak diketahui',
                              'jumlah': d['jumlah'] as int? ?? 0,
                            };
                          },
                        ).toList();

                        return PeminjamanCard(
                          id: data['id_peminjaman'].toString(),
                          nama:
                              (data['pengguna'] as Map?)?['nama'] as String? ??
                              'Unknown',
                          tglPinjam: _formatDate(data['tanggal_pinjam']),
                          tglKembali: _formatDate(data['tanggal_kembali']),
                          status: data['status'] ?? 'dipinjam',
                          statusColor:
                              (data['status']
                                      ?.toString()
                                      .toLowerCase()
                                      .contains('kembali') ??
                                  false)
                              ? Colors.green
                              : (data['status']?.toString().toLowerCase() ==
                                        'dipinjam'
                                    ? Colors.orange
                                    : Colors.grey),
                          items: items,
                          onRefresh: _loadPeminjaman,
                        );
                      }).toList(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7A00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _showAddPeminjamanDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
