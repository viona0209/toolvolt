import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/kategori/kategori_card.dart';
import '../widgets/kategori/tambah_kategori_dialog.dart';
import '../widgets/kategori/edit_kategori_dialog.dart';
import '../widgets/kategori/hapus_kategori_dialog.dart';

final supabase = Supabase.instance.client;

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  List<Map<String, dynamic>> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('kategori')
          .select('id_kategori, nama_kategori')
          .order('nama_kategori', ascending: true);

      setState(() {
        _kategoriList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kategori: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _tambahKategori(String nama) async {
    try {
      await supabase.from('kategori').insert({'nama_kategori': nama.trim()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil ditambahkan')),
        );
      }
      await _loadKategori();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah kategori: $e')),
        );
      }
    }
  }

  Future<void> _editKategori(int id, String namaBaru) async {
    try {
      await supabase
          .from('kategori')
          .update({'nama_kategori': namaBaru.trim()})
          .eq('id_kategori', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil diupdate')),
        );
      }
      await _loadKategori();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengedit kategori: $e')),
        );
      }
    }
  }

  Future<void> _hapusKategori(int id, String nama) async {
    try {
      await supabase.from('kategori').delete().eq('id_kategori', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori "$nama" berhasil dihapus')),
        );
      }
      await _loadKategori();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus kategori: $e\n(Mungkin masih ada alat yang terkait?)')),
        );
      }
    }
  }

  void _showTambahDialog() {
    showDialog(
      context: context,
      builder: (context) => TambahKategoriDialog(
        onTambah: _tambahKategori,
      ),
    );
  }

  void _showEditDialog(int id, String namaLama) {
    showDialog(
      context: context,
      builder: (context) => EditKategoriDialog(
        id: id,
        namaLama: namaLama,
        onEdit: _editKategori,
      ),
    );
  }

  void _showHapusDialog(int id, String nama) {
    showDialog(
      context: context,
      builder: (context) => HapusKategoriDialog(
        id: id,
        nama: nama,
        onHapus: _hapusKategori,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7733),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: _showTambahDialog,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 32, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Image.asset(
                  "assets/image/logo1remove.png",
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Kategori",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _kategoriList.isEmpty
                        ? const Center(child: Text('Belum ada kategori'))
                        : ListView.builder(
                            itemCount: _kategoriList.length,
                            itemBuilder: (context, index) {
                              final item = _kategoriList[index];
                              final id = item['id_kategori'] as int;
                              final nama = item['nama_kategori'] as String;
                              return KategoriCard(
                                title: nama,
                                onEdit: () => _showEditDialog(id, nama),
                                onDelete: () => _showHapusDialog(id, nama),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}