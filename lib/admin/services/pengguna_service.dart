import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaService {
  final supabase = Supabase.instance.client;

  //Ambil semua pengguna
  Future<List<Map<String, dynamic>>> getPengguna() async {
    try {
      final response = await supabase
          .from('pengguna')
          .select()
          .order('id_pengguna', ascending: true);

      //Langsung assign
      List<Map<String, dynamic>> result = [];
      for (var item in response) {
        result.add(Map<String, dynamic>.from(item));
      }
      return result;
    } catch (e) {
      print('Error getting pengguna: $e');
      return [];
    }
  }

  // 2. Tambah pengguna (via Supabase Auth)
  Future<String?> tambahPengguna({
    required String nama,
    required String username,
    required String role,
    String? email,
    String? password,
  }) async {
    try {
      //Validasi email
      if (email == null || email.isEmpty) {
        return "Email wajib diisi untuk registrasi";
      }

      //GUNAKAN PASSWORD DARI PARAMETER, atau default jika null
      final userPassword = password ?? "Password123!";

      //Validasi panjang password
      if (userPassword.length < 6) {
        return "Password minimal 6 karakter";
      }

      //Sign up via Supabase Auth
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: userPassword, //GUNAKAN PASSWORD DARI INPUT
        data: {'nama': nama, 'username': username, 'role': role},
      );

      if (authResponse.user == null) {
        return "Gagal membuat user. Mungkin email sudah terdaftar.";
      }

      return null; // sukses
    } on AuthException catch (e) {
      if (e.message.contains('already registered') ||
          e.message.contains('already been registered')) {
        return "Email sudah terdaftar";
      }
      return "Auth Error: ${e.message}";
    } catch (e) {
      print('Error tambah pengguna: $e');
      return "Error: ${e.toString()}";
    }
  }

  // 3. Edit pengguna
  Future<String?> editPengguna({
    required int idPengguna,
    required String nama,
    required String username,
    required String role,
    String? email,
  }) async {
    try {
      await supabase
          .from('pengguna')
          .update({'nama': nama, 'username': username, 'role': role})
          .eq('id_pengguna', idPengguna);

      return null;
    } catch (e) {
      print('Error edit pengguna: $e');
      return "Error: ${e.toString()}";
    }
  }

  // 4. Hapus pengguna
  Future<String?> hapusPengguna({
    required int idPengguna,
    String? authId,
  }) async {
    try {
      await supabase.from('pengguna').delete().eq('id_pengguna', idPengguna);

      return null;
    } catch (e) {
      print('Error hapus pengguna: $e');
      return "Error: ${e.toString()}";
    }
  }

  // 5. Reset password (opsional)
  Future<String?> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      print('Error reset password: $e');
      return "Error: ${e.toString()}";
    }
  }
}
