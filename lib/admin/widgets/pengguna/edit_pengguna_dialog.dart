import 'package:flutter/material.dart';
import '../../services/pengguna_service.dart';
import 'label_widget.dart';
import 'input_decoration.dart';

Future<bool?> showEditPenggunaDialog(
  BuildContext context,
  int idPengguna,
  String nama,
  String username,
  String role,
) {
  const primaryOrange = Color(0xFFFF7733);

  final namaController = TextEditingController(text: nama);
  final usernameController = TextEditingController(text: username);
  String? selectedRole = role;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: primaryOrange, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Pengguna",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Nama
                labelWidget("Nama"),
                TextField(
                  controller: namaController,
                  decoration: inputDecoration(),
                ),
                const SizedBox(height: 16),

                // Username
                labelWidget("Username"),
                TextField(
                  controller: usernameController,
                  decoration: inputDecoration(),
                ),
                const SizedBox(height: 16),

                // Role
                labelWidget("Role"),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                    DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                  ],
                  onChanged: (val) => selectedRole = val,
                ),
                const SizedBox(height: 16),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Email tidak dapat diubah di sini.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryOrange),
                        foregroundColor: primaryOrange,
                      ),
                      child: const Text("Batal"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (namaController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Nama wajib diisi"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (usernameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Username wajib diisi"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Show loading
                        showDialog(
                          context: dialogContext,
                          barrierDismissible: false,
                          builder: (ctx) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        final service = PenggunaService();
                        final res = await service.editPengguna(
                          idPengguna: idPengguna,
                          nama: namaController.text.trim(),
                          username: usernameController.text.trim(),
                          role: selectedRole ?? role,
                        );

                        // Hide loading
                        Navigator.pop(dialogContext);

                        if (res == null) {
                          Navigator.pop(dialogContext, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pengguna berhasil diupdate!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Simpan"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}