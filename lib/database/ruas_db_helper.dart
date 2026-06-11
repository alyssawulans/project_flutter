import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:project_flutter/models/user_model.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/models/edukasi_model.dart';

class RuasDbHelper {
  static final RuasDbHelper instance = RuasDbHelper._init();
  static Database? _database;

  RuasDbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ruas_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN tempat_lahir TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN tanggal_lahir TEXT');
    }
    if (oldVersion < 3) {
      try {
        await db.execute("ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'");
      } catch (_) {}
      
      try {
        final adminExists = await db.rawQuery("SELECT id FROM users WHERE email = 'admin.ruas@gmail.com'");
        if (adminExists.isEmpty) {
          await db.insert('users', {
            'nama': 'Admin RUAS',
            'email': 'admin.ruas@gmail.com',
            'nomor_telp': '081234567891',
            'password': 'admin123',
            'tanggal_daftar': '24 Sep 2023',
            'role': 'admin',
          });
        }
      } catch (_) {}
    }
  }

  Future _createDB(Database db, int version) async {
    // 1. Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        nomor_telp TEXT NOT NULL,
        password TEXT NOT NULL,
        tanggal_daftar TEXT NOT NULL,
        tempat_lahir TEXT,
        tanggal_lahir TEXT,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');

    // 2. Create laporan table
    await db.execute('''
      CREATE TABLE laporan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        kategori TEXT NOT NULL,
        lokasi TEXT NOT NULL,
        koordinat TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        status TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        foto TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 3. Create edukasi table
    await db.execute('''
      CREATE TABLE edukasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        kategori TEXT NOT NULL,
        konten TEXT NOT NULL,
        gambar TEXT NOT NULL,
        tanggal TEXT NOT NULL
      )
    ''');

    // Seed Initial Data
    await _seedInitialData(db);
  }

  Future _seedInitialData(Database db) async {
    // Seed default user
    int userId = await db.insert('users', {
      'nama': 'Andi Pratama',
      'email': 'andi.pratama@gmail.com',
      'nomor_telp': '081234567890',
      'password': 'password123',
      'tanggal_daftar': '24 Sep 2023',
      'role': 'user',
    });

    // Seed default admin
    await db.insert('users', {
      'nama': 'Admin RUAS',
      'email': 'admin.ruas@gmail.com',
      'nomor_telp': '081234567891',
      'password': 'admin123',
      'tanggal_daftar': '24 Sep 2023',
      'role': 'admin',
    });

    // Seed 3 reports for this user
    await db.insert('laporan', {
      'judul': 'Pembuangan Sampah Sembarangan',
      'kategori': 'Sampah',
      'lokasi': 'Jakarta Pusat, DKI Jakarta',
      'koordinat': '-6.1818, 106.8223',
      'deskripsi': 'Terjadi pembuangan sampah rumah tangga di pinggir jalan dekat sungai. Bau menyengat dan mengganggu lingkungan sekitar.',
      'status': 'Diproses',
      'tanggal': '24 Sep 2023',
      'user_id': userId,
      'foto': 'assets/images/kota_1.jpg',
    });

    await db.insert('laporan', {
      'judul': 'Pembakaran Sampah',
      'kategori': 'Sampah',
      'lokasi': 'Bandung, Jawa Barat',
      'koordinat': '-6.9175, 107.6191',
      'deskripsi': 'Pembakaran sampah liar dekat pemukiman warga secara berkala, menimbulkan asap tebal dan sesak napas.',
      'status': 'Selesai',
      'tanggal': '23 Sep 2023',
      'user_id': userId,
      'foto': 'assets/images/kota_2.jpg',
    });

    await db.insert('laporan', {
      'judul': 'Polusi Udara (Kendaraan Asap Tebal)',
      'kategori': 'Udara',
      'lokasi': 'Surabaya, Jawa Timur',
      'koordinat': '-7.2575, 112.7521',
      'deskripsi': 'Truk industri menghasilkan asap hitam pekat saat melintas di jalan raya utama.',
      'status': 'Diproses',
      'tanggal': '22 Sep 2023',
      'user_id': userId,
      'foto': 'assets/images/kota_3.jpg',
    });

    // Seed 3 educational articles
    await db.insert('edukasi', {
      'judul': 'Apa itu PM2.5?',
      'kategori': 'Udara',
      'konten': 'PM2.5 adalah partikel udara yang berukuran lebih kecil dari 2.5 mikron (mikrometer). Partikel ini sangat kecil sehingga dapat menembus masker biasa dan langsung masuk ke paru-paru hingga pembuluh darah, memicu berbagai penyakit pernapasan seperti asma dan ISPA. Sumber utama PM2.5 adalah kendaraan bermotor, pembakaran sampah, dan aktivitas industri.',
      'gambar': 'assets/images/sensor_indoor.png',
      'tanggal': '24 Sep 2023',
    });

    await db.insert('edukasi', {
      'judul': 'Dampak Polusi Udara Terhadap Kesehatan',
      'kategori': 'Udara',
      'konten': 'Polusi udara tidak hanya menyebabkan batuk dan sesak napas jangka pendek. Paparan jangka panjang dapat meningkatkan risiko penyakit jantung, stroke, kanker paru-paru, dan mengurangi angka harapan hidup. Sangat disarankan memakai masker standar N95 saat indeks kualitas udara (AQI) sedang buruk.',
      'gambar': 'assets/images/sensor_temp.png',
      'tanggal': '22 Sep 2023',
    });

    await db.insert('edukasi', {
      'judul': 'Cara Mengurangi Polusi Udara',
      'kategori': 'Udara',
      'konten': 'Kita bisa berkontribusi dengan: menggunakan transportasi umum, menghindari pembakaran sampah terbuka, menanam pohon di sekitar rumah, dan menghemat penggunaan energi listrik yang mayoritas masih diproduksi dari batu bara.',
      'gambar': 'assets/images/sensor_ozone.png',
      'tanggal': '20 Sep 2023',
    });
  }

  // --- USER OPERATIONS ---
  Future<UserModel?> registerUser(UserModel user) async {
    final db = await instance.database;
    try {
      final id = await db.insert('users', user.toMap());
      return UserModel(
        id: id,
        nama: user.nama,
        email: user.email,
        nomorTelp: user.nomorTelp,
        password: user.password,
        tanggalDaftar: user.tanggalDaftar,
        tempatLahir: user.tempatLahir,
        tanggalLahir: user.tanggalLahir,
      );
    } catch (e) {
      // Email duplicate error
      return null;
    }
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserProfile(int id, String nama, String nomorTelp, {String? tempatLahir, String? tanggalLahir}) async {
    final db = await instance.database;
    final Map<String, dynamic> values = {
      'nama': nama,
      'nomor_telp': nomorTelp,
    };
    if (tempatLahir != null) {
      values['tempat_lahir'] = tempatLahir;
    }
    if (tanggalLahir != null) {
      values['tanggal_lahir'] = tanggalLahir;
    }
    return await db.update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserPassword(int id, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- LAPORAN OPERATIONS ---
  Future<int> createLaporan(LaporanModel laporan) async {
    final db = await instance.database;
    return await db.insert('laporan', laporan.toMap());
  }

  Future<List<LaporanModel>> getLaporans({int? userId, String? status, String? category}) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }

    if (status != null && status != 'Semua') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'status = ?';
      whereArgs.add(status);
    }

    if (category != null && category != 'Semua') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'kategori = ?';
      whereArgs.add(category);
    }

    final result = await db.query(
      'laporan',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );

    return result.map((json) => LaporanModel.fromMap(json)).toList();
  }

  Future<int> updateLaporan(LaporanModel laporan) async {
    final db = await instance.database;
    return await db.update(
      'laporan',
      laporan.toMap(),
      where: 'id = ?',
      whereArgs: [laporan.id],
    );
  }

  Future<int> deleteLaporan(int id) async {
    final db = await instance.database;
    return await db.delete(
      'laporan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getLaporanCount({int? userId}) async {
    final db = await instance.database;
    final maps = await db.rawQuery(
      userId != null
          ? 'SELECT COUNT(*) as count FROM laporan WHERE user_id = ?'
          : 'SELECT COUNT(*) as count FROM laporan',
      userId != null ? [userId] : null,
    );
    if (maps.isNotEmpty) {
      return maps.first['count'] as int;
    }
    return 0;
  }

  // --- EDUKASI OPERATIONS ---
  Future<int> createEdukasi(EdukasiModel edukasi) async {
    final db = await instance.database;
    return await db.insert('edukasi', edukasi.toMap());
  }

  Future<List<EdukasiModel>> getEdukasis({String? category}) async {
    final db = await instance.database;
    final result = await db.query(
      'edukasi',
      where: (category != null && category != 'Semua') ? 'kategori = ?' : null,
      whereArgs: (category != null && category != 'Semua') ? [category] : null,
      orderBy: 'id DESC',
    );

    return result.map((json) => EdukasiModel.fromMap(json)).toList();
  }

  Future<int> updateEdukasi(EdukasiModel edukasi) async {
    final db = await instance.database;
    return await db.update(
      'edukasi',
      edukasi.toMap(),
      where: 'id = ?',
      whereArgs: [edukasi.id],
    );
  }

  Future<int> deleteEdukasi(int id) async {
    final db = await instance.database;
    return await db.delete(
      'edukasi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getEdukasiCount() async {
    final db = await instance.database;
    final maps = await db.rawQuery('SELECT COUNT(*) as count FROM edukasi');
    if (maps.isNotEmpty) {
      return maps.first['count'] as int;
    }
    return 0;
  }
}

