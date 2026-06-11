import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_flutter/database/ruas_db_helper.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/laporan_add_view.dart';
import 'package:project_flutter/views/laporan_detail_view.dart';

class LaporanListView extends StatefulWidget {
  const LaporanListView({super.key});

  @override
  State<LaporanListView> createState() => _LaporanListViewState();
}

class _LaporanListViewState extends State<LaporanListView> {
  String _searchQuery = '';
  String _selectedStatus = 'Semua';
  List<LaporanModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });

    // Get reports from DB with selected status filter
    final results = await RuasDbHelper.instance.getLaporans(
      status: _selectedStatus == 'Semua' ? null : _selectedStatus,
    );

    // Apply search filter if query is not empty
    List<LaporanModel> filtered = results;
    if (_searchQuery.isNotEmpty) {
      filtered = results
          .where((r) =>
              r.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.lokasi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.kategori.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (mounted) {
      setState(() {
        _reports = filtered;
        _isLoading = false;
      });
    }
  }

  void _onStatusTabSelected(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    final statusTabs = ['Semua', 'Diproses', 'Selesai', 'Ditolak'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FBFB);
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        title: Text(
          'Daftar Laporan',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D9488)),
            onPressed: _fetchReports,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _fetchReports();
                  },
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari laporan...',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Horizontal Status Tags
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: statusTabs.length,
                itemBuilder: (context, index) {
                  final status = statusTabs[index];
                  final isSelected = _selectedStatus == status;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0D9488),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : borderColor,
                        ),
                      ),
                      onSelected: (_) => _onStatusTabSelected(status),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Laporan List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                  : _reports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description_outlined, size: 64, color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada laporan ditemukan',
                                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchReports,
                          color: const Color(0xFF0D9488),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _reports.length,
                            itemBuilder: (context, index) {
                              final report = _reports[index];
                              return _buildReportCard(report);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LaporanAddView()),
          ).then((_) => _fetchReports());
        },
        backgroundColor: const Color(0xFF0D9488),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReportCard(LaporanModel report) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color cardTextColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final Color cardSubTextColor = isDark ? const Color(0xFF94A3B8) : Colors.black45;
    final Color cardBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    Color badgeColor = Colors.orange;
    if (report.status == 'Selesai') {
      badgeColor = Colors.green;
    } else if (report.status == 'Ditolak') {
      badgeColor = Colors.red;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LaporanDetailView(laporan: report),
            ),
          ).then((_) => _fetchReports());
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: report.foto.startsWith('http')
                    ? Image.network(
                        report.foto,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: isDark ? const Color(0xFF334155) : Colors.teal.shade50,
                          child: const Icon(Icons.image, color: Color(0xFF0D9488)),
                        ),
                      )
                    : report.foto.startsWith('assets/')
                        ? Image.asset(
                            report.foto,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: isDark ? const Color(0xFF334155) : Colors.teal.shade50,
                              child: const Icon(Icons.image, color: Color(0xFF0D9488)),
                            ),
                          )
                        : report.foto.isNotEmpty
                            ? Image.file(
                                File(report.foto),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: isDark ? const Color(0xFF334155) : Colors.teal.shade50,
                                  child: const Icon(Icons.image, color: Color(0xFF0D9488)),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: isDark ? const Color(0xFF334155) : Colors.teal.shade50,
                                child: const Icon(Icons.photo_library_outlined, color: Color(0xFF0D9488)),
                              ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            report.kategori,
                            style: const TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.judul,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cardTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.lokasi,
                            style: TextStyle(
                              fontSize: 12,
                              color: cardSubTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          report.tanggal,
                          style: TextStyle(
                            fontSize: 11,
                            color: cardSubTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.status,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}

