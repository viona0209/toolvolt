import 'package:flutter/material.dart';
import '../../services/pengguna_service.dart';
import 'label_widget.dart';
import 'input_decoration.dart';

Future<bool?> showTambahPenggunaDialog(BuildContext context) {
  const primaryOrange = Color(0xFFFF7733);

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? selectedRole;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryOrange, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text('Tambah Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),

              // Input Nama
              labelWidget('Nama'),
              TextField(controller: namaController, decoration: inputDecoration()),
              const SizedBox(height: 16),

              // Email
              labelWidget('Email'),
              TextField(controller: emailController, decoration: inputDecoration()),
              const SizedBox(height: 16),

              // Password
              labelWidget('Kata Sandi'),
              TextField(controller: passwordController, obscureText: true, decoration: inputDecoration()),
              const SizedBox(height: 16),

              // Confirm Password
              labelWidget('Konfirmasi Kata Sandi'),
              TextField(controller: confirmPasswordController, obscureText: true, decoration: inputDecoration()),
              const SizedBox(height: 16),

              // Role
              labelWidget('Role'),
              DropdownButtonFormField<String>(
                value: selectedRole,
                isExpanded: true,
                decoration: inputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                  DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                ],
                onChanged: (val) => selectedRole = val,
              ),

              const SizedBox(height: 32),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (passwordController.text != confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password tidak sama")),
                        );
                        return;
                      }

                      final service = PenggunaService();
                      final res = await service.tambahPengguna(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        nama: namaController.text.trim(),
                        username: emailController.text.split("@")[0],
                        role: selectedRole ?? "peminjam",
                      );

                      if (res == null) {
                        Navigator.pop(dialogContext, true); // SUCCESS
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
