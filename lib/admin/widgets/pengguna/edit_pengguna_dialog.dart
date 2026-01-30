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
          side: BorderSide(color: primaryOrange, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Pengguna",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              labelWidget("Nama"),
              TextField(
                controller: namaController,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              labelWidget("Username"),
              TextField(
                controller: usernameController,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

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

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text("Batal"),
                  ),
                  const SizedBox(width: 16),

                  ElevatedButton(
                    onPressed: () async {
                      final service = PenggunaService();

                      final res = await service.editPengguna(
                        idPengguna: idPengguna,
                        nama: namaController.text.trim(),
                        username: usernameController.text.trim(),
                        role: selectedRole ?? role,
                      );

                      if (res == null) {
                        Navigator.pop(dialogContext, true);
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(res)));
                      }
                    },
                    child: const Text("Edit"),
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
