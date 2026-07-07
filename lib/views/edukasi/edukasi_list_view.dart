import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/edukasi_model.dart';
import 'package:project_flutter/views/edukasi/daftar_edukasi_view.dart';
import 'package:project_flutter/views/edukasi/edukasi_detail_view.dart';
import 'package:project_flutter/views/edukasi/edukasi_image_viewer.dart';
import 'package:project_flutter/views/edukasi/edukasi_form_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EdukasiListView extends StatefulWidget {
  const EdukasiListView({super.key});

  @override
  State<EdukasiListView> createState() => _EdukasiListViewState();
}

class _EdukasiListViewState extends State<EdukasiListView> {
  String _userName = 'Andi Pratama';
  String _userRole = 'user';
  EdukasiModel? _featuredArticle;
  List<EdukasiModel> _articles = [];
  bool _isLoading = true;

  // Categories displayed in dashboard
  final List<String> _displayCategories = [
    'Semua',
    'Polusi Udara',
    'Lingkungan',
    'Sampah',
  ];

  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  // List of daily fun facts
  final List<String> _funFacts = [
    'Satu pohon dewasa mampu menyerap sekitar 22 kg CO₂ setiap tahun untuk membantu menyaring udara.',
    'Menanam tanaman hias seperti Lidah Mertua di dalam ruangan dapat menyerap racun benzena dan formaldehida.',
    'Kualitas udara di dalam ruangan bisa 2 hingga 5 kali lebih buruk daripada kualitas udara di luar ruangan.',
    'Hutan hujan Amazon menghasilkan sekitar 20 persen oksigen di bumi dari seluruh pepohonan di sana.',
    'Berkendara sepeda sejauh 10 km setiap hari dapat mencegah emisi sekitar 1,3 ton CO₂ per tahun.',
    'Polusi udara dapat berdampak negatif pada kesehatan mental dan memicu stres atau kecemasan.',
    'Menggunakan transportasi umum dapat mengurangi emisi karbon pribadi Anda hingga 45 persen setiap perjalanan.',
    'Sebagian besar debu di rumah kita sebenarnya berasal dari sel kulit mati manusia dan serat pakaian.',
    'Tanaman Lidah Buaya melepaskan oksigen pada malam hari, menjadikannya tanaman ideal diletakkan di kamar tidur.',
    'Membuka jendela selama 15 menit setiap pagi dapat mengurangi penumpukan gas karbon dioksida di dalam rumah.',
    'Satu hektar hutan kota mampu menghasilkan oksigen yang cukup untuk kebutuhan bernapas 18 orang setiap hari.',
    'Polusi partikulat halus (PM2.5) dapat terbawa angin hingga jarak ratusan kilometer dari sumber asalnya.',
  ];

  final List<String> _funFactsEn = [
    'One mature tree can absorb about 22 kg of CO₂ each year to help filter the air.',
    'Planting ornamental plants like Snake Plant indoors can absorb benzene and formaldehyde toxins.',
    'Indoor air quality can be 2 to 5 times worse than outdoor air quality.',
    'The Amazon rainforest produces about 20 percent of the earth\'s oxygen from all the trees there.',
    'Riding a bicycle for 10 km every day can prevent emissions of about 1.3 tons of CO₂ per year.',
    'Air pollution can negatively impact mental health and trigger stress or anxiety.',
    'Using public transportation can reduce your personal carbon emissions by up to 45 percent per trip.',
    'Most dust in our homes actually comes from dead human skin cells and clothing fibers.',
    'Aloe Vera plants release oxygen at night, making them ideal plants to place in the bedroom.',
    'Opening windows for 15 minutes every morning can reduce the accumulation of carbon dioxide gas inside the house.',
    'One hectare of urban forest can produce enough oxygen for the breathing needs of 18 people every day.',
    'Fine particulate pollution (PM2.5) can be carried by the wind up to hundreds of kilometers from its source of origin.',
  ];

