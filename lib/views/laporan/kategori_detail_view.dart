import 'package:flutter/material.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/views/laporan/buat_laporan.dart';

class CategoryDetailInfo {
  final String titleId;
  final String titleEn;
  final IconData icon;
  final Color themeColor;
  final String factId;
  final String factEn;
  final String warningId;
  final String warningEn;
  final List<String> tipsId;
  final List<String> tipsEn;

  CategoryDetailInfo({
    required this.titleId,
    required this.titleEn,
    required this.icon,
    required this.themeColor,
    required this.factId,
    required this.factEn,
    required this.warningId,
    required this.warningEn,
    required this.tipsId,
    required this.tipsEn,
  });
}

final Map<String, CategoryDetailInfo> _categoryData = {
  "Pembakaran Sampah": CategoryDetailInfo(
    titleId: "Pembakaran Sampah",
    titleEn: "Trash Burning",
    icon: Icons.local_fire_department_rounded,
    themeColor: const Color(0xFFEA580C),
    factId:
        "Membakar sampah di area terbuka melepaskan karbon monoksida, dioksin, dan partikulat halus (PM2.5) langsung ke udara yang membahayakan sistem pernapasan.",
    factEn:
        "Burning trash in open areas releases carbon monoxide, dioxins, and fine particulate matter (PM2.5) directly into the air, harming respiratory systems.",
    warningId:
        "Asap pembakaran sampah sangat berbahaya bagi penderita asma, anak-anak, dan lansia.",
    warningEn:
        "Trash burning smoke is highly hazardous for asthmatics, children, and the elderly.",
    tipsId: [
      "Ambil foto/video kepulan asap dan sumber api.",
      "Laporkan sesegera mungkin selagi pembakaran masih aktif.",
      "Pastikan posisi pengambilan foto aman dari jangkauan api.",
    ],
    tipsEn: [
      "Capture photos/videos of the smoke plume and fire source.",
      "Report as soon as possible while the burning is active.",
      "Ensure your photo position is safe from the fire.",
    ],
  ),
  "Asap Industri / Pabrik": CategoryDetailInfo(
    titleId: "Asap Industri / Pabrik",
    titleEn: "Industrial / Factory Smoke",
    icon: Icons.factory_rounded,
    themeColor: const Color(0xFF475569),
    factId:
        "Asap pembuangan dari cerobong pabrik industri melepaskan zat kimia berbahaya seperti belerang dioksida dan nitrogen oksida yang mencemari udara sekitar.",
    factEn:
        "Exhaust smoke from industrial chimneys releases harmful chemical agents like sulfur dioxide and nitrogen oxide that contaminate the ambient air.",
    warningId:
        "Polusi udara industri dapat menurunkan fungsi paru-paru penduduk sekitar secara jangka panjang.",
    warningEn:
        "Industrial air pollution can reduce the lung function of surrounding residents in the long term.",
    tipsId: [
      "Foto asap hitam tebal yang keluar dari cerobong pabrik.",
      "Tuliskan nama pabrik atau kawasan industrinya.",
      "Catat waktu kepekatan asap tertinggi.",
    ],
    tipsEn: [
      "Photo the thick black smoke coming from the factory chimney.",
      "Write down the factory or industrial area name.",
      "Record the time of peak smoke density.",
    ],
  ),
  "Asap Kendaraan": CategoryDetailInfo(
    titleId: "Asap Kendaraan",
    titleEn: "Vehicle Smoke",
    icon: Icons.directions_car_rounded,
    themeColor: const Color(0xFF0284C7),
    factId:
        "Gas buang kendaraan bermotor menghasilkan karbon monoksida (CO) dan hidrokarbon yang merupakan penyumbang polusi udara terbesar di kota-kota besar.",
    factEn:
        "Vehicle exhaust gases produce carbon monoxide (CO) and hydrocarbons which are the largest contributors to air pollution in major cities.",
    warningId:
        "Paparan asap kendaraan secara langsung di jalan raya meningkatkan risiko infeksi saluran pernapasan.",
    warningEn:
        "Direct exposure to vehicle exhaust on the highway increases the risk of respiratory infections.",
    tipsId: [
      "Foto bus, truk, atau motor yang mengeluarkan asap pekat berlebih.",
      "Tuliskan lokasi jalan atau persimpangan tempat kendaraan melintas.",
      "Sebutkan jika polusi sering terjadi saat macet.",
    ],
    tipsEn: [
      "Photo buses, trucks, or motorcycles releasing excessive thick exhaust smoke.",
      "Write down the street location or intersection where the vehicle passes.",
      "Mention if pollution frequently occurs during traffic congestion.",
    ],
  ),
  "Debu & Konstruksi": CategoryDetailInfo(
    titleId: "Debu & Konstruksi",
    titleEn: "Dust & Construction",
    icon: Icons.construction_rounded,
    themeColor: const Color(0xFFD97706),
    factId:
        "Proyek konstruksi bangunan dan jalan raya menghasilkan debu semen dan partikel silika yang mengganggu kenyamanan bernapas warga sekitar.",
    factEn:
        "Building and highway construction projects generate cement dust and silica particles that disrupt the respiratory comfort of surrounding residents.",
    warningId:
        "Debu proyek konstruksi yang terhirup terus-menerus berbahaya bagi saluran pernapasan.",
    warningEn:
        "Inhaling construction project dust continuously is hazardous to the respiratory tract.",
    tipsId: [
      "Foto area proyek konstruksi yang menghasilkan debu berlebih.",
      "Sebutkan nama jalan atau lokasi proyek.",
      "Tuliskan apakah proyek menyediakan jaring pengaman debu.",
    ],
    tipsEn: [
      "Photo the construction project area generating excessive dust.",
      "Mention the street name or project location.",
      "Describe if the project provides dust safety netting.",
    ],
  ),
  "Polusi Bau & Gas": CategoryDetailInfo(
    titleId: "Polusi Bau & Gas",
    titleEn: "Odor & Gas Pollution",
    icon: Icons.air_rounded,
    themeColor: const Color(0xFF0D9488),
    factId:
        "Bau tidak sedap dari tumpukan sampah basah atau kebocoran gas kimia dapat mencemari kenyamanan pemukiman dan memicu pusing serta mual.",
    factEn:
        "Bad odors from wet trash piles or chemical gas leaks can ruin residential comfort and trigger dizziness and nausea.",
    warningId:
        "Bau gas kimia tertentu dapat beracun atau mudah terbakar jika terpapar percikan api.",
    warningEn:
        "Certain chemical gas odors can be toxic or highly flammable if exposed to sparks.",
    tipsId: [
      "Deskripsikan jenis bau yang tercium (misal: bau busuk sampah, bau gas menyengat).",
      "Sebutkan perkiraan sumber bau tersebut.",
      "Tuliskan efek kesehatan yang dirasakan warga sekitar.",
    ],
    tipsEn: [
      "Describe the type of odor smelled (e.g., rotten trash smell, strong gas odor).",
      "Mention the estimated source of the odor.",
      "Describe the health effects felt by nearby residents.",
    ],
  ),
  "Lainnya": CategoryDetailInfo(
    titleId: "Lainnya",
    titleEn: "Others",
    icon: Icons.more_horiz_rounded,
    themeColor: const Color(0xFF64748B),
    factId:
        "Kategori ini ditujukan untuk permasalahan lingkungan lain seperti perusakan pohon pelindung, pembalakan liar, atau pemanfaatan ruang publik ilegal.",
    factEn:
        "This category is intended for other environmental issues such as damage to shelter trees, illegal logging, or illegal use of public space.",
    warningId:
        "Melaporkan segala kejanggalan lingkungan membantu menciptakan kota yang tertata rapi.",
    warningEn:
        "Reporting any environmental irregularities helps create a well-organized city.",
    tipsId: [
      "Berikan penjelasan sedetail mungkin tentang pelanggaran lingkungan yang terjadi.",
      "Sertakan foto bukti situasi di lapangan.",
      "Sebutkan patokan jalan atau tanda pengenal lokasi terdekat.",
    ],
    tipsEn: [
      "Describe the environmental violation in as much detail as possible.",
      "Attach photographic proof of the scene.",
      "Mention nearby landmarks or street signs.",
    ],
  ),
};

