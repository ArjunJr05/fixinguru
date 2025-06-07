import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Format phone number with country code
  String formatPhoneNumber(String phoneNumber, String countryCode) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code if not already present
    if (!digitsOnly.startsWith(countryCode)) {
      return '+$countryCode$digitsOnly';
    }
    return '+$digitsOnly';
  }

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError, required forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification on some devices (Android)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_getErrorMessage(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError('Failed to send OTP. Please try again.');
    }
  }

  // Verify OTP
  Future<void> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign the user in (or link the credential with the current user)
      await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-phone-number':
        return 'The provided phone number is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled in Firebase console.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
