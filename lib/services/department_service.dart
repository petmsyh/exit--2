import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all departments
  Stream<List<Department>> getDepartments() {
    return _firestore
        .collection('departments')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Department.fromFirestore(doc))
            .toList());
  }

  // Get department by ID
  Future<Department?> getDepartmentById(String id) async {
    final doc = await _firestore.collection('departments').doc(id).get();
    if (!doc.exists) return null;
    return Department.fromFirestore(doc);
  }

  // Create department (Super Admin only)
  Future<String> createDepartment({
    required String name,
    required String description,
    required String createdBy,
  }) async {
    final department = Department(
      id: '',
      name: name,
      description: description,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    final docRef = await _firestore
        .collection('departments')
        .add(department.toFirestore());
    
    return docRef.id;
  }

  // Update department (Super Admin only)
  Future<void> updateDepartment({
    required String id,
    required String name,
    required String description,
  }) async {
    await _firestore.collection('departments').doc(id).update({
      'name': name,
      'description': description,
    });
  }

  // Delete department (Super Admin only)
  Future<void> deleteDepartment(String id) async {
    await _firestore.collection('departments').doc(id).delete();
  }
}
