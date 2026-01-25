import 'package:flutter/material.dart';
import 'package:toolvolt/admin/screen/admin_alat_page.dart';
import 'package:toolvolt/admin/screen/admin_peminjaman.dart';
import 'package:toolvolt/admin/screen/admin_pengaturan.dart';
import 'package:toolvolt/admin/screen/admin_pengembalian.dart';
import '../widgets/admin_bottom_nav.dart';
import 'package:toolvolt/admin/widgets/info_card.dart';
import 'package:toolvolt/admin/widgets/activity_item.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 2;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminAlatPage()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeminjamanPage()),
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
          MaterialPageRoute(builder: (_) => const PengembalianPage()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
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
                'Hallo admin',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                children: const [
                  InfoCard(
                    icon: Icons.build_outlined,
                    title: 'Total Alat',
                    value: '14',
                    subtitle: 'Semua Peralatan',
                  ),
                  InfoCard(
                    icon: Icons.check_box_outlined,
                    title: 'Alat Tersedia',
                    value: '10',
                    subtitle: 'Siap Dipinjam',
                  ),
                  InfoCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Pinjam Aktif',
                    value: '2',
                    subtitle: 'Sedang Dipinjam',
                  ),
                  InfoCard(
                    icon: Icons.timer_outlined,
                    title: 'Kembali Hari Ini',
                    value: '0',
                    subtitle: 'Jadwal Kembali',
                  ),
                ],
              ),

              const SizedBox(height: 36),

              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 18),

              const ActivityItem(
                title: 'Meminjam Obeng Set',
                user: 'Ayu Lestari',
                qty: '5 unit',
                date: '15/1/2026',
              ),
              const ActivityItem(
                title: 'Mengembalikan Tang Ampere',
                user: 'Rizky Ilham',
                qty: '1 unit',
                date: '14/1/2026',
              ),
              const ActivityItem(
                title: 'Menambah Alat: Power Supply',
                user: 'Malika',
                qty: '6 unit',
                date: '13/1/2026',
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
