import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toolvolt/admin/screen/admin_dashboard.dart';
import 'package:toolvolt/admin/screen/admin_peminjaman.dart';
import 'package:toolvolt/admin/screen/admin_pengaturan.dart';
import 'package:toolvolt/admin/screen/admin_pengembalian.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/alat_card.dart';
import 'package:image_picker/image_picker.dart';

class AdminAlatPage extends StatefulWidget {
  const AdminAlatPage({super.key});

  @override
  State<AdminAlatPage> createState() => _AdminAlatPageState();
}

class _AdminAlatPageState extends State<AdminAlatPage> {
  int _currentIndex = 0;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String selectedKategori = 'Semua';

  final List<String> kategoriList = [
    'Semua',
    'Alat Ukur',
    'Alat Tangan',
    'Alat Listrik',
  ];

  final List<Map<String, dynamic>> alatList = [
    {
      'nama': 'Multimeter Digital',
      'kategori': 'Alat Ukur',
      'kondisi': 'Baik',
      'total': 7,
      'tersedia': 5,
      'dipinjam': 2,
      'image': 'assets/image/multimeter.png',
    },
    {
      'nama': 'Tang Potong',
      'kategori': 'Alat Tangan',
      'kondisi': 'Baik',
      'total': 5,
      'tersedia': 4,
      'dipinjam': 1,
      'image': 'assets/image/tangpotong.png',
    },
    {
      'nama': 'Solder Listrik',
      'kategori': 'Alat Listrik',
      'kondisi': 'Baik',
      'total': 10,
      'tersedia': 4,
      'dipinjam': 6,
      'image': 'assets/image/solderlistrik.png',
    },
  ];

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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showTambahProductDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF7A00)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tambah Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  _inputLabel('Name'),
                  _textField(),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        flex: 2, 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_inputLabel('Kategori'), _dropdownField()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_inputLabel('Total'), _textField()],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_inputLabel('Kondisi'), _textField()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_inputLabel('Tersedia'), _textField()],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _inputLabel('Image'),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF7A00)),
                      ),
                      child: _selectedImage == null
                          ? const Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF7A00)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Tambah',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/image/logo1remove.png',
                width: MediaQuery.of(context).size.width * 0.55,
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 22, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD8D8D8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    height: 44,
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        setState(() {
                          selectedKategori = value;
                        });
                      },
                      itemBuilder: (context) {
                        return kategoriList
                            .map(
                              (kategori) => PopupMenuItem<String>(
                                value: kategori,
                                child: Text(kategori),
                              ),
                            )
                            .toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8D8D8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedKategori,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: alatList
                    .where(
                      (alat) =>
                          selectedKategori == 'Semua' ||
                          alat['kategori'] == selectedKategori,
                    )
                    .map(
                      (alat) => AlatCard(
                        nama: alat['nama'],
                        kategori: alat['kategori'],
                        kondisi: alat['kondisi'],
                        total: alat['total'],
                        tersedia: alat['tersedia'],
                        dipinjam: alat['dipinjam'],
                        imagePath: alat['image'],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7A00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _showTambahProductDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _textField() {
    return SizedBox(
      height: 42,
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF7A00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF7A00)),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return SizedBox(
      height: 42,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF7A00)),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Alat Ukur', child: Text('Alat Ukur')),
          DropdownMenuItem(value: 'Alat Tangan', child: Text('Alat Tangan')),
          DropdownMenuItem(value: 'Alat Listrik', child: Text('Alat Listrik')),
        ],
        onChanged: (value) {},
      ),
    );
  }
}
