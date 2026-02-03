import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:toolvolt/petugas/service/laporan_service.dart';
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

  final LaporanService laporanService = LaporanService();

  List<Map<String, dynamic>> laporanData = [];
  bool loading = false;

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
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> loadLaporan() async {
    if (tanggalMulaiController.text.isEmpty ||
        tanggalAkhirController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih tanggal mulai & akhir")),
      );
      return;
    }

    setState(() => loading = true);

    if (selectedJenisLaporan == "Laporan peminjaman") {
      laporanData = await laporanService.getLaporanPeminjaman(
        start: tanggalMulaiController.text,
        end: tanggalAkhirController.text,
      );
    } else {
      laporanData = await laporanService.getLaporanPengembalian(
        start: tanggalMulaiController.text,
        end: tanggalAkhirController.text,
      );
    }

    setState(() => loading = false);
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              selectedJenisLaporan!,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Text(
            "Periode: ${tanggalMulaiController.text} s/d ${tanggalAkhirController.text}",
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 15),

          // TABLE
          pw.Table.fromTextArray(
            headers: ["Nama", "Tanggal Pinjam", "Tanggal Kembali", "Status"],
            data: laporanData.map((data) {
              final String nama = (selectedJenisLaporan == "Laporan peminjaman")
                  ? (data['pengguna']?['nama'] ?? '-')
                  : (data['peminjaman']?['pengguna']?['nama'] ?? '-');

              final String tglPinjam =
                  (selectedJenisLaporan == "Laporan peminjaman")
                  ? (data['tanggal_pinjam'] ?? '-')
                  : (data['peminjaman']?['tanggal_pinjam'] ?? '-');

              final String tglKembali =
                  (selectedJenisLaporan == "Laporan peminjaman")
                  ? (data['tanggal_kembali'] ?? '-')
                  : (data['peminjaman']?['tanggal_kembali'] ?? '-');

              final String status =
                  (selectedJenisLaporan == "Laporan peminjaman")
                  ? (data['status'] ?? '-')
                  : (data['kondisi_setelah'] ?? '-');

              return [nama, tglPinjam, tglKembali, status];
            }).toList(),
          ),
        ],
      ),
    );

    // SAVE / DOWNLOAD
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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

  Widget buildLaporanTable() {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (laporanData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Tidak ada data untuk rentang tanggal ini"),
        ),
      );
    }

    return Column(
      children: laporanData.map((data) {
        // AMBIL DATA DENGAN NULL SAFETY
        final String nama = (selectedJenisLaporan == "Laporan peminjaman")
            ? (data['pengguna']?['nama'] ?? '-')
            : (data['peminjaman']?['pengguna']?['nama'] ?? '-');

        final String tanggalPinjam =
            (selectedJenisLaporan == "Laporan peminjaman")
            ? (data['tanggal_pinjam'] ?? '-')
            : (data['peminjaman']?['tanggal_pinjam'] ?? '-');

        final String tanggalKembali =
            (selectedJenisLaporan == "Laporan peminjaman")
            ? (data['tanggal_kembali'] ?? '-')
            : (data['peminjaman']?['tanggal_kembali'] ?? '-');

        String statusText;
        Color statusColor = primaryOrange;

        if (selectedJenisLaporan == "Laporan peminjaman") {
          final status = data['status'] ?? '';
          statusText = status.isNotEmpty ? status : '-';
          if (status.toLowerCase() == 'dikembalikan')
            statusColor = Colors.green;
        } else {
          final kondisiSetelah = data['kondisi_setelah'] ?? '-';
          statusText = kondisiSetelah;
          if (kondisiSetelah.toLowerCase() == 'baik')
            statusColor = Colors.green;
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(nama, style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tanggalPinjam,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  tanggalKembali,
                  style: const TextStyle(fontSize: 13),
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
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUnderlinedLabel('Jenis Laporan'),
                    DropdownButton<String>(
                      value: selectedJenisLaporan,
                      isExpanded: true,
                      underline: const SizedBox(),
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
                      onChanged: (v) =>
                          setState(() => selectedJenisLaporan = v),
                    ),
                    const SizedBox(height: 15),
                    _buildUnderlinedLabel("Tanggal Mulai"),
                    TextField(
                      controller: tanggalMulaiController,
                      readOnly: true,
                      onTap: () => _selectDate(context, tanggalMulaiController),
                      decoration: const InputDecoration(hintText: "yyyy-mm-dd"),
                    ),
                    const SizedBox(height: 15),
                    _buildUnderlinedLabel("Tanggal Akhir"),
                    TextField(
                      controller: tanggalAkhirController,
                      readOnly: true,
                      onTap: () => _selectDate(context, tanggalAkhirController),
                      decoration: const InputDecoration(hintText: "yyyy-mm-dd"),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: loadLaporan,
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text(
                              "Tampilkan",
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              minimumSize: const Size(95, 36),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: laporanData.isEmpty ? null : generatePDF,
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text(
                              "Download",
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              minimumSize: const Size(85, 36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Text(
                selectedJenisLaporan ?? '-',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: strokeOrange),
                ),
                child: buildLaporanTable(),
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
