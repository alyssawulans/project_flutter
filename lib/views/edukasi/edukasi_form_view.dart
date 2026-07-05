import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/edukasi_model.dart';

class EdukasiFormView extends StatefulWidget {
  final EdukasiModel? article;
  const EdukasiFormView({super.key, this.article});

  @override
  State<EdukasiFormView> createState() => _EdukasiFormViewState();
}

class _EdukasiFormViewState extends State<EdukasiFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _kontenController;

  late String _selectedKategori;
  late String _selectedGambar;
  bool _isSaving = false;

  final List<String> _kategoriList = ['Udara', 'Sampah', 'Kesehatan', 'Umum'];

  // Map representation of preset pictures from our assets list
  final List<Map<String, String>> _presetImages = [
    {'name': 'Sensor Indoor (Teal)', 'path': 'assets/images/sensor_indoor.png'},
    {'name': 'Sensor Temperature (Red)', 'path': 'assets/images/sensor_temp.png'},
    {'name': 'Sensor Ozone (Purple)', 'path': 'assets/images/sensor_ozone.png'},
    {'name': 'Sensor Car (Orange)', 'path': 'assets/images/sensor_car.png'},
    {'name': 'Sensor Outdoor (Blue)', 'path': 'assets/images/sensor_outdoor.png'},
  ];

  @override
  void initState() {
    super.initState();
    final isEditing = widget.article != null;
    _judulController = TextEditingController(text: isEditing ? widget.article!.judul : '');
    _kontenController = TextEditingController(text: isEditing ? widget.article!.konten : '');
    _selectedKategori = isEditing ? widget.article!.kategori : 'Udara';
    _selectedGambar = isEditing ? widget.article!.gambar : 'assets/images/sensor_indoor.png';
  }

  void _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(now);

    final item = EdukasiModel(
      id: widget.article?.id,
      firestoreId: widget.article?.firestoreId,
      judul: _judulController.text.trim(),
      kategori: _selectedKategori,
      konten: _kontenController.text.trim(),
      gambar: _selectedGambar,
      tanggal: widget.article?.tanggal ?? formattedDate,
    );

    if (widget.article == null) {
      await FirebaseAuthService.instance.createEdukasi(item);
    } else {
      await FirebaseAuthService.instance.updateEdukasi(item);
    }

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.article == null ? 'Artikel berhasil dibuat!' : 'Artikel berhasil diperbarui!'),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context, item);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.article != null;
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
          isEditing ? 'Ubah Artikel' : 'Tulis Artikel Baru',
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
                // Judul
                Text('Judul Artikel *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _judulController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Apa itu Partikulat PM2.5?',
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
                      return 'Judul artikel wajib diisi';
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

                // Preset Gambar
                Text('Ilustrasi Gambar *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: _presetImages.length,
                    itemBuilder: (context, index) {
                      final img = _presetImages[index];
                      final isSelected = _selectedGambar == img['path'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGambar = img['path']!;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(img['path']!, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Konten
                Text('Konten Artikel *', style: TextStyle(fontWeight: FontWeight.bold, color: labelColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _kontenController,
                  maxLines: 8,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Tulis penjelasan lengkap mengenai isu lingkungan di sini...',
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
                      return 'Konten artikel wajib diisi';
                    }
                    return null;
                  },
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
                        onPressed: _isSaving ? null : _saveArticle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEditing ? 'Perbarui' : 'Simpan', style: const TextStyle(fontWeight: FontWeight.bold)),
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

