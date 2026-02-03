import 'package:flutter/material.dart';
import '../../services/pengguna_service.dart';

Future<bool?> showHapusPenggunaDialog(
  BuildContext context,
  int idPengguna,
  String nama, {
  String? authId,
}) {
  const primaryOrange = Color(0xFFFF7733);

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
                "Hapus Pengguna",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                "Apakah kamu yakin ingin menghapus \"$nama\"?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Akun auth juga akan dihapus permanen.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
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

                      final res = await service.hapusPengguna(
                        idPengguna: idPengguna,
                        authId: authId,
                      );

                      if (res == null) {
                        Navigator.pop(dialogContext, true);
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(res)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Hapus"),
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
