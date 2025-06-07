import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fixinguru/login/password.dart';
import 'package:fixinguru/login/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _secondsRemaining = 60;
  bool _timerActive = true;
  bool _isVerifying = false;
  bool _isResending = false;

  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store current verification details
  String _currentVerificationId = '';
  int? _currentResendToken;

  bool get isOtpComplete {
    for (var controller in _otpControllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _currentResendToken = widget.resendToken;
    _startTimer();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timerActive) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
            _startTimer();
          } else {
            _timerActive = false;
          }
        });
      }
    });
  }

  String get formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _secondsRemaining = 60;
      _timerActive = true;
    });

    _startTimer();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 120),
        forceResendingToken: _currentResendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle auto-verification if it happens
          try {
            await _auth.signInWithCredential(credential);
            if (mounted) {
              _navigateToPasswordPage();
            }
          } catch (e) {
            if (mounted) {
              _showError('Auto-verification failed');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _isResending = false;
            });
            String errorMessage = 'Failed to resend code';

            if (e.code == 'too-many-requests') {
              errorMessage =
                  'Too many attempts. Please wait before trying again.';
            } else if (e.code == 'invalid-phone-number') {
              errorMessage = 'Invalid phone number';
            } else {
              errorMessage = e.message ?? 'Failed to resend code';
            }

            _showError(errorMessage);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          // Update verification details
          _currentVerificationId = verificationId;
          _currentResendToken = resendToken;

          if (mounted) {
            setState(() {
              _isResending = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code resent successfully!'),
                backgroundColor: Color(0xFF4AC959),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
          if (mounted) {
            setState(() {
              _isResending = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showError('Error resending OTP: ${e.toString()}');
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!isOtpComplete || _isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    String otp = _otpControllers.map((controller) => controller.text).join();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        // Successfully verified, navigate to password page
        _navigateToPasswordPage();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        String errorMessage = 'Verification failed';

        if (e.code == 'invalid-verification-code') {
          errorMessage =
              'Invalid verification code. Please check and try again.';
          _clearOtpFields();
        } else if (e.code == 'session-expired') {
          errorMessage =
              'Verification session expired. Please request a new code.';
        } else {
          errorMessage = e.message ?? 'Unknown verification error';
        }

        _showError(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        _showError('Error: ${e.toString()}');
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  void _navigateToPasswordPage() {
    final phoneNumberDigits =
        widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
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
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onOtpFieldChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      // Move to next field
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      // Move to previous field
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Auto-verify when all fields are filled
    if (isOtpComplete) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && isOtpComplete) {
          _verifyOtp();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Responsive calculations
    final isSmallScreen = size.width < 360;
    final baseFontSize = size.width / 28;
    final titleFontSize = max(min(baseFontSize * 1.8, 32.0), 22.0);
    final subtitleFontSize = max(min(baseFontSize * 1.2, 20.0), 16.0);
    final buttonFontSize = max(min(baseFontSize * 1.1, 18.0), 14.0);
    final labelFontSize = max(min(baseFontSize * 0.9, 16.0), 12.0);

    final horizontalPadding = max(size.width * 0.05, 12.0);
    final spacingHeight = max(size.height * 0.02, 8.0);
    final iconSize = max(min(size.width * 0.06, 24.0), 16.0);
    final buttonHeight = max(min(size.height * 0.07, 56.0), 40.0);

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
                          // Back button
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

                          SizedBox(height: spacingHeight),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Text(
                              'Verify Your Phone',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize / textScaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 3),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Text(
                              'Enter the 6-digit code sent to ${widget.phoneNumber}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: subtitleFontSize / textScaleFactor,
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 4),

                          // OTP Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return _buildOtpField(index, size);
                            }),
                          ),

                          SizedBox(height: spacingHeight * 3),

                          // Timer and Resend Section
                          Center(
                            child: Column(
                              children: [
                                if (_timerActive)
                                  Text(
                                    'Resend code in $formattedTime',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: labelFontSize / textScaleFactor,
                                    ),
                                  )
                                else
                                  TextButton(
                                    onPressed: _isResending ? null : _resendOtp,
                                    child: _isResending
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF4AC959),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Resend Code',
                                            style: TextStyle(
                                              color: const Color(0xFF4AC959),
                                              fontSize: labelFontSize /
                                                  textScaleFactor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: spacingHeight * 4),
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
                                  elevation: isOtpComplete ? 5 : 0,
                                  shadowColor:
                                      const Color(0xFF4AC959).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: (isOtpComplete && !_isVerifying)
                                    ? _verifyOtp
                                    : null,
                                child: _isVerifying
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
                                            'Verify & Continue',
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

                          SizedBox(height: spacingHeight * 2),

                          // Change phone number link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Change Phone Number',
                                style: TextStyle(
                                  color: const Color(0xFF4AC959),
                                  fontSize: labelFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight),
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

  Widget _buildOtpField(int index, Size size) {
    final fieldSize = max(min(size.width * 0.12, 50.0), 40.0);
    final fontSize = max(min(size.width * 0.05, 20.0), 16.0);

    return SizedBox(
      width: fieldSize,
      height: fieldSize,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[850]!.withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _otpControllers[index].text.isNotEmpty
                  ? const Color(0xFF4AC959)
                  : Colors.grey[700]!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4AC959),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onOtpFieldChanged(value, index),
        onTap: () {
          // Clear field when tapped if it has content
          if (_otpControllers[index].text.isNotEmpty) {
            _otpControllers[index].clear();
          }
        },
      ),
    );
  }
}

// Background painter classes (same as your signup screen)
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
