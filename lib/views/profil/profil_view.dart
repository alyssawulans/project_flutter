import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/views/profil/pengaturan_view.dart';
import 'package:project_flutter/views/profil/notification_list_view.dart';
import 'package:project_flutter/views/core/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilView extends StatefulWidget {
  const ProfilView({super.key});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  String _userName = 'Andi Pratama';
  String _userEmail = 'andi.pratama@gmail.com';
  String? _profilePhotoPath;
  int _laporanCount = 0;
  int _laporanDiprosesCount = 0;
  int _laporanSelesaiCount = 0;
  bool _isLoading = true;

  String _ecoStarterTier = 'Bronze';
  String _greenReporterTier = 'Locked';
  String _airGuardianTier = 'Locked';

  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id') ?? 1;
    final userFirestoreId = prefs.getString('current_user_firestore_id');

    final user = userFirestoreId != null
        ? await FirebaseAuthService.instance.getUser(userFirestoreId)
        : null;
    final allLaporan = await FirebaseAuthService.instance.getLaporans(
      userFirestoreId: userFirestoreId,
    );
    final lCount = allLaporan.length;
    final lDiproses = allLaporan
        .where((l) => l.status.toLowerCase() == 'diproses')
        .length;
    final lSelesai = allLaporan
        .where(
          (l) =>
              l.status.toLowerCase() == 'selesai' ||
              l.status.toLowerCase() == 'selesay',
        )
        .length;

    // 1. Eco Starter:
    String ecoStarter = 'Bronze';
    if (user != null) {
      final bool isProfileComplete =
          user.tempatLahir.isNotEmpty && user.tanggalLahir.isNotEmpty;
      if (isProfileComplete) {
        if (lCount >= 3) {
          ecoStarter = 'Gold';
        } else {
          ecoStarter = 'Silver';
        }
      }
    }

    // 2. Green Reporter:
    String greenReporter = 'Locked';
    if (lCount >= 5) {
      greenReporter = 'Gold';
    } else if (lCount >= 3) {
      greenReporter = 'Silver';
    } else if (lCount >= 1) {
      greenReporter = 'Bronze';
    }

    // 3. Air Guardian:
    final readKey = 'read_articles_$userId';
    final readList = prefs.getStringList(readKey) ?? [];
    final readCount = readList.length;

    String airGuardian = 'Locked';
    if (readCount >= 5) {
      airGuardian = 'Gold';
    } else if (readCount >= 3) {
      airGuardian = 'Silver';
    } else if (readCount >= 1) {
      airGuardian = 'Bronze';
    }

    if (mounted) {
      setState(() {
        if (user != null) {
          _userName = user.nama;
          _userEmail = user.email;
        }
        _profilePhotoPath = prefs.getString('profile_photo_$userId');
        _laporanCount = lCount;
        _laporanDiprosesCount = lDiproses;
        _laporanSelesaiCount = lSelesai;
        _ecoStarterTier = ecoStarter;
        _greenReporterTier = greenReporter;
        _airGuardianTier = airGuardian;
        _isLoading = false;
      });
    }
  }

  Color _getTopBadgeColor(String eco, String reporter, String guardian) {
    if (reporter == 'Gold' || guardian == 'Gold' || eco == 'Gold') {
      return const Color(0xFFD97706); // Amber Gold
    }
    if (reporter == 'Silver' || guardian == 'Silver' || eco == 'Silver') {
      return const Color(0xFF475569); // Slate Silver
    }
    return const Color(0xFFB45309); // Bronze
  }

  String _getRankName(String eco, String reporter, String guardian) {
    int score = 0;
    if (eco == 'Gold') {
      score += 3;
    } else if (eco == 'Silver') {
      score += 2;
    } else if (eco == 'Bronze') {
      score += 1;
    }

    if (reporter == 'Gold') {
      score += 3;
    } else if (reporter == 'Silver') {
      score += 2;
    } else if (reporter == 'Bronze') {
      score += 1;
    }

    if (guardian == 'Gold') {
      score += 3;
    } else if (guardian == 'Silver') {
      score += 2;
    } else if (guardian == 'Bronze') {
      score += 1;
    }

    if (score >= 8) return 'Gold Guardian';
    if (score >= 5) return 'Silver Volunteer';
    return 'Eco Starter';
  }

  Color _getBadgeDetailBgColor(String tier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      switch (tier) {
        case 'Gold':
          return const Color(0xFFD97706).withOpacity(0.15);
        case 'Silver':
          return const Color(0xFF475569).withOpacity(0.15);
        case 'Bronze':
          return const Color(0xFFB45309).withOpacity(0.15);
        default:
          return const Color(0xFF1E293B);
      }
    }
    switch (tier) {
      case 'Gold':
        return const Color(0xFFFFFBEB);
      case 'Silver':
        return const Color(0xFFF8FAFC);
      case 'Bronze':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getBadgeDetailBorderColor(String tier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      switch (tier) {
        case 'Gold':
          return const Color(0xFFFDE68A).withOpacity(0.3);
        case 'Silver':
          return const Color(0xFFE2E8F0).withOpacity(0.3);
        case 'Bronze':
          return const Color(0xFFFED7AA).withOpacity(0.3);
        default:
          return const Color(0xFF334155);
      }
    }
    switch (tier) {
      case 'Gold':
        return const Color(0xFFFDE68A);
      case 'Silver':
        return const Color(0xFFE2E8F0);
      case 'Bronze':
        return const Color(0xFFFED7AA);
      default:
        return const Color(0xFFCBD5E1);
    }
  }

  void _showEditProfileDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final userFirestoreId = prefs.getString('current_user_firestore_id');
    final user = userFirestoreId != null
        ? await FirebaseAuthService.instance.getUser(userFirestoreId)
        : null;
    if (user == null) return;

    final namaController = TextEditingController(text: user.nama);
    final telpController = TextEditingController(text: user.nomorTelp);
    final tempatLahirController = TextEditingController(text: user.tempatLahir);
    String selectedTanggalLahir = user.tanggalLahir;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final lang = AppSettingsController
              .instance
              .settingsNotifier
              .value
              .languageCode;
          final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            backgroundColor: dialogBg,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [activeTeal, primaryTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == 'en' ? 'Edit Profile' : 'Edit Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lang == 'en'
                              ? 'Update your personal information to complete your profile and level up badges.'
                              : 'Perbarui informasi pribadi Anda untuk melengkapi profil dan meningkatkan lencana.',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildInputField(
                          lang == 'en' ? 'Full Name' : 'Nama Lengkap',
                          namaController,
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          lang == 'en' ? 'Phone Number' : 'Nomor Telepon',
                          telpController,
                          Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          lang == 'en' ? 'Place of Birth' : 'Tempat Lahir',
                          tempatLahirController,
                          Icons.location_city_outlined,
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () async {
                            final initialDate = selectedTanggalLahir.isNotEmpty
                                ? (DateFormat(
                                        'dd MMM yyyy',
                                        'id_ID',
                                      ).tryParse(selectedTanggalLahir) ??
                                      DateTime.now())
                                : DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: isDark
                                        ? ColorScheme.dark(
                                            primary: activeTeal,
                                            onPrimary: Colors.white,
                                            surface: const Color(0xFF1E293B),
                                            onSurface: Colors.white,
                                          )
                                        : ColorScheme.light(
                                            primary: activeTeal,
                                            onPrimary: Colors.white,
                                            onSurface: textDark,
                                          ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedTanggalLahir = DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(picked);
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang == 'en'
                                            ? 'Date of Birth'
                                            : 'Tanggal Lahir',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedTanggalLahir.isNotEmpty
                                            ? selectedTanggalLahir
                                            : (lang == 'en'
                                                  ? 'Select Date of Birth'
                                                  : 'Pilih Tanggal Lahir'),
                                        style: TextStyle(
                                          color: selectedTanggalLahir.isNotEmpty
                                              ? (isDark
                                                    ? const Color(0xFFF8FAFC)
                                                    : textDark)
                                              : const Color(0xFF94A3B8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  foregroundColor: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  lang == 'en' ? 'Cancel' : 'Batal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (namaController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          lang == 'en'
                                              ? 'Name cannot be empty'
                                              : 'Nama tidak boleh kosong',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  await FirebaseAuthService.instance
                                      .updateUserProfile(
                                        userFirestoreId!,
                                        namaController.text.trim(),
                                        telpController.text.trim(),
                                        tempatLahir: tempatLahirController.text
                                            .trim(),
                                        tanggalLahir: selectedTanggalLahir,
                                      );

                                  await prefs.setString(
                                    'current_user_name',
                                    namaController.text.trim(),
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _loadUserProfile();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          lang == 'en'
                                              ? 'Profile updated successfully'
                                              : 'Profil berhasil diperbarui',
                                        ),
                                        backgroundColor: const Color(
                                          0xFF0D9488,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: activeTeal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  lang == 'en' ? 'Save' : 'Simpan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldBgColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color fieldBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final Color textValueColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color labelColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: fieldBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fieldBorderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textValueColor),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey, size: 20),
          labelText: label,
          labelStyle: TextStyle(color: labelColor, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _changePassword() {
    final oldPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscureOldPassword = true;
    bool obscurePassword = true;
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final lang = AppSettingsController
              .instance
              .settingsNotifier
              .value
              .languageCode;
          final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            backgroundColor: dialogBg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Gradient Banner
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [activeTeal, primaryTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'en' ? 'Change Password' : 'Ubah Kata Sandi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF8FAFC) : textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang == 'en'
                            ? 'Enter your old password first to verify account ownership before updating it.'
                            : 'Masukkan kata sandi lama Anda terlebih dahulu untuk memverifikasi kepemilikan akun sebelum memperbaruinya.',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Kata Sandi Lama
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: oldPasswordController,
                          obscureText: obscureOldPassword,
                          enabled: !isProcessing,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            labelText: lang == 'en'
                                ? 'Old Password'
                                : 'Kata Sandi Lama',
                            labelStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            hintText: lang == 'en'
                                ? 'Enter current password'
                                : 'Masukkan kata sandi saat ini',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureOldPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscureOldPassword = !obscureOldPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Kata Sandi Baru
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          enabled: !isProcessing,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            labelText: lang == 'en'
                                ? 'New Password'
                                : 'Kata Sandi Baru',
                            labelStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            hintText: lang == 'en'
                                ? 'Minimum 6 characters'
                                : 'Minimal 6 karakter',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                ),
                                foregroundColor: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                lang == 'en' ? 'Cancel' : 'Batal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () async {
                                      if (oldPasswordController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              lang == 'en'
                                                  ? 'Old password cannot be empty'
                                                  : 'Kata sandi lama tidak boleh kosong',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      if (passwordController.text.length < 6) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              lang == 'en'
                                                  ? 'New password must be at least 6 characters'
                                                  : 'Kata sandi baru minimal 6 karakter',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setDialogState(() {
                                        isProcessing = true;
                                      });

                                      try {
                                        await FirebaseAuthService.instance
                                            .reauthenticateAndUpdatePassword(
                                              oldPasswordController.text,
                                              passwordController.text,
                                            );

                                        if (mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                lang == 'en'
                                                    ? 'Password updated successfully'
                                                    : 'Kata sandi berhasil diperbarui',
                                              ),
                                              backgroundColor: const Color(
                                                0xFF0D9488,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setDialogState(() {
                                            isProcessing = false;
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                lang == 'en'
                                                    ? 'Incorrect old password or failed to update: $e'
                                                    : 'Kata sandi lama salah atau gagal memperbarui: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isProcessing
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      lang == 'en' ? 'Update' : 'Perbarui',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
          );
        },
      ),
    );
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          backgroundColor: dialogBg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Warning Banner
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      "Keluar Aplikasi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Apakah Anda yakin ingin keluar dari akun RUAS Anda?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                              foregroundColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Keluar",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        );
      },
    );
    if (confirm == true) {
      await FirebaseAuthService.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('current_user_name');
      await prefs.remove('current_user_email');
      await prefs.remove('current_user_firestore_id');
      await prefs.remove('current_user_role');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashView()),
          (route) => false,
        );
      }
    }
  }

  void _showAllBadgesInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang =
        AppSettingsController.instance.settingsNotifier.value.languageCode;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFBBF24), activeTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'en'
                        ? 'Achievement Badges List'
                        : 'Daftar Lencana Pencapaian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF8FAFC) : textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang == 'en'
                        ? 'Badges you can unlock by participating in environmental preservation:'
                        : 'Lencana yang dapat Anda buka dengan berpartisipasi menjaga lingkungan:',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBadgeDetailItem(
                    image: 'assets/images/project_akhir/badge_1.png',
                    title: 'Eco Starter',
                    desc: lang == 'en'
                        ? 'Has joined the RUAS application to preserve the environment.'
                        : 'Telah bergabung dengan aplikasi RUAS untuk menjaga kelestarian lingkungan.',
                    bgColor: _getBadgeDetailBgColor(_ecoStarterTier),
                    borderColor: _getBadgeDetailBorderColor(_ecoStarterTier),
                    statusText: _ecoStarterTier == 'Locked'
                        ? (lang == 'en' ? 'Locked' : 'Terkunci')
                        : (lang == 'en'
                              ? 'Level: $_ecoStarterTier'
                              : 'Level: $_ecoStarterTier'),
                    isLocked: _ecoStarterTier == 'Locked',
                  ),
                  _buildBadgeDetailItem(
                    image: 'assets/images/project_akhir/badge_2.png',
                    title: 'Green Reporter',
                    desc: lang == 'en'
                        ? 'Submitting reports regarding pollution or waste in the surrounding environment.'
                        : 'Mengirimkan laporan mengenai polusi atau sampah lingkungan sekitar.',
                    bgColor: _getBadgeDetailBgColor(_greenReporterTier),
                    borderColor: _getBadgeDetailBorderColor(_greenReporterTier),
                    statusText: _greenReporterTier == 'Locked'
                        ? (lang == 'en' ? 'Locked' : 'Terkunci')
                        : (lang == 'en'
                              ? 'Level: $_greenReporterTier'
                              : 'Level: $_greenReporterTier'),
                    isLocked: _greenReporterTier == 'Locked',
                  ),
                  _buildBadgeDetailItem(
                    image: 'assets/images/project_akhir/badge_3.png',
                    title: 'Air Guardian',
                    desc: lang == 'en'
                        ? 'Reading educational articles & monitoring the air quality index.'
                        : 'Membaca artikel edukasi & memantau indeks kualitas udara.',
                    bgColor: _getBadgeDetailBgColor(_airGuardianTier),
                    borderColor: _getBadgeDetailBorderColor(_airGuardianTier),
                    statusText: _airGuardianTier == 'Locked'
                        ? (lang == 'en' ? 'Locked' : 'Terkunci')
                        : (lang == 'en'
                              ? 'Level: $_airGuardianTier'
                              : 'Level: $_airGuardianTier'),
                    isLocked: _airGuardianTier == 'Locked',
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          lang == 'en' ? 'Close' : 'Tutup',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeDetailItem({
    required String image,
    required String title,
    required String desc,
    required Color bgColor,
    required Color borderColor,
    required String statusText,
    required bool isLocked,
  }) {
    Color statusColor;
    if (statusText.contains('Gold')) {
      statusColor = const Color(0xFFD97706);
    } else if (statusText.contains('Silver')) {
      statusColor = const Color(0xFF475569);
    } else if (statusText.contains('Bronze')) {
      statusColor = const Color(0xFFB45309);
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          ColorFiltered(
            colorFilter: isLocked
                ? const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ])
                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: Image.asset(
              image,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.stars,
                color: isLocked ? Colors.grey : statusColor,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF8FAFC)
                            : textDark,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey[300]
                            : statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: isLocked ? Colors.grey[600] : statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 400,
      );

      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('current_user_id') ?? 1;
        await prefs.setString('profile_photo_$userId', image.path);

        setState(() {
          _profilePhotoPath = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diubah!'),
              backgroundColor: Color(0xFF0D9488),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D9488)),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF0D9488),
              ),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profilePhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Foto Profil'),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('current_user_id') ?? 1;
                  await prefs.remove('profile_photo_$userId');
                  setState(() {
                    _profilePhotoPath = null;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto profil dihapus.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_profilePhotoPath != null) {
      if (_profilePhotoPath!.startsWith('assets/')) {
        return Image.asset(
          _profilePhotoPath!,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 38, color: Color(0xFF0D9488)),
        );
      } else {
        return Image.file(
          File(_profilePhotoPath!),
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 38, color: Color(0xFF0D9488)),
        );
      }
    }
    return Image.asset(
      'assets/images/profile.png',
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person, size: 38, color: Color(0xFF0D9488)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        final lang = settings.languageCode;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final Color bgColor = isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC);
        final Color appBarBgColor = isDark
            ? const Color(0xFF1E293B)
            : Colors.white;
        final Color cardBgColor = isDark
            ? const Color(0xFF1E293B)
            : Colors.white;
        final Color textColor = isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF0F172A);
        final Color subTextColor = isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);
        final Color borderColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFF1F5F9);
        final Color dividerColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFF1F5F9);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: appBarBgColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Profil',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: textColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengaturanView(),
                    ),
                  ).then((_) => _loadUserProfile());
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  color: activeTeal,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Profil Saya Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang == 'en' ? 'My Profile' : 'Profil Saya',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Avatar Stack with Verified Badge & Edit Button
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: _showImageSourcePicker,
                                        child: CircleAvatar(
                                          radius: 38,
                                          backgroundColor: isDark
                                              ? const Color(0xFF0F4C43)
                                              : const Color(0xFFE2F1ED),
                                          child: ClipOval(
                                            child: _buildProfileImage(),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: GestureDetector(
                                          onTap: _showImageSourcePicker,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0D9488),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 18),
                                  // Name & Email
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _userEmail,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: subTextColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getTopBadgeColor(
                                              _ecoStarterTier,
                                              _greenReporterTier,
                                              _airGuardianTier,
                                            ).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified_rounded,
                                                size: 12,
                                                color: _getTopBadgeColor(
                                                  _ecoStarterTier,
                                                  _greenReporterTier,
                                                  _airGuardianTier,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                lang == 'en'
                                                    ? 'Rank: ${_getRankName(_ecoStarterTier, _greenReporterTier, _airGuardianTier)}'
                                                    : 'Pangkat: ${_getRankName(_ecoStarterTier, _greenReporterTier, _airGuardianTier)}',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: _getTopBadgeColor(
                                                    _ecoStarterTier,
                                                    _greenReporterTier,
                                                    _airGuardianTier,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Divider(color: dividerColor, height: 1),
                              const SizedBox(height: 16),
                              // Stats row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildMockupStatCol(
                                    lang == 'en'
                                        ? 'Total Reports'
                                        : 'Total Laporan',
                                    '$_laporanCount',
                                  ),
                                  _buildMockupDivider(),
                                  _buildMockupStatCol(
                                    lang == 'en'
                                        ? 'Reports In Progress'
                                        : 'Laporan Diproses',
                                    '$_laporanDiprosesCount',
                                  ),
                                  _buildMockupDivider(),
                                  _buildMockupStatCol(
                                    lang == 'en'
                                        ? 'Reports Completed'
                                        : 'Laporan Selesai',
                                    '$_laporanSelesaiCount',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Badge Saya Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'en' ? 'My Badges' : 'Badge Saya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: _showAllBadgesInfo,
                              child: Text(
                                lang == 'en' ? 'View All' : 'Lihat Semua',
                                style: TextStyle(
                                  color: activeTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMockupBadgeItem(
                              image: 'assets/images/project_akhir/badge_1.png',
                              label: 'Eco Starter',
                              tier: _ecoStarterTier,
                            ),
                            _buildMockupBadgeItem(
                              image: 'assets/images/project_akhir/badge_2.png',
                              label: 'Green Reporter',
                              tier: _greenReporterTier,
                            ),
                            _buildMockupBadgeItem(
                              image: 'assets/images/project_akhir/badge_3.png',
                              label: 'Air Guardian',
                              tier: _airGuardianTier,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // 3. Menu List Options
                        Container(
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withValues(alpha: 0.01),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuTile(
                                Icons.person_outline_rounded,
                                lang == 'en' ? 'Edit Profile' : 'Edit Profil',
                                onTap: _showEditProfileDialog,
                              ),
                              Divider(height: 1, color: dividerColor),
                              _buildMenuTile(
                                Icons.notifications_none_rounded,
                                lang == 'en' ? 'Notifications' : 'Notifikasi',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationListView(),
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, color: dividerColor),
                              _buildMenuTile(
                                Icons.lock_outline_rounded,
                                lang == 'en'
                                    ? 'Change Password'
                                    : 'Ubah Kata Sandi',
                                onTap: _changePassword,
                              ),
                              Divider(height: 1, color: dividerColor),
                              _buildMenuTile(
                                Icons.info_outline_rounded,
                                lang == 'en' ? 'About App' : 'Tentang Aplikasi',
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final isDark =
                                          Theme.of(context).brightness ==
                                          Brightness.dark;
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        backgroundColor: isDark
                                            ? const Color(0xFF1E293B)
                                            : Colors.white,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Header Gradient Banner with decorative shapes
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      activeTeal,
                                                      primaryTeal,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 28,
                                                    ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/logo_ruas.png',
                                                          height: 72,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      12,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: const Icon(
                                                                  Icons
                                                                      .air_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 48,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        const Text(
                                                          'RUAS',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            letterSpacing: 1.5,
                                                          ),
                                                        ),
                                                        Text(
                                                          lang == 'en'
                                                              ? 'Breathing Space for All'
                                                              : 'Ruang Napas Untuk Semua',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  24.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Description Card
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF0D9488,
                                                              ).withOpacity(
                                                                0.15,
                                                              )
                                                            : const Color(
                                                                0xFFEFF6F5,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        border: Border.all(
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF0D9488,
                                                                ).withOpacity(
                                                                  0.3,
                                                                )
                                                              : const Color(
                                                                  0xFFCCECE7,
                                                                ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.spa_rounded,
                                                            color: activeTeal,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              lang == 'en'
                                                                  ? 'RUAS is an air quality monitoring (AQI), environmental cleanliness reporting, and interactive educational media platform to achieve a healthy and clean Indonesian society.'
                                                                  : 'RUAS adalah platform pemantauan kualitas udara (AQI), pelaporan kebersihan lingkungan, dan media edukasi interaktif untuk mewujudkan masyarakat Indonesia yang sehat dan bersih.',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                height: 1.5,
                                                                color: isDark
                                                                    ? const Color(
                                                                        0xFFF8FAFC,
                                                                      )
                                                                    : textDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      lang == 'en'
                                                          ? 'App Key Features'
                                                          : 'Fitur Utama Aplikasi',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: activeTeal,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Feature Rows inline
                                                    _buildFeatureRow(
                                                      Icons.map_rounded,
                                                      const Color(0xFFE0F2FE),
                                                      Colors.blue,
                                                      lang == 'en'
                                                          ? 'National AQI Map'
                                                          : 'Peta AQI Nasional',
                                                      lang == 'en'
                                                          ? 'Monitor standard air pollution indices updated across Indonesia.'
                                                          : 'Pantau indeks standar pencemar udara terupdate di wilayah Indonesia.',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    _buildFeatureRow(
                                                      Icons.campaign_rounded,
                                                      const Color(0xFFFEF3C7),
                                                      Colors.amber[800]!,
                                                      lang == 'en'
                                                          ? 'Public Reports'
                                                          : 'Laporan Masyarakat',
                                                      lang == 'en'
                                                          ? 'Report air pollution and waste spots in real-time.'
                                                          : 'Laporkan titik polusi udara dan sampah secara real-time.',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    _buildFeatureRow(
                                                      Icons.menu_book_rounded,
                                                      const Color(0xFFEFF6F5),
                                                      primaryTeal,
                                                      lang == 'en'
                                                          ? 'Interactive Education'
                                                          : 'Edukasi Interaktif',
                                                      lang == 'en'
                                                          ? 'Learn cleanliness tips and the health impacts of air quality.'
                                                          : 'Pelajari kiat-kiat kebersihan dan dampak kualitas udara bagi kesehatan.',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    _buildFeatureRow(
                                                      Icons.quiz_rounded,
                                                      const Color(0xFFFCE7F3),
                                                      Colors.pink,
                                                      lang == 'en'
                                                          ? 'Quizzes & Challenges'
                                                          : 'Kuis & Tantangan',
                                                      lang == 'en'
                                                          ? 'Test your environmental knowledge to gain achievement rewards.'
                                                          : 'Uji pengetahuan lingkunganmu untuk mendapatkan reward pencapaian.',
                                                    ),
                                                    const SizedBox(height: 24),
                                                    // App Metadata
                                                    Center(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            lang == 'en'
                                                                ? 'Version 1.0.0'
                                                                : 'Versi 1.0.0',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            lang == 'en'
                                                                ? 'Developed with 💚 by RUAS Team'
                                                                : 'Dikembangkan dengan 💚 oleh Tim RUAS',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: activeTeal,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    // Close Button
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              activeTeal,
                                                          foregroundColor:
                                                              Colors.white,
                                                          elevation: 0,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          lang == 'en'
                                                              ? 'Close'
                                                              : 'Tutup',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildMenuTile(
                                Icons.help_outline_rounded,
                                lang == 'en' ? 'Help' : 'Bantuan',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        lang == 'en'
                                            ? 'Contact alyssawulans@gmail.com for help.'
                                            : 'Hubungi alyssawulans@gmail.com untuk bantuan.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              _buildMenuTile(
                                Icons.logout_rounded,
                                lang == 'en' ? 'Log Out' : 'Keluar',
                                iconColor: Colors.red,
                                textColor: Colors.red,
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMockupDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 32,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildMockupStatCol(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupBadgeItem({
    required String image,
    required String label,
    required String tier,
  }) {
    final bool isLocked = tier == 'Locked';

    Color tierColor;
    switch (tier) {
      case 'Gold':
        tierColor = const Color(0xFFD97706);
        break;
      case 'Silver':
        tierColor = const Color(0xFF475569);
        break;
      case 'Bronze':
        tierColor = const Color(0xFFB45309);
        break;
      default:
        tierColor = Colors.grey;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isLocked
                    ? (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9))
                    : tierColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocked
                      ? (isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFE2E8F0))
                      : tierColor.withValues(alpha: 0.5),
                  width: isLocked ? 1 : 2.5,
                ),
              ),
              child: ColorFiltered(
                colorFilter: isLocked
                    ? const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ])
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Image.asset(
                  image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.stars,
                    color: isLocked ? Colors.grey : tierColor,
                    size: 40,
                  ),
                ),
              ),
            ),
            if (!isLocked)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tier.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFF8FAFC)
                : const Color(0xFF1E293B),
          ),
        ),
        Text(
          isLocked
              ? (AppSettingsController
                            .instance
                            .settingsNotifier
                            .value
                            .languageCode ==
                        'en'
                    ? 'Locked'
                    : 'Terkunci')
              : (AppSettingsController
                            .instance
                            .settingsNotifier
                            .value
                            .languageCode ==
                        'en'
                    ? 'Level: $tier'
                    : 'Tingkat: $tier'),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isLocked
                ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8))
                : tierColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title, {
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveTextColor =
        textColor ??
        (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));
    return ListTile(
      leading: Icon(icon, color: iconColor ?? activeTeal, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: effectiveTextColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFCBD5E1),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    Color bgColor,
    Color iconColor,
    String title,
    String desc,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? iconColor.withOpacity(0.15)
                : bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF8FAFC)
                      : textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF94A3B8)
                      : Colors.grey,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
