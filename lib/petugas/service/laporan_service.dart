import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LaporanService {
  // ========================
  // LAPORAN PEMINJAMAN
  // ========================
  Future<List<Map<String, dynamic>>> getLaporanPeminjaman({
    required String start,
    required String end,
  }) async {
    final response = await supabase
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          tanggal_kembali,
          status,
          pengguna (
            nama
          ),
          detail_peminjaman (
            jumlah,
            alat (
              id_alat,
              nama_alat,
              kondisi,
              gambar_alat
            )
          )
        ''')
        .gte('tanggal_pinjam', start)
        .lte('tanggal_pinjam', end)
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

    // ========================
  // LAPORAN PENGEMBALIAN
  // ========================
  Future<List<Map<String, dynamic>>> getLaporanPengembalian({
    required String start,
    required String end,
  }) async {
    final response = await supabase
        .from('pengembalian')
        .select('''
          id_pengembalian,
          tanggal_pengembalian,
          kondisi_setelah,
          catatan,
          total_denda,
          peminjaman (
            tanggal_pinjam,
            tanggal_kembali,
            pengguna (nama),
            detail_peminjaman (
              jumlah,
              alat (
                id_alat,
                nama_alat,
                kondisi,
                gambar_alat
              )
            )
          )
        ''')
        .gte('tanggal_pengembalian', start)
        .lte('tanggal_pengembalian', end)
        .order('tanggal_pengembalian', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
