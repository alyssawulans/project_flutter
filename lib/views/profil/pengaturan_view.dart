import 'package:flutter/material.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/config/app_translations.dart';
import 'package:project_flutter/config/debug_config.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/views/auth/admin_register_view.dart';
import 'package:project_flutter/views/admin/database_viewer_view.dart';
import 'package:project_flutter/views/core/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanView extends StatefulWidget {
  const PengaturanView({super.key});

  @override
  State<PengaturanView> createState() => _PengaturanViewState();
}

class _PengaturanViewState extends State<PengaturanView> {
  bool _notifikasiStatus = true;

  // User Profile Data (for account info popup)
  String _userName = 'Andi Pratama';
  String _userEmail = 'andi.pratama@gmail.com';
  String _userPhone = '081234567890';
  String _joinDate = '24 Sep 2023';
  String _userRole = 'user';

  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userFirestoreId = prefs.getString('current_user_firestore_id');
    final user = userFirestoreId != null ? await FirebaseAuthService.instance.getUser(userFirestoreId) : null;

    if (mounted && user != null) {
      setState(() {
        _userName = user.nama;
        _userEmail = user.email;
        _userPhone = user.nomorTelp;
        _joinDate = user.tanggalDaftar;
        _userRole = user.role;
      });
    }
  }

  void _showAccountInfo() {
    final settings = AppSettingsController.instance.settingsNotifier.value;
    final lang = settings.languageCode;
    final isDark = settings.themeMode == ThemeMode.dark;

    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color rowBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color rowBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                Icons.badge_rounded,
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
                    AppTranslations.translate('account_info_title', lang),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTranslations.translate('account_info_desc', lang),
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.person_rounded,
                    AppTranslations.translate('account_name', lang),
                    _userName,
                    rowBg,
                    rowBorder,
                    textColor,
                    subTextColor,
                  ),
                  _buildInfoRow(
                    Icons.email_rounded,
                    AppTranslations.translate('account_email', lang),
                    _userEmail,
                    rowBg,
                    rowBorder,
                    textColor,
                    subTextColor,
                  ),
                  _buildInfoRow(
                    Icons.phone_android_rounded,
                    AppTranslations.translate('account_phone', lang),
                    _userPhone,
                    rowBg,
                    rowBorder,
                    textColor,
                    subTextColor,
                  ),
                  _buildInfoRow(
                    Icons.calendar_month_rounded,
                    AppTranslations.translate('account_join', lang),
                    _joinDate,
                    rowBg,
                    rowBorder,
                    textColor,
                    subTextColor,
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
                          AppTranslations.translate('close', lang),
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color rowBg,
    Color rowBorder,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rowBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeTeal, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final settings = AppSettingsController.instance.settingsNotifier.value;
    final lang = settings.languageCode;
    final isDark = settings.themeMode == ThemeMode.dark;

    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color inputBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color inputBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                        AppTranslations.translate('change_password', lang),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppTranslations.translate('change_password_desc', lang),
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: inputBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: AppTranslations.translate(
                              'change_password_label',
                              lang,
                            ),
                            labelStyle: TextStyle(
                              color: subTextColor,
                              fontSize: 13,
                            ),
                            hintText: AppTranslations.translate(
                              'change_password_hint',
                              lang,
                            ),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF475569)
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
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                ),
                                foregroundColor: subTextColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                AppTranslations.translate('cancel', lang),
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
                                if (passwordController.text.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppTranslations.translate(
                                          'change_password_error',
                                          lang,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final userFirestoreId =
                                    prefs.getString('current_user_firestore_id');

                                if (userFirestoreId != null) {
                                  await FirebaseAuthService.instance.updateUserPassword(
                                    userFirestoreId,
                                    passwordController.text,
                                  );
                                }

                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppTranslations.translate(
                                          'change_password_success',
                                          lang,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF0D9488),
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
                                AppTranslations.translate('save', lang),
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

  void _showPrivacyInfo() {
    final settings = AppSettingsController.instance.settingsNotifier.value;
    final lang = settings.languageCode;
    final isDark = settings.themeMode == ThemeMode.dark;

    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color containerBg = isDark
        ? const Color(0xFF0F2625)
        : const Color(0xFFEFF6F5);
    final Color containerBorder = isDark
        ? const Color(0xFF134E4A)
        : const Color(0xFFCCECE7);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                Icons.security_rounded,
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
                    AppTranslations.translate('privacy_policy_title', lang),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: containerBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: containerBorder),
                    ),
                    child: Text(
                      AppTranslations.translate('privacy_policy_desc', lang),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          AppTranslations.translate('privacy_policy_btn', lang),
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

  void _logout() async {
    final settings = AppSettingsController.instance.settingsNotifier.value;
    final lang = settings.languageCode;
    final isDark = settings.themeMode == ThemeMode.dark;

    final Color dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                      AppTranslations.translate('logout_confirm_title', lang),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppTranslations.translate('logout_confirm_desc', lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
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
                              foregroundColor: subTextColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              AppTranslations.translate('cancel', lang),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                            child: Text(
                              AppTranslations.translate('logout_btn', lang),
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
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('current_user_name');
      await prefs.remove('current_user_email');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashView()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToRegisterAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminRegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, child) {
        final lang = settings.languageCode;
        final isDark = settings.themeMode == ThemeMode.dark;

        final Color bgColor = isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC);
        final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color textColor = isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF0F172A);
        final Color subTextColor = isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);
        final Color borderColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFF1F5F9);

        // Map language name
        final String currentLangLabel = settings.languageCode == 'id'
            ? 'Bahasa Indonesia'
            : 'English';
        final String currentThemeLabel = settings.themeMode == ThemeMode.dark
            ? AppTranslations.translate('theme_dark', lang)
            : AppTranslations.translate('theme_light', lang);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: cardColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              AppTranslations.translate('settings_title', lang),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              children: [
                // 1. Akun Section
                Text(
                  AppTranslations.translate('account', lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        Icons.person_outline_rounded,
                        AppTranslations.translate('account_info', lang),
                        textColor,
                        onTap: _showAccountInfo,
                      ),
                      Divider(height: 1, color: borderColor),
                      _buildMenuTile(
                        Icons.lock_outline_rounded,
                        AppTranslations.translate('change_password', lang),
                        textColor,
                        onTap: _changePassword,
                      ),
                      Divider(height: 1, color: borderColor),
                      _buildMenuTile(
                        Icons.lock_person_outlined,
                        AppTranslations.translate('privacy', lang),
                        textColor,
                        onTap: _showPrivacyInfo,
                      ),
                      if (_userRole == 'admin') ...[
                        Divider(height: 1, color: borderColor),
                        _buildMenuTile(
                          Icons.admin_panel_settings_outlined,
                          "Daftarkan Admin Baru",
                          textColor,
                          onTap: _navigateToRegisterAdmin,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Preferensi Section
                Text(
                  AppTranslations.translate('preferences', lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Bahasa selector
                      ListTile(
                        leading: Icon(
                          Icons.language_rounded,
                          color: activeTeal,
                          size: 22,
                        ),
                        title: Text(
                          AppTranslations.translate('language', lang),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentLangLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () => _showBahasaPicker(
                          context,
                          settings.languageCode,
                          lang,
                        ),
                      ),
                      Divider(height: 1, color: borderColor),

                      Divider(height: 1, color: borderColor),
                      // Notifikasi toggle
                      SwitchListTile(
                        activeThumbColor: Colors.white,
                        activeTrackColor: activeTeal,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        title: Text(
                          AppTranslations.translate('notifications', lang),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        secondary: Icon(
                          Icons.notifications_none_rounded,
                          color: activeTeal,
                          size: 22,
                        ),
                        value: _notifikasiStatus,
                        onChanged: (bool value) {
                          setState(() {
                            _notifikasiStatus = value;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _notifikasiStatus
                                    ? (lang == 'id'
                                          ? 'Notifikasi diaktifkan'
                                          : 'Notifications enabled')
                                    : (lang == 'id'
                                          ? 'Notifikasi dimatikan'
                                          : 'Notifications disabled'),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: activeTeal,
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      // Mode Gelap toggle
                      SwitchListTile(
                        activeThumbColor: Colors.white,
                        activeTrackColor: activeTeal,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        title: Text(
                          AppTranslations.translate('dark_mode', lang),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        secondary: Icon(
                          Icons.dark_mode_outlined,
                          color: activeTeal,
                          size: 22,
                        ),
                        value: settings.themeMode == ThemeMode.dark,
                        onChanged: (bool value) {
                          AppSettingsController.instance.updateTheme(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? (lang == 'id'
                                          ? 'Mode Gelap diaktifkan'
                                          : 'Dark Mode enabled')
                                    : (lang == 'id'
                                          ? 'Mode Gelap dimatikan'
                                          : 'Dark Mode disabled'),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: activeTeal,
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      // Font Size selector
                      ListTile(
                        leading: Icon(
                          Icons.format_size_rounded,
                          color: activeTeal,
                          size: 22,
                        ),
                        title: Text(
                          AppTranslations.translate('font_size', lang),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getFontSizeLabel(
                                settings.fontSizeMultiplier,
                                lang,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () => _showFontSizePicker(
                          context,
                          settings.fontSizeMultiplier,
                          lang,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Lainnya Section
                Text(
                  AppTranslations.translate('others', lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (DebugConfig.showDatabaseViewer &&
                          _userRole == 'admin') ...[
                        _buildMenuTile(
                          Icons.storage_rounded,
                          'SQLite Database Viewer',
                          textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DatabaseViewerView(),
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, color: borderColor),
                      ],
                      _buildMenuTile(
                        Icons.help_outline_rounded,
                        AppTranslations.translate('help_faq', lang),
                        textColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                lang == 'id'
                                    ? 'Bantuan: hubungi support@ruas.id'
                                    : 'Help: contact support@ruas.id',
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      ListTile(
                        leading: Icon(
                          Icons.info_outline_rounded,
                          color: activeTeal,
                          size: 22,
                        ),
                        title: Text(
                          AppTranslations.translate('about_app', lang),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'RUAS v1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () {
                          final settings = AppSettingsController
                              .instance
                              .settingsNotifier
                              .value;
                          final lang = settings.languageCode;
                          final isDark = settings.themeMode == ThemeMode.dark;

                          final Color dialogBg = isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white;
                          final Color textColor = isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF0F172A);
                          final Color subTextColor = isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B);
                          final Color containerBg = isDark
                              ? const Color(0xFF0F2625)
                              : const Color(0xFFEFF6F5);
                          final Color containerBorder = isDark
                              ? const Color(0xFF134E4A)
                              : const Color(0xFFCCECE7);

                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              clipBehavior: Clip.antiAlias,
                              backgroundColor: dialogBg,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header Gradient Banner with decorative shapes
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [activeTeal, primaryTeal],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
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
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.air_rounded,
                                                        color: Colors.white,
                                                        size: 48,
                                                      ),
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                'RUAS',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              const Text(
                                                'Ruang Napas Untuk Semua',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Description Card
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: containerBg,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: containerBorder,
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.spa_rounded,
                                                  color: activeTeal,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    AppTranslations.translate(
                                                      'about_app_desc',
                                                      lang,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      height: 1.5,
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            AppTranslations.translate(
                                              'about_app_features',
                                              lang,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: activeTeal,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Feature Rows inline
                                          _buildFeatureRow(
                                            Icons.map_rounded,
                                            isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFE0F2FE),
                                            Colors.blue,
                                            AppTranslations.translate(
                                              'about_app_feature1_title',
                                              lang,
                                            ),
                                            AppTranslations.translate(
                                              'about_app_feature1_desc',
                                              lang,
                                            ),
                                            textColor,
                                            subTextColor,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildFeatureRow(
                                            Icons.campaign_rounded,
                                            isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFFEF3C7),
                                            Colors.amber[800]!,
                                            AppTranslations.translate(
                                              'about_app_feature2_title',
                                              lang,
                                            ),
                                            AppTranslations.translate(
                                              'about_app_feature2_desc',
                                              lang,
                                            ),
                                            textColor,
                                            subTextColor,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildFeatureRow(
                                            Icons.menu_book_rounded,
                                            isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFEFF6F5),
                                            primaryTeal,
                                            AppTranslations.translate(
                                              'about_app_feature3_title',
                                              lang,
                                            ),
                                            AppTranslations.translate(
                                              'about_app_feature3_desc',
                                              lang,
                                            ),
                                            textColor,
                                            subTextColor,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildFeatureRow(
                                            Icons.quiz_rounded,
                                            isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFFCE7F3),
                                            Colors.pink,
                                            AppTranslations.translate(
                                              'about_app_feature4_title',
                                              lang,
                                            ),
                                            AppTranslations.translate(
                                              'about_app_feature4_desc',
                                              lang,
                                            ),
                                            textColor,
                                            subTextColor,
                                          ),
                                          const SizedBox(height: 24),
                                          // App Metadata
                                          Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Versi 1.0.0 (Final Project)',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: subTextColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  AppTranslations.translate(
                                                    'about_app_footer',
                                                    lang,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: activeTeal,
                                                    fontWeight: FontWeight.w600,
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
                                                  Navigator.pop(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: activeTeal,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                AppTranslations.translate(
                                                  'close',
                                                  lang,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Logout Tile Button
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 22,
                    ),
                    title: Text(
                      AppTranslations.translate('logout', lang),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFCA5A5),
                      size: 20,
                    ),
                    onTap: _logout,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    Color textColor, {
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: activeTeal, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showBahasaPicker(
    BuildContext context,
    String currentLang,
    String lang,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: const Text(
                'Bahasa Indonesia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentLang == 'id'
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateLanguage('id');
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text(
                'English',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentLang == 'en'
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateLanguage('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showTemaPicker(
    BuildContext context,
    ThemeMode currentMode,
    String lang,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                AppTranslations.translate('theme_light', lang),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentMode == ThemeMode.light
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                AppTranslations.translate('theme_dark', lang),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentMode == ThemeMode.dark
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showFontSizePicker(
    BuildContext context,
    double currentMultiplier,
    String lang,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                AppTranslations.translate('font_size_small', lang),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentMultiplier == 0.85
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateFontSize(0.85);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                AppTranslations.translate('font_size_medium', lang),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentMultiplier == 1.0
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateFontSize(1.0);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                AppTranslations.translate('font_size_large', lang),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: currentMultiplier == 1.15
                  ? Icon(Icons.check_circle, color: activeTeal)
                  : null,
              onTap: () {
                AppSettingsController.instance.updateFontSize(1.15);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getFontSizeLabel(double multiplier, String lang) {
    if (multiplier == 0.85) {
      return AppTranslations.translate('font_size_small', lang);
    } else if (multiplier == 1.15) {
      return AppTranslations.translate('font_size_large', lang);
    } else {
      return AppTranslations.translate('font_size_medium', lang);
    }
  }

  Widget _buildFeatureRow(
    IconData icon,
    Color bgColor,
    Color iconColor,
    String title,
    String desc,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
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
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: subTextColor,
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
