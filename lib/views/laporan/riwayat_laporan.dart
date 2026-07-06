import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/laporan/detail_laporan.dart';
import 'package:project_flutter/views/laporan/laporan_beranda.dart';

// Keep a stub ReportItem and ReportStorage for backwards compatibility if needed, but we will use LaporanModel
class ReportItem {
  final String title;
  final String date;
  final String status;
  final List<String> imageUrls;
  final String category;
  final String description;
  final String lokasi;
  final String koordinat;
  final String detailStatusTitle;
  final String detailStatusDesc;
  final String detailStatusTime;
  final List<Map<String, String>> timeline;

  ReportItem({
    required this.title,
    required this.date,
    required this.status,
    required this.imageUrls,
    required this.category,
    required this.description,
    required this.lokasi,
    required this.koordinat,
    required this.detailStatusTitle,
    required this.detailStatusDesc,
    required this.detailStatusTime,
    required this.timeline,
  });

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : "";
}

class ReportStorage {
  static final List<ReportItem> reports = [];
}

class RiwayatLaporan extends StatefulWidget {
  const RiwayatLaporan({super.key});

  @override
  State<RiwayatLaporan> createState() => _RiwayatLaporanState();
}

class _RiwayatLaporanState extends State<RiwayatLaporan> {
  // Colors based on premium design system
  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  late Future<List<LaporanModel>> _laporanFuture;
  String _userRole = 'user';
  String? _userFirestoreId;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchLaporans();
  }

  Future<void> _loadUserAndFetchLaporans() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('current_user_role') ?? 'user';
        _userFirestoreId = prefs.getString('current_user_firestore_id');
        _isLoadingUser = false;
        _laporanFuture = _fetchAllLaporans();
      });
    }
  }

  /// Mengambil seluruh data laporan dari database Firestore secara async.
  Future<List<LaporanModel>> _fetchAllLaporans() async {
    if (_userRole == 'admin') {
      return await FirebaseAuthService.instance.getLaporans();
    } else {
      return await FirebaseAuthService.instance.getLaporans(userFirestoreId: _userFirestoreId);
    }
  }

  /// Me-refresh seluruh data laporan setelah ada perubahan (edit/delete).
  void _refreshLaporans() {
    setState(() {
      _laporanFuture = _fetchAllLaporans();
    });
  }

  Color getBadgeTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF10B981);
      case 'ditolak':
        return const Color(0xFFEF4444);
      case 'diproses':
      default:
        return const Color(0xFFF97316);
    }
  }

  Color getBadgeBgColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
      case 'ditolak':
        return isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2);
      case 'diproses':
      default:
        return isDark ? const Color(0xFF78350F) : const Color(0xFFFFF7ED);
    }
  }

  Color getBadgeBorderColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0);
      case 'ditolak':
        return isDark ? const Color(0xFFB91C1C) : const Color(0xFFFECACA);
      case 'diproses':
      default:
        return isDark ? const Color(0xFFB45309) : const Color(0xFFFED7AA);
    }
  }

  /// Membangun daftar laporan berdasarkan filter status menggunakan FutureBuilder.
  /// [filterStatus] dapat berupa 'Semua', 'Diproses', 'Selesai', atau 'Ditolak'.
  Widget _buildReportList(String filterStatus) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    // FutureBuilder mengelola tiga kondisi: loading, error, dan data tersedia
    return FutureBuilder<List<LaporanModel>>(
      future: _laporanFuture,
      builder: (context, snapshot) {
        // Kondisi 1: Sedang memuat data dari SQLite
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0D9488)),
          );
        }

        // Kondisi 2: Error saat query database
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: subTextColor),
            ),
          );
        }

        // Kondisi 3: Data berhasil dimuat, lakukan filter berdasarkan status
        final allReports = snapshot.data ?? [];
        final filteredList = allReports.where((item) {
          if (filterStatus == 'Semua') return true;
          return item.status.toLowerCase() == filterStatus.toLowerCase();
        }).toList();

        // Tampilkan pesan kosong jika tidak ada laporan pada filter ini
        if (filteredList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    'assets/animations/confuse.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Belum ada laporan status $filterStatus",
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Tampilkan list laporan yang sudah difilter
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final item = filteredList[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Navigasi ke detail laporan; refresh list setelah kembali
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailLaporan(report: item),
                      ),
                    ).then((_) => _refreshLaporans());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Thumbnail foto laporan
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildItemImage(item.firstFoto, isDark),
                        ),
                        const SizedBox(width: 16),
                        // Judul dan tanggal laporan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.tanggal,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge status dan chevron navigasi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? const Color(0xFF64748B) : Colors.grey[400],
                              size: 18,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getBadgeBgColor(item.status, isDark),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: getBadgeBorderColor(item.status, isDark),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  color: getBadgeTextColor(item.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemImage(String path, bool isDark) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorImage(isDark),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorImage(isDark),
      );
    } else if (path.isNotEmpty) {
      return Image.file(
        File(path),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorImage(isDark),
      );
    } else {
      return _errorImage(isDark);
    }
  }

  Widget _errorImage(bool isDark) {
    return Container(
      width: 72,
      height: 72,
      color: isDark ? const Color(0xFF334155) : Colors.grey[100],
      child: Icon(
        Icons.broken_image,
        color: isDark ? Colors.white30 : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color appBarTitleColor = isDark ? Colors.white : primaryTeal;
    final Color indicatorColor = isDark ? const Color(0xFF0D9488) : primaryTeal;
    final Color tabLabelColor = isDark ? const Color(0xFF0D9488) : primaryTeal;
    final Color tabUnselectedLabelColor = isDark ? const Color(0xFF64748B) : Colors.grey[400]!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarBgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : primaryTeal),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // If we can't pop, go back to LaporanBeranda
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanBeranda(),
                  ),
                );
              }
            },
          ),
          title: Text(
            'Riwayat Laporan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: appBarTitleColor,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            isScrollable: false,
            indicatorColor: indicatorColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3.0,
            labelColor: tabLabelColor,
            unselectedLabelColor: tabUnselectedLabelColor,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Diproses'),
              Tab(text: 'Selesai'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportList('Semua'),
            _buildReportList('Diproses'),
            _buildReportList('Selesai'),
            _buildReportList('Ditolak'),
          ],
        ),
      ),
    );
  }
}

