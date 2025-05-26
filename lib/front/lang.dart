import 'package:fixinguru/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Responsive calculations
    final isSmallScreen = size.width < 360;

    // Adaptive sizing
    final baseFontSize = size.width / 28;
    final titleFontSize = max(min(baseFontSize * 1.8, 32.0), 22.0);
    final subtitleFontSize = max(min(baseFontSize * 1.1, 18.0), 16.0);
    final buttonFontSize = max(min(baseFontSize * 1.1, 18.0), 14.0);
    final noteFontSize = max(min(baseFontSize * 0.9, 15.0), 12.0);

    // Responsive spacing
    final horizontalPadding = max(size.width * 0.05, 12.0);
    final spacingHeight = max(size.height * 0.02, 8.0);
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

          // Content
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: spacingHeight / 10),

                          // Logo image
                          Image.asset(
                            'assets/images/lang.png',
                            height: min(size.height * 0.25, 180),
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Welcome text
                          Text(
                            'Welcome to FixinGuru',
                            style: TextStyle(
                              color: const Color(0xFF4AC959),
                              fontSize: titleFontSize / textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: spacingHeight / 2),

                          // Choose language text
                          Text(
                            'Choose Language to Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: subtitleFontSize / textScaleFactor,
                            ),
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Language grid with improved styling and animations
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _languageButton(
                                language: 'Tamil',
                                flagPath: 'assets/images/india.png',
                                size: size,
                                textScaleFactor: textScaleFactor,
                              ),
                              _languageButton(
                                language: 'English',
                                flagPath: 'assets/images/usa.png',
                                size: size,
                                textScaleFactor: textScaleFactor,
                              ),
                              _languageButton(
                                language: 'Melayu',
                                flagPath: 'assets/images/malaysia.png',
                                size: size,
                                textScaleFactor: textScaleFactor,
                              ),
                              _languageButton(
                                language: '中文',
                                flagPath: 'assets/images/china.png',
                                size: size,
                                textScaleFactor: textScaleFactor,
                              ),
                            ],
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Note text with responsive styling
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Note: ',
                                  style: TextStyle(
                                    color: const Color(0xFF4AC959),
                                    fontSize: noteFontSize / textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'you can also change the language later in settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: noteFontSize / textScaleFactor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: spacingHeight * 2),

                          // Continue button with matching styling to login page
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
                                  elevation:
                                      selectedLanguage.isNotEmpty ? 5 : 0,
                                  shadowColor:
                                      const Color(0xFF4AC959).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: selectedLanguage.isNotEmpty
                                    ? () {
                                        // Add haptic feedback
                                        HapticFeedback.mediumImpact();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
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

  Widget _languageButton({
    required String language,
    required String flagPath,
    required Size size,
    required double textScaleFactor,
  }) {
    final bool isSelected = selectedLanguage == language;
    final flagSize = max(min(size.width * 0.1, 40.0), 30.0);
    final fontSize = max(min(size.width * 0.04, 16.0), 12.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          selectedLanguage = language;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4AC959).withOpacity(0.2)
              : Colors.grey[900]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF4AC959) : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4AC959).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flag image with responsive sizing
              Image.asset(
                flagPath,
                height: flagSize,
                width: flagSize,
              ),

              SizedBox(height: size.height * 0.01),

              // Language text with responsive sizing
              Text(
                language,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize / textScaleFactor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusing the same background painters from LoginScreen
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
    double curveHeight = size.height * 0.36;

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
    double curveHeight = size.height * 0.36;

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
