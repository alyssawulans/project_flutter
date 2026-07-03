import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project_flutter/models/user_model.dart';

part 'user_model_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserModelFirebase {
  final String? id; // Firebase Document ID / User UID
  final String nama;
  final String email;
  final String nomorTelp;
  final String password;
  final String tanggalDaftar;
  final String tempatLahir;
  final String tanggalLahir;
  final String role;

  UserModelFirebase({
    this.id,
    required this.nama,
    required this.email,
    required this.nomorTelp,
    required this.password,
    required this.tanggalDaftar,
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.role = 'user',
  });

  factory UserModelFirebase.fromJson(Map<String, dynamic> json) =>
      _$UserModelFirebaseFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelFirebaseToJson(this);

  // Menyediakan toMap() dan fromMap() untuk Firestore/Sqlite compatibility
  Map<String, dynamic> toMap() => toJson();

  factory UserModelFirebase.fromMap(Map<String, dynamic> map, {String? docId}) {
    final updatedMap = Map<String, dynamic>.from(map);
    if (docId != null) {
      updatedMap['id'] = docId;
    }
    return UserModelFirebase.fromJson(updatedMap);
  }

  factory UserModelFirebase.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModelFirebase.fromMap(data, docId: doc.id);
  }

  // Konversi dari UserModel biasa ke UserModelFirebase
  factory UserModelFirebase.fromUserModel(UserModel user, {String? firebaseId}) {
    return UserModelFirebase(
      id: firebaseId ?? user.id?.toString(),
      nama: user.nama,
      email: user.email,
      nomorTelp: user.nomorTelp,
      password: user.password,
      tanggalDaftar: user.tanggalDaftar,
      tempatLahir: user.tempatLahir,
      tanggalLahir: user.tanggalLahir,
      role: user.role,
    );
  }

  // Konversi dari UserModelFirebase ke UserModel biasa
  UserModel toUserModel({int? sqliteId}) {
    return UserModel(
      id: sqliteId ?? (id != null ? int.tryParse(id!) : null),
      nama: nama,
      email: email,
      nomorTelp: nomorTelp,
      password: password,
      tanggalDaftar: tanggalDaftar,
      tempatLahir: tempatLahir,
      tanggalLahir: tanggalLahir,
      role: role,
    );
  }
}
