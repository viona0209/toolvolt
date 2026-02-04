import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolvolt/peminjam/service/peminjam_service.dart';
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

    if (user == null) return;

    final authId = user.id;

    final response = await Supabase.instance.client
        .from('pengguna')
        .select('id_pengguna')
        .eq('auth_id', authId)
        .maybeSingle();

    if (response == null || response['id_pengguna'] == null) return;

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
    return LayoutBuilder(
      builder: (context, constraint) {
        final width = constraint.maxWidth;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hallo Peminjam',
                      style: TextStyle(
                          fontSize: width * 0.065, fontWeight: FontWeight.bold)),
                  SizedBox(height: width * 0.01),
                  Text('Selamat Datang !',
                      style: TextStyle(fontSize: width * 0.04, color: Colors.black54)),
                  SizedBox(height: width * 0.035),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildCard(
                            icon: Icons.inventory_2_rounded,
                            title: "Alat Tersedia",
                            value: totalAlat.toString(),
                            subtitle: "Semua Peralatan",
                            width: width,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
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
                                  width: width,
                                ),
                              ),
                              SizedBox(height: width * 0.02),
                              Expanded(
                                child: _buildCardSmall(
                                  icon: Icons.history_rounded,
                                  title: "Riwayat",
                                  subtitleTop: "",
                                  value: totalRiwayat.toString(),
                                  subtitleBottom: "Total Riwayat",
                                  width: width,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: width * 0.05),
                  Text(
                    'Riwayat',
                    style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: width * 0.03),
                  for (var item in riwayat) _buildRiwayatItem(item, width),
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
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: width * 0.18, color: primaryOrange),
          SizedBox(height: width * 0.04),
          Text(title,
              style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          SizedBox(height: width * 0.03),
          Text(value,
              style: TextStyle(
                  fontSize: width * 0.15,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange),
              textAlign: TextAlign.center),
          SizedBox(height: width * 0.02),
          Text(subtitle, style: _subtitleStyle(), textAlign: TextAlign.center),
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
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _iconBox(icon, size: width * 0.08),
              SizedBox(width: width * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _titleSmall(width), overflow: TextOverflow.ellipsis),
                    if (subtitleTop.isNotEmpty)
                      Text(subtitleTop,
                          style: _titleSmall(width), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: width * 0.11,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: width * 0.01),
              Text(subtitleBottom, style: _subtitleStyle(), textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(Map<String, dynamic> item, double width) {
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
      margin: EdgeInsets.only(bottom: width * 0.03),
      padding: EdgeInsets.all(width * 0.035),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(statusIcon,
              color: statusColor, bg: statusColor.withOpacity(0.12), size: width * 0.08),
          SizedBox(width: width * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pinjam: $pinjam", style: TextStyle(fontSize: width * 0.035)),
                SizedBox(height: width * 0.015),
                Text("Kembali: $kembali", style: TextStyle(fontSize: width * 0.035)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.035, vertical: width * 0.015),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: Colors.white, fontSize: width * 0.03),
                ),
              ),
              SizedBox(height: width * 0.015),
              Text('$jumlah item', style: TextStyle(fontSize: width * 0.03)),
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

  Widget _iconBox(IconData icon, {Color color = primaryOrange, Color? bg, required double size}) {
    return Container(
      padding: EdgeInsets.all(size * 0.35),
      decoration: BoxDecoration(
        color: bg ?? primaryOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  TextStyle _titleSmall(double width) =>
      TextStyle(fontSize: width * 0.027, fontWeight: FontWeight.w500);

  TextStyle _subtitleStyle() =>
      const TextStyle(fontSize: 13, color: Colors.black54);
}
