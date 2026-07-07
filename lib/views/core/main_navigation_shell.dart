import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/config/app_translations.dart';
import 'package:project_flutter/views/edukasi/edukasi_list_view.dart';
import 'package:project_flutter/views/beranda/home_view.dart';
import 'package:project_flutter/views/laporan/laporan_beranda.dart';
import 'package:project_flutter/views/maps/maps_view.dart';
import 'package:project_flutter/views/profil/profil_view.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('current_user_role') ?? 'user';
    });
  }



  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavItem(
    int index,
    IconData normalIcon,
    IconData selectedIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? const Color(0xFF0D9488) 
        : (isDark ? Colors.white38 : Colors.black38);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? selectedIcon : normalIcon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final lang = settings.languageCode;

        final views = [
          const HomeView(),
          const MapsView(),
          const LaporanBeranda(),
          const EdukasiListView(),
          const ProfilView(),
        ];

        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvoked: (didPop) {
            if (didPop) return;
            setState(() {
              _currentIndex = 0;
            });
          },
          child: Scaffold(
            extendBody: true, // Crucial for floating bottom bar transparent areas
            body: IndexedStack(index: _currentIndex, children: views),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home
              Expanded(
                child: _buildNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  AppTranslations.translate('nav_home', lang),
                  isDark,
                ),
              ),
              // Maps
              Expanded(
                child: _buildNavItem(
                  1,
                  Icons.map_outlined,
                  Icons.map,
                  AppTranslations.translate('nav_maps', lang),
                  isDark,
                ),
              ),
              // Center Green Button (Laporan)
              GestureDetector(
                onTap: () => _onTabTapped(2),
                child: Container(
                  width: 60,
                  height: 60,
                  transform: Matrix4.translationValues(
                    0.0,
                    -20.0,
                    0.0,
                  ), // Elevated slightly, not too high
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _userRole == 'admin' ? Icons.assignment : Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              // Edukasi
              Expanded(
                child: _buildNavItem(
                  3,
                  Icons.school_outlined,
                  Icons.school,
                  AppTranslations.translate('nav_education', lang),
                  isDark,
                ),
              ),
              // Profil
              Expanded(
                child: _buildNavItem(
                  4,
                  Icons.person_outline,
                  Icons.person,
                  AppTranslations.translate('nav_profile', lang),
                  isDark,
                ),
              ),
            ],
          ),
        ),
          ), // closes Padding
        ), // closes Scaffold
      ); // closes PopScope & returns it
    },
  );
}
}

