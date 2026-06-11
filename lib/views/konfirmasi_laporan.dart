import 'package:flutter/material.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/detail_laporan.dart';
import 'package:project_flutter/views/laporan_beranda.dart';
import 'package:project_flutter/views/main_navigation_shell.dart';

class KonfirmasiLaporan extends StatefulWidget {
  final String nomorLaporan;
  final String tanggal;
  final String kategori;
  final LaporanModel report;

  const KonfirmasiLaporan({
    super.key,
    required this.nomorLaporan,
    required this.tanggal,
    required this.kategori,
    required this.report,
  });

  @override
  State<KonfirmasiLaporan> createState() => _KonfirmasiLaporanState();
}

class _KonfirmasiLaporanState extends State<KonfirmasiLaporan> {
  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final Color detailLabelColor = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color buttonTextColor = isDark ? const Color(0xFF2DD4BF) : primaryTeal;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Success Circle Check
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        "assets/images/project_akhir/success.png",
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Laporan Berhasil Dikirim!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "Terima kasih atas partisipasi Anda dalam menjaga lingkungan. Laporan Anda akan kami tindak lanjuti.",
                        style: TextStyle(
                          fontSize: 13,
                          color: subTextColor,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Info Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? Border.all(color: borderColor) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Nomor Laporan",
                              style: TextStyle(
                                fontSize: 11,
                                color: detailLabelColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.nomorLaporan,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  // Simulated Copy to clipboard
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Nomor laporan disalin ke clipboard!",
                                      ),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: activeTeal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(color: borderColor),
                          const SizedBox(height: 12),
                          Text(
                            "Tanggal",
                            style: TextStyle(
                              fontSize: 11,
                              color: detailLabelColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tanggal,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Kategori",
                            style: TextStyle(
                              fontSize: 11,
                              color: detailLabelColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.kategori,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? activeTeal : primaryTeal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailLaporan(report: widget.report),
                                  ),
                                );
                              },
                              child: const Text(
                                "Lihat Detail Laporan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: borderColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MainNavigationShell(initialTab: 0),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Text(
                                "Kembali ke Beranda",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: buttonTextColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