class KategoriDetailView extends StatefulWidget {
  final String categoryName;

  const KategoriDetailView({super.key, required this.categoryName});

  @override
  State<KategoriDetailView> createState() => _KategoriDetailViewState();
}

class _KategoriDetailViewState extends State<KategoriDetailView> {
  int _activeReportsCount = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    _loadReportStats();
  }

  Future<void> _loadReportStats() async {
    try {
      final reports = await FirebaseAuthService.instance.getLaporans();
      final count = reports
          .where(
            (r) =>
                r.kategori.toLowerCase() == widget.categoryName.toLowerCase(),
          )
          .length;
      if (mounted) {
        setState(() {
          _activeReportsCount = count;
          _isLoadingCount = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine category configuration
    // Fallback if the database has other names, map safely
    final configKey = _categoryData.keys.firstWhere(
      (k) => k.toLowerCase() == widget.categoryName.toLowerCase(),
      orElse: () => "Lainnya",
    );
    final CategoryDetailInfo info = _categoryData[configKey]!;

    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        final lang = settings.languageCode;
        final isDark = settings.themeMode == ThemeMode.dark;

        final title = lang == 'id' ? info.titleId : info.titleEn;
        final fact = lang == 'id' ? info.factId : info.factEn;
        final warning = lang == 'id' ? info.warningId : info.warningEn;
        final tipsList = lang == 'id' ? info.tipsId : info.tipsEn;

        // Custom dark mode palettes
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

        // Highlight stats colors
        final Color statsBg = isDark
            ? const Color(0xFF0F2625)
            : const Color(0xFFEFF6F5);
        final Color statsBorder = isDark
            ? const Color(0xFF134E4A)
            : const Color(0xFFCCECE7);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : info.themeColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Curve Banner Header with Category Icon
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : info.themeColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 32,
                    top: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(info.icon, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'id'
                                  ? 'Edukasi Lingkungan'
                                  : 'Environmental Education',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Fakta & Dampak Kesehatan Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: info.themeColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lang == 'id'
                                      ? 'Fakta & Dampak'
                                      : 'Facts & Impacts',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: info.themeColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fact,
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Red Warning Banner
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFEF2F2,
                                ).withValues(alpha: isDark ? 0.08 : 1.0),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFEE2E2,
                                  ).withValues(alpha: isDark ? 0.15 : 1.0),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      warning,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFEF4444),
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Statistik Laporan Sekitar Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: statsBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: statsBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang == 'id'
                                        ? 'Laporan Sekitar'
                                        : 'Reports Nearby',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFF0D9488)
                                          : const Color(0xFF0F4C43),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lang == 'id'
                                        ? 'Jumlah laporan aktif terekam saat ini.'
                                        : 'Total active reports logged nationally.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subTextColor,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            _isLoadingCount
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF0D9488),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '$_activeReportsCount',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: info.themeColor,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Panduan Melapor
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment_turned_in_outlined,
                                  color: info.themeColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lang == 'id'
                                      ? 'Panduan Melapor'
                                      : 'Reporting Guide',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: info.themeColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // List tips
                            ...List.generate(tipsList.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: info.themeColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: info.themeColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tipsList[index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BuatLaporan(initialCategory: widget.categoryName),
                    ),
                  ).then((_) {
                    _loadReportStats();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: info.themeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lang == 'id' ? "Mulai Melapor" : "Start Reporting",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

