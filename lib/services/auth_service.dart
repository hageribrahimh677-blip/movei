import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email.trim(),
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'avatar': null,
      'wishlist': [],
    });

    return credential;
  }

  Future<void> resetPassword({required String email}) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() {
    return _auth.signOut();
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'مفيش حساب مسجل بالإيميل ده';
      case 'wrong-password':
        return 'الباسورد غلط';
      case 'invalid-email':
        return 'صيغة الإيميل مش صحيحة';
      case 'email-already-in-use':
        return 'الإيميل ده مستخدم بالفعل';
      case 'weak-password':
        return 'الباسورد لازم يكون 6 حروف/أرقام على الأقل';
      case 'invalid-credential':
        return 'بيانات الدخول غلط';
      default:
        return 'حصل خطأ، حاولي تاني';
    }
  }
}