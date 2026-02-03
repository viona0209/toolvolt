import 'package:flutter/material.dart';

class RiwayatPengembalianCard extends StatelessWidget {
  final String id;
  final String nama;
  final String tanggalKembali;
  final String denda;
  final String kondisiSetelah;

  const RiwayatPengembalianCard({
    super.key,
    required this.id,
    required this.nama,
    required this.tanggalKembali,
    required this.denda,
    required this.kondisiSetelah,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (kondisiSetelah) {
      case 'Baik':
        statusColor = Colors.green;
        break;
      case 'Rusak Ringan':
      case 'Rusak Sedang':
        statusColor = Colors.orange;
        break;
      case 'Rusak Berat':
      case 'Hilang':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                'ID : $id',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kondisiSetelah,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                nama,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Kembali : $tanggalKembali',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Denda : $denda',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
