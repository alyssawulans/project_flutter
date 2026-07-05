import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project_flutter/models/laporan_model.dart';

part 'laporan_model_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class LaporanModelFirebase {
  final String? id; // Firebase Document ID
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

  LaporanModelFirebase({
    this.id,
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

  factory LaporanModelFirebase.fromJson(Map<String, dynamic> json) =>
      _$LaporanModelFirebaseFromJson(json);

  Map<String, dynamic> toJson() => _$LaporanModelFirebaseToJson(this);

  Map<String, dynamic> toMap() => toJson();

  factory LaporanModelFirebase.fromMap(Map<String, dynamic> map, {String? docId}) {
    final updatedMap = Map<String, dynamic>.from(map);
    if (docId != null) {
      updatedMap['id'] = docId;
    }
    return LaporanModelFirebase.fromJson(updatedMap);
  }

  factory LaporanModelFirebase.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LaporanModelFirebase.fromMap(data, docId: doc.id);
  }

  // Konversi dari LaporanModel biasa ke LaporanModelFirebase
  factory LaporanModelFirebase.fromLaporanModel(LaporanModel model, {String? firebaseId}) {
    return LaporanModelFirebase(
      id: firebaseId ?? model.firestoreId,
      judul: model.judul,
      kategori: model.kategori,
      lokasi: model.lokasi,
      koordinat: model.koordinat,
      deskripsi: model.deskripsi,
      status: model.status,
      tanggal: model.tanggal,
      userId: model.userId,
      userFirestoreId: model.userFirestoreId,
      foto: model.foto,
    );
  }

  // Konversi dari LaporanModelFirebase ke LaporanModel biasa
  LaporanModel toLaporanModel({int? sqliteId}) {
    return LaporanModel(
      id: sqliteId ?? (id != null ? int.tryParse(id!) : null),
      firestoreId: id,
      judul: judul,
      kategori: kategori,
      lokasi: lokasi,
      koordinat: koordinat,
      deskripsi: deskripsi,
      status: status,
      tanggal: tanggal,
      userId: userId,
      userFirestoreId: userFirestoreId,
      foto: foto,
    );
  }
}
