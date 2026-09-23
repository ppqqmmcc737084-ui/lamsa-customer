import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  Future<String> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser!.uid;
    final credential = await auth.signInAnonymously();
    return credential.user!.uid;
  }

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
}