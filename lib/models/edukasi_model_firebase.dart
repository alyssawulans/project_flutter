import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project_flutter/models/edukasi_model.dart';

part 'edukasi_model_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class EdukasiModelFirebase {
  final String? id; // Firebase Document ID
  final String judul;
  final String kategori;
  final String konten;
  final String gambar; // can be asset path or local file path
  final String tanggal;

  EdukasiModelFirebase({
    this.id,
    required this.judul,
    required this.kategori,
    required this.konten,
    required this.gambar,
    required this.tanggal,
  });

  factory EdukasiModelFirebase.fromJson(Map<String, dynamic> json) =>
      _$EdukasiModelFirebaseFromJson(json);

  Map<String, dynamic> toJson() => _$EdukasiModelFirebaseToJson(this);

  Map<String, dynamic> toMap() => toJson();

  factory EdukasiModelFirebase.fromMap(Map<String, dynamic> map, {String? docId}) {
    final updatedMap = Map<String, dynamic>.from(map);
    if (docId != null) {
      updatedMap['id'] = docId;
    }
    return EdukasiModelFirebase.fromJson(updatedMap);
  }

  factory EdukasiModelFirebase.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EdukasiModelFirebase.fromMap(data, docId: doc.id);
  }

  // Konversi dari EdukasiModel biasa ke EdukasiModelFirebase
  factory EdukasiModelFirebase.fromEdukasiModel(EdukasiModel model, {String? firebaseId}) {
    return EdukasiModelFirebase(
      id: firebaseId ?? model.firestoreId,
      judul: model.judul,
      kategori: model.kategori,
      konten: model.konten,
      gambar: model.gambar,
      tanggal: model.tanggal,
    );
  }

  // Konversi dari EdukasiModelFirebase ke EdukasiModel biasa
  EdukasiModel toEdukasiModel({int? sqliteId}) {
    return EdukasiModel(
      id: sqliteId ?? (id != null ? int.tryParse(id!) : null),
      firestoreId: id,
      judul: judul,
      kategori: kategori,
      konten: konten,
      gambar: gambar,
      tanggal: tanggal,
    );
  }
}
