import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/config/app_translations.dart';
import 'package:project_flutter/database/ruas_db_helper.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/buat_laporan.dart';
import 'package:project_flutter/views/detail_laporan.dart';
import 'package:project_flutter/views/riwayat_laporan.dart';
import 'package:project_flutter/views/kategori_detail_view.dart';

class LaporanBeranda extends StatefulWidget {
  const LaporanBeranda({super.key});

  @override
  State<LaporanBeranda> createState() => _LaporanBerandaState();
}

class _LaporanBerandaState extends State<LaporanBeranda> {
  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  late Future<List<LaporanModel>> _laporanFuture;
  String _userRole = 'user';
  int _userId = 1;
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
        _userId = prefs.getInt('current_user_id') ?? 1;
        _isLoadingUser = false;
        _laporanFuture = _fetchLaporans();
      });
    }
  }

  Future<List<LaporanModel>> _fetchLaporans() async {
    if (_userRole == 'admin') {
      return await RuasDbHelper.instance.getLaporans();
    } else {
      return await RuasDbHelper.instance.getLaporans(userId: _userId);
    }
  }

  void _refreshLaporans() {
    setState(() {
      _laporanFuture = _fetchLaporans();
    });
  }

  // Static list of categories with assets/images or icons
  final List<Map<String, dynamic>> categories = [
    {
      "nama": "Pembuangan Sampah",
      "icon": Icons.delete_outline,
      "color": const Color(0xFF0D9488),
    },
    {
      "nama": "Pembakaran Sampah",
      "icon": Icons.local_fire_department_outlined,
      "color": const Color(0xFFEA580C),
    },
    {
      "nama": "Polusi Udara",
      "icon": Icons.cloud_outlined,
      "color": const Color(0xFF0284C7),
    },
    {
      "nama": "Limbah Cair",
      "icon": Icons.water_drop_outlined,
      "color": const Color(0xFF2563EB),
    },
    {
      "nama": "Kebisingan",
      "icon": Icons.volume_up_outlined,
      "color": const Color(0xFF7C3AED),
    },
    {
      "nama": "Lainnya",
      "icon": Icons.more_horiz_outlined,
      "color": const Color(0xFF475569),
    },
  ];

  Color getBadgeTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesay':
      case 'selesai':
        return const Color(0xFF10B981);
      case 'ditolak':
        return const Color(0xFFEF4444);
      case 'diproses':
      default:
        return const Color(0xFFF97316);
    }
  }

  Color getBadgeBgColor(String status, bool isDark, Color cardBgColor) {
    Color baseColor;
    switch (status.toLowerCase()) {
      case 'selesai':
        baseColor = const Color(0xFF10B981);
        break;
      case 'ditolak':
        baseColor = const Color(0xFFEF4444);
        break;
      case 'diproses':
      default:
        baseColor = const Color(0xFFF97316);
        break;
    }
    return isDark 
        ? Color.alphaBlend(baseColor.withValues(alpha: 0.15), cardBgColor)
        : baseColor.withValues(alpha: 0.12);
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

    // Deteksi tema gelap/terang untuk penyesuaian warna komponen
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = AppSettingsController.instance.settingsNotifier.value;
    final lang = settings.languageCode;

    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F8FB);
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final Color iconColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1A2E44);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Image.asset(
            'assets/images/logo_ruas.png',
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: iconColor,
                size: 24,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryTeal, activeTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryTeal.withValues(alpha: isDark ? 0.3 : 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userRole == 'admin'
                        ? "Panel Pengelolaan Laporan"
                        : AppTranslations.translate('report_banner_title', lang),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userRole == 'admin'
                        ? "Selamat datang di Panel Admin RUAS. Anda memiliki wewenang untuk meninjau, menyetujui, atau menolak setiap laporan isu lingkungan yang masuk."
                        : AppTranslations.translate('report_banner_desc', lang),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  if (_userRole != 'admin') ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        // Navigasi ke halaman Buat Laporan, lalu refresh data setelah kembali
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuatLaporan(),
                          ),
                        ).then((_) {
                          _refreshLaporans();
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: primaryTeal, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.translate('create_report_btn', lang),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 2. Kategori Laporan Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.translate('report_category', lang),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke Riwayat Laporan, refresh setelah kembali
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatLaporan(),
                        ),
                      ).then((_) {
                        _refreshLaporans();
                      });
                    },
                    child: Text(
                      AppTranslations.translate('view_all', lang),
                      style: TextStyle(
                        color: activeTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KategoriDetailView(categoryName: cat['nama']),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.01),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cat['color'].withOpacity(isDark ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat['icon'],
                            color: cat['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['nama'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 3. Laporan Terbaru Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.translate('recent_reports', lang),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatLaporan(),
                        ),
                      ).then((_) {
                        // Navigasi ke Riwayat Laporan, refresh setelah kembali
                        _refreshLaporans();
                      });
                    },
                    child: Text(
                      AppTranslations.translate('view_all', lang),
                      style: TextStyle(
                        color: activeTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // FutureBuilder: memuat data laporan dari SQLite secara async.
            // Menampilkan loading spinner saat data dimuat, lalu merender list laporan.
            FutureBuilder<List<LaporanModel>>(
              future: _laporanFuture,
              builder: (context, snapshot) {
                // --- State 1: Sedang memuat data dari database ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                    ),
                  );
                }

                // --- State 2: Terjadi error saat mengambil data ---
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Gagal memuat laporan: ${snapshot.error}',
                        style: TextStyle(color: subTextColor),
                      ),
                    ),
                  );
                }

                // --- State 3: Data berhasil dimuat ---
                // Ambil 3 laporan terbaru dari hasil query SQLite
                final allReports = snapshot.data ?? [];
                final recentReports = allReports.take(3).toList();

                if (recentReports.isEmpty) {
                  // Tampilkan pesan kosong jika belum ada laporan
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: isDark ? Colors.white24 : Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppTranslations.translate('no_reports', lang),
                            style: TextStyle(color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Tampilkan list 3 laporan terbaru
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recentReports.length,
                  itemBuilder: (context, index) {
                    final item = recentReports[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.01),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Navigasi ke halaman detail laporan, lalu refresh list
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildReportImage(item.foto),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.judul,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.lokasi,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: subTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Badge status laporan (Diproses/Selesai/Ditolak)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getBadgeBgColor(item.status, isDark, cardBgColor),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: getBadgeTextColor(item.status),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item.tanggal,
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _buildReportImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorImage(),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorImage(),
      );
    } else if (path.isNotEmpty) {
      return Image.file(
        File(path),
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorImage(),
      );
    } else {
      return _errorImage();
    }
  }

  Widget _errorImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 68,
      height: 68,
      color: isDark ? const Color(0xFF334155) : Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        color: isDark ? Colors.white30 : Colors.grey,
      ),
    );
  }
}

