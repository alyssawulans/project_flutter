import 'dart:convert';
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
  Map<String, dynamic> toMap() {
    final map = toJson();
    map.remove('password'); // Hapus password agar tidak disimpan ke Firestore
    if (map.containsKey('nomor_telp') && map['nomor_telp'] != null) {
      map['nomor_telp'] = _encryptPhone(map['nomor_telp'] as String);
    }
    return map;
  }

  factory UserModelFirebase.fromMap(Map<String, dynamic> map, {String? docId}) {
    final updatedMap = Map<String, dynamic>.from(map);
    if (docId != null) {
      updatedMap['id'] = docId;
    }
    // Dekripsi nomor telepon jika dalam format terenkripsi
    if (updatedMap.containsKey('nomor_telp') && updatedMap['nomor_telp'] != null) {
      updatedMap['nomor_telp'] = _decryptPhone(updatedMap['nomor_telp'] as String);
    }
    // Set password kosong karena tidak disimpan di Firestore
    if (!updatedMap.containsKey('password')) {
      updatedMap['password'] = '';
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

  // Helper Enkripsi No Telepon (XOR + Base64)
  static String _encryptPhone(String phone) {
    if (phone.isEmpty) return '';
    const key = 'RUAS_SECRET_KEY';
    final bytes = utf8.encode(phone);
    final encrypted = List<int>.generate(bytes.length, (i) => bytes[i] ^ key.codeUnitAt(i % key.length));
    return base64Encode(encrypted);
  }

  // Helper Dekripsi No Telepon (XOR + Base64)
  static String _decryptPhone(String value) {
    if (value.isEmpty) return '';
    // Jika data lama (hanya angka/karakter telp biasa), jangan didekripsi
    final phoneRegex = RegExp(r'^[+0-9\s\-]+$');
    if (phoneRegex.hasMatch(value)) {
      return value;
    }
    try {
      const key = 'RUAS_SECRET_KEY';
      final bytes = base64Decode(value);
      final decrypted = List<int>.generate(bytes.length, (i) => bytes[i] ^ key.codeUnitAt(i % key.length));
      return utf8.decode(decrypted);
    } catch (_) {
      return value;
    }
  }
}
