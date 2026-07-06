import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:project_flutter/models/user_model.dart';
import 'package:project_flutter/models/user_model_firebase.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/models/edukasi_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._init();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  FirebaseAuthService._init();

  // --- USER OPERATIONS ---

  // Register user baru menggunakan Firebase Auth dan disimpan ke Firestore
  Future<UserModelFirebase?> registerUser(
    UserModelFirebase user,
    String password,
  ) async {
    try {
      // 1. Daftarkan di Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;

      // 2. Simpan profil lengkap ke Firestore
      final updatedUser = UserModelFirebase(
        id: uid,
        nama: user.nama,
        email: user.email,
        nomorTelp: user.nomorTelp,
        password: user.password, // opsional disimpan / diabaikan
        tanggalDaftar: user.tanggalDaftar,
        tempatLahir: user.tempatLahir,
        tanggalLahir: user.tanggalLahir,
        role: user.role,
      );

      await _db.collection('users').doc(uid).set(updatedUser.toMap());
      return updatedUser;
    } catch (e) {
      return null;
    }
  }

  // Wrapper untuk register menggunakan UserModel biasa (SQLite compatibility)
  Future<UserModel?> registerUserModel(UserModel user) async {
    final fbUser = UserModelFirebase.fromUserModel(user);
    final result = await registerUser(fbUser, user.password);
    return result?.toUserModel();
  }

  // Login user menggunakan Firebase Auth dan ambil datanya dari Firestore
  Future<UserModelFirebase?> loginUser(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;
      return await getUser(uid);
    } catch (e) {
      return null;
    }
  }

  // Wrapper untuk login menggunakan UserModel biasa (SQLite compatibility)
  Future<UserModel?> loginUserModel(String email, String password) async {
    final result = await loginUser(email, password);
    return result?.toUserModel();
  }

  // Ambil detail data user dari Firestore berdasarkan UID
  Future<UserModelFirebase?> getUser(String id) async {
    try {
      final doc = await _db.collection('users').doc(id).get();
      if (doc.exists) {
        return UserModelFirebase.fromDocument(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Wrapper untuk getUser menggunakan UserModel biasa (SQLite compatibility)
  Future<UserModel?> getUserModel(String id) async {
    final result = await getUser(id);
    return result?.toUserModel();
  }

  // Update profil user di Firestore
  Future<void> updateUserProfile(
    String id,
    String nama,
    String nomorTelp, {
    String? tempatLahir,
    String? tanggalLahir,
  }) async {
    final Map<String, dynamic> values = {'nama': nama, 'nomor_telp': nomorTelp};
    if (tempatLahir != null) {
      values['tempat_lahir'] = tempatLahir;
    }
    if (tanggalLahir != null) {
      values['tanggal_lahir'] = tanggalLahir;
    }
    await _db.collection('users').doc(id).update(values);
  }

  // Update password user di Firebase Auth (Firestore tidak menyimpan password)
  Future<void> updateUserPassword(String id, String newPassword) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == id) {
      await currentUser.updatePassword(newPassword);
    }
  }

  // Verifikasi password lama dengan re-autentikasi lalu update ke password baru
  Future<void> reauthenticateAndUpdatePassword(String oldPassword, String newPassword) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.email != null) {
      final credential = auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: oldPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);
    } else {
      throw Exception("User tidak sedang masuk.");
    }
  }

  // --- LAPORAN OPERATIONS ---

  // Membuat laporan baru di Firestore
  Future<String> createLaporan(LaporanModel laporan) async {
    final docRef = _db.collection('laporan').doc();
    final data = laporan.toMap();
    data.remove('id');
    data['firestore_id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  // Mendapatkan daftar laporan di Firestore dengan filter opsional
  Future<List<LaporanModel>> getLaporans({
    String? userFirestoreId,
    String? status,
    String? category,
  }) async {
    Query query = _db.collection('laporan');

    if (userFirestoreId != null && userFirestoreId.isNotEmpty) {
      query = query.where('user_firestore_id', isEqualTo: userFirestoreId);
    }

    if (status != null && status != 'Semua') {
      query = query.where('status', isEqualTo: status);
    }

    if (category != null && category != 'Semua') {
      query = query.where('kategori', isEqualTo: category);
    }

    final querySnapshot = await query.get();
    final results = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['firestore_id'] = doc.id;
      return LaporanModel.fromMap(data);
    }).toList();

    // Urutkan berdasarkan tanggal terbaru
    results.sort((a, b) {
      return b.tanggal.compareTo(a.tanggal);
    });

    return results;
  }

  // Update laporan di Firestore
  Future<void> updateLaporan(LaporanModel laporan) async {
    if (laporan.firestoreId != null) {
      await _db
          .collection('laporan')
          .doc(laporan.firestoreId)
          .update(laporan.toMap());
    }
  }

  // Menghapus laporan berdasarkan Firestore Document ID
  Future<void> deleteLaporan(String firestoreId) async {
    await _db.collection('laporan').doc(firestoreId).delete();
  }

  // Menghitung jumlah laporan secara real-time di Firestore
  Future<int> getLaporanCount({String? userFirestoreId}) async {
    Query query = _db.collection('laporan');
    if (userFirestoreId != null && userFirestoreId.isNotEmpty) {
      query = query.where('user_firestore_id', isEqualTo: userFirestoreId);
    }
    final aggregateQuery = await query.count().get();
    return aggregateQuery.count ?? 0;
  }

  // --- EDUKASI OPERATIONS ---

  // Membuat konten edukasi baru di Firestore
  Future<String> createEdukasi(EdukasiModel edukasi) async {
    final docRef = _db.collection('edukasi').doc();
    final data = edukasi.toMap();
    data.remove('id');
    data['firestore_id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  // Mendapatkan daftar edukasi di Firestore dengan filter kategori
  Future<List<EdukasiModel>> getEdukasis({String? category}) async {
    Query query = _db.collection('edukasi');

    if (category != null && category != 'Semua') {
      query = query.where('kategori', isEqualTo: category);
    }

    final querySnapshot = await query.get();
    final results = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['firestore_id'] = doc.id;
      return EdukasiModel.fromMap(data);
    }).toList();

    // Urutkan berdasarkan tanggal terbaru
    results.sort((a, b) {
      return b.tanggal.compareTo(a.tanggal);
    });

    return results;
  }

  // Update edukasi di Firestore
  Future<void> updateEdukasi(EdukasiModel edukasi) async {
    if (edukasi.firestoreId != null) {
      await _db
          .collection('edukasi')
          .doc(edukasi.firestoreId)
          .update(edukasi.toMap());
    }
  }

  // Menghapus edukasi berdasarkan Firestore Document ID
  Future<void> deleteEdukasi(String firestoreId) async {
    await _db.collection('edukasi').doc(firestoreId).delete();
  }

  // Menghitung jumlah edukasi di Firestore
  Future<int> getEdukasiCount() async {
    final aggregateQuery = await _db.collection('edukasi').count().get();
    return aggregateQuery.count ?? 0;
  }
}
