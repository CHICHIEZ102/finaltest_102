import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/app_user.dart';

class AuthController {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Stream<User?> get authChanges => _auth.authStateChanges();

  static Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  static Future<void> signOut() => _auth.signOut();

  /// ดึงข้อมูลสมาชิก (รวม role) แบบ real-time จาก collection users
  static Stream<AppUser?> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots().map((s) =>
          s.exists ? AppUser.fromMap(s.data() as Map<String, dynamic>) : null);

  /// สร้างบัญชีทดสอบ admin@test.com / operator@test.com (รหัสผ่าน 123456)
  static Future<void> seedTestAccounts() async {
    await _seed('Admin', 'admin@test.com', 'admin');
    await _seed('Operator', 'operator@test.com', 'operator');
    await _auth.signOut();
  }

  static Future<void> _seed(String name, String email, String role) async {
    const pw = '123456';
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(email: email, password: pw);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
      cred = await _auth.signInWithEmailAndPassword(email: email, password: pw);
    }
    final u = AppUser(uid: cred.user!.uid, name: name, email: email, role: role);
    await _db.collection('users').doc(u.uid).set(u.toMap());
  }
}
