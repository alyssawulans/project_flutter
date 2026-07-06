import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/laporan/laporan_edit_view.dart';

class LaporanDetailView extends StatefulWidget {
  final LaporanModel laporan;
  const LaporanDetailView({super.key, required this.laporan});

  @override
  State<LaporanDetailView> createState() => _LaporanDetailViewState();
}

class _LaporanDetailViewState extends State<LaporanDetailView> {
  late LaporanModel _currentLaporan;
  String _pelaporName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentLaporan = widget.laporan;
    _loadPelapor();
  }

  Future<void> _loadPelapor() async {
    final user = _currentLaporan.userFirestoreId != null ? await FirebaseAuthService.instance.getUser(_currentLaporan.userFirestoreId!) : null;
    if (user != null) {
      if (mounted) {
        setState(() {
          _pelaporName = user.nama;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _pelaporName = 'Andi Pratama';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReport() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Laporan', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text(
          'Apakah Anda yakin ingin menghapus laporan ini secara permanen dari database?',
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.black54),
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
      await FirebaseAuthService.instance.deleteLaporan(_currentLaporan.firestoreId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // Go back to list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    Color statusColor = Colors.orange;
    if (_currentLaporan.status == 'Selesai') {
      statusColor = Colors.green;
    } else if (_currentLaporan.status == 'Ditolak') {
      statusColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Laporan',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0D9488)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LaporanEditView(laporan: _currentLaporan),
                ),
              ).then((updatedReport) {
                if (updatedReport != null && updatedReport is LaporanModel) {
                  setState(() {
                    _currentLaporan = updatedReport;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo display header
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                    child: _currentLaporan.firstFoto.startsWith('http')
                        ? Image.network(
                            _currentLaporan.firstFoto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                          )
                        : _currentLaporan.firstFoto.startsWith('assets/')
                            ? Image.asset(
                                _currentLaporan.firstFoto,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.broken_image_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              )
                            : _currentLaporan.firstFoto.isNotEmpty
                                ? Image.file(
                                    File(_currentLaporan.firstFoto),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.photo_outlined, size: 60, color: Colors.black26),
                                  ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _currentLaporan.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          _currentLaporan.judul,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info cards grid
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.category_outlined, 'Kategori', _currentLaporan.kategori, isDark),
                              Divider(height: 16, color: borderColor),
                              _buildInfoRow(Icons.location_on_outlined, 'Lokasi', _currentLaporan.lokasi, isDark),
                              Divider(height: 16, color: borderColor),
                              _buildInfoRow(Icons.calendar_today_outlined, 'Tanggal', _currentLaporan.tanggal, isDark),
                              Divider(height: 16, color: borderColor),
                              _buildInfoRow(Icons.person_outline, 'Pelapor', _pelaporName, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Coordinates telemetry card
                        if (_currentLaporan.koordinat.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F2625) : const Color(0xFFEFF6F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? const Color(0xFF134E4A) : const Color(0xFFCCE5E1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gps_fixed, color: Color(0xFF0D9488), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Telemetri GPS (Koordinat)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _currentLaporan.koordinat,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Membuka peta eksternal...')),
                                    );
                                  },
                                  icon: const Icon(Icons.map, size: 14, color: Color(0xFF0D9488)),
                                  label: Text(
                                    'Buka Peta',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Description
                        Text(
                          'Deskripsi Laporan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentLaporan.deskripsi,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Timeline progress
                        Text(
                          'Alur Tindak Lanjut',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimeline(isDark),
                        const SizedBox(height: 36),

                        // Delete button
                        ElevatedButton.icon(
                          onPressed: _deleteReport,
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          label: const Text('Hapus Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    final Color labelColor = isDark ? const Color(0xFF94A3B8) : Colors.black54;
    final Color valColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;

    return Row(
      children: [
        Icon(icon, color: labelColor, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(color: labelColor, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(bool isDark) {
    bool isDiproses = _currentLaporan.status == 'Diproses' || _currentLaporan.status == 'Selesai';
    bool isSelesai = _currentLaporan.status == 'Selesai';

    return Column(
      children: [
        _buildTimelineStep('Laporan Diterima', 'Laporan Anda telah berhasil masuk database lokal RUAS.', true, isDark),
        _buildTimelineLine(isDiproses, isDark),
        _buildTimelineStep('Sedang Diproses', 'Petugas sedang meninjau lokasi pelanggaran lingkungan.', isDiproses, isDark),
        _buildTimelineLine(isSelesai, isDark),
        _buildTimelineStep('Selesai Ditindak', 'Kondisi lingkungan sudah dibersihkan atau diselesaikan.', isSelesai, isDark),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String desc, bool isActive, bool isDark) {
    final Color activeTitleColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final Color inactiveTitleColor = isDark ? const Color(0xFF475569) : Colors.black38;
    final Color activeDescColor = isDark ? const Color(0xFF94A3B8) : Colors.black54;
    final Color inactiveDescColor = isDark ? const Color(0xFF475569) : Colors.black38;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
          child: Icon(
            isActive ? Icons.check : Icons.circle,
            size: isActive ? 14 : 8,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? activeTitleColor : inactiveTitleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? activeDescColor : inactiveDescColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
      alignment: Alignment.centerLeft,
      child: Container(
        height: 24,
        width: 2,
        color: isActive ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
      ),
    );
  }
}

