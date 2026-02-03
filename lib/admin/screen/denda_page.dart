import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/denda/tambah_denda_dialog.dart';
import '../widgets/denda/edit_denda_dialog.dart';
import '../widgets/denda/hapus_denda_dialog.dart';

final supabase = Supabase.instance.client;

class DendaScreen extends StatefulWidget {
  const DendaScreen({super.key});

  @override
  State<DendaScreen> createState() => _DendaScreenState();
}

class _DendaScreenState extends State<DendaScreen> {
  List<Map<String, dynamic>> _dendaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDenda();
  }

  Future<void> _loadDenda() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('denda')
          .select('id_denda, nama_denda, biaya')
          .order('nama_denda', ascending: true);

      setState(() {
        _dendaList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data denda: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _tambahDenda(String nama, int biaya) async {
    try {
      await supabase.from('denda').insert({
        'nama_denda': nama.trim(),
        'biaya': biaya,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denda berhasil ditambahkan')),
        );
      }
      await _loadDenda();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambah denda: $e')));
      }
    }
  }

  Future<void> _editDenda(int id, String namaBaru, int biayaBaru) async {
    try {
      await supabase
          .from('denda')
          .update({'nama_denda': namaBaru.trim(), 'biaya': biayaBaru})
          .eq('id_denda', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denda berhasil diupdate')),
        );
      }
      await _loadDenda();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengedit denda: $e')));
      }
    }
  }

  Future<void> _hapusDenda(int id, String nama) async {
    try {
      await supabase.from('denda').delete().eq('id_denda', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Denda "$nama" berhasil dihapus')),
        );
      }
      await _loadDenda();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus denda: $e\n(Mungkin masih digunakan di peminjaman?)',
            ),
          ),
        );
      }
    }
  }

  void _showTambahDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahDendaDialog(onTambah: _tambahDenda),
    );
  }

  void _showEditDialog(int id, String namaLama, int biayaLama) {
    showDialog(
      context: context,
      builder: (context) => EditDendaDialog(
        id: id,
        namaLama: namaLama,
        biayaLama: biayaLama,
        onEdit: _editDenda,
      ),
    );
  }

  void _showHapusDialog(int id, String nama) {
    showDialog(
      context: context,
      builder: (context) =>
          HapusDendaDialog(id: id, nama: nama, onHapus: _hapusDenda),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF7733);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        onPressed: _showTambahDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.black,
                  ),
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
                "Denda",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _dendaList.isEmpty
                    ? const Center(child: Text('Belum ada data denda'))
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Nama Denda',
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
                                      'Biaya',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Aksi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: _dendaList.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey[200],
                                ),
                                itemBuilder: (context, index) {
                                  final denda = _dendaList[index];
                                  final id = denda['id_denda'] as int;
                                  final nama = denda['nama_denda'] as String;
                                  final biaya = denda['biaya'] as int;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            nama,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Rp ${biaya.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () => _showEditDialog(
                                                  id,
                                                  nama,
                                                  biaya,
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () =>
                                                    _showHapusDialog(id, nama),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
