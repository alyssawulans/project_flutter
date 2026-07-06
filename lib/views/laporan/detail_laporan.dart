import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/laporan/laporan_edit_view.dart';
import 'package:project_flutter/views/laporan/riwayat_laporan.dart';

class DetailLaporan extends StatefulWidget {
  final LaporanModel report;
  const DetailLaporan({super.key, required this.report});

  @override
  State<DetailLaporan> createState() => _DetailLaporanState();
}

class _DetailLaporanState extends State<DetailLaporan> {
  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  late LaporanModel _currentReport;
  String _userRole = 'user';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('current_user_role') ?? 'user';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _updateReportStatus(String newStatus) async {
    final updatedReport = LaporanModel(
      id: _currentReport.id,
      firestoreId: _currentReport.firestoreId,
      judul: _currentReport.judul,
      kategori: _currentReport.kategori,
      lokasi: _currentReport.lokasi,
      koordinat: _currentReport.koordinat,
      deskripsi: _currentReport.deskripsi,
      status: newStatus,
      tanggal: _currentReport.tanggal,
      userId: _currentReport.userId,
      userFirestoreId: _currentReport.userFirestoreId,
      foto: _currentReport.foto,
    );

    await FirebaseAuthService.instance.updateLaporan(updatedReport);

    if (mounted) {
      setState(() {
        _currentReport = updatedReport;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Laporan berhasil ditandai sebagai $newStatus"),
          backgroundColor: newStatus == 'Selesai' ? const Color(0xFF0D9488) : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Getters to act as wrapper mapping LaporanModel to the UI fields
  String get title => _currentReport.judul;
  String get status => _currentReport.status;
  String get category => _currentReport.kategori;
  String get description => _currentReport.deskripsi;
  String get lokasi => _currentReport.lokasi;
  String get koordinat => _currentReport.koordinat;
  String get imageUrl => _currentReport.foto.split(',').first;
  List<String> get imageUrls {
    if (_currentReport.foto.isEmpty) return [];
    return _currentReport.foto.split(',').where((url) => url.isNotEmpty).toList();
  }

  String get detailStatusTitle => _currentReport.status;

  String get detailStatusDesc {
    if (_currentReport.status == 'Selesai') {
      return "Laporan telah selesai ditindaklanjuti oleh petugas kebersihan setempat.";
    } else if (_currentReport.status == 'Ditolak') {
      return "Laporan ditolak karena informasi lokasi kurang jelas atau foto tidak relevan.";
    } else {
      return "Laporan Anda sedang kami verifikasi dan teruskan ke pihak terkait.";
    }
  }

  String get detailStatusTime {
    if (_currentReport.status == 'Selesai') {
      return "${_currentReport.tanggal}, 14:30";
    } else if (_currentReport.status == 'Ditolak') {
      return "${_currentReport.tanggal}, 16:00";
    } else {
      return "${_currentReport.tanggal}, 10:15";
    }
  }

  List<Map<String, String>> get timeline {
    if (_currentReport.status == 'Selesai') {
      return [
        {'title': 'Laporan dibuat', 'waktu': '${_currentReport.tanggal}, 09:00'},
        {'title': 'Sedang diproses', 'waktu': '${_currentReport.tanggal}, 10:00'},
        {'title': 'Laporan selesai', 'waktu': '${_currentReport.tanggal}, 14:30'},
      ];
    } else if (_currentReport.status == 'Ditolak') {
      return [
        {'title': 'Laporan dibuat', 'waktu': '${_currentReport.tanggal}, 13:00'},
        {'title': 'Laporan ditolak', 'waktu': '${_currentReport.tanggal}, 16:00'},
      ];
    } else {
      return [
        {'title': 'Laporan dibuat', 'waktu': '${_currentReport.tanggal}, 09:41'},
        {'title': 'Sedang diproses', 'waktu': '${_currentReport.tanggal}, 10:15'},
      ];
    }
  }

  Future<void> _deleteReport() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Laporan',
          style: TextStyle(color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus laporan ini?',
          style: TextStyle(color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuthService.instance.deleteLaporan(_currentReport.firestoreId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dihapus'), backgroundColor: Colors.red),
        );
        Navigator.pop(context); // Go back
      }
    }
  }

  Color getStatusColor(String status) {
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

  Color getStatusBgColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
      case 'ditolak':
        return isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2);
      case 'diproses':
      default:
        return isDark ? const Color(0xFF78350F) : const Color(0xFFFFFBEB);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'diproses':
      default:
        return Icons.access_time_rounded;
    }
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: url.startsWith('http')
                  ? Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                    )
                  : Image.file(
                      File(url),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
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

    final report = this;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : primaryTeal;
    final Color cardIconBg = isDark ? const Color(0xFF0F4C43).withOpacity(0.3) : const Color(0xFFF0FDFA);

    final statusColor = getStatusColor(_currentReport.status);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : primaryTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Laporan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: titleColor,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_userRole != 'admin')
            IconButton(
              icon: Icon(Icons.edit_outlined, color: activeTeal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LaporanEditView(laporan: _currentReport),
                  ),
                ).then((updated) {
                  if (updated != null && updated is LaporanModel) {
                    setState(() {
                      _currentReport = updated;
                    });
                  }
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status Laporan Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: getStatusBgColor(report.status, isDark),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: statusColor.withOpacity(isDark ? 0.4 : 0.2),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status Laporan",
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          getStatusIcon(report.status),
                          color: statusColor,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          report.detailStatusTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.detailStatusDesc,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFE2E8F0) : Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report.detailStatusTime,
                      style: TextStyle(fontSize: 11, color: subTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Informasi Laporan
              Text(
                "Informasi Laporan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: borderColor),
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
                    // Large Photo Header
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                      child: report.imageUrl.startsWith('http')
                          ? Image.network(
                              report.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 180,
                                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: isDark ? Colors.white30 : Colors.grey,
                                    ),
                                  ),
                            )
                          : Image.file(
                              File(report.imageUrl),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 180,
                                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: isDark ? Colors.white30 : Colors.grey,
                                    ),
                                  ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            report.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Category Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: cardIconBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.assignment,
                                  size: 18,
                                  color: activeTeal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Kategori",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: subTextColor,
                                      ),
                                    ),
                                    Text(
                                      report.category,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: cardIconBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: activeTeal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Lokasi",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: subTextColor,
                                      ),
                                    ),
                                    Text(
                                      report.lokasi,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            "Deskripsi",
                            style: TextStyle(
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFE2E8F0) : Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Foto Bukti Row
              Text(
                "Foto Bukti",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: report.imageUrls.length,
                  itemBuilder: (context, index) {
                    final imgUrl = report.imageUrls[index];
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(imgUrl),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imgUrl.startsWith('http')
                              ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.broken_image,
                                        color: isDark ? Colors.white30 : Colors.grey,
                                      ),
                                )
                              : Image.file(
                                  File(imgUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.broken_image,
                                        color: isDark ? Colors.white30 : Colors.grey,
                                      ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 4. Riwayat Status Timeline
              Text(
                "Riwayat Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(report.timeline.length, (index) {
                    final step = report.timeline[index];
                    final isLast = index == report.timeline.length - 1;
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          // Step indicator line & circle
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activeTeal,
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: activeTeal.withOpacity(0.3),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Step details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    step['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    step['waktu'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (_userRole == 'admin' && _currentReport.status.toLowerCase() == 'diproses')
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _updateReportStatus('Ditolak'),
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          label: const Text(
                            "Tolak Laporan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F4C43), Color(0xFF0D9488)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _updateReportStatus('Selesai'),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text(
                            "Setujui Laporan",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

