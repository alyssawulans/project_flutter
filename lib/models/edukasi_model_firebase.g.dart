// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edukasi_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdukasiModelFirebase _$EdukasiModelFirebaseFromJson(
  Map<String, dynamic> json,
) => EdukasiModelFirebase(
  id: json['id'] as String?,
  judul: json['judul'] as String,
  kategori: json['kategori'] as String,
  konten: json['konten'] as String,
  gambar: json['gambar'] as String,
  tanggal: json['tanggal'] as String,
);

Map<String, dynamic> _$EdukasiModelFirebaseToJson(
  EdukasiModelFirebase instance,
) => <String, dynamic>{
  'id': instance.id,
  'judul': instance.judul,
  'kategori': instance.kategori,
  'konten': instance.konten,
  'gambar': instance.gambar,
  'tanggal': instance.tanggal,
};
