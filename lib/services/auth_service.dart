import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Cek apakah email terdaftar
      final existingUser = await supabase
          .from('pengguna')
          .select('auth_id, email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser == null) {
        return {
          'success': false,
          'error_type': 'email_not_found',
          'message': 'Email tidak terdaftar',
        };
      }

      // 2. Coba login Supabase
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {
          'success': false,
          'error_type': 'wrong_password',
          'message': 'Password salah',
        };
      }

      // 3. Ambil data lengkap pengguna
      final userData = await supabase
          .from('pengguna')
          .select()
          .eq('auth_id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        return {
          'success': false,
          'error_type': 'user_data_missing',
          'message': 'Data pengguna tidak ditemukan',
        };
      }

      return {
        'success': true,
        'user': response.user,
        'userData': userData,
        'role': userData['role'],
        'nama': userData['nama'],
      };
    }

    // 4. Tangani Error Supabase Auth
    on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return {
          'success': false,
          'error_type': 'wrong_credentials',
          'message': 'Email atau password salah',
        };
      }

      if (msg.contains('email not confirmed')) {
        return {
          'success': false,
          'error_type': 'email_unverified',
          'message': 'Email belum diverifikasi',
        };
      }

      return {
        'success': false,
        'error_type': 'auth_exception',
        'message': e.message,
      };
    }

    // 5. Error lain
    catch (e) {
      return {
        'success': false,
        'error_type': 'exception',
        'message': 'Error: $e',
      };
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final userData = await supabase
          .from('pengguna')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      return userData;
    } catch (e) {
      print('Error get current user: $e');
      return null;
    }
  }

  Future<String?> getCurrentUserRole() async {
    final userData = await getCurrentUserData();
    return userData?['role'];
  }
}
