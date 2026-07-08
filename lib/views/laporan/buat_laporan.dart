import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/widgets/report_image.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/views/laporan/konfirmasi_laporan.dart';
import 'package:project_flutter/views/laporan/laporan_beranda.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:shared_preferences/shared_preferences.dart';

class BuatLaporan extends StatefulWidget {
  final String? initialCategory;
  const BuatLaporan({super.key, this.initialCategory});

  @override
  State<BuatLaporan> createState() => _BuatLaporanState();
}

final List<Map<String, dynamic>> _daftarKategori = [
  {
    "nama": "Pembakaran Sampah",
    "icon": Icons.local_fire_department_outlined,
    "color": const Color(0xFFEA580C),
  },
  {
    "nama": "Asap Industri / Pabrik",
    "icon": Icons.factory_outlined,
    "color": const Color(0xFF475569),
  },
  {
    "nama": "Asap Kendaraan",
    "icon": Icons.directions_car_outlined,
    "color": const Color(0xFF0284C7),
  },
  {
    "nama": "Debu & Konstruksi",
    "icon": Icons.construction_outlined,
    "color": const Color(0xFFD97706),
  },
  {
    "nama": "Polusi Bau & Gas",
    "icon": Icons.air_outlined,
    "color": const Color(0xFF0D9488),
  },
  {
    "nama": "Lainnya",
    "icon": Icons.more_horiz_outlined,
    "color": const Color(0xFF64748B),
  },
];

