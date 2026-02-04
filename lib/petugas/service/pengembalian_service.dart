import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PengembalianService {
  Future<bool> prosesPengembalian({
    required int idPeminjaman,
    required String kondisi,
    required DateTime tanggalPengembalian,
    required String aktivitas,
    required int idPengguna,
  }) async {
    try {
      final peminjaman = await supabase
          .from('peminjaman')
          .select('tanggal_pinjam')
          .eq('id_peminjaman', idPeminjaman)
          .single();

      final tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
      final selisihHari = tanggalPengembalian.difference(tanggalPinjam).inDays;

      int totalDenda = 0;

      if (selisihHari > 7) totalDenda += (selisihHari - 7) * 5000;

      switch (kondisi) {
        case 'Rusak Ringan':
          totalDenda += 20000;
          break;
        case 'Rusak Sedang':
          totalDenda += 50000;
          break;
        case 'Rusak Berat':
          totalDenda += 100000;
          break;
        case 'Hilang':
          totalDenda += 200000;
          break;
      }

      // Insert ke tabel pengembalian
      await supabase.from('pengembalian').insert({
        'id_peminjaman': idPeminjaman,
        'tanggal_pengembalian': tanggalPengembalian.toIso8601String().split('T')[0],
        'kondisi_setelah': kondisi,
        'total_denda': totalDenda,
      });

      // Update status peminjaman
      await supabase
          .from('peminjaman')
          .update({
            'status': 'dikembalikan',
            'tanggal_kembali': tanggalPengembalian.toIso8601String().split('T')[0]
          })
          .eq('id_peminjaman', idPeminjaman);

      // Update kondisi alat
      final details = await supabase
          .from('detail_peminjaman')
          .select('id_alat')
          .eq('id_peminjaman', idPeminjaman);

      for (var item in details) {
        await supabase
            .from('alat')
            .update({'kondisi': kondisi})
            .eq('id_alat', item['id_alat']);
      }

      // Insert log aktivitas
      await supabase.from('log_aktivitas').insert({
        'id_pengguna': idPengguna, // pakai ID user yang login
        'aktivitas': aktivitas.isNotEmpty ? aktivitas : 'Melakukan pengembalian', // jangan null
        'waktu': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error proses pengembalian: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBelumDikembalikan() async {
    final data = await supabase
        .from('peminjaman')
        .select('id_peminjaman, tanggal_pinjam, pengguna(nama)')
        .eq('status', 'dipinjam')
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getRiwayatPengembalian() async {
    final data = await supabase
        .from('pengembalian')
        .select('''
          id_pengembalian,
          tanggal_pengembalian,
          kondisi_setelah,
          total_denda,
          peminjaman(
            id_peminjaman,
            status,
            pengguna(nama)
          )
        ''')
        .order('tanggal_pengembalian', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
