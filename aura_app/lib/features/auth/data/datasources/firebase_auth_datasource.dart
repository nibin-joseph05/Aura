import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String error) onError,
    int? forceResendToken,
  }) async {
    try {
      await _auth.setSettings(
        appVerificationDisabledForTesting: false,
        forceRecaptchaFlow: true,
      );

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            onError("Auto-verification failed");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = "Phone verification failed";

          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = "Invalid phone number format";
              break;
            case 'too-many-requests':
              errorMessage = "Too many requests. Please try again later";
              break;
            case 'operation-not-allowed':
              errorMessage = "Phone authentication is not enabled";
              break;
            default:
              errorMessage = e.message ?? errorMessage;
          }

          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError("Failed to send OTP: ${e.toString()}");
    }
  }

  Future<User?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid OTP code');
      } else if (e.code == 'session-expired') {
        throw Exception('OTP expired. Request a new one');
      }
      throw Exception(e.message ?? 'Verification failed');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
            'An account already exists with a different sign-in method',
          );
        case 'invalid-credential':
          throw Exception('Invalid credentials. Please try again');
        case 'operation-not-allowed':
          throw Exception('Google sign-in is not enabled');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'user-not-found':
          throw Exception('No account found');
        case 'wrong-password':
          throw Exception('Invalid credentials');
        default:
          throw Exception(e.message ?? 'Google sign-in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-credential':
          throw Exception('Invalid email or password');
        default:
          throw Exception(e.message ?? 'Sign in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters');
        default:
          throw Exception(e.message ?? 'Sign up failed');
      }
    } catch (e) {
      throw Exception('Failed to create account: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  Future<void> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'provider-already-linked':
          break;
        case 'invalid-credential':
          throw Exception('Invalid credentials');
        case 'credential-already-in-use':
          throw Exception('This email is already linked to another account');
        case 'email-already-in-use':
          break;
        default:
          throw Exception(e.message ?? 'Failed to link email');
      }
    } catch (e) {
      if (!e.toString().contains('already')) {
        throw Exception('Failed to link email: ${e.toString()}');
      }
    }
  }
}
