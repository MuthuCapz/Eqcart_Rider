import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user for splash screen
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
