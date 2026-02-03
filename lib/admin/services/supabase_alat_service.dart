import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAlatService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllAlat() async {
    final response = await supabase
        .from('alat')
        .select('''
          id_alat,
          nama_alat,
          kondisi,
          jumlah_total,
          jumlah_tersedia,
          gambar_alat,
          kategori!inner (nama_kategori)
        ''')
        .order('nama_alat');

    return response.map((item) {
      return {
        'id': item['id_alat'],
        'nama': item['nama_alat'],
        'kategori': item['kategori']?['nama_kategori'] ?? 'Tidak diketahui',
        'kondisi': item['kondisi'] ?? 'Baik',
        'total': item['jumlah_total'],
        'tersedia': item['jumlah_tersedia'],
        'dipinjam':
            (item['jumlah_total'] ?? 0) - (item['jumlah_tersedia'] ?? 0),
        'image': item['gambar_alat'] ?? '',
      };
    }).toList();
  }

  Future<List<String>> fetchKategoriNames() async {
    final response = await supabase
        .from('kategori')
        .select('nama_kategori')
        .order('nama_kategori');

    return response.map((e) => e['nama_kategori'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final response = await supabase
        .from('kategori')
        .select('id_kategori, nama_kategori')
        .order('nama_kategori');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<String?> uploadImage({File? mobileFile, Uint8List? webBytes}) async {
    if (mobileFile == null && webBytes == null) return null;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'alat/$fileName';

      if (kIsWeb && webBytes != null) {
        await supabase.storage
            .from('alat-gambar')
            .uploadBinary(
              path,
              webBytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else if (mobileFile != null) {
        await supabase.storage
            .from('alat-gambar')
            .upload(
              path,
              mobileFile,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      }

      return supabase.storage.from('alat-gambar').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> insertAlat({
    required String nama,
    required String idKategoriNama,
    required String kondisi,
    required int total,
    required int tersedia,
    String? imageUrl,
  }) async {
    final kategoriRes = await supabase
        .from('kategori')
        .select('id_kategori')
        .eq('nama_kategori', idKategoriNama)
        .maybeSingle();

    if (kategoriRes == null) {
      throw 'Kategori "$idKategoriNama" tidak ditemukan';
    }

    final idKategori = kategoriRes['id_kategori'] as int;

    await supabase.from('alat').insert({
      'nama_alat': nama,
      'id_kategori': idKategori,
      'kondisi': kondisi,
      'jumlah_total': total,
      'jumlah_tersedia': tersedia,
      'gambar_alat': imageUrl,
    });

    return true;
  }
}
