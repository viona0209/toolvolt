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

  Color getKondisiColor(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case "baik":
        return Colors.green.shade600;
      case "rusak ringan":
        return Colors.orange.shade600;
      case "rusak berat":
        return Colors.red.shade600;
      case "hilang":
        return const Color.fromARGB(255, 0, 35, 88);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.shade600,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ID : $id",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (tanggalKembali != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Dikembalikan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            nama,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Pinjam : $tanggalPinjam",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),

          if (tanggalKembali != null) ...[
            const SizedBox(height: 4),
            Text(
              "Kembali : $tanggalKembali",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],

          if (kondisiSetelah != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: getKondisiColor(kondisiSetelah!).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: getKondisiColor(kondisiSetelah!),
                  width: 1.2,
                ),
              ),
              child: Text(
                kondisiSetelah!,
                style: TextStyle(
                  color: getKondisiColor(kondisiSetelah!),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (catatan != null) ...[
            const SizedBox(height: 6),
            Text(
              "Catatan : $catatan",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
