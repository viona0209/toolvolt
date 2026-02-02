import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDashboardService {
  final _supabase = Supabase.instance.client;

  /// ambil aktivitas terbaru
  Future<List<Map<String, dynamic>>> fetchAktivitasTerbaru() async {
    final res = await _supabase
        .from('log_aktivitas')
        .select('''
          id_log,
          aktivitas,
          waktu,
          pengguna (
            nama
          )
        ''')
        .order('waktu', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(res);
  }

  /// statistik
  Future<int> totalAlat() async {
    final res = await _supabase.from('alat').select('id_alat');
    return res.length;
  }

  Future<int> alatTersedia() async {
    final res = await _supabase
        .from('alat')
        .select('id_alat')
        .gt('jumlah_tersedia', 0);
    return res.length;
  }

  Future<int> pinjamAktif() async {
    final res = await _supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('status', 'dipinjam');
    return res.length;
  }

  Future<int> kembaliHariIni() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final res = await _supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('tanggal_kembali', today);
    return res.length;
  }
}