import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PetugasDashboardService {
  // TOTAL ALAT
  Future<int> getTotalAlat() async {
    final response = await supabase.from('alat').select('id_alat');
    return response.length;
  }

  // TOTAL ALAT TERSEDIA
  Future<int> getAlatTersedia() async {
    final response = await supabase
        .from('alat')
        .select('jumlah_tersedia');

    int total = 0;
    for (var item in response) {
      total += (item['jumlah_tersedia'] as int);
    }
    return total;
  }

  // PINJAM AKTIF
  Future<int> getPinjamAktif() async {
    final response = await supabase
        .from('peminjaman')
        .select('status')
        .eq('status', 'dipinjam');

    return response.length;
  }

  // KEMBALI HARI INI
  Future<int> getKembaliHariIni() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final response = await supabase
        .from('peminjaman')
        .select('tanggal_kembali')
        .eq('tanggal_kembali', today);

    return response.length;
  }

  // AKTIVITAS TERBARU (3 TERATAS)
  Future<List<Map<String, dynamic>>> getAktivitasTerbaru() async {
    final response = await supabase
        .from('log_aktivitas')
        .select('''
          aktivitas,
          waktu,
          pengguna (
            nama
          )
        ''')
        .order('waktu', ascending: false)
        .limit(3);

    return response;
  }
}
