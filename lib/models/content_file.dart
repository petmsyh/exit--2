import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType {
  courseMaterial,
  pastExam,
}

class ContentFile {
  final String id;
  final String fileName;
  final String departmentId;
  final ContentType contentType;
  final String uploaderId;
  final DateTime uploadedAt;
  final String telegramFileId;
  final String fileUrl;
  final String? description;
  final int fileSize;

  ContentFile({
    required this.id,
    required this.fileName,
    required this.departmentId,
    required this.contentType,
    required this.uploaderId,
    required this.uploadedAt,
    required this.telegramFileId,
    required this.fileUrl,
    this.description,
    required this.fileSize,
  });

  factory ContentFile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentFile(
      id: doc.id,
      fileName: data['fileName'] ?? '',
      departmentId: data['departmentId'] ?? '',
      contentType: data['contentType'] == 'pastExam'
          ? ContentType.pastExam
          : ContentType.courseMaterial,
      uploaderId: data['uploaderId'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      telegramFileId: data['telegramFileId'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      description: data['description'],
      fileSize: data['fileSize'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fileName': fileName,
      'departmentId': departmentId,
      'contentType': contentType.name,
      'uploaderId': uploaderId,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'telegramFileId': telegramFileId,
      'fileUrl': fileUrl,
      'description': description,
      'fileSize': fileSize,
    };
  }

  bool canBeEditedBy(String userId, bool isSuperAdmin) {
    if (isSuperAdmin) return true;
    if (userId != uploaderId) return false;
    
    final hoursSinceUpload = DateTime.now().difference(uploadedAt).inHours;
    return hoursSinceUpload < 24;
  }
}
