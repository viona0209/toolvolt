import 'package:flutter/material.dart';
import '../widgets/pengembalian_card';
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

  static const Color primaryColor = Color(0xFFBE4A31);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                PengembalianCard(
                  id: '1',
                  nama: 'Dewi Lestari',
                  tanggalPinjam: '16/1/2025',
                ),

                const SizedBox(height: 20),

                const Text(
                  'Riwayat Pengembalian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                RiwayatPengembalianCard(
                  id: '2',
                  nama: 'Ahmad Rizky',
                  tanggalKembali: '17/1/2026',
                  denda: '-',
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

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

            // case 4:
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (_) => const PengaturanPage()),
            //   );
            //   break;
          }
        },
      ),
    );
  }
}
