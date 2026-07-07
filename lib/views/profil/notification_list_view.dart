import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/notification_model.dart';
import 'package:project_flutter/views/laporan/detail_laporan.dart';
import 'package:project_flutter/views/edukasi/edukasi_detail_view.dart';

class NotificationListView extends StatefulWidget {
  const NotificationListView({super.key});

  @override
  State<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _userFirestoreId = '';
  bool _showSimPanel = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndNotifications();
  }

  Future<void> _loadUserAndNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    _userFirestoreId = prefs.getString('current_user_firestore_id') ?? '';

    await _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (_userFirestoreId.isEmpty) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
      return;
    }

    final notifs = await FirebaseAuthService.instance.getNotifications(_userFirestoreId);
    if (mounted) {
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notif) async {
    if (notif.isRead || notif.id == null) return;
    await FirebaseAuthService.instance.markNotificationAsRead(notif.id!);
    
    // Update local state instantly
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notif.id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: notif.id,
          title: notif.title,
          body: notif.body,
          tanggal: notif.tanggal,
          isRead: true,
          type: notif.type,
          relatedId: notif.relatedId,
          userFirestoreId: notif.userFirestoreId,
        );
      }
    });
  }

  Future<void> _markAllAsRead() async {
    if (_userFirestoreId.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    await FirebaseAuthService.instance.markAllNotificationsAsRead(_userFirestoreId);
    await _fetchNotifications();
    if (mounted) {
      final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? 'All notifications marked as read' : 'Semua notifikasi ditandai telah dibaca'),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notif, int index) async {
    if (notif.id == null) return;
    
    // Keep a backup for undo action
    final backup = notif;
    
    setState(() {
      _notifications.removeAt(index);
    });

    await FirebaseAuthService.instance.deleteNotification(notif.id!);

    if (mounted) {
      final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;
      final displayTitle = lang == 'en'
          ? (notif.title.contains('Peringatan Polusi Udara')
              ? '⚠️ Air Pollution Warning'
              : (notif.title.contains('Status Laporan Diperbarui')
                  ? '✅ Report Status Updated'
                  : (notif.title.contains('Edukasi Lingkungan Baru')
                      ? '🎓 New Environmental Education'
                      : notif.title)))
          : notif.title;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'en' ? 'Notification "$displayTitle" deleted' : 'Notifikasi "${notif.title}" dihapus'),
          action: SnackBarAction(
            label: lang == 'en' ? 'Undo' : 'Batal',
            textColor: Colors.tealAccent,
            onPressed: () async {
              await FirebaseAuthService.instance.createNotification(backup);
              _fetchNotifications();
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Handle clicking a notification (marks as read and deep-links to details)
  void _onNotificationTap(NotificationModel notif) async {
    await _markAsRead(notif);

    if (!mounted) return;

    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;
    if (notif.type == 'laporan' && notif.relatedId.isNotEmpty) {
      _showLoadingDialog();
      final report = await FirebaseAuthService.instance.getLaporanById(notif.relatedId);
      if (mounted) Navigator.pop(context); // pop loading dialog

      if (report != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLaporan(report: report),
          ),
        ).then((_) => _fetchNotifications());
      } else {
        _showErrorSnackBar(lang == 'en' ? 'Report not found or has been deleted.' : 'Laporan tidak ditemukan atau sudah dihapus.');
      }
    } else if (notif.type == 'edukasi' && notif.relatedId.isNotEmpty) {
      _showLoadingDialog();
      final article = await FirebaseAuthService.instance.getEdukasiById(notif.relatedId);
      if (mounted) Navigator.pop(context); // pop loading dialog

      if (article != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EdukasiDetailView(article: article),
          ),
        ).then((_) => _fetchNotifications());
      } else {
        _showErrorSnackBar(lang == 'en' ? 'Educational article not found.' : 'Artikel edukasi tidak ditemukan.');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D9488)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // SIMULATOR METHODS
  Future<void> _simulateAQIWarning() async {
    if (_userFirestoreId.isEmpty) return;
    final notif = NotificationModel(
      title: '⚠️ Peringatan Polusi Udara',
      body: 'Kualitas udara di dekat Anda berada dalam kategori Tidak Sehat (AQI: 158). Disarankan memakai masker jika beraktivitas di luar.',
      tanggal: DateTime.now().toIso8601String(),
      isRead: false,
      type: 'aqi',
      relatedId: '',
      userFirestoreId: _userFirestoreId,
    );
    await FirebaseAuthService.instance.createNotification(notif);
    await _fetchNotifications();
  }

  Future<void> _simulateLaporanStatusChange() async {
    if (_userFirestoreId.isEmpty) return;
    
    // Ambil satu laporan acak dari user ini untuk disimulasikan, atau buat dummy related id
    final laporans = await FirebaseAuthService.instance.getLaporans(userFirestoreId: _userFirestoreId);
    String relatedId = 'dummy_laporan_id';
    String judul = 'Pembakaran Sampah Liar';
    if (laporans.isNotEmpty) {
      relatedId = laporans.first.firestoreId ?? 'dummy_laporan_id';
      judul = laporans.first.judul;
    }

    final notif = NotificationModel(
      title: '✅ Status Laporan Diperbarui',
      body: 'Kabar baik! Laporan Anda mengenai "$judul" telah selesai ditindaklanjuti oleh petugas lapangan.',
      tanggal: DateTime.now().toIso8601String(),
      isRead: false,
      type: 'laporan',
      relatedId: relatedId,
      userFirestoreId: _userFirestoreId,
    );
    await FirebaseAuthService.instance.createNotification(notif);
    await _fetchNotifications();
  }

  Future<void> _simulateNewEdukasi() async {
    if (_userFirestoreId.isEmpty) return;

    final articles = await FirebaseAuthService.instance.getEdukasis();
    String relatedId = 'dummy_edukasi_id';
    String judul = '5 Cara Mengurangi Sampah Plastik';
    if (articles.isNotEmpty) {
      relatedId = articles.first.firestoreId ?? 'dummy_edukasi_id';
      judul = articles.first.judul;
    }

    final notif = NotificationModel(
      title: '🎓 Edukasi Lingkungan Baru',
      body: 'Artikel baru diterbitkan: "$judul". Pelajari cara menjaga lingkungan di sekitar kita sekarang!',
      tanggal: DateTime.now().toIso8601String(),
      isRead: false,
      type: 'edukasi',
      relatedId: relatedId,
      userFirestoreId: _userFirestoreId,
    );
    await FirebaseAuthService.instance.createNotification(notif);
    await _fetchNotifications();
  }

  String _formatDateString(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;

      if (difference.inMinutes < 1) {
        return lang == 'en' ? 'Just now' : 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return lang == 'en' ? '${difference.inMinutes}m ago' : '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        return lang == 'en' ? '${difference.inHours}h ago' : '${difference.inHours} jam yang lalu';
      } else if (difference.inDays == 1) {
        return lang == 'en' ? 'Yesterday' : 'Kemarin';
      } else {
        return DateFormat('d MMM yyyy, HH:mm', lang == 'en' ? 'en_US' : 'id_ID').format(dateTime);
      }
    } catch (_) {
      return isoString; // fallback
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'aqi':
        return Colors.orange.shade800;
      case 'laporan':
        return const Color(0xFF0D9488);
      case 'edukasi':
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'aqi':
        return Icons.air_rounded;
      case 'laporan':
        return Icons.assignment_rounded;
      case 'edukasi':
        return Icons.school_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final lang = settings.languageCode;
        
        final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final Color textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
        final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            title: Text(
              lang == 'en' ? 'Notifications' : 'Notifikasi',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (_notifications.any((n) => !n.isRead))
                IconButton(
                  icon: const Icon(Icons.mark_chat_read_outlined, size: 22),
                  tooltip: lang == 'en' ? 'Mark All as Read' : 'Tandai Semua Dibaca',
                  onPressed: _markAllAsRead,
                ),
              IconButton(
                icon: Icon(_showSimPanel ? Icons.developer_mode : Icons.developer_mode_outlined, color: activeTeal),
                tooltip: lang == 'en' ? 'Simulator Panel' : 'Panel Simulator',
                onPressed: () {
                  setState(() {
                    _showSimPanel = !_showSimPanel;
                  });
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // COLLAPSIBLE SIMULATOR PANEL
                if (_showSimPanel)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: activeTeal.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bug_report, color: activeTeal, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              lang == 'en' ? 'Notification Simulator Panel (Testing)' : 'Panel Simulasi Notifikasi (Pengujian)',
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.air, size: 14),
                                label: Text(lang == 'en' ? 'Simulate AQI' : 'Simulasi AQI'),
                                onPressed: _simulateAQIWarning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: activeTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.assignment, size: 14),
                                label: Text(lang == 'en' ? 'Simulate Report' : 'Simulasi Laporan'),
                                onPressed: _simulateLaporanStatusChange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.school, size: 14),
                                label: Text(lang == 'en' ? 'Simulate Education' : 'Simulasi Edukasi'),
                                onPressed: _simulateNewEdukasi,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // MAIN LIST AREA
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                        )
                      : _notifications.isEmpty
                          ? RefreshIndicator(
                              onRefresh: _fetchNotifications,
                              color: activeTeal,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.notifications_off_outlined,
                                          size: 72,
                                          color: subTextColor.withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          lang == 'en' ? 'No notifications yet' : 'Belum ada notifikasi',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          lang == 'en'
                                              ? 'Notifications related to your activity will appear here.'
                                              : 'Notifikasi terkait aktivitas Anda akan muncul di sini.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subTextColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchNotifications,
                              color: activeTeal,
                              child: ListView.separated(
                                itemCount: _notifications.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
                                itemBuilder: (context, index) {
                                  final notif = _notifications[index];
                                  final isUnread = !notif.isRead;
                                  final typeColor = _getTypeColor(notif.type);
                                  
                                  final displayTitle = lang == 'en'
                                      ? (notif.title.contains('Peringatan Polusi Udara')
                                          ? '⚠️ Air Pollution Warning'
                                          : (notif.title.contains('Status Laporan Diperbarui')
                                              ? '✅ Report Status Updated'
                                              : (notif.title.contains('Edukasi Lingkungan Baru')
                                                  ? '🎓 New Environmental Education'
                                                  : notif.title)))
                                      : notif.title;
                                  final displayBody = lang == 'en'
                                      ? (notif.body.contains('Kualitas udara di dekat Anda berada dalam kategori Tidak Sehat (AQI: 158). Disarankan memakai masker jika beraktivitas di luar.')
                                          ? 'Air quality near you is in the Unhealthy category (AQI: 158). It is recommended to wear a mask if doing outdoor activities.'
                                          : (notif.body.contains('Kabar baik! Laporan Anda mengenai')
                                              ? notif.body.replaceAll('Kabar baik! Laporan Anda mengenai', 'Good news! Your report regarding').replaceAll('telah selesai ditindaklanjuti oleh petugas lapangan.', 'has been resolved by field officers.')
                                              : (notif.body.contains('Artikel baru diterbitkan:')
                                                  ? notif.body.replaceAll('Artikel baru diterbitkan:', 'New article published:').replaceAll('Pelajari cara menjaga lingkungan di sekitar kita sekarang!', 'Learn how to protect our environment now!')
                                                  : notif.body)))
                                      : notif.body;

                                  return Dismissible(
                                    key: Key(notif.id ?? index.toString()),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (direction) => _deleteNotification(notif, index),
                                    child: InkWell(
                                      onTap: () => _onNotificationTap(notif),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isUnread 
                                              ? (isDark ? const Color(0xFF1E293B) : Colors.teal.shade50.withValues(alpha: 0.3))
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ICON COLUMN
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: typeColor.withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _getTypeIcon(notif.type),
                                                color: typeColor,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),

                                            // TEXT CONTENT COLUMN
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          displayTitle,
                                                          style: TextStyle(
                                                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                                            color: textColor,
                                                            fontSize: 14,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (isUnread)
                                                        Container(
                                                          width: 7,
                                                          height: 7,
                                                          margin: const EdgeInsets.only(left: 8),
                                                          decoration: BoxDecoration(
                                                            color: activeTeal,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    displayBody,
                                                    style: TextStyle(
                                                      color: isUnread ? textColor.withValues(alpha: 0.9) : subTextColor,
                                                      fontSize: 12.5,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatDateString(notif.tanggal),
                                                    style: TextStyle(
                                                      color: subTextColor.withValues(alpha: 0.8),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
