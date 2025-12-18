import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current app user data
  Future<AppUser?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Stream of current user data
  Stream<AppUser?> get currentUserStream {
    final user = currentUser;
    if (user == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return AppUser.fromFirestore(doc);
          }
          return null;
        });
  }

  // ✅ NEW - Ensure user document exists (for Google Sign-In or any auth method)
  Future<void> ensureUserDocumentExists(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      // If document doesn't exist, create it
      if (!userDoc.exists) {
        print('📝 Creating user document for ${user.email}...');
        
        AppUser newUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
          phoneNumber: user.phoneNumber,
          role: 'user', // Default to user (change to admin manually in Firestore)
          createdAt: DateTime.now(),
          avatarUrl: user.photoURL,
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
        print('✅ Created user document for ${user.email}');
      } else {
        print('✅ User document already exists for ${user.email}');
      }
    } catch (e) {
      print('❌ Error ensuring user document: $e');
    }
  }

  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      print('🔐 AuthService: Starting Firebase signup...');
      
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ AuthService: Firebase user created: ${userCredential.user?.uid}');

      // Create user document in Firestore
      AppUser newUser = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        location: location,
        role: 'user', // Default role
        createdAt: DateTime.now(),
      );

      print('📝 AuthService: Creating Firestore document...');
      
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      print('✅ AuthService: Firestore document created');

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      print('✅ AuthService: Display name updated');

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ AuthService: FirebaseAuthException: ${e.code} - ${e.message}');
      return _getErrorMessage(e);
    } catch (e) {
      print('❌ AuthService: Unexpected error: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Signing in...');
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ AuthService: Sign in successful');
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ AuthService: Sign in error: ${e.code}');
      return _getErrorMessage(e);
    } catch (e) {
      print('❌ AuthService: Unexpected error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }

  // Make user admin (for testing - should be restricted in production)
  Future<void> makeAdmin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'admin',
      });
    } catch (e) {
      print('Error making user admin: $e');
      rethrow;
    }
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}