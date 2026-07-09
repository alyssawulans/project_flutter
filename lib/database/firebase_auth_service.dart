import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/models/user_model.dart';
import 'package:project_flutter/models/user_model_firebase.dart';
import 'package:project_flutter/models/laporan_model.dart';
import 'package:project_flutter/models/edukasi_model.dart';
import 'package:project_flutter/models/notification_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._init();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://ruas-app.firebasestorage.app',
  );

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

      UserModelFirebase? user = await getUser(uid);
      if (user == null) {
        // Jika dokumen user belum ada di Firestore (misalnya admin yang dibuat langsung di console),
        // otomatis buat profilnya. Jika email mengandung kata "admin", beri role admin.
        final isEmailAdmin = email.toLowerCase().contains('admin');
        final defaultUser = UserModelFirebase(
          id: uid,
          nama: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
          email: email,
          nomorTelp: '080000000000',
          password: '',
          tanggalDaftar: DateFormat(
            'd MMM yyyy',
            'id_ID',
          ).format(DateTime.now()),
          tempatLahir: 'Jakarta',
          tanggalLahir: '01 Jan 1990',
          role: isEmailAdmin ? 'admin' : 'user',
        );
        await _db.collection('users').doc(uid).set(defaultUser.toMap());
        user = defaultUser;
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  // Login menggunakan Google Sign-In
  Future<UserModelFirebase?> signInWithGoogle() async {
    try {
      // 1. Jalankan alur Google Sign-In
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '702163532500-9btv70j2i2maneognp66oc8n7unfb2qe.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      // 2. Ambil detail otentikasi dari akun google
      final googleAuth = await googleUser.authentication;

      // 3. Buat kredensial Firebase baru
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Masuk ke Firebase Auth menggunakan kredensial tersebut
      final auth.UserCredential userCredential = await _auth
          .signInWithCredential(credential);
      final uid = userCredential.user?.uid;
      if (uid == null) return null;

      // 6. Ambil data profil dari Firestore
      UserModelFirebase? user = await getUser(uid);
      if (user == null) {
        // Jika user Google baru pertama kali login, otomatis buat profil default di Firestore
        final displayName =
            googleUser.displayName ?? googleUser.email.split('@').first;
        final defaultUser = UserModelFirebase(
          id: uid,
          nama: displayName,
          email: googleUser.email,
          nomorTelp: '080000000000',
          password: '',
          tanggalDaftar: DateFormat(
            'd MMM yyyy',
            'id_ID',
          ).format(DateTime.now()),
          tempatLahir: 'Jakarta',
          tanggalLahir: '01 Jan 1990',
          role: googleUser.email.toLowerCase().contains('admin')
              ? 'admin'
              : 'user',
        );
        await _db.collection('users').doc(uid).set(defaultUser.toMap());
        user = defaultUser;
      }
      return user;
    } catch (e, stackTrace) {
      print('Error during Google Sign-In: $e');
      print('StackTrace: $stackTrace');
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
  Future<void> reauthenticateAndUpdatePassword(
    String oldPassword,
    String newPassword,
  ) async {
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

  // Sign out dari Firebase Auth dan Google Sign-In
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '702163532500-9btv70j2i2maneognp66oc8n7unfb2qe.apps.googleusercontent.com',
      );
      // Hapus sesi Google Sign-In agar pada login berikutnya muncul dialog pilihan akun
      await googleSignIn.signOut();
    } catch (e) {
      print('Error during Google Sign-Out: $e');
    }
  }

  // Helper untuk mengunggah file lokal ke Firebase Storage dan mengembalikan URL download
  Future<String> uploadFile(String filePath, String folderName) async {
    // Jika path kosong, berupa asset, web url, atau data Base64, kembalikan apa adanya
    if (filePath.isEmpty ||
        filePath.startsWith('assets/') ||
        filePath.startsWith('http') ||
        filePath.startsWith('data:image/') ||
        filePath.length > 1000) {
      return filePath;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return filePath;
      }

      // Buat nama file unik berdasarkan timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final ref = _storage.ref().child(folderName).child(fileName);

      print(
        'Uploading file to Firebase Storage bucket: ${_storage.bucket} at path: $folderName/$fileName',
      );

      // Mulai upload
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('Upload success! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('DEBUG STORAGE ERROR: $e');
      rethrow; // Rethrow agar UI tahu bahwa upload gagal
    }
  }

  // --- LAPORAN OPERATIONS ---

  // Membuat laporan baru di Firestore
  Future<String> createLaporan(LaporanModel laporan) async {
    final docRef = _db.collection('laporan').doc();
    final data = laporan.toMap();
    data.remove('id');
    data['firestore_id'] = docRef.id;

    // Handle multiple photos upload if any
    if (laporan.foto.isNotEmpty) {
      final List<String> paths;
      if (laporan.foto.startsWith('data:image/')) {
        final parts = laporan.foto.split(',data:image/');
        paths = [];
        for (int i = 0; i < parts.length; i++) {
          if (i == 0) {
            paths.add(parts[i]);
          } else {
            paths.add('data:image/' + parts[i]);
          }
        }
      } else {
        paths = laporan.foto.split(',');
      }

      final List<String> uploadedUrls = [];
      for (final path in paths) {
        if (path.trim().isNotEmpty) {
          final url = await uploadFile(path.trim(), 'laporan');
          uploadedUrls.add(url);
        }
      }
      data['foto'] = uploadedUrls.join(',');
    }

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
      final data = laporan.toMap();

      // Handle multiple photos upload if any
      if (laporan.foto.isNotEmpty) {
        final List<String> paths;
        if (laporan.foto.startsWith('data:image/')) {
          final parts = laporan.foto.split(',data:image/');
          paths = [];
          for (int i = 0; i < parts.length; i++) {
            if (i == 0) {
              paths.add(parts[i]);
            } else {
              paths.add('data:image/' + parts[i]);
            }
          }
        } else {
          paths = laporan.foto.split(',');
        }

        final List<String> uploadedUrls = [];
        for (final path in paths) {
          if (path.trim().isNotEmpty) {
            final url = await uploadFile(path.trim(), 'laporan');
            uploadedUrls.add(url);
          }
        }
        data['foto'] = uploadedUrls.join(',');
      }

      await _db.collection('laporan').doc(laporan.firestoreId).update(data);
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

    // Upload image if it is a local file path
    final uploadedUrl = await uploadFile(edukasi.gambar, 'edukasi');
    data['gambar'] = uploadedUrl;

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
      final data = edukasi.toMap();

      // Upload image if it is a local file path
      final uploadedUrl = await uploadFile(edukasi.gambar, 'edukasi');
      data['gambar'] = uploadedUrl;

      await _db.collection('edukasi').doc(edukasi.firestoreId).update(data);
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

  // --- NOTIFICATION OPERATIONS ---

  // Membuat notifikasi baru di Firestore
  Future<String> createNotification(NotificationModel notification) async {
    final docRef = _db.collection('notifications').doc();
    final data = notification.toMap();
    data['id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  // Mendapatkan daftar notifikasi untuk user tertentu
  Future<List<NotificationModel>> getNotifications(
    String userFirestoreId,
  ) async {
    try {
      final querySnapshot = await _db
          .collection('notifications')
          .where('user_firestore_id', isEqualTo: userFirestoreId)
          .get();

      final results = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel.fromMap(data, doc.id);
      }).toList();

      // Urutkan berdasarkan tanggal terbaru (descending)
      results.sort((a, b) {
        return b.tanggal.compareTo(a.tanggal);
      });

      return results;
    } catch (e) {
      return [];
    }
  }

  // Tandai notifikasi sebagai dibaca
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }

  // Tandai semua notifikasi user sebagai dibaca
  Future<void> markAllNotificationsAsRead(String userFirestoreId) async {
    final querySnapshot = await _db
        .collection('notifications')
        .where('user_firestore_id', isEqualTo: userFirestoreId)
        .where('is_read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  // Hapus notifikasi
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  // Menghitung jumlah notifikasi yang belum dibaca
  Future<int> getUnreadNotificationCount(String userFirestoreId) async {
    try {
      final query = _db
          .collection('notifications')
          .where('user_firestore_id', isEqualTo: userFirestoreId)
          .where('is_read', isEqualTo: false);
      final aggregateQuery = await query.count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Mendapatkan stream daftar notifikasi untuk user tertentu (real-time)
  Stream<List<NotificationModel>> getNotificationsStream(
    String userFirestoreId,
  ) {
    return _db
        .collection('notifications')
        .where('user_firestore_id', isEqualTo: userFirestoreId)
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs.map((doc) {
            final data = doc.data();
            return NotificationModel.fromMap(data, doc.id);
          }).toList();

          // Urutkan berdasarkan tanggal terbaru (descending)
          results.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          return results;
        });
  }

  // Mendapatkan stream jumlah notifikasi yang belum dibaca (real-time)
  Stream<int> getUnreadNotificationCountStream(String userFirestoreId) {
    return _db
        .collection('notifications')
        .where('user_firestore_id', isEqualTo: userFirestoreId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mengambil laporan berdasarkan Firestore ID (untuk navigasi/deep linking)
  Future<LaporanModel?> getLaporanById(String firestoreId) async {
    try {
      final doc = await _db.collection('laporan').doc(firestoreId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['firestore_id'] = doc.id;
        return LaporanModel.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mengambil edukasi berdasarkan Firestore ID (untuk navigasi/deep linking)
  Future<EdukasiModel?> getEdukasiById(String firestoreId) async {
    try {
      final doc = await _db.collection('edukasi').doc(firestoreId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['firestore_id'] = doc.id;
        return EdukasiModel.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
