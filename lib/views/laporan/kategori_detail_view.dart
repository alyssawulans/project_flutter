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
  "Pembuangan Sampah": CategoryDetailInfo(
    titleId: "Pembuangan Sampah",
    titleEn: "Waste Dumping",
    icon: Icons.delete_outline_rounded,
    themeColor: const Color(0xFF0D9488),
    factId:
        "Pembuangan sampah sembarangan dapat mencemari tanah, menyumbat aliran air, dan menjadi sarang berbagai penyakit menular seperti demam berdarah.",
    factEn:
        "Illegal dumping pollutes soil, clogs water drainage, and serves as breeding grounds for infectious diseases like dengue fever.",
    warningId:
        "Sampah plastik membutuhkan waktu ratusan tahun untuk terurai di lingkungan.",
    warningEn:
        "Plastic waste takes hundreds of years to decompose in the environment.",
    tipsId: [
      "Ambil foto tumpukan sampah secara jelas.",
      "Gunakan titik lokasi koordinat GPS yang akurat.",
      "Tuliskan deskripsi jenis sampah (misal: sampah medis, plastik, limbah industri).",
    ],
    tipsEn: [
      "Capture a clear photo of the waste pile.",
      "Use precise GPS coordinate markers.",
      "Describe the type of waste (e.g., medical, plastic, industrial waste).",
    ],
  ),
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
  "Polusi Udara": CategoryDetailInfo(
    titleId: "Polusi Udara",
    titleEn: "Air Pollution",
    icon: Icons.cloud_rounded,
    themeColor: const Color(0xFF0284C7),
    factId:
        "Polusi udara akibat emisi kendaraan dan cerobong pabrik menurunkan indeks kualitas udara (AQI) secara drastis dan menyebabkan infeksi saluran pernapasan akut (ISPA).",
    factEn:
        "Air pollution from vehicle exhaust and factory chimneys severely drops the air quality index (AQI), causing acute respiratory infections (ARI).",
    warningId:
        "Paparan polusi udara jangka panjang meningkatkan risiko penyakit jantung dan stroke.",
    warningEn:
        "Long-term exposure to air pollution increases the risk of heart disease and stroke.",
    tipsId: [
      "Foto sumber polusi udara secara jelas (misal: cerobong asap pabrik, bus berasap tebal).",
      "Sebutkan waktu kejadian polusi tertinggi.",
      "Berikan keterangan arah angin dan kepekatan asap jika memungkinkan.",
    ],
    tipsEn: [
      "Photo the pollution source clearly (e.g., factory smoke stack, smoky bus exhaust).",
      "Mention the time when the pollution is peak.",
      "Describe wind direction and smoke density if possible.",
    ],
  ),
  "Limbah Cair": CategoryDetailInfo(
    titleId: "Limbah Cair",
    titleEn: "Liquid Waste",
    icon: Icons.water_drop_rounded,
    themeColor: const Color(0xFF2563EB),
    factId:
        "Pembuangan limbah cair industri atau domestik tanpa pengolahan mencemari ekosistem sungai, mematikan ikan, dan meracuni pasokan air tanah warga.",
    factEn:
        "Dumping industrial or domestic wastewater without treatment contaminates river ecosystems, kills aquatic life, and poisons clean groundwater sources.",
    warningId:
        "Limbah cair beracun dapat menyebabkan iritasi kulit hebat dan kanker jika terkonsumsi.",
    warningEn:
        "Toxic liquid waste can cause severe skin irritation and cancer if consumed.",
    tipsId: [
      "Foto aliran limbah yang keluar beserta warna dan kondisinya.",
      "Tuliskan nama sungai atau parit terdampak.",
      "Sebutkan jika tercium bau menyengat atau berbusa tebal.",
    ],
    tipsEn: [
      "Photo the waste flow along with its color and condition.",
      "Write down the name of the affected river or canal.",
      "Mention if there is a strong odor or thick foam.",
    ],
  ),
  "Kebisingan": CategoryDetailInfo(
    titleId: "Kebisingan",
    titleEn: "Noise Pollution",
    icon: Icons.volume_up_rounded,
    themeColor: const Color(0xFF7C3AED),
    factId:
        "Kebisingan konstan di atas 85 desibel dari proyek konstruksi atau aktivitas komersial di malam hari dapat memicu gangguan tidur, stres, dan gangguan pendengaran permanen.",
    factEn:
        "Constant noise above 85 decibels from construction sites or commercial night activities can cause sleep disorders, stress, and permanent hearing damage.",
    warningId:
        "Kebisingan di malam hari sangat mengganggu kenyamanan dan konsentrasi istirahat warga.",
    warningEn:
        "Night-time noise pollution severely disrupts community rest and concentration.",
    tipsId: [
      "Tuliskan sumber suara bising secara spesifik.",
      "Sebutkan perkiraan jam mulai dan berakhirnya kebisingan.",
      "Lampirkan rekaman video bersuara sebagai bukti kebisingan.",
    ],
    tipsEn: [
      "Specify the exact source of the noise.",
      "Provide the estimated start and end hours of the noise.",
      "Attach a video recording with sound as proof of noise.",
    ],
  ),
  "Lainnya": CategoryDetailInfo(
    titleId: "Lainnya",
    titleEn: "Others",
    icon: Icons.more_horiz_rounded,
    themeColor: const Color(0xFF475569),
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

