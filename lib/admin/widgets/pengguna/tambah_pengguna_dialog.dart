import 'package:flutter/material.dart';
import 'label_widget.dart';
import 'input_decoration.dart';

void showTambahPenggunaDialog(BuildContext context) {
  const primaryOrange = Color(0xFFFF7733);
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? selectedRole;

  showDialog(
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
              const Text(
                'Tambah Pengguna',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              labelWidget('Nama'),
              TextField(
                controller: namaController,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              labelWidget('Email'),
              TextField(
                controller: emailController,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              labelWidget('Kata Sandi'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              labelWidget('Konfirmasi Kata Sandi'),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              labelWidget('Role'),
              DropdownButtonFormField<String?>(
                value: selectedRole,
                isExpanded: true,
                decoration: inputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Peminjam', child: Text('Peminjam')),
                  DropdownMenuItem(value: 'Petugas', child: Text('Petugas')),
                ],
                onChanged: (val) => selectedRole = val,
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryOrange, width: 1.5),
                      foregroundColor: primaryOrange,
                      minimumSize: const Size(110, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(130, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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