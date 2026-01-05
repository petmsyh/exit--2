import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current app user data
  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(doc);
  }

  // Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) return null;

      return AppUser.fromFirestore(doc);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register new student
  Future<AppUser> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String departmentId,
    required String inviterName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      final appUser = AppUser(
        uid: user.uid,
        email: email,
        fullName: fullName,
        role: UserRole.student,
        departmentId: departmentId,
        inviterName: inviterName,
        isApproved: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toFirestore());

      return appUser;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create admin account (Super Admin only)
  Future<void> createAdmin({
    required String email,
    required String password,
    required String fullName,
    required String departmentId,
  }) async {
    // Note: In production, this should be done via Firebase Admin SDK
    // For now, we'll create the user record directly
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final appUser = AppUser(
      uid: user.uid,
      email: email,
      fullName: fullName,
      role: UserRole.admin,
      departmentId: departmentId,
      isApproved: true,
      createdAt: DateTime.now(),
      approvedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(appUser.toFirestore());
    
    // Sign out the newly created admin account
    await _auth.signOut();
  }

  // Approve student
  Future<void> approveStudent(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isApproved': true,
      'approvedAt': Timestamp.now(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user session is still valid (for unapproved students)
  Future<bool> checkStudentApprovalStatus() async {
    final appUser = await getCurrentAppUser();
    if (appUser == null) return false;
    
    if (appUser.role == UserRole.student && !appUser.isApproved) {
      final timeSinceCreation = DateTime.now().difference(appUser.createdAt);
      if (timeSinceCreation.inMinutes >= 5) {
        await signOut();
        return false;
      }
    }
    
    return true;
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return e.toString();
  }
}
