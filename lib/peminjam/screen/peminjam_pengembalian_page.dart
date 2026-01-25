import 'package:flutter/material.dart';
import '../widgets/pengembalian_card.dart';
import '../widgets/peminjam_bottom_nav.dart';
import 'peminjam_dashboard_page.dart';
import 'peminjam_list_alat_page.dart';
import 'peminjam_peminjaman_page.dart';

class PeminjamPengembalianPage extends StatefulWidget {
  const PeminjamPengembalianPage({super.key});

  @override
  State<PeminjamPengembalianPage> createState() =>
      _PeminjamPengembalianPageState();
}

class _PeminjamPengembalianPageState extends State<PeminjamPengembalianPage> {
  int _currentIndex = 3;

  static const Color primaryColor = Color(0xFFBE4A31);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: Padding(
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
                'Pengembalian Alat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              const PengembalianPeminjamCard(
                id: '1',
                nama: 'Dewi Lestari',
                tanggalPinjam: '16/1/2025',
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: PeminjamBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PeminjamListAlatPage()),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PeminjamPeminjamanPage(),
                ),
              );
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
