// --- MODEL CLASS UNTUK LEVEL 3 ---
class Alatpantau {
  final String nama;
  final String deskripsi;
  final String pathGambar;
  final String status;
  final String waktu;

  Alatpantau({
    required this.nama,
    required this.deskripsi,
    required this.pathGambar,
    required this.status,
    required this.waktu,
  });
}

class AppImage1 {
  static const String logo = 'assets/images/logo_ruas.png';
  static const String avatar = 'assets/images/profile.webp';
}

// --- DATA SOURCE REPOSITORY ---
class RuasData {
  // Level 1: List String Sederhana
  static final List<String> listSederhana = [
    "Karbon Monoksida (CO)",
    "Partikulat (PM2.5)",
    "Partikulat (PM10)",
    "Sulfur Dioksida (SO2)",
    "Ozon (O3)",
    "Nitrogen Dioksida (NO2)",
    "Indeks Standar Pencemar (ISPU)",
    "Kelembapan Udara",
    "Suhu Lingkungan",
    "Zona Hijau Kota",
  ];

  // Level 2: List of Maps
  static final List<Map<String, dynamic>> listofMap = [
    {"nama": "Pembuangan Sampah", "gambar": "assets/images/sensor_indoor.png"},
    {"nama": "Pembakaran Sampah", "gambar": "assets/images/sensor_indoor.png"},
    {"nama": "Polusi Udara", "gambar": "assets/images/sensor_indoor.png"},
    {"nama": "Limbah Cair", "gambar": "assets/images/sensor_indoor.png"},
    {"nama": "Kebisingan", "gambar": "assets/images/sensor_indoor.png"},
    {"nama": "Lainnya", "gambar": "assets/images/sensor_indoor.png"},
  ];

  // Level 3: List of Model Objects
  static final List<Alatpantau> listModel = [
    Alatpantau(
      nama: "Pembuangan Sampah Sembarangan",
      deskripsi: "Jakarta Pusat, DKI Jakarta",
      pathGambar: "assets/images/sensor_indoor.png",
      status: "DIPROSES",
      waktu: "2 Jam yang lalu",
    ),
    Alatpantau(
      nama: "Pembuangan Sampah Sembarangan",
      deskripsi: "Bandung, Jawa Barat",
      pathGambar: "assets/images/sensor_indoor.png",
      status: "DIPROSES",
      waktu: "2 Jam yang lalu",
    ),
  ];
}

