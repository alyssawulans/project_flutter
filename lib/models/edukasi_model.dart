class EdukasiModel {
  final int? id;
  final String? firestoreId; // Untuk Firebase Document ID
  final String judul;
  final String kategori;
  final String konten;
  final String gambar; // can be asset path or local file path
  final String tanggal;

  EdukasiModel({
    this.id,
    this.firestoreId,
    required this.judul,
    required this.kategori,
    required this.konten,
    required this.gambar,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestore_id': firestoreId,
      'judul': judul,
      'kategori': kategori,
      'konten': konten,
      'gambar': gambar,
      'tanggal': tanggal,
    };
  }

  factory EdukasiModel.fromMap(Map<String, dynamic> map) {
    return EdukasiModel(
      id: map['id'],
      firestoreId: map['firestore_id'],
      judul: map['judul'] ?? '',
      kategori: map['kategori'] ?? '',
      konten: map['konten'] ?? '',
      gambar: map['gambar'] ?? '',
      tanggal: map['tanggal'] ?? '',
    );
  }
}

