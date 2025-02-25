import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fixinguru/login/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for the form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFormValid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to check form validity
    _emailController.addListener(_checkFormValidity);
    _passwordController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if all fields are filled
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
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

          // Login content with improved scrolling and sizing
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
                          SizedBox(height: spacingHeight / 2),

                          // App logo with responsive sizing
                          Center(
                            child: Image.asset(
                              'assets/images/login.png',
                              height: min(size.height * 0.25, 180),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 3),

                          // Form fields container with adaptive sizing
                          Container(
                            padding: EdgeInsets.all(containerPadding),
                            height: 250,
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
                                // Email field
                                _buildInputField(
                                  context: context,
                                  label: 'Email Address',
                                  hintText: 'Enter your email address',
                                  controller: _emailController,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  labelFontSize: labelFontSize,
                                  hintFontSize: hintFontSize,
                                  iconSize: iconSize,
                                ),

                                SizedBox(height: spacingHeight * 1.5),

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
                              ],
                            ),
                          ),

                          SizedBox(height: spacingHeight * 0.8),

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
                                        // Login logic here
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

                          SizedBox(height: spacingHeight * 0.8),

                          // OR LOG IN WITH - with FittedBox for better text scaling
                          Row(
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
                                    'OR LOG IN WITH',
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

                          SizedBox(height: spacingHeight * 0.8),

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

                          SizedBox(height: spacingHeight * 0.8),

                          // Register link with adaptable text sizing
                          Center(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Not a member of FixinGuru yet?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: hintFontSize,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Register here',
                                    style: TextStyle(
                                      color: const Color(0xFF4AC959),
                                      fontSize: hintFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
            // This triggers the listener which calls _checkFormValidity
          },
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
    double curveHeight = size.height * 0.34;

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
    double curveHeight = size.height * 0.34;

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
