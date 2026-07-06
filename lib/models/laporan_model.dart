class LaporanModel {
  final int? id;
  final String? firestoreId; // Untuk Firebase Document ID
  final String judul;
  final String kategori;
  final String lokasi;
  final String koordinat;
  final String deskripsi;
  final String status; // 'Diproses', 'Selesai', 'Ditolak'
  final String tanggal;
  final int userId;
  final String? userFirestoreId; // Untuk Firebase User UID
  final String foto; // local file path or empty if not present

  LaporanModel({
    this.id,
    this.firestoreId,
    required this.judul,
    required this.kategori,
    required this.lokasi,
    required this.koordinat,
    required this.deskripsi,
    required this.status,
    required this.tanggal,
    required this.userId,
    this.userFirestoreId,
    required this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestore_id': firestoreId,
      'judul': judul,
      'kategori': kategori,
      'lokasi': lokasi,
      'koordinat': koordinat,
      'deskripsi': deskripsi,
      'status': status,
      'tanggal': tanggal,
      'user_id': userId,
      'user_firestore_id': userFirestoreId,
      'foto': foto,
    };
  }

  factory LaporanModel.fromMap(Map<String, dynamic> map) {
    return LaporanModel(
      id: map['id'],
      firestoreId: map['firestore_id'],
      judul: map['judul'] ?? '',
      kategori: map['kategori'] ?? '',
      lokasi: map['lokasi'] ?? '',
      koordinat: map['koordinat'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      status: map['status'] ?? 'Diproses',
      tanggal: map['tanggal'] ?? '',
      userId: map['user_id'] ?? 0,
      userFirestoreId: map['user_firestore_id'],
      foto: map['foto'] ?? '',
    );
  }

  String get firstFoto {
    if (foto.isEmpty) return '';
    return foto.split(',').first;
  }

  List<String> get listFoto {
    if (foto.isEmpty) return [];
    return foto.split(',').where((url) => url.isNotEmpty).toList();
  }
}

