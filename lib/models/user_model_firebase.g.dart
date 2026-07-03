// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModelFirebase _$UserModelFirebaseFromJson(Map<String, dynamic> json) =>
    UserModelFirebase(
      id: json['id'] as String?,
      nama: json['nama'] as String,
      email: json['email'] as String,
      nomorTelp: json['nomor_telp'] as String,
      password: json['password'] as String,
      tanggalDaftar: json['tanggal_daftar'] as String,
      tempatLahir: json['tempat_lahir'] as String? ?? '',
      tanggalLahir: json['tanggal_lahir'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );

Map<String, dynamic> _$UserModelFirebaseToJson(UserModelFirebase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama': instance.nama,
      'email': instance.email,
      'nomor_telp': instance.nomorTelp,
      'password': instance.password,
      'tanggal_daftar': instance.tanggalDaftar,
      'tempat_lahir': instance.tempatLahir,
      'tanggal_lahir': instance.tanggalLahir,
      'role': instance.role,
    };
