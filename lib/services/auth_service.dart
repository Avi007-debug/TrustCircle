import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Email / Password Sign-Up ───────────────────────────────────────────────
  Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) return null;

    await user.updateDisplayName(name);

    final model = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      photoUrl: '',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(model.toMap());

    return model;
  }

  // ── Email / Password Sign-In ───────────────────────────────────────────────
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) return null;
    return _fetchOrCreateUserDoc(user);
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) return null;

    return _fetchOrCreateUserDoc(user, fromGoogle: true, googleUser: googleUser);
  }

  // ── Fetch or Create Firestore User Doc ────────────────────────────────────
  Future<UserModel> _fetchOrCreateUserDoc(
    User user, {
    bool fromGoogle = false,
    GoogleSignInAccount? googleUser,
  }) async {
    final ref = _firestore.collection(AppConstants.usersCollection).doc(user.uid);
    final snap = await ref.get();

    if (snap.exists) {
      return UserModel.fromMap(snap.data()!);
    }

    final model = UserModel(
      uid: user.uid,
      name: fromGoogle ? (googleUser?.displayName ?? user.displayName ?? '') : (user.displayName ?? ''),
      email: user.email ?? '',
      photoUrl: fromGoogle ? (googleUser?.photoUrl ?? '') : '',
      createdAt: DateTime.now(),
    );
    await ref.set(model.toMap());
    return model;
  }

  // ── Get Current User Model ─────────────────────────────────────────────────
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.data()!);
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
