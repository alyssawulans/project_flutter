import 'package:flutter/material.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/edukasi_model.dart';
import 'package:project_flutter/views/edukasi/edukasi_form_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EdukasiDetailView extends StatefulWidget {
  final EdukasiModel article;
  const EdukasiDetailView({super.key, required this.article});

  @override
  State<EdukasiDetailView> createState() => _EdukasiDetailViewState();
}

class _EdukasiDetailViewState extends State<EdukasiDetailView> {
  late EdukasiModel _currentArticle;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _currentArticle = widget.article;
    _markArticleAsRead();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('current_user_role') ?? 'user';
      });
    }
  }

  Future<void> _markArticleAsRead() async {
    if (_currentArticle.id == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id') ?? 1;
      final readKey = 'read_articles_$userId';
      final readList = prefs.getStringList(readKey) ?? [];
      final articleIdStr = _currentArticle.id.toString();
      if (!readList.contains(articleIdStr)) {
        readList.add(articleIdStr);
        await prefs.setStringList(readKey, readList);
      }
    } catch (_) {}
  }

  Future<void> _deleteArticle() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Artikel',
          style: TextStyle(color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus artikel edukasi ini?',
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

    if (confirm == true && _currentArticle.firestoreId != null) {
      await FirebaseAuthService.instance.deleteEdukasi(_currentArticle.firestoreId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus'), backgroundColor: Colors.red),
        );
        Navigator.pop(context); // Go back
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color appBarColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.black45;
    final Color dividerColor = isDark ? const Color(0xFF334155) : Colors.grey.shade300;
    final Color tagBg = isDark ? const Color(0xFF0F4C43).withOpacity(0.3) : const Color(0xFFE2F1ED);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Edukasi',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_userRole == 'admin') ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: isDark ? Colors.white : Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EdukasiFormView(article: _currentArticle),
                  ),
                ).then((updated) {
                  if (updated != null && updated is EdukasiModel) {
                    setState(() {
                      _currentArticle = updated;
                    });
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteArticle,
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image
            Container(
              height: 240,
              width: double.infinity,
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              child: _currentArticle.gambar.startsWith('assets/')
                  ? Image.asset(
                      _currentArticle.gambar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image_outlined,
                        size: 60,
                        color: isDark ? Colors.white30 : Colors.grey,
                      ),
                    )
                  : Center(
                      child: Icon(Icons.menu_book, size: 60, color: isDark ? Colors.white38 : Colors.black26),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta tags row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(6),
                          border: isDark ? Border.all(color: const Color(0xFF0D9488).withOpacity(0.5)) : null,
                        ),
                        child: Text(
                          _currentArticle.kategori,
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today_outlined, size: 14, color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 6),
                      Text(
                        _currentArticle.tanggal,
                        style: TextStyle(fontSize: 12, color: subTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _currentArticle.judul,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: dividerColor),
                  const SizedBox(height: 16),

                  // Content
                  Text(
                    _currentArticle.konten,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

