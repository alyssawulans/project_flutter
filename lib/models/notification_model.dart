class NotificationModel {
  final String? id; // Firestore Document ID
  final String title;
  final String body;
  final String tanggal; // ISO date string (DateTime.toIso8601String())
  final bool isRead;
  final String type; // 'laporan', 'aqi', 'edukasi'
  final String relatedId; // ID of the related report or education item
  final String userFirestoreId; // UID of the recipient

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.tanggal,
    required this.isRead,
    required this.type,
    required this.relatedId,
    required this.userFirestoreId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'tanggal': tanggal,
      'is_read': isRead,
      'type': type,
      'related_id': relatedId,
      'user_firestore_id': userFirestoreId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      tanggal: map['tanggal'] ?? '',
      isRead: map['is_read'] ?? false,
      type: map['type'] ?? '',
      relatedId: map['related_id'] ?? '',
      userFirestoreId: map['user_firestore_id'] ?? '',
    );
  }
}
