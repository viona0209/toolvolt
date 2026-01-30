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
  // 2. Tambah pengguna (HARUS buat Auth user dulu!)
  // =============================
  Future<String?> tambahPengguna({
  required String email,
  required String password,
  required String nama,
  required String username,
  required String role,
}) async {
  try {
    // 1. Buat akun Auth BIASA (bukan admin)
    final authRes = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final uid = authRes.user?.id;

    if (uid == null) {
      return "Gagal membuat akun auth.";
    }

    // 2. Simpan ke tabel pengguna
    await supabase.from('pengguna').insert({
      'uid_auth': uid,
      'nama': nama,
      'username': username,
      'role': role,
    });

    return null;
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
  }) async {
    try {
      await supabase.from('pengguna').update({
        'nama': nama,
        'username': username,
        'role': role,
      }).eq('id_pengguna', idPengguna);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // =============================
  // 4. Hapus pengguna (hapus tabel + hapus Auth User)
  // =============================
  Future<String?> hapusPengguna({
    required int idPengguna,
    required String uidAuth,
  }) async {
    try {
      // Hapus dari tabel pengguna
      await supabase.from('pengguna').delete().eq('id_pengguna', idPengguna);

      // Hapus user auth dari Supabase Auth
      await supabase.auth.admin.deleteUser(uidAuth);

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
