import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/peminjaman_card.dart';
import '../widgets/peminjam_bottom_nav.dart';
import 'peminjam_dashboard_page.dart';
import 'peminjam_list_alat_page.dart';
import 'peminjam_pengembalian_page.dart';

final supabase = Supabase.instance.client;

class PeminjamPeminjamanPage extends StatefulWidget {
  const PeminjamPeminjamanPage({super.key});

  @override
  State<PeminjamPeminjamanPage> createState() => _PeminjamPeminjamanPageState();
}

class _PeminjamPeminjamanPageState extends State<PeminjamPeminjamanPage> {
  int _currentIndex = 1;
  String selectedStatus = 'status';
  List<Map<String, dynamic>> listPeminjaman = [];
  List<Map<String, dynamic>> get filteredList {
    if (selectedStatus == "status") return listPeminjaman;
    return listPeminjaman
        .where((item) => item["status"] == selectedStatus)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  Future<void> _loadPeminjaman() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final res = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('auth_id', user.id)
          .single();
      if (res == null) return;
      final int idPengguna = res['id_pengguna'];

      final data = await supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tanggal_pinjam,
            tanggal_kembali,
            status,
            detail_peminjaman(
              id_alat,
              jumlah,
              alat(nama_alat)
            )
          ''')
          .eq('id_pengguna', idPengguna)
          .order('id_peminjaman', ascending: false);

      if (!mounted) return;
      setState(() => listPeminjaman = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint("ERR load peminjaman: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: listPeminjaman.isEmpty
                  ? const Center(child: Text("Tidak ada peminjaman"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final idDatabase = item["id_peminjaman"].toString();

                        String alat = "-";
                        final detail = item["detail_peminjaman"];
                        if (detail != null && detail.isNotEmpty) {
                          alat = detail[0]["alat"]["nama_alat"] ?? "-";
                        }

                        final status = item["status"];
                        final statusColor = status == "dipinjam"
                            ? Colors.orange
                            : Colors.green;

                        return Column(
                          children: [
                            PeminjamanPeminjamCard(
                              id: idDatabase,
                              nama: "Anda",
                              tanggalPinjam: item["tanggal_pinjam"].toString(),
                              tanggalKembali:
                                  item["tanggal_kembali"]?.toString() ?? "-",
                              alat: alat,
                              status: status,
                              statusColor: statusColor,
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Center(
            child: Image.asset(
              'assets/image/logo1remove.png',
              width: MediaQuery.of(context).size.width * 0.55,
            ),
          ),
          const SizedBox(height: 35),
          const Text(
            'Daftar peminjaman',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatusFilter()),
              const SizedBox(width: 12),
              Expanded(child: _buildAjukanButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus == "status" ? null : selectedStatus,
          hint: const Text("status"),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'dipinjam', child: Text('dipinjam')),
            DropdownMenuItem(
              value: 'dikembalikan',
              child: Text('dikembalikan'),
            ),
            DropdownMenuItem(value: 'disetujui', child: Text('disetujui')),
            DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
            DropdownMenuItem(value: 'ditolak', child: Text('ditolak')),
          ],
          onChanged: (v) => setState(() => selectedStatus = v!),
        ),
      ),
    );
  }

  Widget _buildAjukanButton(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFBE4A31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _showAjukanPeminjamanDialog(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ajukan Peminjaman",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            SizedBox(width: 6),
            Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return PeminjamBottomNav(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PeminjamListAlatPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PeminjamDashboardPage()),
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
        }
      },
    );
  }

  void _showAjukanPeminjamanDialog(BuildContext context) {
    DateTime? tglPinjam;
    DateTime? tglKembali;
    String selectedAlat = "Pilih alat";
    List<Map<String, dynamic>> daftarAlat = [];

    Future<void> loadAlat() async {
      final res = await supabase
          .from('alat')
          .select('id_alat,nama_alat,jumlah_tersedia');
      daftarAlat = List<Map<String, dynamic>>.from(res);
    }

    loadAlat();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Ajukan peminjaman",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text("tgl. pinjam"),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tglPinjam ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() => tglPinjam = picked);
                        }
                      },
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF7733)),
                        ),
                        child: Text(
                          tglPinjam != null
                              ? "${tglPinjam!.day}-${tglPinjam!.month}-${tglPinjam!.year}"
                              : "Pilih tanggal",
                          style: TextStyle(
                            color: tglPinjam != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text("tgl. kembali"),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tglKembali ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() => tglKembali = picked);
                        }
                      },
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF7733)),
                        ),
                        child: Text(
                          tglKembali != null
                              ? "${tglKembali!.day}-${tglKembali!.month}-${tglKembali!.year}"
                              : "Pilih tanggal",
                          style: TextStyle(
                            color: tglKembali != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text("Pilih alat"),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF7733)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedAlat,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: "Pilih alat",
                              child: Text("Pilih alat"),
                            ),
                            ...daftarAlat.map(
                              (a) => DropdownMenuItem(
                                value: a["id_alat"].toString(),
                                child: Text(
                                  "${a["nama_alat"]} (Tersedia: ${a["jumlah_tersedia"]})",
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setStateDialog(() => selectedAlat = v!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (tglPinjam == null ||
                                  tglKembali == null ||
                                  selectedAlat == "Pilih alat") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lengkapi semua data"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(context);
                              await _ajukanPeminjaman(
                                "${tglPinjam!.year}-${tglPinjam!.month}-${tglPinjam!.day}",
                                "${tglKembali!.year}-${tglKembali!.month}-${tglKembali!.day}",
                                int.parse(selectedAlat),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7733),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Ajukan",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF7733)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Color(0xFFFF7733)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _ajukanPeminjaman(
    String tPinjam,
    String tKembali,
    int idAlat,
  ) async {
    try {
      final user = supabase.auth.currentUser!;
      final res = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('auth_id', user.id)
          .single();
      final int idPengguna = res['id_pengguna'];

      final insertPeminjaman = await supabase
          .from('peminjaman')
          .insert({
            'id_pengguna': idPengguna,
            'tanggal_pinjam': tPinjam,
            'tanggal_kembali': tKembali,
            'status': 'Menunggu',
          })
          .select()
          .single();
      final idPeminjaman = insertPeminjaman["id_peminjaman"];

      await supabase.from('detail_peminjaman').insert({
        'id_peminjaman': idPeminjaman,
        'id_alat': idAlat,
        'jumlah': 1,
      });

      await supabase.rpc(
        "kurangi_jumlah_tersedia",
        params: {"alatid": idAlat, "jumlahpinjam": 1},
      );

      await supabase.from('log_aktivitas').insert({
        'id_pengguna': idPengguna,
        'aktivitas':
            'Mengajukan peminjaman alat ID $idAlat (peminjaman ID $idPeminjaman)',
      });

      _loadPeminjaman();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengajuan berhasil"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("ERR ajukan peminjaman: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengajukan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
