import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PengembalianService {
  /// Ambil daftar pengembalian
  Future<List<Map<String, dynamic>>> getPengembalian() async {
    try {
      final response = await supabase
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tanggal_pengembalian,
            kondisi_setelah,
            catatan,
            total_denda,
            peminjaman(
              id_peminjaman,
              tanggal_pinjam,
              pengguna(nama)
            )
          ''')
          .order('tanggal_pengembalian', ascending: false);

      // langsung konversi PostgrestList ke List<Map>
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      // tangani error
      throw Exception('Gagal mengambil data pengembalian: $e');
    }
  }
}
