import 'package:fixinguru/login/captch.dart';
import 'package:fixinguru/login/otp.dart';
import 'package:fixinguru/login/password.dart';
import 'package:fixinguru/login/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  bool acceptTerms = false;
  bool receiveUpdates = false;
  bool _isLoading = false;
  bool _isCaptchaVerified = false;

  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store verification ID globally to handle reCAPTCHA flow
  String? _currentVerificationId;
  int? _resendToken;

  bool get canContinue =>
      acceptTerms &&
      receiveUpdates &&
      _phoneController.text.isNotEmpty &&
      _isCaptchaVerified &&
      !_isLoading;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);

    // Configure Firebase Auth settings to handle reCAPTCHA properly
    _configureFirebaseAuth();
  }

  void _configureFirebaseAuth() {
    // Enable app verification for production
    _auth.setSettings(
      appVerificationDisabledForTesting: false,
      userAccessGroup: null,
    );
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onCaptchaVerified(dynamic isVerified) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isCaptchaVerified = isVerified is bool ? isVerified : false;
        });
      });
    }
  }

  void _onPhoneChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Check if phone number already exists in Firestore
  Future<bool> _checkPhoneExists(String phoneNumber) async {
    try {
      // Clean phone number to match Firestore format
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final phoneWithoutCountryCode = cleanPhone.length > 10
          ? cleanPhone.substring(cleanPhone.length - 10)
          : cleanPhone;

      // Check in users collection
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneWithoutCountryCode)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone existence: $e');
      return false;
    }
  }

  // Show phone already exists dialog
  void _showPhoneExistsDialog(String phoneNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C2C2C),
                  const Color(0xFF1A1A1A),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4AC959).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4AC959).withOpacity(0.2),
                        const Color(0xFF4AC959).withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF4AC959),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: Color(0xFF4AC959),
                    size: 40,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Phone Number Already Exists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Message
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'The phone number ',
                      ),
                      TextSpan(
                        text: phoneNumber,
                        style: const TextStyle(
                          color: Color(0xFF4AC959),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' is already registered with FixinGuru.\n\nPlease try logging in or use a different phone number.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    // Try Different Number Button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _phoneController.clear();
                          setState(() {
                            _isCaptchaVerified = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF4AC959),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Try Different',
                          style: TextStyle(
                            color: Color(0xFF4AC959),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Login Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pop(); // Go back to login screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4AC959),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login Instead',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendOTP() async {
    if (!canContinue) return;

    setState(() {
      _isLoading = true;
    });

    String formattedPhone = _phoneAuthService.formatPhoneNumber(
      _phoneController.text.trim(),
      '91',
    );

    try {
      // First, check if phone number already exists
      bool phoneExists = await _checkPhoneExists(formattedPhone);

      if (phoneExists) {
        setState(() {
          _isLoading = false;
        });
        // Show the phone exists dialog
        _showPhoneExistsDialog(_phoneController.text.trim());
        return;
      }

      // If phone doesn't exist, proceed with OTP verification
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,

        // Increased timeout to handle network issues
        timeout: const Duration(seconds: 120),

        // Force resending token for subsequent attempts
        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (rarely happens on Android)
          try {
            await _auth.signInWithCredential(credential);
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _navigateToPasswordPage(formattedPhone);
            }
          } catch (e) {
            if (mounted) {
              _showError('Auto-verification failed: ${e.toString()}');
            }
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            String errorMessage = 'Verification failed';

            if (e.code == 'too-many-requests') {
              errorMessage = 'Please wait before requesting another code';
            } else if (e.code == 'invalid-phone-number') {
              errorMessage = 'Invalid phone number format';
            } else if (e.code == 'quota-exceeded') {
              errorMessage = 'SMS quota exceeded. Please try again later';
            } else {
              errorMessage = e.message ?? 'Unknown error occurred';
            }

            _showError(errorMessage);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          // Store verification details
          _currentVerificationId = verificationId;
          _resendToken = resendToken;

          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            // Navigate to OTP screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  phoneNumber: formattedPhone,
                  verificationId: verificationId,
                  resendToken: resendToken,
                ),
              ),
            );
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // Update verification ID when timeout occurs
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Error: ${e.toString()}');
      }
    }
  }

  void _navigateToPasswordPage(String phoneNumber) {
    final phoneNumberDigits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneNumberWithoutCountryCode = phoneNumberDigits.length > 10
        ? phoneNumberDigits.substring(phoneNumberDigits.length - 10)
        : phoneNumberDigits;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordPage(
          phoneNumber: phoneNumberWithoutCountryCode,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewPadding = MediaQuery.of(context).viewPadding;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Responsive calculations
    final isSmallScreen = size.width < 360;
    final isVerySmallScreen = size.width < 320;

    // Adaptive sizing
    final baseFontSize = size.width / 28;
    final titleFontSize = max(min(baseFontSize * 1.8, 32.0), 22.0);
    final subtitleFontSize = max(min(baseFontSize * 1.6, 28.0), 20.0);
    final buttonFontSize = max(min(baseFontSize * 1.1, 18.0), 14.0);
    final labelFontSize = max(min(baseFontSize * 0.9, 16.0), 12.0);
    final hintFontSize = max(min(baseFontSize * 0.8, 14.0), 11.0);

    // Responsive spacing
    final horizontalPadding = max(size.width * 0.05, 12.0);
    final containerPadding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = max(min(size.width * 0.06, 24.0), 16.0);
    final buttonHeight = max(min(size.height * 0.07, 56.0), 40.0);
    final spacingHeight = max(size.height * 0.02, 8.0);

    // Checkbox sizing
    final checkboxScale = max(min(size.width * 0.003, 1.2), 0.9);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background with dual colors
          SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),

          // Green curve
          SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: CurvePainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button with proper spacing
                          Padding(
                            padding: EdgeInsets.only(top: spacingHeight),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: Colors.white, size: iconSize),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),

                          // Join FixinGuru Text with responsive sizing
                          Padding(
                            padding: EdgeInsets.only(
                                left: horizontalPadding,
                                top: spacingHeight / 2),
                            child: Text(
                              'Join FixinGuru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize / textScaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 3),

                          // Phone field with responsive sizing
                          _buildInputField(
                            context: context,
                            label: 'Phone Number',
                            hintText: 'Enter your phone number',
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            labelFontSize: labelFontSize,
                            hintFontSize: hintFontSize,
                            iconSize: iconSize,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),

                          SizedBox(height: spacingHeight * 1.5),

                          // Captcha Widget
                          CaptchaWidget(
                            onCaptchaVerified: _onCaptchaVerified,
                            primaryColor: const Color(0xFF4AC959),
                            backgroundColor: const Color(0xFF212121),
                            textColor: Colors.white,
                            initialVerifiedState: false,
                          ),

                          SizedBox(height: spacingHeight * 1.5),

                          // Terms checkbox with responsive sizing
                          _buildCheckbox(
                            context: context,
                            value: acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                acceptTerms = value!;
                              });
                            },
                            textSpan: TextSpan(
                              text: 'I hereby accept the general ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: hintFontSize / textScaleFactor,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'terms & conditions',
                                  style: TextStyle(
                                    color: Color(0xFF4AC959),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' of FixinGuru, the cancellation policy and confirm that I am over 18 years of age.',
                                ),
                              ],
                            ),
                            scale: checkboxScale,
                          ),

                          SizedBox(height: spacingHeight),

                          // Newsletter checkbox with responsive sizing
                          _buildCheckbox(
                            context: context,
                            value: receiveUpdates,
                            onChanged: (value) {
                              setState(() {
                                receiveUpdates = value!;
                              });
                            },
                            textSpan: TextSpan(
                              text:
                                  'I would like to receive helpful information, updates, news and promotions through the FixinGuru ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: hintFontSize / textScaleFactor,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'newsletter',
                                  style: TextStyle(
                                    color: Color(0xFF4AC959),
                                  ),
                                ),
                              ],
                            ),
                            scale: checkboxScale,
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Continue button with responsive sizing and loading state
                          Center(
                            child: SizedBox(
                              width: min(size.width * 0.8, 320),
                              height: buttonHeight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4AC959),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[700],
                                  disabledForegroundColor: Colors.grey[400],
                                  elevation: canContinue ? 5 : 0,
                                  shadowColor:
                                      const Color(0xFF4AC959).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: canContinue ? _sendOTP : null,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            'Send OTP',
                                            style: TextStyle(
                                              fontSize: buttonFontSize /
                                                  textScaleFactor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    bool obscureText = false,
    required double labelFontSize,
    required double hintFontSize,
    required double iconSize,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final verticalPadding = max(min(size.height * 0.018, 15.0), 10.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4AC959), size: iconSize),
            SizedBox(width: max(size.width * 0.02, 8.0)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize / textScaleFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: max(size.height * 0.01, 4.0)),
        TextField(
          controller: controller,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: labelFontSize / textScaleFactor,
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: hintFontSize / textScaleFactor,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: max(size.width * 0.04, 16.0),
            ),
            filled: true,
            fillColor: Colors.grey[850]!.withOpacity(0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF4AC959), width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
          onChanged: (value) => _onPhoneChanged(),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required BuildContext context,
    required bool value,
    required Function(bool?) onChanged,
    required TextSpan textSpan,
    required double scale,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: scale,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4AC959),
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            textSpan,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String image,
    required Color backgroundColor,
    required Color? imageColor,
    required VoidCallback onPressed,
  }) {
    final size = MediaQuery.of(context).size;
    final buttonSize = max(min(size.width * 0.12, 45.0), 36.0);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            image,
            width: buttonSize * 0.6,
            color: imageColor,
          ),
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greyPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    double curveHeight = size.height * 0.28;

    final greyPath = Path();
    greyPath.moveTo(0, 0);
    greyPath.lineTo(size.width, 0);
    greyPath.lineTo(size.width, curveHeight);

    greyPath.quadraticBezierTo(
      size.width * 0.1,
      curveHeight - size.height * 0.08,
      0,
      curveHeight - size.height * 0.05,
    );

    greyPath.close();

    final blackPath = Path();
    blackPath.moveTo(0, curveHeight - size.height * 0.05);
    blackPath.quadraticBezierTo(
      size.width * 0.1,
      curveHeight - size.height * 0.13,
      size.width,
      curveHeight,
    );
    blackPath.lineTo(size.width, size.height);
    blackPath.lineTo(0, size.height);
    blackPath.close();

    canvas.drawPath(greyPath, greyPaint);
    canvas.drawPath(blackPath, blackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = max(min(size.width * 0.01, 5.0), 2.0);

    final paint = Paint()
      ..color = const Color(0xFF4AC959)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double curveHeight = size.height * 0.28;

    final path = Path();
    path.moveTo(0, curveHeight - size.height * 0.05);
    path.quadraticBezierTo(
      size.width * 0.1,
      curveHeight - size.height * 0.13,
      size.width,
      curveHeight,
    );

    final glowSize = max(min(size.width * 0.02, 10.0), 4.0);
    final glowPaint = Paint()
      ..color = const Color(0xFF4AC959).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowSize
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, min(5.0, size.width * 0.01));

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
