import 'package:flutter/material.dart';
import '../../services/pengguna_service.dart';
import 'label_widget.dart';
import 'input_decoration.dart';

Future<bool?> showTambahPenggunaDialog(BuildContext context) {
  const primaryOrange = Color(0xFFFF7733);

  final namaController = TextEditingController();
  final emailController = TextEditingController(); // optional
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
              const Text(
                'Tambah Pengguna',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              // Input Nama
              labelWidget('Nama'),
              TextField(controller: namaController, decoration: inputDecoration()),
              const SizedBox(height: 16),

              // Email (optional)
              labelWidget('Email'),
              TextField(controller: emailController, decoration: inputDecoration()),
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
                      if (namaController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama wajib diisi")),
                        );
                        return;
                      }

                      final service = PenggunaService();
                      final res = await service.tambahPengguna(
                        nama: namaController.text.trim(),
                        username: emailController.text.trim().isEmpty
                            ? namaController.text.trim().replaceAll(' ', '_').toLowerCase()
                            : emailController.text.trim().split("@")[0],
                        role: selectedRole ?? "peminjam",
                        email: emailController.text.trim().isEmpty
                            ? null
                            : emailController.text.trim(),
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
