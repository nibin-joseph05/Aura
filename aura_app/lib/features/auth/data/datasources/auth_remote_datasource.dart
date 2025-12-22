import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        codeAutoRetrievalTimeout: (String verificationId) {
          
        },
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

  
  Future<void> signOut() async {
    await _auth.signOut();
  }

  
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }
}