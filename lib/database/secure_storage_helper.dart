import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  // Buat instance FlutterSecureStorage
  static const _storage = FlutterSecureStorage();

  // Simpan data (enkripsi)
  static Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Ambil data (dekripsi)
  static Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  // Hapus data tertentu
  static Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  // Hapus seluruh data penting
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
