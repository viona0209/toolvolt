import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogAktivitasPage extends StatefulWidget {
  const LogAktivitasPage({super.key});

  @override
  State<LogAktivitasPage> createState() => _LogAktivitasPageState();
}

/* ============================
   MODEL DATA LOG AKTIVITAS
============================ */
class LogAktivitas {
  final String aktivitas;
  final String nama;
  final String role;
  final DateTime waktu;

  LogAktivitas({
    required this.aktivitas,
    required this.nama,
    required this.role,
    required this.waktu,
  });

  factory LogAktivitas.fromMap(Map<String, dynamic> map) {
    final pengguna = map['pengguna'];

    return LogAktivitas(
      aktivitas: map['aktivitas'] ?? '-',
      nama: pengguna != null && pengguna['nama'] != null
          ? pengguna['nama']
          : 'System',
      role: pengguna != null && pengguna['role'] != null
          ? pengguna['role']
          : 'system',
      waktu: DateTime.parse(map['waktu']),
    );
  }
}

class _LogAktivitasPageState extends State<LogAktivitasPage> {
  final supabase = Supabase.instance.client;

  List<LogAktivitas> _aktivitasList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLogAktivitas();
  }

  /* ============================
     AMBIL & FILTER LOG INTI
  ============================ */
  Future<void> loadLogAktivitas() async {
    try {
      final response = await supabase
          .from('log_aktivitas')
          .select('''
            aktivitas,
            waktu,
            pengguna (
              nama,
              role
            )
          ''')
          .order('waktu', ascending: false);

      final List<String> aktivitasInti = [
        'mengajukan',
        'disetujui',
        'ditolak',
        'pengembalian',
        'menambah',
      ];

      final filtered = response.where((e) {
        final aktivitas = (e['aktivitas'] ?? '').toString().toLowerCase();
        return aktivitasInti.any((key) => aktivitas.contains(key));
      }).toList();

      setState(() {
        _aktivitasList = filtered.map((e) => LogAktivitas.fromMap(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error load log aktivitas: $e');
      isLoading = false;
    }
  }

  /* ============================
     RANGKUM TEKS AKTIVITAS
  ============================ */
  String ringkasAktivitas(LogAktivitas log) {
    final text = log.aktivitas.toLowerCase();
    final nama = log.nama;

    if (text.contains('mengajukan')) {
      return '$nama mengajukan peminjaman alat';
    }

    if (text.contains('disetujui')) {
      return 'Petugas menyetujui peminjaman';
    }

    if (text.contains('ditolak')) {
      return 'Petugas menolak peminjaman';
    }

    if (text.contains('pengembalian') || text.contains('mengembalikan')) {
      return '$nama mengembalikan alat';
    }

    if (text.contains('menambah') || text.contains('insert')) {
      return 'Admin menambahkan alat';
    }

    return log.aktivitas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Image.asset(
                  "assets/image/logo1remove.png",
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Log Aktivitas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 300,
                child: Row(
                  children: [
                    // KOTAK 1 — TOTAL AKTIVITAS
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFFF7733),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 60,
                              color: Color(0xFFFF7733),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Total Aktivitas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _aktivitasList.length.toString(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // KOTAK 2 & 3
                    Expanded(
                      child: Column(
                        children: [
                          _smallStatCard(
                            icon: Icons.today,
                            title: 'Hari Ini',
                            value: _aktivitasList
                                .where((e) {
                                  final now = DateTime.now();
                                  return e.waktu.day == now.day &&
                                      e.waktu.month == now.month &&
                                      e.waktu.year == now.year;
                                })
                                .length
                                .toString(),
                            suffix: 'Aktivitas',
                          ),
                          const SizedBox(height: 14),
                          _smallStatCard(
                            icon: Icons.people_outline,
                            title: 'User Aktif',
                            value: _aktivitasList
                                .map((e) => e.nama)
                                .toSet()
                                .length
                                .toString(),
                            suffix: 'Pengguna',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _aktivitasList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final a = _aktivitasList[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFE5D9),
                            ),
                            child: const Icon(
                              Icons.sync_alt,
                              color: Color(0xFF9C2F14),
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ringkasAktivitas(a),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _infoChip(a.nama),
                                    const SizedBox(width: 8),
                                    _infoChip(a.role),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Text(
                            '${a.waktu.day}/${a.waktu.month}/${a.waktu.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }

  Widget _smallStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String suffix,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF7733), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: const Color(0xFFFF7733)),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                suffix,
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}