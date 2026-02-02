import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PeminjamanService {
  Future<List<Map<String, dynamic>>> getAllPeminjaman() async {
    try {
      final response = await supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tanggal_pinjam,
            tanggal_kembali,
            status,
            pengguna (id_pengguna, nama),
            detail_peminjaman (
              jumlah,
              alat (id_alat, nama_alat)
            )
          ''')
          .order('tanggal_pinjam', ascending: false);

      print('Response raw: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error load peminjaman: $e');
      return [];
    }
  }

  Future<bool> tambahPeminjaman({
    required int idPengguna,
    required DateTime tanggalPinjam,
    required DateTime? tanggalKembali,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final peminjamanRes = await supabase
          .from('peminjaman')
          .insert({
            'id_pengguna': idPengguna,
            'tanggal_pinjam': tanggalPinjam.toIso8601String().split('T')[0],
            'tanggal_kembali': tanggalKembali?.toIso8601String().split('T')[0],

            // STATUS AWAL HARUS "MENUNGGU"
            'status': 'Menunggu',
          })
          .select('id_peminjaman')
          .single();

      final idPeminjaman = peminjamanRes['id_peminjaman'] as int;

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
