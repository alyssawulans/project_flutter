import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseViewerView extends StatefulWidget {
  const DatabaseViewerView({super.key});

  @override
  State<DatabaseViewerView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseViewerView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _laporan = [];
  List<Map<String, dynamic>> _edukasi = [];

  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  // Keep track of expanded card indices per table
  final Map<String, Set<int>> _expandedRows = {
    'users': {},
    'laporan': {},
    'edukasi': {},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
      });
    });
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = FirebaseFirestore.instance;

      // Query raw map data from the tables
      final usersSnapshot = await db.collection('users').get();
      final usersData = usersSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      final laporanSnapshot = await db.collection('laporan').get();
      final laporanData = laporanSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      final edukasiSnapshot = await db.collection('edukasi').get();
      final edukasiData = edukasiSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      if (mounted) {
        setState(() {
          _users = usersData;
          _laporan = laporanData;
          _edukasi = edukasiData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearTable(String tableName) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Hapus Tabel $tableName?',
          style: TextStyle(color: isDark ? Colors.white : textDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua data di tabel "$tableName"? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final db = FirebaseFirestore.instance;
        final snapshot = await db.collection(tableName).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        await _loadAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Semua data di tabel "$tableName" berhasil dihapus'),
              backgroundColor: activeTeal,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _copyToClipboard(Map<String, dynamic> row) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(row);
    Clipboard.setData(ClipboardData(text: prettyJson));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_all, color: Colors.white),
            SizedBox(width: 8),
            Text('Data baris disalin sebagai JSON!'),
          ],
        ),
        backgroundColor: activeTeal,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredData(
    List<Map<String, dynamic>> data,
  ) {
    if (_searchQuery.isEmpty) return data;
    return data.where((row) {
      return row.values.any((value) {
        if (value == null) return false;
        return value
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      });
    }).toList();
  }

  String _getTableNameAt(int index) {
    switch (index) {
      case 0:
        return 'users';
      case 1:
        return 'laporan';
      case 2:
        return 'edukasi';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color activeTealColor = isDark ? const Color(0xFF2DD4BF) : activeTeal;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : textDark),
        title: _isSearching
            ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Cari data di tabel...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            )
            : Text(
              'SQLite Database Viewer',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            tooltip: 'Hapus semua data di tabel aktif',
            onPressed: () {
              final activeTableName = _getTableNameAt(_tabController.index);
              _clearTable(activeTableName);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: activeTealColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: activeTealColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'Users (${_users.length})'),
            Tab(text: 'Laporan (${_laporan.length})'),
            Tab(text: 'Edukasi (${_edukasi.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
            child: CircularProgressIndicator(color: activeTealColor),
          )
          : TabBarView(
            controller: _tabController,
            children: [
              _buildTableList('users', _users, Icons.person_rounded, 'nama'),
              _buildTableList(
                'laporan',
                _laporan,
                Icons.description_rounded,
                'judul',
              ),
              _buildTableList(
                'edukasi',
                _edukasi,
                Icons.menu_book_rounded,
                'judul',
              ),
            ],
          ),
    );
  }

  Widget _buildTableList(
    String tableName,
    List<Map<String, dynamic>> rawData,
    IconData tableIcon,
    String primaryKeyColumn,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color listCardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color listTextColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color listSubTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;
    final Color listBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final Color activeTealColor = isDark ? const Color(0xFF2DD4BF) : activeTeal;

    final filteredData = _getFilteredData(rawData);

    if (filteredData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : tableIcon,
                size: 64,
                color: isDark ? const Color(0xFF334155) : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ada hasil pencarian untuk "$_searchQuery"'
                    : 'Tabel "$tableName" kosong',
                style: TextStyle(
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Coba gunakan kata kunci pencarian yang lain.'
                    : 'Belum ada data yang disimpan pada tabel ini.',
                style: TextStyle(color: listSubTextColor, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final row = filteredData[index];
        final id = row['id'] ?? index;
        final isExpanded = _expandedRows[tableName]?.contains(id) ?? false;
        final primaryText = row[primaryKeyColumn]?.toString() ?? '-';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: listCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: listBorderColor),
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
              // Header of Row (Tile)
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedRows[tableName]?.remove(id);
                    } else {
                      _expandedRows[tableName]?.add(id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: activeTealColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(tableIcon, color: activeTealColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryText,
                              style: TextStyle(
                                color: listTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: $id',
                              style: TextStyle(
                                color: listSubTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Details Panel
              if (isExpanded) ...[
                Divider(height: 1, color: listBorderColor),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...row.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: activeTealColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value?.toString() ?? 'NULL',
                                style: TextStyle(
                                  color: listTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                      Divider(height: 1, color: listBorderColor),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(row),
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text(
                              'Salin JSON',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: activeTealColor,
                              side: BorderSide(color: activeTealColor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

