import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PengembalianService {
  Future<List<Map<String, dynamic>>> getPengembalian() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User belum login");
      final dataPengguna = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('auth_id', user.id)
          .single();

      final int idPengguna = dataPengguna['id_pengguna'];
      final peminjamanList = await supabase
          .from('peminjaman')
          .select('id_peminjaman')
          .eq('id_pengguna', idPengguna);

      if (peminjamanList.isEmpty) return [];

      final List<int> ids = peminjamanList
          .map<int>((e) => e['id_peminjaman'])
          .toList();

      final String orQuery = ids.map((id) => 'id_peminjaman.eq.$id').join(',');

      final response = await supabase
          .from('pengembalian')
          .select('''
            id_pengembalian,
            tanggal_pengembalian,
            kondisi_setelah,
            catatan,
            total_denda,
            peminjaman (
              id_peminjaman,
              tanggal_pinjam,
              pengguna (
                id_pengguna,
                nama
              )
            )
          ''')
          .or(orQuery)
          .order('id_pengembalian', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data pengembalian: $e');
    }
  }
}
