import 'package:flutter/material.dart';
import '../widgets/history_card.dart';
import '../widgets/persetujuan_card.dart';
import '../widgets/petugas_bottom_nav.dart';
import 'petugas_dashboard.dart';
import 'petugas_laporan_page.dart';
import 'petugas_pengembalian_page.dart';

class PetugasPeminjamanPage extends StatefulWidget {
  const PetugasPeminjamanPage({super.key});

  @override
  State<PetugasPeminjamanPage> createState() => _PetugasPeminjamanPageState();
}

class _PetugasPeminjamanPageState extends State<PetugasPeminjamanPage> {
  int _currentIndex = 0;

  static const Color primaryColor = Color(0xFFBE4A31);

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'List Peminjaman',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Status',
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        items: const [
                          DropdownMenuItem(
                            value: 'Status',
                            child: Text(
                              'Status',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ],
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

              ApprovalCard(
                id: '3',
                nama: 'Kangkung',
                tanggalPinjam: '10/1/2026',
                tanggalKembali: '17/1/2026',
                alat: 'Obeng set',
                jumlah: 1,
                onApproved: () {},
                onRejected: () {},
              ),
              const SizedBox(height: 32),
              const Text(
                'Riwayat Peminjaman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              HistoryCard(
                id: '1',
                nama: 'Dewi Lestari',
                tanggalPinjam: '16/1/2026',
                tanggalKembali: '23/1/2026',
                alat: 'Tang Potong',
                status: 'Dipinjam',
                statusColor: Colors.orange,
                jumlah: 1,
              ),

              HistoryCard(
                id: '2',
                nama: 'Ahmad Rizky',
                tanggalPinjam: '10/1/2026',
                tanggalKembali: '17/1/2026',
                alat: 'Tang Ampere',
                status: 'Dikembalikan',
                statusColor: Colors.green,
                jumlah: 1,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
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
