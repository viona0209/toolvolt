import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PengembalianService {
  Future<List<Map<String, dynamic>>> getAllPengembalian() async {
    try {
      final response = await supabase
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tanggal_pengembalian,
            kondisi_setelah,
            catatan,
            peminjaman (
              id_peminjaman,
              tanggal_pinjam,
              tanggal_kembali,
              pengguna ( nama ),
              detail_peminjaman (
                jumlah,
                alat ( nama_alat )
              )
            )
          ''')
          .order('tanggal_pengembalian', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error load pengembalian: $e');
      return [];
    }
  }
}
