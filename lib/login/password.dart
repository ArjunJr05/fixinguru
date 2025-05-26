import 'package:fixinguru/login/detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fixinguru/login/verify.dart';
import 'package:fixinguru/front/first.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;

  // Password validation flags
  bool _hasEightChars = false;
  bool _hasLettersAndNumbers = false;
  bool _hasUpperAndLowerCase = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to check form validity
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    // Clean up controllers
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate password
  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      // Check for at least 8 characters
      _hasEightChars = password.length >= 8;

      // Check for mixture of letters and numbers
      _hasLettersAndNumbers = RegExp(r'[A-Za-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password);

      // Check for mixture of uppercase and lowercase
      _hasUpperAndLowerCase = RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password);

      // Check if passwords match
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text &&
              _confirmPasswordController.text.isNotEmpty;

      // Update form validity
      _checkFormValidity();
    });
  }

  // Validate confirm password
  void _validateConfirmPassword() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text &&
              _confirmPasswordController.text.isNotEmpty;

      // Update form validity
      _checkFormValidity();
    });
  }

  // Check if all requirements are met
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _hasEightChars &&
          _hasLettersAndNumbers &&
          _hasUpperAndLowerCase &&
          _passwordsMatch;
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

          // Password content with improved scrolling and sizing
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
                            padding: const EdgeInsets.only(top: 10),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: Colors.white, size: iconSize),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),

                          // Join FixinGuru Text
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, top: 10, bottom: 20),
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

                          // Form fields container with adaptive sizing
                          Container(
                            padding: EdgeInsets.all(containerPadding),
                            decoration: BoxDecoration(
                              color: Colors.grey[900]!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey[800]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Password field
                                _buildInputField(
                                  context: context,
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  controller: _passwordController,
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  labelFontSize: labelFontSize,
                                  hintFontSize: hintFontSize,
                                  iconSize: iconSize,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF4AC959),
                                      size: iconSize,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),

                                SizedBox(height: spacingHeight * 1.5),

                                // Confirm Password field
                                _buildInputField(
                                  context: context,
                                  label: 'Confirm Password',
                                  hintText: 'Confirm your password',
                                  controller: _confirmPasswordController,
                                  icon: Icons.lock_outline,
                                  obscureText: _obscureConfirmPassword,
                                  labelFontSize: labelFontSize,
                                  hintFontSize: hintFontSize,
                                  iconSize: iconSize,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF4AC959),
                                      size: iconSize,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: spacingHeight * 1.5),

                          // Password requirements container
                          Container(
                            padding: EdgeInsets.all(containerPadding),
                            decoration: BoxDecoration(
                              color: Colors.grey[900]!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey[800]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequirementRow(
                                  context: context,
                                  text: 'At least 8 characters',
                                  isMet: _hasEightChars,
                                  iconSize: iconSize * 0.8,
                                  fontSize: hintFontSize,
                                ),
                                SizedBox(height: spacingHeight * 0.8),
                                _buildRequirementRow(
                                  context: context,
                                  text: 'A mixture of letters & numbers',
                                  isMet: _hasLettersAndNumbers,
                                  iconSize: iconSize * 0.8,
                                  fontSize: hintFontSize,
                                ),
                                SizedBox(height: spacingHeight * 0.8),
                                _buildRequirementRow(
                                  context: context,
                                  text:
                                      'A mixture of uppercase & lowercase letters',
                                  isMet: _hasUpperAndLowerCase,
                                  iconSize: iconSize * 0.8,
                                  fontSize: hintFontSize,
                                ),
                                SizedBox(height: spacingHeight * 0.8),
                                _buildRequirementRow(
                                  context: context,
                                  text: 'Passwords match',
                                  isMet: _passwordsMatch,
                                  iconSize: iconSize * 0.8,
                                  fontSize: hintFontSize,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Register button with responsive sizing
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
                                  elevation: _isFormValid ? 5 : 0,
                                  shadowColor:
                                      const Color(0xFF4AC959).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: _isFormValid
                                    ? () {
                                        // Add haptic feedback
                                        HapticFeedback.mediumImpact();
                                        // Navigate to next page (verification)
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const DetailPage(),
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
                                      'Register',
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

  // Requirement row builder with responsive sizing
  Widget _buildRequirementRow({
    required BuildContext context,
    required String text,
    required bool isMet,
    required double iconSize,
    required double fontSize,
  }) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? const Color(0xFF4AC959) : Colors.red,
          size: iconSize,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize / textScaleFactor,
            ),
          ),
        ),
      ],
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
        ),
      ],
    );
  }
}

// Background painter for dual colors
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

// Green curve painter with responsive stroke width
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
