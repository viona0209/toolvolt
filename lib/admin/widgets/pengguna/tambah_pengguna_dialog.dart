import 'package:flutter/material.dart';
import '../../services/pengguna_service.dart';
import 'label_widget.dart';
import 'input_decoration.dart';

Future<bool?> showTambahPenggunaDialog(BuildContext context) {
  const primaryOrange = Color(0xFFFF7733);

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController(); // ✅ TAMBAH INI
  String? selectedRole;
  bool obscurePassword = true; // ✅ TAMBAH INI

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder( // ✅ GUNAKAN StatefulBuilder
        builder: (context, setState) {
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
                      'Tambah Pengguna',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 24),

                    // Input Nama
                    labelWidget('Nama *'),
                    TextField(
                      controller: namaController,
                      decoration: inputDecoration(),
                    ),
                    const SizedBox(height: 16),

                    // Email (WAJIB untuk Auth)
                    labelWidget('Email *'),
                    TextField(
                      controller: emailController,
                      decoration: inputDecoration(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Username (optional)
                    labelWidget('Username'),
                    TextField(
                      controller: usernameController,
                      decoration: inputDecoration(),
                    ),
                    const SizedBox(height: 16),

                    // ✅ TAMBAH INPUT PASSWORD
                    labelWidget('Password *'),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Minimal 6 karakter',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryOrange, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role
                    labelWidget('Role *'),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      decoration: inputDecoration(),
                      hint: const Text('Pilih role'),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                        DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                      ],
                      onChanged: (val) => selectedRole = val,
                    ),

                    const SizedBox(height: 16),

                    // Info password
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
                              'Password minimal 6 karakter. User dapat mengubahnya setelah login.',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryOrange),
                            foregroundColor: primaryOrange,
                          ),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            // Validasi
                            if (namaController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Nama wajib diisi"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email wajib diisi"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // ✅ VALIDASI PASSWORD
                            if (passwordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Password wajib diisi"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (passwordController.text.trim().length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Password minimal 6 karakter"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (selectedRole == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Role wajib dipilih"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Format email tidak valid"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Auto-generate username dari email jika kosong
                            String username = usernameController.text.trim();
                            if (username.isEmpty) {
                              username = emailController.text.trim().split("@")[0];
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
                            final res = await service.tambahPengguna(
                              nama: namaController.text.trim(),
                              username: username,
                              role: selectedRole!,
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(), // ✅ KIRIM PASSWORD
                            );

                            // Hide loading
                            Navigator.pop(dialogContext);

                            if (res == null) {
                              Navigator.pop(dialogContext, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Pengguna berhasil ditambahkan!"),
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
                          child: const Text('Tambah'),
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
    },
  );
}