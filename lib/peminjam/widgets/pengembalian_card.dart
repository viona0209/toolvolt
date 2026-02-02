import 'package:flutter/material.dart';

class PengembalianPeminjamCard extends StatelessWidget {
  final String id;
  final String nama;
  final String tanggalPinjam;
  final String? tanggalKembali;
  final String? kondisiSetelah;
  final String? catatan;

  const PengembalianPeminjamCard({
    super.key,
    required this.id,
    required this.nama,
    required this.tanggalPinjam,
    this.tanggalKembali,
    this.kondisiSetelah,
    this.catatan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: $id', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Nama: $nama'),
          const SizedBox(height: 4),
          Text('Tanggal Pinjam: $tanggalPinjam'),
          if (tanggalKembali != null) ...[
            const SizedBox(height: 4),
            Text('Tanggal Kembali: $tanggalKembali'),
          ],
          if (kondisiSetelah != null) ...[
            const SizedBox(height: 4),
            Text('Kondisi: $kondisiSetelah'),
          ],
          if (catatan != null) ...[
            const SizedBox(height: 4),
            Text('Catatan: $catatan'),
          ],
        ],
      ),
    );
  }
}
