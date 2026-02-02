import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {
          'success': false,
          'message': 'Login gagal',
        };
      }

      final userData = await supabase
          .from('pengguna')
          .select()
          .eq('auth_id', response.user!.id)
          .single();

      return {
        'success': true,
        'user': response.user,
        'userData': userData,
        'role': userData['role'],
        'nama': userData['nama'],
      };
    } on AuthException catch (e) {
      String message = 'Login gagal';
      
      if (e.message.contains('Invalid login credentials')) {
        message = 'Email atau password salah';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'Email belum diverifikasi';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
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
          .single();

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