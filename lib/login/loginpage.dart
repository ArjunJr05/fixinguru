import 'package:fixinguru/home/homepage.dart';
import 'package:fixinguru/home/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:fixinguru/login/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CAPTCHA Widget
class CaptchaWidget extends StatefulWidget {
  final Function(bool) onCaptchaVerified;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final bool initialVerifiedState;

  const CaptchaWidget({
    Key? key,
    required this.onCaptchaVerified,
    this.primaryColor = const Color(0xFF4AC959),
    this.backgroundColor = const Color(0xFF212121),
    this.textColor = Colors.white,
    this.initialVerifiedState = false,
  }) : super(key: key);

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  final TextEditingController _captchaController = TextEditingController();
  String _captchaText = '';
  late bool _isVerified;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isVerified = widget.initialVerifiedState;
    _generateCaptcha();
  }

  @override
  void dispose() {
    _captchaController.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _captchaText = String.fromCharCodes(
      Iterable.generate(
          5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    setState(() {
      _isVerified = false;
      _errorMessage = '';
      _captchaController.clear();
    });
    widget.onCaptchaVerified(false);
  }

  // Method to verify captcha - called externally
  bool verifyCaptcha() {
    final userInput = _captchaController.text.toUpperCase().trim();
    if (userInput == _captchaText) {
      setState(() {
        _isVerified = true;
        _errorMessage = '';
      });
      widget.onCaptchaVerified(true);
      return true;
    } else {
      setState(() {
        _isVerified = false;
        _errorMessage = 'Incorrect captcha. Please try again.';
      });
      widget.onCaptchaVerified(false);
      _generateCaptcha();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Responsive font sizes
    final titleFontSize = max(min(size.width / 30, 16.0), 12.0);
    final buttonFontSize = max(min(size.width / 28, 16.0), 12.0);
    final hintFontSize = max(min(size.width / 32, 14.0), 10.0);
    final iconSize = max(min(size.width * 0.06, 24.0), 16.0);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVerified ? widget.primaryColor : Colors.grey[600]!,
          width: _isVerified ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Security Verification',
            style: TextStyle(
              color: widget.textColor,
              fontSize: titleFontSize / textScaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          // Captcha display
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  height: max(min(size.height * 0.08, 50), 35),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: CaptchaPainter(_captchaText),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              IconButton(
                onPressed: _generateCaptcha,
                icon: Icon(
                  Icons.refresh,
                  color: widget.primaryColor,
                  size: iconSize,
                ),
                tooltip: 'Generate new captcha',
                padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                constraints: BoxConstraints(
                  minWidth: iconSize + 8,
                  minHeight: iconSize + 8,
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 8 : 12),

          // Input field
          TextField(
            controller: _captchaController,
            style: TextStyle(
              color: widget.textColor,
              fontSize: buttonFontSize / textScaleFactor,
            ),
            decoration: InputDecoration(
              hintText: 'Enter captcha code',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: hintFontSize / textScaleFactor,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 6 : 8,
              ),
              filled: true,
              fillColor: Colors.grey[850]!.withOpacity(0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              suffixIcon: _isVerified
                  ? Icon(
                      Icons.check_circle,
                      color: widget.primaryColor,
                      size: iconSize * 0.8,
                    )
                  : null,
            ),
            textCapitalization: TextCapitalization.characters,
          ),

          if (_errorMessage.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: hintFontSize / textScaleFactor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CaptchaPainter extends CustomPainter {
  final String text;

  CaptchaPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    // Draw background noise lines
    final noisePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        noisePaint,
      );
    }

    // Draw noise dots
    final dotPaint = Paint()..color = Colors.grey[500]!;
    for (int i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        1.0,
        dotPaint,
      );
    }

    // Draw captcha text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final charWidth = size.width / text.length;
    final baseFontSize = min(size.height * 0.6, 20);

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final colors = [
        Colors.black,
        Colors.blue[800]!,
        Colors.red[800]!,
        Colors.green[800]!
      ];
      final color = colors[random.nextInt(colors.length)];

      textPainter.text = TextSpan(
        text: char,
        style: TextStyle(
          color: color,
          fontSize: baseFontSize + random.nextInt(4).toDouble(),
          fontWeight: FontWeight.bold,
          fontFamily: random.nextBool() ? 'monospace' : null,
        ),
      );

      textPainter.layout();

      final xOffset = i * charWidth + (charWidth - textPainter.width) / 2;
      final yOffset = (size.height - textPainter.height) / 2 +
          (random.nextDouble() - 0.5) * 6;

      canvas.save();
      canvas.translate(
          xOffset + textPainter.width / 2, yOffset + textPainter.height / 2);
      canvas.rotate((random.nextDouble() - 0.5) * 0.2);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);

      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Main Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for the form fields
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<_CaptchaWidgetState> _captchaKey =
      GlobalKey<_CaptchaWidgetState>();
  bool _isFormValid = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isCaptchaVerified = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_checkFormValidity);
    _passwordController.addListener(_checkFormValidity);

    // Defer initial check to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormValidity();
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if all fields are filled (captcha verification happens on continue)
  void _checkFormValidity() {
    final isValid =
        _phoneController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    if (_isFormValid != isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isFormValid = isValid;
          });
        }
      });
    }
  }

  // Handle captcha verification
  void _onCaptchaVerified(bool isVerified) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isCaptchaVerified = isVerified;
        });
      }
    });
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('phoneNumber', phoneNumber);
  }

  // Login function to authenticate with Firestore
  Future<void> _login() async {
    if (!_isFormValid) return;

    // First verify captcha
    if (!_captchaKey.currentState!.verifyCaptcha()) {
      return; // Captcha verification failed, error message will be shown
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String phoneNumber = _phoneController.text.trim();
      String password = _passwordController.text.trim();

      // Add timeout and better error handling
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get()
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Connection timeout. Please check your internet connection.');
        },
      );

      if (userDoc.exists) {
        // Get user data
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if password field exists and matches
        if (userData.containsKey('password')) {
          String storedPassword = userData['password'].toString();

          if (storedPassword == password) {
            // Login successful - Save login state
            await _saveLoginState(phoneNumber);

            HapticFeedback.mediumImpact();

            // Navigate to main page
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ),
              );
            }
          } else {
            // Wrong password
            _showErrorDialog('Invalid password. Please try again.');
          }
        } else {
          // Password field doesn't exist in document
          _showErrorDialog('User data is incomplete. Please contact support.');
        }
      } else {
        // User not found
        _showErrorDialog('Phone number not registered. Please sign up first.');
      }
    } on Exception catch (e) {
      // Handle timeout and other exceptions
      String errorMessage = e.toString();
      if (errorMessage.contains('timeout') ||
          errorMessage.contains('Connection timeout')) {
        _showErrorDialog(
            'Connection timeout. Please check your internet connection and try again.');
      }
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Login Failed',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF4AC959)),
              ),
            ),
          ],
        );
      },
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

    return Scaffold(
      // Allow content to resize when keyboard appears
      resizeToAvoidBottomInset: true,
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
                              height: min(size.height * 0.2, 150),
                            ),
                          ),

                          SizedBox(height: spacingHeight * 3),

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
                                // Phone number field
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
                                    LengthLimitingTextInputFormatter(15),
                                  ],
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

                                SizedBox(height: spacingHeight * 1.5),

                                // CAPTCHA Widget
                                CaptchaWidget(
                                  key: _captchaKey,
                                  onCaptchaVerified: _onCaptchaVerified,
                                  primaryColor: const Color(0xFF4AC959),
                                  backgroundColor: const Color(0xFF212121),
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: spacingHeight * 1.2),

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
                                  elevation: _isFormValid ? 5 : 0,
                                  shadowColor:
                                      const Color(0xFF4AC959).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed:
                                    _isFormValid && !_isLoading ? _login : null,
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            'Continue',
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
                          SizedBox(height: spacingHeight * 0.4),
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
                                        builder: (context) =>
                                            const SignUpScreen(),
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
          // Removed onChanged callback that was causing the issue
        ),
      ],
    );
  }
}

// Utility class to handle login state management
class LoginStateManager {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _phoneNumberKey = 'phoneNumber';

  // Save login state when user successfully logs in
  static Future<void> saveLoginState(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_phoneNumberKey, phoneNumber);
  }

  // Clear login state when user logs out
  static Future<void> clearLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_phoneNumberKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get saved phone number
  static Future<String?> getSavedPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumberKey);
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
    double curveHeight = size.height * 0.31;

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
    double curveHeight = size.height * 0.31;

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
