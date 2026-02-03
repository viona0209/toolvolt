import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolvolt/peminjam/service/peminjam_service.dart';
import '../../login_screen.dart';
import '../widgets/peminjam_bottom_nav.dart';
import 'peminjam_list_alat_page.dart';
import 'peminjam_peminjaman_page.dart';
import 'peminjam_pengembalian_page.dart';

class PeminjamDashboardPage extends StatefulWidget {
  const PeminjamDashboardPage({super.key});

  @override
  State<PeminjamDashboardPage> createState() => _PeminjamDashboardPageState();
}

class _PeminjamDashboardPageState extends State<PeminjamDashboardPage> {
  int _currentIndex = 2;
  static const Color primaryOrange = Color(0xFFFF8E01);

  final service = PeminjamService();

  int totalAlat = 0;
  int peminjamanAktif = 0;
  int totalRiwayat = 0;
  List<Map<String, dynamic>> riwayat = [];

  int? idPeminjam;

  @override
  void initState() {
    super.initState();
    loadPeminjamIdAndData();
  }

  Future<void> loadPeminjamIdAndData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint("⚠ Tidak ada user yang login!");
      return;
    }

    final authId = user.id;

    final response = await Supabase.instance.client
        .from('pengguna')
        .select('id_pengguna')
        .eq('auth_id', authId)
        .maybeSingle();

    if (response == null || response['id_pengguna'] == null) {
      debugPrint(
        "⚠ Gagal mengambil id peminjam: pastikan user ada di tabel 'pengguna'",
      );
      return;
    }

    idPeminjam = response['id_pengguna'] as int;

    loadData();
  }

  Future<void> loadData() async {
    if (idPeminjam == null) return;

    final alat = await service.getTotalAlatTersedia();
    final aktif = await service.getPeminjamanAktif(idPeminjam!);
    final histori = await service.getTotalRiwayat(idPeminjam!);
    final listRiwayat = await service.getRiwayat(idPeminjam!);

    setState(() {
      totalAlat = alat;
      peminjamanAktif = aktif;
      totalRiwayat = histori;
      riwayat = listRiwayat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hallo Peminjam',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              const Text(
                'Selamat Datang !',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 28),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildCard(
                        icon: Icons.inventory_2_rounded,
                        title: "Alat Tersedia",
                        value: totalAlat.toString(),
                        subtitle: "Semua Peralatan",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildCardSmall(
                              icon: Icons.assignment_turned_in_outlined,
                              title: "Pinjam",
                              subtitleTop: "Aktif",
                              value: peminjamanAktif.toString(),
                              subtitleBottom: "Sedang dipinjam",
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildCardSmall(
                              icon: Icons.history_rounded,
                              title: "Riwayat",
                              subtitleTop: "",
                              value: totalRiwayat.toString(),
                              subtitleBottom: "Total Riwayat",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Riwayat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (var item in riwayat) _buildRiwayatItem(item),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PeminjamBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);

          Widget page;
          switch (index) {
            case 0:
              page = const PeminjamListAlatPage();
              break;
            case 1:
              page = const PeminjamPeminjamanPage();
              break;
            case 2:
              page = const PeminjamDashboardPage();
              break;
            case 3:
              page = const PeminjamPengembalianPage();
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: primaryOrange),
          const SizedBox(height: 24),
          Text(title, style: _titleStyle()),
          const SizedBox(height: 12),
          Text(value, style: _valueStyle()),
          const SizedBox(height: 8),
          Text(subtitle, style: _subtitleStyle()),
        ],
      ),
    );
  }

  Widget _buildCardSmall({
    required IconData icon,
    required String title,
    required String subtitleTop,
    required String value,
    required String subtitleBottom,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _titleSmall()),
                  if (subtitleTop.isNotEmpty)
                    Text(subtitleTop, style: _titleSmall()),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Text(value, style: _valueSmall()),
              const SizedBox(height: 6),
              Text(subtitleBottom, style: _subtitleStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(Map<String, dynamic> item) {
    final pinjam = item['tanggal_pinjam'] ?? '-';
    final kembali = item['tanggal_kembali'] ?? '-';
    final jumlah = item['detail_peminjaman']?.length ?? 0;

    final status = (item['status'] ?? "").toString().toLowerCase();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case "dikembalikan":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline_rounded;
        statusText = "Dikembalikan";
        break;
      case "disetujui":
        statusColor = Colors.blue;
        statusIcon = Icons.verified_rounded;
        statusText = "Disetujui";
        break;
      case "dipinjam":
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_rounded;
        statusText = "Dipinjam";
        break;
      case "ditolak":
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusText = "Ditolak";
        break;
      case "menunggu":
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_bottom_rounded;
        statusText = "Menunggu";
        break;
      default:
        statusColor = Colors.black26;
        statusIcon = Icons.help_outline_rounded;
        statusText = "Tidak diketahui";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(
            statusIcon,
            color: statusColor,
            bg: statusColor.withOpacity(0.12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pinjam: $pinjam"),
                const SizedBox(height: 6),
                Text("Kembali: $kembali"),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text('$jumlah item', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: primaryOrange, width: 1.8),
    boxShadow: [
      BoxShadow(
        color: primaryOrange.withOpacity(0.07),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _iconBox(IconData icon, {Color color = primaryOrange, Color? bg}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg ?? primaryOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }

  TextStyle _titleStyle() =>
      const TextStyle(fontSize: 17, fontWeight: FontWeight.w600);

  TextStyle _titleSmall() =>
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

  TextStyle _valueStyle() => const TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.bold,
    color: primaryOrange,
  );

  TextStyle _valueSmall() => const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: primaryOrange,
  );

  TextStyle _subtitleStyle() =>
      const TextStyle(fontSize: 13, color: Colors.black54);
}
