import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/widgets/dashed_border_painter.dart';
import 'package:project_flutter/widgets/report_image.dart';

class LaporanAddView extends StatefulWidget {
  const LaporanAddView({super.key});

  @override
  State<LaporanAddView> createState() => _LaporanAddViewState();
}

class _LaporanAddViewState extends State<LaporanAddView> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _selectedKategori = 'Pembakaran Sampah';
  String _koordinat = '-6.1818, 106.8223';
  String? _pickedImagePath;
  bool _isGettingLocation = false;
  bool _isSaving = false;

  final List<String> _kategoriList = [
    'Pembakaran Sampah',
    'Asap Industri / Pabrik',
    'Asap Kendaraan',
    'Debu & Konstruksi',
    'Polusi Bau & Gas',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _lokasiController.text = 'Jakarta Pusat, DKI Jakarta';
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        setState(() {
          _koordinat = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _lokasiController.text = 'DKI Jakarta (GPS Terdeteksi)';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lokasi berhasil diambil dari GPS HP!'),
              backgroundColor: Color(0xFF0D9488),
            ),
          );
        }
      } else {
        throw Exception('Izin lokasi ditolak');
      }
    } catch (e) {
      // Fail gracefully, use simulation
      setState(() {
        _koordinat = '-6.9175, 107.6191';
        _lokasiController.text = 'Bandung, Jawa Barat (Simulasi)';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menggunakan simulasi lokasi: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80, // Kualitas ditingkatkan untuk upload Firebase Storage
        maxWidth: 1024,
      );

      if (image != null) {
        setState(() {
          _pickedImagePath = image.path; // Simpan path lokal, upload ke Firebase Storage saat submit
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D9488)),
              title: Text('Kamera', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0D9488)),
              title: Text('Galeri', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: Text('Gunakan Dummy Asset', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _pickedImagePath = 'assets/images/kota_4.jpeg';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id') ?? 1;
    final userFirestoreId = prefs.getString('current_user_firestore_id');

    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(now);

    final newReport = LaporanModel(
      judul: _judulController.text.trim(),
      kategori: _selectedKategori,
      lokasi: _lokasiController.text.trim(),
      koordinat: _koordinat,
      deskripsi: _deskripsiController.text.trim(),
      status: 'Diproses',
      tanggal: formattedDate,
      userId: userId,
      userFirestoreId: userFirestoreId,
      foto: _pickedImagePath ?? 'assets/images/logo_ruas.png',
    );

    try {
      await FirebaseAuthService.instance.createLaporan(newReport);

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil disimpan!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan laporan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.black38;
    final Color labelColor = isDark ? const Color(0xFFE2E8F0) : Colors.black87;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final Color bannerBg = isDark ? const Color(0xFF0F2625) : const Color(0xFFF0FDFA);
    final Color bannerBorder = isDark ? const Color(0xFF134E4A) : const Color(0xFFCCFBF1);
    final Color bannerText = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppSettingsController.instance.settingsNotifier.value.languageCode == 'en' ? 'Create New Report' : 'Buat Laporan Baru',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info header banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bannerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bannerBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF0D9488)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Laporkan pencemaran udara, tumpukan sampah, atau masalah lingkungan untuk ditindaklanjuti.',
                          style: TextStyle(fontSize: 12, color: bannerText, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Judul Laporan
                Text('Judul Laporan *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _judulController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Pembuangan sampah sembarangan',
                    hintStyle: TextStyle(color: subTextColor),
                    fillColor: cardColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul laporan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori
                Text('Kategori *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    fillColor: cardColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                    ),
                  ),
                  items: _kategoriList.map((kat) {
                    return DropdownMenuItem(
                      value: kat,
                      child: Text(kat, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedKategori = val!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Lokasi
                Text('Lokasi Kejadian *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lokasiController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Masukkan alamat lokasi kejadian',
                    hintStyle: TextStyle(color: subTextColor),
                    fillColor: cardColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                    ),
                    suffixIcon: _isGettingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488)),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.my_location, color: Color(0xFF0D9488)),
                            onPressed: _getCurrentLocation,
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lokasi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Koordinat Terpilih: $_koordinat',
                  style: TextStyle(fontSize: 11, color: subTextColor, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                Text('Deskripsi Detail *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Jelaskan kondisi laporan secara detail agar mudah ditindaklanjuti...',
                    hintStyle: TextStyle(color: subTextColor),
                    fillColor: cardColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Foto Bukti
                Text('Foto Bukti (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                        borderRadius: 10,
                      ),
                      child: _pickedImagePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt_outlined, size: 40, color: Color(0xFF0D9488)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Ambil Foto Bukti Kejadian',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Klik untuk membuka Kamera / Galeri',
                                  style: TextStyle(fontSize: 10, color: subTextColor),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ReportImage(
                                path: _pickedImagePath!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                if (_pickedImagePath != null) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _pickedImagePath = null;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                    label: const Text('Hapus Foto', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveLaporan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Laporan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

