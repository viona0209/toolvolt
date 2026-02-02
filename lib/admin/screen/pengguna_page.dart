import 'package:flutter/material.dart';
import '../services/pengguna_service.dart';
import '../widgets/pengguna/pengguna_card.dart';
import '../widgets/pengguna/tambah_pengguna_dialog.dart';
import '../widgets/pengguna/edit_pengguna_dialog.dart';
import '../widgets/pengguna/hapus_pengguna_dialog.dart';
import '../widgets/pengguna/input_decoration.dart';

class PenggunaScreen extends StatefulWidget {
  const PenggunaScreen({super.key});

  @override
  State<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  final penggunaService = PenggunaService();

  List<Map<String, dynamic>> penggunaList = [];
  List<Map<String, dynamic>> filteredPenggunaList = [];
  bool loading = true;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    searchController.addListener(_filterPengguna);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterPengguna() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPenggunaList = penggunaList;
      } else {
        filteredPenggunaList = penggunaList.where((pengguna) {
          final nama = (pengguna['nama'] ?? '').toString().toLowerCase();
          final role = (pengguna['role'] ?? '').toString().toLowerCase();
          return nama.contains(query) || role.contains(query);
        }).toList();
      }
    });
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    penggunaList = await penggunaService.getPengguna();
    filteredPenggunaList = penggunaList;

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF7733);

    final totalPengguna = penggunaList.length;

    final totalPetugas = penggunaList
        .where((e) => e['role'] == 'petugas' || e['role'] == 'admin')
        .length;

    final totalPeminjam =
        penggunaList.where((e) => e['role'] == 'peminjam').length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Back button
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 32,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
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
                        'Pengguna',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Search + button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: inputDecoration(
                                // hintText: 'Cari pengguna...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () async {
                              final success = await showTambahPenggunaDialog(
                                context,
                              );
                              if (success == true) loadData();
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ===== Total Card =====
                      SizedBox(
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTotalCard(
                                  icon: Icons.person_outline,
                                  color: primaryOrange,
                                  title: "Total Pengguna",
                                  total: totalPengguna,
                                  subtitle: "Terdaftar",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      width: 150,
                                      child: _buildTotalCard(
                                        icon: Icons.shield_outlined,
                                        color: primaryOrange,
                                        title: "Petugas",
                                        total: totalPetugas,
                                        subtitle: "Staff",
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 150,
                                      height: 200,
                                      child: _buildTotalCard(
                                        icon: Icons.person_outline,
                                        color: primaryOrange,
                                        title: "Peminjam",
                                        total: totalPeminjam,
                                        subtitle: "Siswa",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Daftar Pengguna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== LIST PENGGUNA =====
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryOrange, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            // HEADER
                            _buildHeader(),

                            // --- LOOP DATA ---
                            if (filteredPenggunaList.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'Tidak ada pengguna ditemukan',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              ...filteredPenggunaList.map((item) {
                                return Column(
                                  children: [
                                    PenggunaCard(
                                      name: item['nama'] ?? "-",
                                      role: item['role'] ?? "",
                                      onEdit: () async {
                                        final success =
                                            await showEditPenggunaDialog(
                                          context,
                                          item['id_pengguna'],
                                          item['nama'],
                                          item['username'],
                                          item['role'],
                                        );
                                        if (success == true) loadData();
                                      },
                                      onDelete: () async {
                                        final success =
                                            await showHapusPenggunaDialog(
                                          context,
                                          item['id_pengguna'],
                                          item['nama'],
                                          authId: item['auth_id']?.toString(), // ✅ KIRIM AUTH_ID
                                        );
                                        if (success == true) loadData();
                                      },
                                    ),
                                    if (item !=
                                        filteredPenggunaList.last)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey[300],
                                      ),
                                  ],
                                );
                              }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTotalCard({
    required IconData icon,
    required Color color,
    required String title,
    required int total,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.3),
        color: const Color(0xFFFFF8F4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            "$total",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nama',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Role',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(
            width: 70,
            child: Text('Aksi', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}