import 'package:flutter/material.dart';
import 'package:toolvolt/admin/screen/admin_dashboard.dart';
import 'package:toolvolt/petugas/screen/petugas_dashboard.dart';
import 'package:toolvolt/peminjam/screen/peminjam_dashboard_page.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _obscurePassword = true; // untuk tooglr password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showOrangeSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF7A00),
        content: Text(message),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty) {
      _showOrangeSnackbar('Email tidak boleh kosong');
      return;
    }
    if (pass.isEmpty) {
      _showOrangeSnackbar('Password tidak boleh kosong');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _authService.login(email: email, password: pass);

      if (!mounted) return;

      if (result['success'] == false) {
        final type = result['error_type'];

        if (type == 'email_not_found') {
          _showOrangeSnackbar('Email tidak terdaftar');
        } else if (type == 'email_wrong') {
          _showOrangeSnackbar('Email salah');
        } else if (type == 'wrong_password') {
          _showOrangeSnackbar('Password salah');
        } else if (type == 'email_password_wrong') {
          _showOrangeSnackbar('Email dan password salah');
        } else {
          _showOrangeSnackbar(result['message'] ?? 'Login gagal');
        }
        return;
      }

      final userName = (result['nama'] ?? '-').toString();
      final userRole = (result['role'] ?? 'peminjam').toString();

      _showOrangeSnackbar('Selamat datang, $userName!');

      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (userRole == 'petugas') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PetugasDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeminjamDashboardPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showOrangeSnackbar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Text(
                'Selamat Datang!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kelola dan pinjam peralatan ketenagalistrikan dengan lebih mudah dan efisien.',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              const Text(
                'Email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'admin@example.com',
                  filled: true,
                  fillColor: Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF7A00),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // tmbah ini untukj sembunyikan dan lihat password
                decoration: InputDecoration(
                  hintText: '••••••••',
                  filled: true,
                  fillColor: Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF7A00),
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton( //icon untuk lihat pasasword
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off // semisal lihatpasswordmati
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () { //semisal di klik maka password muncul
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 67,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}