class _BuatLaporanState extends State<BuatLaporan> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String? selectedDropdown;
  String currentLokasi = "Jakarta Pusat, DKI Jakarta";
  String currentKoordinat = "-6.1818, 106.8223";

  // List to hold selected photos (simulated URLs or local file paths)
  final List<String> selectedPhotos = [];

  // Controllers characters length tracker
  int titleLength = 0;
  int descLength = 0;

  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selectedDropdown = widget.initialCategory;
    judulController.addListener(() {
      setState(() {
        titleLength = judulController.text.length;
      });
    });
    deskripsiController.addListener(() {
      setState(() {
        descLength = deskripsiController.text.length;
      });
    });
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  // Pre-loaded high-quality environmental pictures for camera/gallery simulator
  final List<String> galleryPool = [
    "https://images.unsplash.com/photo-1618477388954-7852f32655ec?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1506012787146-f92b2d7d6d96?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=500&auto=format&fit=crop",
  ];

  // Helper lists of national cities
  final List<Map<String, String>> wilayahNasional = [
    {"nama": "Jakarta Pusat, DKI Jakarta", "koordinat": "-6.1818, 106.8223"},
    {"nama": "Bandung, Jawa Barat", "koordinat": "-6.9175, 107.6191"},
    {"nama": "Surabaya, Jawa Timur", "koordinat": "-7.2575, 112.7521"},
    {"nama": "Yogyakarta, DI Yogyakarta", "koordinat": "-7.7956, 110.3695"},
    {"nama": "Medan, Sumatera Utara", "koordinat": "3.5952, 98.6722"},
    {"nama": "Denpasar, Bali", "koordinat": "-8.6705, 115.2126"},
    {"nama": "Makassar, Sulawesi Selatan", "koordinat": "-5.1476, 119.4327"},
  ];

  void _showLocationPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              color: sheetBgColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF475569)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Pilih Lokasi Laporan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Option 1: Gunakan GPS
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F4C43).withOpacity(0.3)
                            : const Color(0xFFF0FDFA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.my_location, color: activeTeal),
                    ),
                    title: Text(
                      "Gunakan Lokasi GPS Saat Ini",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      "Mendeteksi lokasi otomatis via GPS",
                      style: TextStyle(color: subTextColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _determineGPSPosition();
                    },
                  ),
                  Divider(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pilih Wilayah Nasional",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // List of sub-districts
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: wilayahNasional.length,
                      itemBuilder: (context, index) {
                        final kec = wilayahNasional[index];
                        return ListTile(
                          title: Text(
                            kec['nama']!,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Koordinat: ${kec['koordinat']}",
                            style: TextStyle(color: subTextColor),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: subTextColor,
                          ),
                          onTap: () {
                            setState(() {
                              currentLokasi = kec['nama']!;
                              currentKoordinat = kec['koordinat']!;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
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

  Future<void> _determineGPSPosition() async {
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        dialogContext = dialogCtx;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: activeTeal),
                const SizedBox(height: 20),
                Text(
                  "Mencari Sinyal GPS...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mendeteksi lokasi asli Anda",
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Layanan lokasi (GPS) dinonaktifkan di perangkat Anda.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak oleh pengguna.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak secara permanen. Harap aktifkan izin di pengaturan perangkat Anda.';
      }

      // Fetch position with a timeout to prevent hanging forever
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
        dialogContext = null;
      }

      if (!mounted) return;

      final double lat = position.latitude;
      final double lon = position.longitude;

      String resolvedAddress = "";

      // Try to get address from reverse geocoding via standard HttpClient
      try {
        final client = HttpClient();
        // Nominatim guidelines require a valid User-Agent
        client.userAgent =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) LatihanFlutterD7/1.0";
        final request = await client
            .getUrl(
              Uri.parse(
                'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=16',
              ),
            )
            .timeout(const Duration(seconds: 3));

        final response = await request.close();
        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final decoded = json.decode(responseBody);
          final address = decoded['address'];
          if (address != null) {
            final road =
                address['road'] ??
                address['suburb'] ??
                address['village'] ??
                '';
            final city =
                address['city'] ??
                address['town'] ??
                address['city_district'] ??
                address['municipality'] ??
                address['county'] ??
                '';
            final state = address['state'] ?? '';

            List<String> parts = [];
            if (road.toString().isNotEmpty) parts.add(road.toString());
            if (city.toString().isNotEmpty) parts.add(city.toString());
            if (state.toString().isNotEmpty) parts.add(state.toString());

            if (parts.isNotEmpty) {
              resolvedAddress = parts.join(', ');
            }
          }
          if (resolvedAddress.isEmpty) {
            resolvedAddress = decoded['display_name'] ?? "";
          }
        }
      } catch (_) {}

      // Fallback if reverse geocoding was empty or failed
      if (resolvedAddress.isEmpty) {
        Map<String, String> nearestCity = wilayahNasional.first;
        double minDistance = double.infinity;
        for (final city in wilayahNasional) {
          final parts = city['koordinat']!.split(',');
          if (parts.length == 2) {
            final cLat = double.tryParse(parts[0].trim()) ?? 0.0;
            final cLon = double.tryParse(parts[1].trim()) ?? 0.0;
            final double dist =
                (lat - cLat) * (lat - cLat) + (lon - cLon) * (lon - cLon);
            if (dist < minDistance) {
              minDistance = dist;
              nearestCity = city;
            }
          }
        }
        resolvedAddress = nearestCity['nama']!;
      }

      setState(() {
        currentLokasi =
            "$resolvedAddress (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})";
        currentKoordinat =
            "${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}";
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lokasi GPS berhasil diperbarui: $currentLokasi"),
          backgroundColor: activeTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mendeteksi lokasi: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPhotoSourcePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: sheetBgColor,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pilih Foto Bukti",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F4C43).withOpacity(0.3)
                                : const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: activeTeal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Ambil Foto",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F4C43).withOpacity(0.3)
                                : const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: activeTeal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pilih dari Galeri",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 40, // Mengurangi kualitas agar ukuran string Base64 kecil
        maxWidth: 600,    // Membatasi lebar gambar maks 600px
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final base64Url = 'data:image/jpeg;base64,$base64String';
        setState(() {
          selectedPhotos.add(base64Url);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengambil foto: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/confuse.json',
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Tolong tunggu...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sedang mengirim laporan Anda ke sistem.",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            : const Color(0xFFF4F8FB);
        final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color textColor = isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF0F172A);
        final Color subTextColor = isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);
        final Color borderColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0);
        final Color labelColor = isDark
            ? const Color(0xFFE2E8F0)
            : const Color(0xFF1E293B);
        final Color inputFillColor = isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : primaryTeal,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporanBeranda(),
                    ),
                  );
                }
              },
            ),
            title: Text(
              lang == 'en' ? "Create New Report" : "Buat Laporan Baru",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gradient Curved Header Banner
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF0F172A),
                                  ]
                                : [primaryTeal, activeTeal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang == 'en'
                                        ? "Report Environmental Issues"
                                        : "Laporkan Masalah Lingkungan",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lang == 'en'
                                        ? "Your active participation helps us preserve the environment."
                                        : "Partisipasi aktif Anda membantu kami menjaga kelestarian lingkungan.",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_task_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card 1: Informasi Detail Laporan
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.3 : 0.02,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Kategori Dropdown
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        color: activeTeal,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lang == 'en'
                                            ? "Report Category"
                                            : "Kategori Laporan",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: labelColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "*",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: inputFillColor,
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedDropdown,
                                        hint: Text(
                                          lang == 'en'
                                              ? "Select Category..."
                                              : "Pilih Kategori...",
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF64748B)
                                                : Colors.grey[400],
                                            fontSize: 13,
                                          ),
                                        ),
                                        isExpanded: true,
                                        dropdownColor: cardColor,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey,
                                        ),
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                        ),
                                        items: _daftarKategori.map((
                                          Map<String, dynamic> cat,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: cat["nama"] as String,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  cat["icon"] as IconData,
                                                  color: cat["color"] as Color,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  (cat["nama"] as String) ==
                                                          'Pembakaran Sampah'
                                                      ? (lang == 'en'
                                                            ? 'Waste Burning'
                                                            : 'Pembakaran Sampah')
                                                      : ((cat["nama"]
                                                                    as String) ==
                                                                'Asap Industri / Pabrik'
                                                            ? (lang == 'en'
                                                                  ? 'Industrial Smoke'
                                                                  : 'Asap Industri / Pabrik')
                                                            : ((cat["nama"]
                                                                          as String) ==
                                                                      'Asap Kendaraan'
                                                                  ? (lang ==
                                                                            'en'
                                                                        ? 'Vehicle Smoke'
                                                                        : 'Asap Kendaraan')
                                                                  : ((cat["nama"]
                                                                                as String) ==
                                                                            'Debu & Konstruksi'
                                                                        ? (lang ==
                                                                                  'en'
                                                                              ? 'Dust & Construction'
                                                                              : 'Debu & Konstruksi')
                                                                        : ((cat["nama"] as String) ==
                                                                                  'Polusi Bau & Gas'
                                                                              ? (lang ==
                                                                                        'en'
                                                                                    ? 'Odor & Gas'
                                                                                    : 'Polusi Bau & Gas')
                                                                              : ((cat["nama"] as String) ==
                                                                                        'Lainnya'
                                                                                    ? (lang ==
                                                                                              'en'
                                                                                          ? 'Others'
                                                                                          : 'Lainnya')
                                                                                    : (cat["nama"] as String)))))),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedDropdown = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // 2. Judul Laporan
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.title_rounded,
                                        color: activeTeal,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lang == 'en'
                                            ? "Report Title"
                                            : "Judul Laporan",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: labelColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "*",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: judulController,
                                    maxLength: 100,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: lang == 'en'
                                          ? "Write a brief report title..."
                                          : "Tulis judul laporan singkat...",
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : Colors.grey[400],
                                      ),
                                      counterText: "$titleLength/100",
                                      counterStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : Colors.grey[400],
                                        fontSize: 11,
                                      ),
                                      filled: true,
                                      fillColor: inputFillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 16,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: borderColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: activeTeal,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 3. Deskripsi
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note_rounded,
                                        color: activeTeal,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        lang == 'en'
                                            ? "Event Description"
                                            : "Deskripsi Kejadian",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: labelColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "*",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: deskripsiController,
                                    maxLines: 5,
                                    maxLength: 500,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: lang == 'en'
                                          ? "Explain the timeline of the event in detail..."
                                          : "Jelaskan kronologi kejadian secara detail...",
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : Colors.grey[400],
                                      ),
                                      counterText: "$descLength/500",
                                      counterStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : Colors.grey[400],
                                        fontSize: 11,
                                      ),
                                      filled: true,
                                      fillColor: inputFillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 16,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: borderColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: activeTeal,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Card 2: Lokasi Kejadian
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.3 : 0.02,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            color: activeTeal,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            lang == 'en'
                                                ? "Event Location"
                                                : "Lokasi Kejadian",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: labelColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: _showLocationPicker,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(
                                                    0xFF0F4C43,
                                                  ).withOpacity(0.3)
                                                : const Color(0xFFF0FDFA),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: activeTeal.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.gps_fixed_rounded,
                                                color: activeTeal,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                lang == 'en'
                                                    ? "Change Location"
                                                    : "Ubah Lokasi",
                                                style: TextStyle(
                                                  color: activeTeal,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Real Interactive Map
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: SimulatedMapWidget(
                                        key: ValueKey(currentKoordinat),
                                        locationName: currentLokasi,
                                        koordinatStr: currentKoordinat,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Card 3: Foto Bukti
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.3 : 0.02,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.photo_camera_rounded,
                                        color: activeTeal,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lang == 'en'
                                            ? "Evidence Photos"
                                            : "Foto Bukti Kejadian",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: labelColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        "*",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  if (selectedPhotos.isEmpty)
                                    DashedUploadArea(
                                      activeTeal: activeTeal,
                                      onTap: _showPhotoSourcePicker,
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          ...List.generate(selectedPhotos.length, (
                                            index,
                                          ) {
                                            final imgUrl =
                                                selectedPhotos[index];
                                            return Stack(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 12,
                                                    top: 6,
                                                    bottom: 6,
                                                  ),
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: borderColor,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(
                                                              isDark
                                                                  ? 0.2
                                                                  : 0.05,
                                                            ),
                                                        blurRadius: 6,
                                                        offset: const Offset(
                                                          0,
                                                          3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    child: ReportImage(
                                                      path: imgUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                // Remove photo badge button
                                                Positioned(
                                                  top: 0,
                                                  right: 6,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedPhotos.removeAt(
                                                          index,
                                                        );
                                                      });
                                                    },
                                                    child: const CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 12,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                          // Tambah foto button with dashed design
                                          if (selectedPhotos.length < 5)
                                            GestureDetector(
                                              onTap: _showPhotoSourcePicker,
                                              child: CustomPaint(
                                                painter: DashedBorderPainter(
                                                  color: activeTeal.withOpacity(
                                                    0.4,
                                                  ),
                                                  strokeWidth: 1.5,
                                                  gap: 4,
                                                ),
                                                child: Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: inputFillColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.add_a_photo_outlined,
                                                    color: activeTeal,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang == 'en'
                                            ? "Maximum 5 evidence photos"
                                            : "Maksimal 5 foto bukti",
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (selectedPhotos.isNotEmpty)
                                        Text(
                                          "${selectedPhotos.length}/5 ${lang == 'en' ? "Photos Selected" : "Foto Terpilih"}",
                                          style: TextStyle(
                                            color: activeTeal,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Gradient Submit Button
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryTeal, activeTeal],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryTeal.withOpacity(0.35),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (selectedDropdown == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Silakan pilih kategori laporan terlebih dahulu!",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  if (judulController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Judul laporan tidak boleh kosong!",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  if (deskripsiController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Deskripsi laporan tidak boleh kosong!",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  if (selectedPhotos.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Harap tambahkan minimal 1 foto bukti!",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  final DateTime now = DateTime.now();
                                  final String formattedDateStr = DateFormat(
                                    'dd MMM yyyy',
                                    'id_ID',
                                  ).format(now);
                                  final String formattedTimeStr = DateFormat(
                                    'dd MMMM yyyy, HH:mm',
                                    'id_ID',
                                  ).format(now);

                                  // Tampilkan loading dialog dengan animasi Lottie
                                  _showLoadingDialog(context);
                                  await Future.delayed(const Duration(milliseconds: 250));

                                  try {
                                    final count = await FirebaseAuthService
                                        .instance
                                        .getLaporanCount();
                                    final String reportNum =
                                        "#LP${DateFormat('yyMMdd').format(now)}${100 + (count % 900)}";

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userId =
                                        prefs.getInt('current_user_id') ?? 1;
                                    final userFirestoreId = prefs.getString(
                                      'current_user_firestore_id',
                                    );

                                    // Build LaporanModel object
                                    final newReport = LaporanModel(
                                      judul: judulController.text.trim(),
                                      kategori: selectedDropdown!,
                                      lokasi: currentLokasi,
                                      koordinat: currentKoordinat,
                                      deskripsi: deskripsiController.text
                                          .trim(),
                                      status: "Diproses",
                                      tanggal: formattedDateStr,
                                      userId: userId,
                                      userFirestoreId: userFirestoreId,
                                      foto: selectedPhotos.isNotEmpty
                                          ? selectedPhotos.join(',')
                                          : 'assets/images/logo_ruas.png',
                                    );

                                    // Save to Firebase DB
                                    final insertedId = await FirebaseAuthService
                                        .instance
                                        .createLaporan(newReport);
                                    final savedReport = LaporanModel(
                                      firestoreId: insertedId,
                                      judul: newReport.judul,
                                      kategori: newReport.kategori,
                                      lokasi: newReport.lokasi,
                                      koordinat: newReport.koordinat,
                                      deskripsi: newReport.deskripsi,
                                      status: newReport.status,
                                      tanggal: newReport.tanggal,
                                      userId: newReport.userId,
                                      userFirestoreId:
                                          newReport.userFirestoreId,
                                      foto: newReport.foto,
                                    );

                                    // Tutup loading dialog
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }

                                    // Redirect to confirmation
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              KonfirmasiLaporan(
                                                nomorLaporan: reportNum,
                                                tanggal: formattedTimeStr,
                                                kategori: selectedDropdown!,
                                                report: savedReport,
                                              ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // Tutup loading jika terjadi error
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                    // Tampilkan snackbar error
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Gagal mengirim laporan: $e",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Kirim Laporan Sekarang",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Vector simulated Map grid drawing
class SimulatedMapWidget extends StatelessWidget {
  final String locationName;
  final String koordinatStr;
  const SimulatedMapWidget({
    super.key,
    required this.locationName,
    required this.koordinatStr,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mapBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final Color infoBg = isDark
        ? const Color(0xFF1E293B).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);
    final Color infoText = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final Color infoBorder = isDark
        ? const Color(0xFF334155)
        : Colors.transparent;

    final parts = koordinatStr.split(',');
    double lat = -6.8894;
    double lon = 106.7914;
    if (parts.length == 2) {
      lat = double.tryParse(parts[0].trim()) ?? -6.8894;
      lon = double.tryParse(parts[1].trim()) ?? 106.7914;
    }
    final position = LatLng(lat, lon);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: mapBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: position,
                initialZoom: 15.0,
                minZoom: 10.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ruas.id',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: position,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Floating location info card
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: infoBg,
                  border: Border.all(color: infoBorder),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF0D9488),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        locationName
                            .replaceAll(RegExp(r'\([-0-9.,\s]+\)'), '')
                            .trim(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: infoText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    path.addRRect(rrect);

    final Path dashedPath = Path();
    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final double len = gap * 2;
        dashedPath.addPath(
          metric.extractPath(distance, min(distance + gap, metric.length)),
          Offset.zero,
        );
        distance += len;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedUploadArea extends StatelessWidget {
  final VoidCallback onTap;
  final Color activeTeal;
  const DashedUploadArea({
    super.key,
    required this.onTap,
    required this.activeTeal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color areaBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color textColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF334155);

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: activeTeal.withOpacity(0.4),
          strokeWidth: 1.5,
          gap: 6,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: areaBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: activeTeal, size: 36),
              const SizedBox(height: 8),
              Text(
                "Unggah Foto Bukti",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap untuk mengambil foto atau memilih dari galeri",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF64748B) : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