  String _getFunFact(String lang) {
    final day = DateTime.now().day;
    if (lang == 'en') {
      return _funFactsEn[day % _funFactsEn.length];
    }
    return _funFacts[day % _funFacts.length];
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    // Load username
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('current_user_name') ?? 'Andi Pratama';
    final role = prefs.getString('current_user_role') ?? 'user';

    // Find featured article (e.g. PM2.5 article or the first available)
    final articles = await FirebaseAuthService.instance.getEdukasis();
    EdukasiModel? pm25Article;
    try {
      pm25Article = articles.firstWhere(
        (a) =>
            a.judul.toLowerCase().contains('pm2.5') ||
            a.judul.toLowerCase().contains('pm2.5?'),
      );
    } catch (_) {
      if (articles.isNotEmpty) {
        pm25Article = articles.first;
      }
    }

    if (mounted) {
      setState(() {
        _userName = name;
        _userRole = role;
        _featuredArticle = pm25Article;
        _articles = articles;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka tautan: $urlString'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuka tautan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            : const Color(0xFFF4F8FB);
        final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color textColor = isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF0F172A);
        final Color subTextColor = isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);
        final Color borderColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFF1F5F9);

    return Scaffold(
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EdukasiFormView()),
                ).then((_) => _loadDashboardData());
              },
              backgroundColor: activeTeal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
      ),
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D9488)),
            )
          : SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: activeTeal,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header Greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang == 'en' ? 'Hello, $_userName 👋' : 'Halo, $_userName 👋',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lang == 'en'
                                      ? 'What do you want to learn today?'
                                      : 'Apa yang ingin kamu pelajari hari ini?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 2. Search Field Placeholder
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DaftarEdukasiView(),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withValues(alpha: 0.01),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: activeTeal, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                lang == 'en'
                                    ? 'Search article, topic, or category...'
                                    : 'Cari artikel, topik, atau kategori...',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Category Tabs
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _displayCategories.length,
                          itemBuilder: (context, index) {
                            final cat = _displayCategories[index];
                            final isSelected =
                                index == 0; // "Semua" selected in home

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DaftarEdukasiView(
                                        initialCategory: cat,
                                      ),
                                    ),
                                  ).then((_) => _loadDashboardData());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? activeTeal
                                        : (isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFEFF3F6)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: isSelected
                                        ? null
                                        : Border.all(color: borderColor),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat == 'Semua'
                                          ? (lang == 'en' ? 'All' : 'Semua')
                                          : (cat == 'Polusi Udara'
                                              ? (lang == 'en' ? 'Air Pollution' : 'Polusi Udara')
                                              : (cat == 'Lingkungan'
                                                  ? (lang == 'en' ? 'Environment' : 'Lingkungan')
                                                  : (cat == 'Sampah'
                                                      ? (lang == 'en' ? 'Waste' : 'Sampah')
                                                      : cat))),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Large Featured Card
                      GestureDetector(
                        onTap: () {
                          if (_featuredArticle != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EdukasiDetailView(
                                  article: _featuredArticle!,
                                ),
                              ),
                            ).then((_) => _loadDashboardData());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Artikel tidak ditemukan'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [activeTeal, primaryTeal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: activeTeal.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // Decorative Background Shape
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.05,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(22.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _featuredArticle?.judul ?? 'Apa itu PM2.5?',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? const Color(0xFFF8FAFC)
                                                  : Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _featuredArticle?.konten ??
                                                'Kenali partikel berbahaya yang mengancam kesehatan kita.',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _featuredArticle != null
                                                    ? (lang == 'en'
                                                        ? '${(_featuredArticle!.konten.split(" ").length / 150).ceil().clamp(2, 60)} Min Read'
                                                        : '${(_featuredArticle!.konten.split(" ").length / 150).ceil().clamp(2, 60)} Menit Membaca')
                                                    : (lang == 'en' ? '5 Min Read' : '5 Menit Membaca'),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Illustration image: paru_1.png
                                    Image.asset(
                                      'assets/images/project_akhir/paru_1.png',
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.spa_rounded,
                                                  color: Colors.white,
                                                  size: 38,
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
                      const SizedBox(height: 24),

                      // 5. Quick Navigation Grid (Horizontal-like Grid of 4 Items)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickNavButton(
                            label: lang == 'en' ? 'Popular\nArticles' : 'Artikel\nPopuler',
                            icon: Icons.article_rounded,
                            bgColor: isDark
                                ? const Color(0xFF2563EB).withOpacity(0.15)
                                : const Color(0xFFEFF6FF),
                            iconColor: const Color(0xFF3B82F6),
                            onTap: () => _showArtikelBottomSheet(context),
                            isDark: isDark,
                          ),
                          _buildQuickNavButton(
                            label: lang == 'en' ? 'Educational\nVideos' : 'Video\nEdukasi',
                            icon: Icons.play_circle_fill_rounded,
                            bgColor: isDark
                                ? const Color(0xFFDB2777).withOpacity(0.15)
                                : const Color(0xFFFDF2F8),
                            iconColor: const Color(0xFFF472B6),
                            onTap: () => _showVideoBottomSheet(context),
                            isDark: isDark,
                          ),
                          _buildQuickNavButton(
                            label: lang == 'en' ? 'Educational\nInfographics' : 'Infografis\nEdukasi',
                            icon: Icons.pie_chart_rounded,
                            bgColor: isDark
                                ? const Color(0xFF059669).withOpacity(0.15)
                                : const Color(0xFFECFDF5),
                            iconColor: const Color(0xFF34D399),
                            onTap: () => _showInfografisBottomSheet(context),
                            isDark: isDark,
                          ),
                          _buildQuickNavButton(
                            label: lang == 'en' ? 'Educational\nQuizzes' : 'Kuis\nEdukasi',
                            icon: Icons.emoji_events_rounded,
                            bgColor: isDark
                                ? const Color(0xFFD97706).withOpacity(0.15)
                                : const Color(0xFFFFF7ED),
                            iconColor: const Color(0xFFFB923C),
                            onTap: () => _showKuisDialog(context),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // 5. Daftar Edukasi Terbaru Section
                      if (_articles.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'en' ? 'Latest Education' : 'Daftar Edukasi Terbaru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DaftarEdukasiView(),
                                  ),
                                ).then((_) => _loadDashboardData());
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
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
                        const SizedBox(height: 12),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _articles.length > 3 ? 3 : _articles.length,
                          itemBuilder: (context, index) {
                            final article = _articles[index];
                            return _buildMockupArticleCard(
                              article,
                              cardBgColor,
                              textColor,
                              subTextColor,
                              borderColor,
                              isDark,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 6. Fakta Menarik Hari Ini Section
                      Text(
                        lang == 'en' ? 'Interesting Fact Today' : 'Fakta Menarik Hari Ini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0D9488).withOpacity(0.15)
                              : const Color(0xFFECFDF5), // Soft pastel green
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF0D9488).withOpacity(0.3)
                                : const Color(
                                    0xFFA7F3D0,
                                  ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getFunFact(lang),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF2DD4BF)
                                        : primaryTeal,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Illustration image: tanaman.png
                              Image.asset(
                                'assets/images/project_akhir/tanaman.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.eco_rounded,
                                      color: Color(0xFF059669),
                                      size: 40,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
        );
      },
    );
  }

  Widget _buildQuickNavButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showArtikelBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bottomSheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color handleColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey[300]!;
    final Color txtColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTxtColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: bottomSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lang == 'en' ? 'Popular Articles' : 'Artikel Populer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lang == 'en'
                  ? 'Study the following popular articles about the environment and air pollution:'
                  : 'Pelajari artikel populer mengenai lingkungan dan polusi udara berikut:',
              style: TextStyle(color: subTxtColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildArtikelRowItem(
              title: lang == 'en'
                  ? 'Urban Air Pollution - Greenpeace Indonesia'
                  : 'Polusi Udara Perkotaan - Greenpeace Indonesia',
              source: 'Greenpeace Indonesia',
              url:
                  'https://www.greenpeace.org/indonesia/kampanye/perkotaan/polusi-udara/',
            ),
            _buildArtikelRowItem(
              title: lang == 'en'
                  ? 'Impact of Jakarta Pollution on Health - UGM OHCE'
                  : 'Dampak Polusi Jakarta bagi Kesehatan - UGM OHCE',
              source: 'OHCE UGM',
              url:
                  'https://ohce.wg.ugm.ac.id/polusi-jakarta-peringkat-1-di-dunia-bagaimana-dampaknya-pada-kesehatan/',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtikelRowItem({
    required String title,
    required String source,
    required String url,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color innerItemBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color txtColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTxtColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: innerItemBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchURL(url),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2563EB).withOpacity(0.15)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.article_rounded,
                    color: isDark
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        source,
                        style: TextStyle(fontSize: 11, color: subTxtColor),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, color: subTxtColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern bottom sheet for video playlists
  void _showVideoBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bottomSheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color handleColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey[300]!;
    final Color txtColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTxtColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: bottomSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lang == 'en' ? 'Educational Videos' : 'Video Edukasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lang == 'en'
                  ? 'Watch these selected environmental educational videos:'
                  : 'Simak video edukasi lingkungan pilihan terbaik berikut:',
              style: TextStyle(color: subTxtColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildVideoRowItem(
              title: lang == 'en'
                  ? 'Air Pollution Solutions in Indonesia'
                  : 'Solusi Polusi Udara di Indonesia',
              duration: 'YouTube',
              channel: lang == 'en' ? 'Environmental Education' : 'Edukasi Lingkungan',
              url: 'https://youtu.be/ltbx_Gb4x9w?si=MoZQZ7ObKwZ9kgAL',
            ),
            _buildVideoRowItem(
              title: lang == 'en'
                  ? 'Causes & Adverse Impacts of Air Quality'
                  : 'Penyebab & Dampak Buruk Kualitas Udara',
              duration: 'YouTube',
              channel: lang == 'en' ? 'Environmental Info' : 'Info Lingkungan',
              url: 'https://youtu.be/GVBeY1jSG9Y?si=wnjAn-cSth1LVehD',
            ),
            _buildVideoRowItem(
              title: lang == 'en'
                  ? 'How to Protect Yourself from Air Pollution'
                  : 'Cara Melindungi Diri dari Polusi Udara',
              duration: 'YouTube',
              channel: lang == 'en' ? 'Public Health' : 'Kesehatan Masyarakat',
              url: 'https://youtu.be/jtiANpcpJJY?si=BNh6UBoae7YTtddh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoRowItem({
    required String title,
    required String duration,
    required String channel,
    required String url,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color innerItemBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color txtColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTxtColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: innerItemBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchURL(url),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFDB2777).withOpacity(0.15)
                        : const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: isDark
                        ? const Color(0xFFF472B6)
                        : const Color(0xFFDB2777),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$channel • $duration',
                        style: TextStyle(fontSize: 11, color: subTxtColor),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, color: subTxtColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern bottom sheet for Infographics
  void _showInfografisBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bottomSheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color handleColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey[300]!;
    final Color txtColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTxtColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: bottomSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lang == 'en' ? 'Environmental Infographics' : 'Infografis Lingkungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lang == 'en'
                  ? 'Learn material faster through visual infographics:'
                  : 'Pelajari materi lebih cepat melalui visual infografis:',
              style: TextStyle(color: subTxtColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildInfografisRowItem(
              title: lang == 'en'
                  ? 'Relationship Between Dry Days Series and Particulate Concentration'
                  : 'Hubungan Deret Hari Kering dengan Konsentrasi Partikulat',
              size: 'PNG',
              imagePath: 'assets/images/project_akhir/infografis_1.png',
            ),
            _buildInfografisRowItem(
              title: lang == 'en'
                  ? 'Location Mapping of Transboundary Air Pollutants'
                  : 'Penentuan Lokasi Lintas Batas Pencemar Udara',
              size: 'PNG',
              imagePath: 'assets/images/project_akhir/infografis_2.png',
            ),
            _buildInfografisRowItem(
              title: lang == 'en'
                  ? 'Jakarta Air Condition 2026'
                  : 'Kondisi Udara Jakarta 2026',
              size: 'JPG',
              imagePath: 'assets/images/project_akhir/infografis_3.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfografisRowItem({
    required String title,
    required String size,
    required String imagePath,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color innerItemBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color txtColor = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color subTxtColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: innerItemBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context); // close bottom sheet
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EdukasiImageViewer(imagePath: imagePath, title: title),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                      ? const Color(0xFF059669).withOpacity(0.15)
                      : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insert_chart_outlined_rounded,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang == 'en'
                            ? 'Format: $size • Tap to enlarge'
                            : 'Format: $size • Tap untuk memperbesar',
                        style: TextStyle(fontSize: 11, color: subTxtColor),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.zoom_in_rounded, color: subTxtColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Interactive popup Quiz Dialog
  void _showKuisDialog(BuildContext context) {
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;
    int currentQuestion = 0;
    int score = 0;
    final List<Map<String, dynamic>> questionPool = [
      {
        'q': 'Berapakah batas ukuran partikel polusi udara PM2.5?',
        'options': [
          'Lebih kecil dari 2.5 mikron',
          'Lebih besar dari 5 mikron',
          'Tepat 10 mikron',
        ],
        'correct': 0,
      },
      {
        'q': 'Manakah pohon berikut yang memiliki penyerapan karbon terbaik?',
        'options': ['Pohon Pinus', 'Pohon Trembesi', 'Pohon Palem'],
        'correct': 1,
      },
      {
        'q': 'Apa singkatan dari istilah prinsip 3R dalam pengelolaan sampah?',
        'options': [
          'Reduce, Reuse, Recycle',
          'Restore, Repair, Recycle',
          'Reduce, Rebuild, Remove',
        ],
        'correct': 0,
      },
      {
        'q': 'Senyawa kimia apa yang paling bertanggung jawab atas penipisan lapisan ozon?',
        'options': [
          'Klorofluorokarbon (CFC)',
          'Karbon Dioksida (CO₂)',
          'Metana (CH₄)',
        ],
        'correct': 0,
      },
      {
        'q': 'Gas rumah kaca apa yang paling banyak dihasilkan dari pembusukan sampah organik di TPA?',
        'options': [
          'Oksigen (O₂)',
          'Metana (CH₄)',
          'Nitrogen Oksida (N₂O)',
        ],
        'correct': 1,
      },
      {
        'q': 'Apa sumber utama polutan partikulat PM2.5 di area perkotaan?',
        'options': [
          'Asap rokok dan pembakaran lilin',
          'Emisi gas buang kendaraan bermotor',
          'Uap air laut dan debu jalanan',
        ],
        'correct': 1,
      },
      {
        'q': 'Berapa lama perkiraan waktu yang dibutuhkan botol plastik untuk terurai di alam?',
        'options': [
          'Sekitar 50 tahun',
          'Sekitar 100 tahun',
          'Sekitar 450 tahun',
        ],
        'correct': 2,
      },
      {
        'q': 'Jenis sampah mana yang paling tepat untuk dibuang ke dalam wadah tempat sampah berwarna hijau?',
        'options': [
          'Sisa makanan dan daun kering (Organik)',
          'Botol plastik dan kaleng bekas (Anorganik)',
          'Baterai dan lampu bekas (B3)',
        ],
        'correct': 0,
      },
      {
        'q': 'Apa nama indeks resmi yang digunakan pemerintah Indonesia untuk memantau kualitas udara?',
        'options': [
          'ISPU (Indeks Standar Pencemar Udara)',
          'AQI (Air Quality Index)',
          'API (Air Pollutant Index)',
        ],
        'correct': 0,
      },
      {
        'q': 'Tanaman hias indoor apa yang sangat efektif menyaring racun udara seperti formaldehida?',
        'options': [
          'Lidah Mertua (Sansevieria)',
          'Bunga Mawar',
          'Pohon Kamboja',
        ],
        'correct': 0,
      },
    ];

    final List<Map<String, dynamic>> questionPoolEn = [
      {
        'q': 'What is the size limit for PM2.5 air pollution particles?',
        'options': [
          'Smaller than 2.5 microns',
          'Larger than 5 microns',
          'Exactly 10 microns',
        ],
        'correct': 0,
      },
      {
        'q': 'Which of the following trees has the best carbon absorption?',
        'options': ['Pine Tree', 'Trembesi Tree', 'Palm Tree'],
        'correct': 1,
      },
      {
        'q': 'What does the 3R principle stand for in waste management?',
        'options': [
          'Reduce, Reuse, Recycle',
          'Restore, Repair, Recycle',
          'Reduce, Rebuild, Remove',
        ],
        'correct': 0,
      },
      {
        'q': 'Which chemical compound is most responsible for ozone layer depletion?',
        'options': [
          'Chlorofluorocarbon (CFC)',
          'Carbon Dioxide (CO₂)',
          'Methane (CH₄)',
        ],
        'correct': 0,
      },
      {
        'q': 'Which greenhouse gas is produced in the largest quantity from organic waste decomposition in landfills?',
        'options': [
          'Oxygen (O₂)',
          'Methane (CH₄)',
          'Nitrous Oxide (N₂O)',
        ],
        'correct': 1,
      },
      {
        'q': 'What is the main source of PM2.5 particulate pollutants in urban areas?',
        'options': [
          'Cigarette smoke and candle burning',
          'Exhaust emissions from motor vehicles',
          'Sea salt spray and road dust',
        ],
        'correct': 1,
      },
      {
        'q': 'Approximately how long does it take for a plastic bottle to decompose in nature?',
        'options': [
          'Around 50 years',
          'Around 100 years',
          'Around 450 years',
        ],
        'correct': 2,
      },
      {
        'q': 'Which type of waste is most appropriate to dispose of in a green trash container?',
        'options': [
          'Food scraps and dry leaves (Organic)',
          'Plastic bottles and used cans (Inorganic)',
          'Used batteries and light bulbs (Hazardous)',
        ],
        'correct': 0,
      },
      {
        'q': 'What is the name of the official index used by the Indonesian government to monitor air quality?',
        'options': [
          'ISPU (Indeks Standar Pencemar Udara)',
          'AQI (Air Quality Index)',
          'API (Air Pollutant Index)',
        ],
        'correct': 0,
      },
      {
        'q': 'Which indoor ornamental plant is highly effective at filtering air toxins like formaldehyde?',
        'options': [
          'Snake Plant (Sansevieria)',
          'Rose Flower',
          'Cambodian Tree',
        ],
        'correct': 0,
      },
    ];

    // Ambil 5 soal secara acak dari pool untuk variasi kuis yang dinamis secara konsisten untuk kedua bahasa
    final List<int> indices = List<int>.generate(questionPool.length, (i) => i)..shuffle();
    final List<int> selectedIndices = indices.take(5).toList();

    final List<Map<String, dynamic>> questions = selectedIndices.map((idx) {
      if (lang == 'en') {
        return questionPoolEn[idx];
      }
      return questionPool[idx];
    }).toList();

    int selectedOptionIndex = -1;
    bool hasSubmitted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final qData = questions[currentQuestion];
            final progress = (currentQuestion + 1) / questions.length;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient Header
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
                    child: Column(
                      children: [
                        const Icon(
                          Icons.quiz_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'en' ? 'New Question' : 'Pertanyaan Baru',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: activeTeal,
                              ),
                            ),
                            Text(
                              lang == 'en'
                                  ? 'Question ${currentQuestion + 1} of ${questions.length}'
                                  : 'Soal ${currentQuestion + 1} dari ${questions.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          qData['q'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF8FAFC) : textDark,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(qData['options'].length, (index) {
                          final option = qData['options'][index];
                          final prefixes = ['A', 'B', 'C'];
                          final isCorrect = index == qData['correct'];
                          final isSelected = index == selectedOptionIndex;

                          // Dynamic styling based on selected state
                          Color itemBorderColor = isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0);
                          Color itemBgColor = isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC);
                          Color prefixBgColor = activeTeal.withOpacity(0.1);
                          Color prefixTextColor = activeTeal;
                          Widget? trailingIcon;

                          if (hasSubmitted) {
                            if (isCorrect) {
                              itemBorderColor = const Color(0xFF10B981);
                              itemBgColor = isDark
                                  ? const Color(0xFF10B981).withOpacity(0.15)
                                  : const Color(0xFFECFDF5);
                              prefixBgColor = const Color(0xFF10B981);
                              prefixTextColor = Colors.white;
                              trailingIcon = const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 20,
                              );
                            } else if (isSelected) {
                              itemBorderColor = const Color(0xFFEF4444);
                              itemBgColor = isDark
                                  ? const Color(0xFFEF4444).withOpacity(0.15)
                                  : const Color(0xFFFEF2F2);
                              prefixBgColor = const Color(0xFFEF4444);
                              prefixTextColor = Colors.white;
                              trailingIcon = const Icon(
                                Icons.cancel_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              );
                            }
                          } else if (isSelected) {
                            itemBorderColor = activeTeal;
                            itemBgColor = activeTeal.withOpacity(0.15);
                            prefixBgColor = activeTeal;
                            prefixTextColor = Colors.white;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: isDark
                                    ? const Color(0xFFF8FAFC)
                                    : textDark,
                                backgroundColor: itemBgColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: itemBorderColor,
                                    width:
                                        isSelected ||
                                            (hasSubmitted && isCorrect)
                                        ? 2.0
                                        : 1.0,
                                  ),
                                ),
                              ),
                              onPressed: hasSubmitted
                                  ? null
                                  : () {
                                      setDialogState(() {
                                        selectedOptionIndex = index;
                                        hasSubmitted = true;
                                      });

                                      if (isCorrect) {
                                        score++;
                                      }

                                      // Wait 1.2s to show result feedback
                                      Future.delayed(
                                        const Duration(milliseconds: 1200),
                                        () {
                                          if (context.mounted) {
                                            if (currentQuestion <
                                                questions.length - 1) {
                                              setDialogState(() {
                                                currentQuestion++;
                                                selectedOptionIndex = -1;
                                                hasSubmitted = false;
                                              });
                                            } else {
                                              Navigator.pop(context);
                                              _showResultDialog(
                                                context,
                                                score,
                                                questions.length,
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: prefixBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      prefixes[index],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: prefixTextColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (trailingIcon != null) trailingIcon,
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              lang == 'en' ? 'Exit Quiz' : 'Keluar Kuis',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, int score, int total) {
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;
    final double percentage = score / total;
    String feedbackTitle = lang == 'en' ? 'Keep it up! 📚' : 'Semangat! 📚';
    String feedbackDesc = lang == 'en'
        ? 'Keep learning about environmental cleanliness and air quality!'
        : 'Terus belajar tentang kebersihan lingkungan dan kualitas udara ya!';
    List<Color> headerColors = [
      const Color(0xFFF59E0B),
      const Color(0xFFD97706),
    ]; // Orange/Gold
    IconData medalIcon = Icons.emoji_events_rounded;

    if (percentage == 1.0) {
      feedbackTitle = lang == 'en' ? 'Perfect! 🏆' : 'Sempurna! 🏆';
      feedbackDesc = lang == 'en'
          ? 'Incredible! You are a true Air Hero. All answers correct!'
          : 'Luar biasa! Kamu adalah Pahlawan Udara sejati. Semua jawaban benar!';
      headerColors = [
        const Color(0xFF10B981),
        const Color(0xFF047857),
      ]; // Emerald
      medalIcon = Icons.military_tech_rounded;
    } else if (percentage >= 0.6) {
      feedbackTitle = lang == 'en' ? 'Great! 🌟' : 'Hebat! 🌟';
      feedbackDesc = lang == 'en'
          ? 'Excellent! You have a strong knowledge about environmental cleanliness.'
          : 'Bagus sekali! Kamu memiliki pengetahuan yang kuat tentang kebersihan lingkungan.';
      headerColors = [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]; // Blue
      medalIcon = Icons.stars_rounded;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Styled Trophy Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: headerColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Icon(medalIcon, color: Colors.white, size: 56),
                  const SizedBox(height: 8),
                  Text(
                    feedbackTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Circular Ring Score Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: percentage,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage == 1.0
                                ? const Color(0xFF10B981)
                                : (percentage >= 0.6
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      Text(
                        '${(percentage * 100).round()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFFF8FAFC) : textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    feedbackDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox(
                          lang == 'en' ? 'Correct' : 'Benar',
                          '$score',
                          const Color(0xFF10B981),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFCBD5E1),
                        ),
                        _buildStatBox(
                          lang == 'en' ? 'Incorrect' : 'Salah',
                          '${total - score}',
                          const Color(0xFFEF4444),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFFCBD5E1),
                        ),
                        _buildStatBox(lang == 'en' ? 'Questions' : 'Soal', '$total', activeTeal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showKuisDialog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: activeTeal),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            lang == 'en' ? 'Retake Quiz' : 'Ulangi Kuis',
                            style: TextStyle(
                              color: activeTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            lang == 'en' ? 'Close' : 'Tutup',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  int _estimateReadTime(String content) {
    final words = content.trim().split(RegExp(r'\s+')).length;
    final time = (words / 150).ceil();
    return time < 1 ? 1 : time;
  }

  Widget _buildMockupArticleCard(
    EdukasiModel article,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDark,
  ) {
    final readTime = _estimateReadTime(article.konten);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EdukasiDetailView(article: article),
              ),
            ).then((_) => _loadDashboardData());
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Thumbnail image container
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: article.gambar.startsWith('http')
                      ? Image.network(
                          article.gambar,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: isDark ? const Color(0xFF0F4C43).withValues(alpha: 0.3) : const Color(0xFFE2F1ED),
                            child: Icon(Icons.school, color: activeTeal, size: 28),
                          ),
                        )
                      : article.gambar.startsWith('assets/')
                          ? Image.asset(
                              article.gambar,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: isDark ? const Color(0xFF0F4C43).withValues(alpha: 0.3) : const Color(0xFFE2F1ED),
                                child: Icon(Icons.school, color: activeTeal, size: 28),
                              ),
                            )
                          : Image.file(
                              File(article.gambar),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: isDark ? const Color(0xFF0F4C43).withValues(alpha: 0.3) : const Color(0xFFE2F1ED),
                                child: Icon(Icons.school, color: activeTeal, size: 28),
                              ),
                            ),
                ),
                const SizedBox(width: 16),
                // Title and Read Time details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.judul,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: subTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppSettingsController.instance.settingsNotifier.value.languageCode == 'en'
                                ? '$readTime Min Read'
                                : '$readTime Menit Membaca',
                            style: TextStyle(
                              fontSize: 11,
                              color: subTextColor,
                              fontWeight: FontWeight.w500,
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
  }
}

