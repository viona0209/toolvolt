import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PeminjamService {
  Future<int> getTotalAlatTersedia() async {
    final response = await supabase
        .from('alat')
        .select('jumlah_tersedia');

    int total = 0;
    for (var row in response) {
      total += (row['jumlah_tersedia'] ?? 0) as int;
    }
    return total;
  }

  Future<int> getPeminjamanAktif(int idPengguna) async {
  final data = await supabase
      .from('peminjaman')
      .select()
      .eq('id_pengguna', idPengguna)
      .eq('status', 'Dipinjam');

  return data.length;
}


  Future<int> getTotalRiwayat(int idPeminjam) async {
    final response = await supabase
        .from('peminjaman')
        .select()
        .eq('id_pengguna', idPeminjam);

    return response.length;
  }

  Future<List<Map<String, dynamic>>> getRiwayat(int idPeminjam) async {
    final response = await supabase
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          tanggal_kembali,
          detail_peminjaman(jumlah)
        ''')
        .eq('id_pengguna', idPeminjam)
        .order('id_peminjaman', ascending: false);

    return response;
  }
}
