import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/content_file.dart';

class FileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _flaskApiUrl;

  FileService({String flaskApiUrl = 'http://localhost:5000'})
      : _flaskApiUrl = flaskApiUrl;

  // Upload file to Telegram via Flask API
  Future<Map<String, dynamic>> uploadFileToTelegram(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_flaskApiUrl/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload file to Telegram: $e');
    }
  }

  // Save file metadata to Firestore
  Future<String> saveFileMetadata({
    required String fileName,
    required String departmentId,
    required ContentType contentType,
    required String uploaderId,
    required String telegramFileId,
    required String fileUrl,
    required int fileSize,
    String? description,
  }) async {
    final contentFile = ContentFile(
      id: '',
      fileName: fileName,
      departmentId: departmentId,
      contentType: contentType,
      uploaderId: uploaderId,
      uploadedAt: DateTime.now(),
      telegramFileId: telegramFileId,
      fileUrl: fileUrl,
      description: description,
      fileSize: fileSize,
    );

    final docRef = await _firestore
        .collection('files')
        .add(contentFile.toFirestore());

    return docRef.id;
  }

  // Get files by department
  Stream<List<ContentFile>> getFilesByDepartment(String departmentId) {
    return _firestore
        .collection('files')
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ContentFile.fromFirestore(doc)).toList());
  }

  // Get files by department and content type
  Stream<List<ContentFile>> getFilesByDepartmentAndType(
      String departmentId, ContentType contentType) {
    return _firestore
        .collection('files')
        .where('departmentId', isEqualTo: departmentId)
        .where('contentType', isEqualTo: contentType.name)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ContentFile.fromFirestore(doc)).toList());
  }

  // Update file metadata
  Future<void> updateFileMetadata({
    required String fileId,
    String? fileName,
    String? description,
  }) async {
    final updates = <String, dynamic>{};
    if (fileName != null) updates['fileName'] = fileName;
    if (description != null) updates['description'] = description;

    if (updates.isNotEmpty) {
      await _firestore.collection('files').doc(fileId).update(updates);
    }
  }

  // Delete file
  Future<void> deleteFile(String fileId) async {
    await _firestore.collection('files').doc(fileId).delete();
  }

  // Download file
  Future<void> downloadFile(String fileUrl, String savePath) async {
    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download file');
    }
  }
}
