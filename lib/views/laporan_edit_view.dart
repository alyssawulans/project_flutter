import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_flutter/database/ruas_db_helper.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/widgets/dashed_border_painter.dart';

class LaporanEditView extends StatefulWidget {
  final LaporanModel laporan;
  const LaporanEditView({super.key, required this.laporan});

  @override
  State<LaporanEditView> createState() => _LaporanEditViewState();
}

class _LaporanEditViewState extends State<LaporanEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _lokasiController;
  late TextEditingController _deskripsiController;

  late String _selectedKategori;
  late String _koordinat;
  late String _selectedStatus;
  String? _pickedImagePath;
  bool _isGettingLocation = false;
  bool _isSaving = false;

  final List<String> _kategoriList = [
    'Sampah',
    'Udara',
    'Limbah Cair',
    'Polusi Udara',
    'Kebisingan',
    'Lainnya',
  ];

  final List<String> _statusList = [
    'Diproses',
    'Selesai',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.laporan.judul);
    _lokasiController = TextEditingController(text: widget.laporan.lokasi);
    _deskripsiController = TextEditingController(text: widget.laporan.deskripsi);
    _selectedKategori = widget.laporan.kategori;
    _koordinat = widget.laporan.koordinat;
    _selectedStatus = widget.laporan.status;
    _pickedImagePath = widget.laporan.foto.isNotEmpty ? widget.laporan.foto : null;
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
      } else {
        throw Exception('Izin lokasi ditolak');
      }
    } catch (e) {
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
        imageQuality: 70,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
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
                  _pickedImagePath = 'assets/images/kota_5.jpeg';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final updated = LaporanModel(
      id: widget.laporan.id,
      judul: _judulController.text.trim(),
      kategori: _selectedKategori,
      lokasi: _lokasiController.text.trim(),
      koordinat: _koordinat,
      deskripsi: _deskripsiController.text.trim(),
      status: _selectedStatus,
      tanggal: widget.laporan.tanggal, // Keep original reporting date
      userId: widget.laporan.userId,
      foto: _pickedImagePath ?? widget.laporan.foto,
    );

    await RuasDbHelper.instance.updateLaporan(updated);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil diperbarui!'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, updated); // pop and return updated report to detail screen
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
          'Ubah Laporan',
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
                // Judul Laporan
                Text('Judul Laporan *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _judulController,
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

                // Status Laporan (Kunci Demonstrasi Presentasi)
                Text('Status Laporan *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
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
                  items: _statusList.map((stat) {
                    return DropdownMenuItem(
                      value: stat,
                      child: Text(stat, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStatus = val!;
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
                                Text(
                                  'Ambil Foto Bukti Kejadian',
                                  style: TextStyle(fontSize: 12, color: const Color(0xFF0D9488), fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _pickedImagePath!.startsWith('assets/')
                                  ? Image.asset(
                                      _pickedImagePath!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_pickedImagePath!),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: borderColor),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _updateLaporan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Perbarui', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
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

