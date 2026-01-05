import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  superAdmin,
  admin,
  student,
}

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String departmentId;
  final String? inviterName;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime? approvedAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.departmentId,
    this.inviterName,
    required this.isApproved,
    required this.createdAt,
    this.approvedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: _parseRole(data['role']),
      departmentId: data['departmentId'] ?? '',
      inviterName: data['inviterName'],
      isApproved: data['isApproved'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'departmentId': departmentId,
      'inviterName': inviterName,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'superAdmin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
