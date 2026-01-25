import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // untuk format tanggal konsisten
import '../widgets/petugas_bottom_nav.dart';
import 'petugas_dashboard.dart';
import 'petugas_peminjaman_page.dart';
import 'petugas_pengembalian_page.dart';

class PetugasLaporanPage extends StatefulWidget {
  const PetugasLaporanPage({super.key});

  @override
  State<PetugasLaporanPage> createState() => _PetugasLaporanPageState();
}

class _PetugasLaporanPageState extends State<PetugasLaporanPage> {
  int _currentIndex = 3;

  static const Color primaryOrange = Color(0xFFFF8E01);
  static const Color strokeOrange = Color(0xFFEF6C01);

  String? selectedJenisLaporan = 'Laporan peminjaman';
  TextEditingController tanggalMulaiController = TextEditingController();
  TextEditingController tanggalAkhirController = TextEditingController();

  @override
  void dispose() {
    tanggalMulaiController.dispose();
    tanggalAkhirController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryOrange),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Widget _buildUnderlinedLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Container(
          height: 1.5,
          width: 60,
          color: primaryOrange,
          margin: const EdgeInsets.only(top: 3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/image/logo1remove.png',
                  width: MediaQuery.of(context).size.width * 0.50,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Laporan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUnderlinedLabel('Jenis Laporan'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryOrange.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: selectedJenisLaporan,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(Icons.arrow_drop_down, color: primaryOrange),
                        items: const [
                          DropdownMenuItem(
                            value: 'Laporan peminjaman',
                            child: Text('Laporan peminjaman'),
                          ),
                          DropdownMenuItem(
                            value: 'Laporan pengembalian',
                            child: Text('Laporan pengembalian'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedJenisLaporan = value),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildUnderlinedLabel('Tanggal Mulai'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tanggalMulaiController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange.withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      onTap: () => _selectDate(context, tanggalMulaiController),
                    ),

                    const SizedBox(height: 20),

                    _buildUnderlinedLabel('Tanggal Akhir'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tanggalAkhirController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange.withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      onTap: () => _selectDate(context, tanggalAkhirController),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Mengunduh laporan...'),
                              backgroundColor: primaryOrange,
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text(
                          'Unduh',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Laporan Peminjaman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: strokeOrange, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Nama',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Tgl Pinjam',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Tgl Kembali',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Ayu Lestari',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '16/1/2026',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '22/1/2026',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Dipinjam',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Rizky Ilham',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '14/1/2026',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '29/1/2026',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Dikembalikan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: PetugasBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);

          Widget page;
          switch (index) {
            case 0:
              page = const PetugasPeminjamanPage();
              break;
            case 1:
              page = const PetugasPengembalianPage();
              break;
            case 2:
              page = const PetugasDashboard();
              break;
            case 3:
              page = const PetugasLaporanPage();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}
