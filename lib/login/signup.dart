import 'package:fixinguru/login/otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fixinguru/login/password.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for the form fields
  final _phoneController = TextEditingController();
  bool acceptTerms = false;
  bool receiveUpdates = false;

  // Function to check if both boxes are ticked and phone is entered
  bool get canContinue =>
      acceptTerms && receiveUpdates && _phoneController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to check form validity
    _phoneController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    // Clean up controller
    _phoneController.dispose();
    super.dispose();
  }

  // Check if all fields are filled and checkboxes are ticked
  void _checkFormValidity() {
    setState(() {
      // Updates will happen through setStates elsewhere
    });
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
      // Allow content to resize when keyboard appears
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

                          SizedBox(height: spacingHeight * 5),

                          // phone field with responsive sizing
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
                              _checkFormValidity();
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
                              _checkFormValidity();
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

                          // Continue button with responsive sizing
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
                                onPressed: canContinue
                                    ? () {
                                        // Add haptic feedback
                                        HapticFeedback.mediumImpact();
                                        // Navigate to password page
                                        Navigator.push(
                                          context,
            //                               MaterialPageRoute(
            // builder: (context) => OtpVerificationScreen(
            //   phoneNumber: _phoneController.text,
            // ),
            //                               ),
            MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(phoneNumber: '',)
                                          ),
                                        );
                                      }
                                    : null,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      'Continue',
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

                          SizedBox(height: spacingHeight),

                          // OR SIGN UP WITH - with dividers
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'OR SIGN UP WITH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: spacingHeight),

                          // Social login buttons with responsive sizing
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(
                                context: context,
                                image: 'assets/images/google.png',
                                backgroundColor: Colors.white,
                                imageColor: null,
                                onPressed: () {
                                  // Google login logic
                                  HapticFeedback.mediumImpact();
                                },
                              ),
                              SizedBox(width: max(size.width * 0.05, 16)),
                              _buildSocialButton(
                                context: context,
                                image: 'assets/images/facebook.png',
                                backgroundColor: Colors.blue[600]!,
                                imageColor: Colors.white,
                                onPressed: () {
                                  // Facebook login logic
                                  HapticFeedback.mediumImpact();
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: spacingHeight),

                          // Already signed in link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Already joined FixinGuru?',
                                style: TextStyle(
                                  color: const Color(0xFF4AC959),
                                  fontSize: hintFontSize,
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

  // Improved input field builder with responsive parameters
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
          onChanged: (value) {
            _checkFormValidity();
          },
        ),
      ],
    );
  }

  // Custom checkbox builder with responsive text
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

  // Improved social button builder with responsive sizing
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

// Background painter for dual colors - same as login screen
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

// Green curve painter with responsive stroke width - same as login screen
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
