import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fixinguru/login/password.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  int _secondsRemaining = 60;
  bool _timerActive = true;

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

    _startTimer();

    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      _otpControllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  void _startTimer() {
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

  void _resendOtp() {
    setState(() {
      _secondsRemaining = 60;
      _timerActive = true;
    });

    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code resent!'),
        backgroundColor: Color(0xFF4AC959),
      ),
    );
  }

  void _verifyOtp() {
    HapticFeedback.mediumImpact();
    final enteredOtp =
        _otpControllers.map((controller) => controller.text).join();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4AC959),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final isSmallScreen = size.width < 360;

    final baseFontSize = size.width / 28;
    final titleFontSize = max(min(baseFontSize * 1.8, 32.0), 22.0);
    final subtitleFontSize = max(min(baseFontSize * 1.2, 20.0), 16.0);
    final buttonFontSize = max(min(baseFontSize * 1.1, 18.0), 14.0);
    final hintFontSize = max(min(baseFontSize * 0.8, 14.0), 11.0);

    final horizontalPadding = max(size.width * 0.05, 12.0);
    final buttonHeight = max(min(size.height * 0.07, 56.0), 40.0);
    final spacingHeight = max(size.height * 0.02, 8.0);
    final iconSize = max(min(size.width * 0.06, 24.0), 16.0);

    final boxSize = max(min(size.width * 0.14, 70.0), 50.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
                          Padding(
                            padding: EdgeInsets.only(
                                left: horizontalPadding,
                                top: spacingHeight / 2),
                            child: Text(
                              'Verify Your Number',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize / textScaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(
                                left: horizontalPadding,
                                top: spacingHeight * 5),
                            child: Text(
                              'We\'ve sent a verification code to\n${widget.phoneNumber}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: subtitleFontSize / textScaleFactor,
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 3),

                          // OTP input boxes
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                4,
                                (index) => _buildOtpBox(
                                  context: context,
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  previousFocusNode:
                                      index > 0 ? _focusNodes[index - 1] : null,
                                  nextFocusNode:
                                      index < 3 ? _focusNodes[index + 1] : null,
                                  boxSize: boxSize,
                                  fontSize: titleFontSize,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Timer Text
                          Center(
                            child: Text(
                              'Code expires in: $formattedTime',
                              style: TextStyle(
                                color: _secondsRemaining > 10
                                    ? Colors.white
                                    : Colors.red[300],
                                fontSize: hintFontSize / textScaleFactor,
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 1.5),

                          // "Didn't receive code?" text and button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: hintFontSize / textScaleFactor,
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    _secondsRemaining == 0 ? _resendOtp : null,
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: _secondsRemaining == 0
                                        ? const Color(0xFF4AC959)
                                        : Colors.grey[600],
                                    fontSize: hintFontSize / textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Verify Button
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
                                onPressed: isOtpComplete ? _verifyOtp : null,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      'Verify & Continue',
                                      style: TextStyle(
                                        fontSize:
                                            buttonFontSize / textScaleFactor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Verification message at bottom
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Center(
                              child: Text(
                                'By verifying your number, you agree that we may send you notifications via SMS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: hintFontSize / textScaleFactor,
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

  // OTP Box Builder
  // OTP Box Builder
  Widget _buildOtpBox({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required double boxSize,
    required double fontSize,
    FocusNode? previousFocusNode,
    FocusNode? nextFocusNode,
  }) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: boxSize,
      height: boxSize,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[850]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              focusNode.hasFocus ? const Color(0xFF4AC959) : Colors.grey[700]!,
          width: focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF4AC959).withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (controller.text.isEmpty && previousFocusNode != null) {
                FocusScope.of(context).requestFocus(previousFocusNode);
              }
            }
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize / textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && nextFocusNode != null) {
              // If a digit is entered and there is a next field, move to it
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else if (value.isEmpty && previousFocusNode != null) {
              // If backspace is pressed on an empty field, move to previous field
              FocusScope.of(context).requestFocus(previousFocusNode);
            }

            // Check if all fields are filled to enable the verify button
            setState(() {});
          },
        ),
      ),
    );
  }
}

// Background painter for dual colors - same as signup screen
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for grey area (above the line)
    final greyPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    // Paint for black area (below the line)
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Responsive curve height - works better on various screen sizes
    double curveHeight = size.height * 0.28;

    // Path for the upper grey section
    final greyPath = Path();
    greyPath.moveTo(0, 0);
    greyPath.lineTo(size.width, 0);
    greyPath.lineTo(size.width, curveHeight);

    // Create the curve that separates grey and black
    greyPath.quadraticBezierTo(
      size.width * 0.1,
      curveHeight - size.height * 0.08,
      0,
      curveHeight - size.height * 0.05,
    );

    greyPath.close();

    // Path for the lower black section
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

    // Draw both sections
    canvas.drawPath(greyPath, greyPaint);
    canvas.drawPath(blackPath, blackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Green curve painter with responsive stroke width - same as signup screen
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Responsive stroke width calculation
    final strokeWidth = max(min(size.width * 0.01, 5.0), 2.0);

    final paint = Paint()
      ..color = const Color(0xFF4AC959)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Match curve height with background curve
    double curveHeight = size.height * 0.28;

    final path = Path();
    path.moveTo(0, curveHeight - size.height * 0.05);
    path.quadraticBezierTo(
      size.width * 0.1,
      curveHeight - size.height * 0.13,
      size.width,
      curveHeight,
    );

    // Add a glow effect to the curve with responsive blur size
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
