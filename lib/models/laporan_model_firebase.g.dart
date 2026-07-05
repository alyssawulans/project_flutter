// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laporan_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaporanModelFirebase _$LaporanModelFirebaseFromJson(
  Map<String, dynamic> json,
) => LaporanModelFirebase(
  id: json['id'] as String?,
  judul: json['judul'] as String,
  kategori: json['kategori'] as String,
  lokasi: json['lokasi'] as String,
  koordinat: json['koordinat'] as String,
  deskripsi: json['deskripsi'] as String,
  status: json['status'] as String,
  tanggal: json['tanggal'] as String,
  userId: (json['user_id'] as num).toInt(),
  userFirestoreId: json['user_firestore_id'] as String?,
  foto: json['foto'] as String,
);

Map<String, dynamic> _$LaporanModelFirebaseToJson(
  LaporanModelFirebase instance,
) => <String, dynamic>{
  'id': instance.id,
  'judul': instance.judul,
  'kategori': instance.kategori,
  'lokasi': instance.lokasi,
  'koordinat': instance.koordinat,
  'deskripsi': instance.deskripsi,
  'status': instance.status,
  'tanggal': instance.tanggal,
  'user_id': instance.userId,
  'user_firestore_id': instance.userFirestoreId,
  'foto': instance.foto,
};
