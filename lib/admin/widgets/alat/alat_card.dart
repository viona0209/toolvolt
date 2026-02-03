import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatCard extends StatefulWidget {
  final int idAlat;
  final String nama;
  final String kategori;
  final String kondisi;
  final int total;
  final int tersedia;
  final int dipinjam;
  final String imagePath;
  final VoidCallback? onRefresh;

  const AlatCard({
    super.key,
    required this.idAlat,
    required this.nama,
    required this.kategori,
    required this.kondisi,
    required this.total,
    required this.tersedia,
    required this.dipinjam,
    required this.imagePath,
    this.onRefresh,
  });

  @override
  State<AlatCard> createState() => _AlatCardState();
}

class _AlatCardState extends State<AlatCard> {
  final supabase = Supabase.instance.client;
  List<String> kategoriOptions = [];
  bool isLoadingKategori = true;

  @override
  void initState() {
    super.initState();
    _loadKategoriOptions();
  }

  void showTopMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF6C01),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _loadKategoriOptions() async {
    try {
      final response = await supabase
          .from('kategori')
          .select('id_kategori, nama_kategori')
          .order('nama_kategori');

      if (!mounted) return;
      setState(() {
        kategoriOptions = response
            .map((row) => row['nama_kategori'] as String)
            .toList();
        isLoadingKategori = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingKategori = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFE2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9B3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.imagePath.isNotEmpty
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 30,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.kategori,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(thickness: 0.8),
                    ),
                    Row(
                      children: [
                        Expanded(child: Text('Kondisi : ${widget.kondisi}')),
                        Expanded(child: Text('Tersedia : ${widget.tersedia}')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: Text('Total : ${widget.total}')),
                        Expanded(child: Text('Dipinjam : ${widget.dipinjam}')),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Divider(thickness: 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrange, width: 1.5),
                    foregroundColor: primaryOrange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrange, width: 1.5),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditAlatDialog(
          idAlat: widget.idAlat,
          initialNama: widget.nama,
          initialKategori: widget.kategori,
          initialKondisi: widget.kondisi,
          initialTotal: widget.total,
          initialTersedia: widget.tersedia,
          initialImagePath: widget.imagePath,
          kategoriOptions: kategoriOptions,
          isLoadingKategori: isLoadingKategori,
          primaryOrange: const Color(0xFFFF8E01),
          onSuccess: () {
            widget.onRefresh?.call();
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    const primaryOrange = Color(0xFFFF8E01);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: primaryOrange, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hapus Alat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Apakah kamu yakin ingin menghapus\n${widget.nama} ini?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange, width: 1.5),
                      foregroundColor: primaryOrange,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await supabase
                            .from('alat')
                            .delete()
                            .eq('id_alat', widget.idAlat);

                        if (mounted) {
                          showTopMessage(context, 'Alat berhasil dihapus');
                          widget.onRefresh?.call();
                        }
                      } catch (e) {
                        if (mounted) {
                          showTopMessage(context, 'Gagal menghapus: $e');
                        }
                      }
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditAlatDialog extends StatefulWidget {
  final int idAlat;
  final String initialNama;
  final String initialKategori;
  final String initialKondisi;
  final int initialTotal;
  final int initialTersedia;
  final String initialImagePath;
  final List<String> kategoriOptions;
  final bool isLoadingKategori;
  final Color primaryOrange;
  final VoidCallback onSuccess;

  const _EditAlatDialog({
    required this.idAlat,
    required this.initialNama,
    required this.initialKategori,
    required this.initialKondisi,
    required this.initialTotal,
    required this.initialTersedia,
    required this.initialImagePath,
    required this.kategoriOptions,
    required this.isLoadingKategori,
    required this.primaryOrange,
    required this.onSuccess,
  });

  @override
  State<_EditAlatDialog> createState() => __EditAlatDialogState();
}

class __EditAlatDialogState extends State<_EditAlatDialog> {
  late TextEditingController nameController;
  late TextEditingController totalController;
  late TextEditingController tersediaController;
  late TextEditingController kondisiController;

  String? selectedKategori;
  XFile? pickedFile;
  Uint8List? webImageBytes;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialNama);
    totalController = TextEditingController(
      text: widget.initialTotal.toString(),
    );
    tersediaController = TextEditingController(
      text: widget.initialTersedia.toString(),
    );
    kondisiController = TextEditingController(text: widget.initialKondisi);

    selectedKategori = widget.kategoriOptions.contains(widget.initialKategori)
        ? widget.initialKategori
        : (widget.kategoriOptions.isNotEmpty
              ? widget.kategoriOptions.first
              : null);
  }

  @override
  void dispose() {
    nameController.dispose();
    totalController.dispose();
    tersediaController.dispose();
    kondisiController.dispose();
    super.dispose();
  }

  void showTopMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF6C01),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<String?> _uploadNewImage() async {
    if (pickedFile == null) return widget.initialImagePath;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'alat/$fileName';

      if (kIsWeb) {
        final bytes = await pickedFile!.readAsBytes();
        await supabase.storage
            .from('alat-gambar')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else {
        await supabase.storage
            .from('alat-gambar')
            .upload(
              path,
              File(pickedFile!.path),
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      }

      return supabase.storage.from('alat-gambar').getPublicUrl(path);
    } catch (e, stack) {
      debugPrint('Upload gambar error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
      }
      return null;
    }
  }

  Future<int?> _getKategoriId(String namaKategori) async {
    try {
      final res = await supabase
          .from('kategori')
          .select('id_kategori')
          .eq('nama_kategori', namaKategori)
          .maybeSingle();

      return res?['id_kategori'] as int?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: widget.primaryOrange, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Edit Alat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('Nama Alat'),
              TextField(
                controller: nameController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kategori'),
                        if (widget.isLoadingKategori)
                          const Center(child: CircularProgressIndicator())
                        else if (widget.kategoriOptions.isEmpty)
                          const Text(
                            'Tidak ada kategori tersedia',
                            style: TextStyle(color: Colors.red),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: selectedKategori,
                            hint: const Text('Pilih kategori'),
                            isExpanded: true,
                            decoration: _inputDecoration(),
                            items: widget.kategoriOptions
                                .map(
                                  (kat) => DropdownMenuItem(
                                    value: kat,
                                    child: Text(kat),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedKategori = val),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Total Stok'),
                        TextField(
                          controller: totalController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kondisi'),
                        TextField(
                          controller: kondisiController,
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tersedia'),
                        TextField(
                          controller: tersediaController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('Gambar (tap untuk ganti)'),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final img = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    setState(() {
                      pickedFile = img;
                      webImageBytes = null;
                    });
                  }
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.primaryOrange, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.primaryOrange, width: 1.5),
                      foregroundColor: widget.primaryOrange,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final namaBaru = nameController.text.trim();
                      final totalBaru =
                          int.tryParse(totalController.text) ??
                          widget.initialTotal;
                      final tersediaBaru =
                          int.tryParse(tersediaController.text) ??
                          widget.initialTersedia;

                      if (namaBaru.isEmpty ||
                          selectedKategori == null ||
                          totalBaru < 0 ||
                          tersediaBaru < 0 ||
                          tersediaBaru > totalBaru) {
                        showTopMessage(context, 'Lengkapi data dengan benar');
                        return;
                      }

                      try {
                        String? newImageUrl = widget.initialImagePath;

                        if (pickedFile != null) {
                          newImageUrl = await _uploadNewImage();
                          if (newImageUrl == null) return;
                        }

                        final idKategori = await _getKategoriId(
                          selectedKategori!,
                        );
                        if (idKategori == null) {
                          showTopMessage(context, 'Kategori tidak ditemukan');
                          return;
                        }

                        await supabase
                            .from('alat')
                            .update({
                              'nama_alat': namaBaru,
                              'id_kategori': idKategori,
                              'kondisi': kondisiController.text.trim().isEmpty
                                  ? 'Baik'
                                  : kondisiController.text.trim(),
                              'jumlah_total': totalBaru,
                              'jumlah_tersedia': tersediaBaru,
                              'gambar_alat': newImageUrl,
                            })
                            .eq('id_alat', widget.idAlat);

                        if (!mounted) return;
                        widget.onSuccess();
                        Navigator.pop(context);
                        showTopMessage(context, 'Alat berhasil diperbarui');
                      } catch (e) {
                        if (mounted) {
                          showTopMessage(
                            context,
                            'Gagal menyimpan perubahan: $e',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (pickedFile != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: pickedFile!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                webImageBytes = snapshot.data;
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              if (snapshot.hasError) {
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      } else {
        return Image.file(
          File(pickedFile!.path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      }
    }

    if (widget.initialImagePath.isNotEmpty) {
      return Image.network(
        widget.initialImagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap untuk ganti gambar', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF8E01)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF8E01), width: 2),
    ),
  );
}
