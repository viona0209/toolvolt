import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PengembalianService {
  // Proses pengembalian alat
  Future<bool> prosesPengembalian({
  required int idPeminjaman,
  required String kondisi, // ini akan masuk ke kolom kondisi_setelah
  required DateTime tanggalPengembalian,
}) async {
  try {
    // Ambil tanggal pinjam untuk hitung keterlambatan
    final peminjaman = await supabase
        .from('peminjaman')
        .select('tanggal_pinjam')
        .eq('id_peminjaman', idPeminjaman)
        .single();

    final tanggalPinjam = DateTime.parse(peminjaman['tanggal_pinjam']);
    final selisihHari = tanggalPengembalian.difference(tanggalPinjam).inDays;

    int totalDenda = 0;

    // Hitung denda keterlambatan
    if (selisihHari > 7) {
      totalDenda += (selisihHari - 7) * 1000;
    }

    // Hitung denda berdasarkan kondisi alat
    switch (kondisi) {
      case 'Rusak Ringan':
        totalDenda += 5000;
        break;
      case 'Rusak Sedang':
        totalDenda += 10000;
        break;
      case 'Rusak Berat':
        totalDenda += 20000;
        break;
      case 'Hilang':
        totalDenda += 50000;
        break;
      default:
        totalDenda += 0;
    }

    // Masukkan ke tabel pengembalian
    await supabase.from('pengembalian').insert({
      'id_peminjaman': idPeminjaman,
      'tanggal_pengembalian': tanggalPengembalian.toIso8601String().split('T')[0],
      'kondisi_setelah': kondisi, // <- ini penting
      'total_denda': totalDenda,
    });

    // Update status peminjaman menjadi dikembalikan
    await supabase
        .from('peminjaman')
        .update({'status': 'dikembalikan'})
        .eq('id_peminjaman', idPeminjaman);

    // Update kondisi alat di tabel alat
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

    return true;
  } catch (e) {
    print('Error proses pengembalian: $e');
    return false;
  }
}


  // Daftar peminjaman yang belum dikembalikan
  Future<List<Map<String, dynamic>>> getBelumDikembalikan() async {
    final data = await supabase
        .from('peminjaman')
        .select('id_peminjaman, tanggal_pinjam, pengguna(nama)')
        .eq('status', 'dipinjam')
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Daftar riwayat pengembalian
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
