import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PeminjamanService {
  // Ambil semua data peminjaman + join dengan pengguna & detail alat
  Future<List<Map<String, dynamic>>> getAllPeminjaman() async {
  try {
    final response = await supabase
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          tanggal_kembali,
          status,
          pengguna (nama),
          detail_peminjaman (
            jumlah,
            alat (nama_alat)
          )
        ''')
        .order('tanggal_pinjam', ascending: false);

    print('Response raw: $response');  // ← tambahkan ini untuk debug
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error load peminjaman: $e');
    return [];
  }
}

  // Untuk nanti di dialog tambah → simpan peminjaman + detail
  // (bisa dipanggil dari TambahPeminjamanDialog)
  Future<bool> tambahPeminjaman({
    required int idPengguna,
    required DateTime tanggalPinjam,
    required DateTime? tanggalKembali,
    required List<Map<String, dynamic>> items, // [{id_alat: xx, jumlah: yy}, ...]
  }) async {
    try {
      // 1. Insert ke tabel peminjaman
      final peminjamanRes = await supabase.from('peminjaman').insert({
        'id_pengguna': idPengguna,
        'tanggal_pinjam': tanggalPinjam.toIso8601String().split('T')[0],
        'tanggal_kembali': tanggalKembali?.toIso8601String().split('T')[0],
        'status': 'dipinjam',
      }).select('id_peminjaman').single();

      final idPeminjaman = peminjamanRes['id_peminjaman'] as int;

      // 2. Insert detail_peminjaman untuk setiap alat
      for (final item in items) {
        await supabase.from('detail_peminjaman').insert({
          'id_peminjaman': idPeminjaman,
          'id_alat': item['id_alat'],
          'jumlah': item['jumlah'],
        });
      }

      return true;
    } catch (e) {
      print('Error tambah peminjaman: $e');
      return false;
    }
  }
}