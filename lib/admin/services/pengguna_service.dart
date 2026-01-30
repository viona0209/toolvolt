import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaService {
  final supabase = Supabase.instance.client;

  // =============================
  // 1. Ambil semua pengguna
  // =============================
  Future<List<Map<String, dynamic>>> getPengguna() async {
    final response = await supabase
        .from('pengguna')
        .select()
        .order('id_pengguna', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // =============================
  // 2. Tambah pengguna (langsung ke tabel)
  // =============================
  Future<String?> tambahPengguna({
    required String nama,
    required String username,
    required String role,
    String? email, // optional
  }) async {
    try {
      await supabase.from('pengguna').insert({
        'nama': nama,
        'username': username,
        'role': role,
        'email': email,
      });

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // =============================
  // 3. Edit pengguna
  // =============================
  Future<String?> editPengguna({
    required int idPengguna,
    required String nama,
    required String username,
    required String role,
    String? email, // optional
  }) async {
    try {
      await supabase.from('pengguna').update({
        'nama': nama,
        'username': username,
        'role': role,
        'email': email,
      }).eq('id_pengguna', idPengguna);

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }

  // =============================
  // 4. Hapus pengguna
  // =============================
  Future<String?> hapusPengguna({
    required int idPengguna,
  }) async {
    try {
      await supabase.from('pengguna').delete().eq('id_pengguna', idPengguna);

      return null; // sukses
    } catch (e) {
      return e.toString();
    }
  }
}
