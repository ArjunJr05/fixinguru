import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// First Screen - "Tell us about Yourself"
class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Controllers for the form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to check form validity
    _firstNameController.addListener(_checkFormValidity);
    _lastNameController.addListener(_checkFormValidity);
    _locationController.addListener(_checkFormValidity);
    _phoneController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    // Clean up controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Check if all fields are filled
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _locationController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isSmallScreen = size.width < 360;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Adjust font sizes based on screen size
    final titleFontSize = isSmallScreen ? 28.0 : 32.0;
    final subtitleFontSize = isSmallScreen ? 26.0 : 32.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

    // Adjust paddings based on screen size
    final horizontalPadding = size.width * 0.06; // 6% of screen width
    final containerPadding = isSmallScreen ? 15.0 : 20.0;

    // Adjust heights based on screen size
    final iconSize = size.width * 0.15 < 60 ? size.width * 0.15 : 60.0;
    final spacingHeight = size.height * 0.03; // 3% of screen height

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

          // Form content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacingHeight),

                    // User icon and title
                    Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4AC959).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: iconSize * 0.5,
                            color: const Color(0xFF4AC959),
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tell us about',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Yourself',
                                style: TextStyle(
                                  color: const Color(0xFF4AC959),
                                  fontSize: subtitleFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF4AC959)
                                          .withOpacity(0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: spacingHeight * 3),

                    // Form fields container
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
                          // First Name field
                          _buildInputField(
                            context: context,
                            label: 'First Name',
                            hintText: 'Enter your First Name',
                            controller: _firstNameController,
                            icon: Icons.person_outline,
                          ),

                          SizedBox(height: spacingHeight * 0.8),

                          // Last Name field
                          _buildInputField(
                            context: context,
                            label: 'Last Name',
                            hintText: 'Enter your Last Name',
                            controller: _lastNameController,
                            icon: Icons.people_outline,
                          ),

                          SizedBox(height: spacingHeight * 0.8),

                          // Location field
                          _buildInputField(
                            context: context,
                            label: 'Location',
                            hintText: 'What city do you live in',
                            controller: _locationController,
                            icon: Icons.location_on_outlined,
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.my_location,
                                color: Color(0xFF4AC959),
                              ),
                              onPressed: () {},
                            ),
                          ),

                          SizedBox(height: spacingHeight * 0.8),

                          // Phone Number field
                          _buildInputField(
                            context: context,
                            label: 'Phone Number',
                            hintText: 'Enter your phone number',
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: spacingHeight * 0.8),

                    // Next button
                    Center(
                      child: SizedBox(
                        width: size.width * 0.5,
                        height: size.height * 0.07,
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InterestScreen(),
                                    ),
                                  );
                                }
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: buttonFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Icon(
                                Icons.arrow_forward,
                                color: _isFormValid
                                    ? Colors.white
                                    : Colors.grey[400],
                                size: buttonFontSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: spacingHeight),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build input fields
  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final labelFontSize = isSmallScreen ? 14.0 : 16.0;
    final hintFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final verticalPadding = isSmallScreen ? 12.0 : 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF4AC959), size: iconSize),
            SizedBox(width: size.width * 0.02),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: labelFontSize / textScaleFactor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
        TextField(
          controller: controller,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: labelFontSize / textScaleFactor,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: hintFontSize / textScaleFactor,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: 20,
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
}

class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  // Option selection
  String selectedOption = 'both'; // Default selection

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isSmallScreen = size.width < 360;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Adjust font sizes based on screen size
    final titleFontSize = isSmallScreen ? 28.0 : 32.0;
    final subtitleFontSize = isSmallScreen ? 26.0 : 32.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

    // Adjust paddings based on screen size
    final horizontalPadding = size.width * 0.06; // 6% of screen width
    final containerPadding = isSmallScreen ? 15.0 : 20.0;

    // Adjust heights based on screen size
    final iconSize = size.width * 0.15 < 60 ? size.width * 0.15 : 60.0;
    final spacingHeight = size.height * 0.03; // 3% of screen height

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

          // Form content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacingHeight),

                    // Icon and title
                    Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4AC959).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.interests,
                            size: iconSize * 0.5,
                            color: const Color(0xFF4AC959),
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What are you',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize / 2,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'interested in?',
                                style: TextStyle(
                                  color: const Color(0xFF4AC959),
                                  fontSize: subtitleFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF4AC959)
                                          .withOpacity(0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: spacingHeight * 4),

                    // Options container
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
                        children: [
                          _buildOptionTile(
                            value: 'help',
                            title: 'Getting Help',
                            subtitle: 'I want to post tasks and find help',
                            icon: Icons.help_outline,
                            context: context,
                          ),

                          SizedBox(height: spacingHeight * 0.5),

                          // Option 2 - Making Money
                          _buildOptionTile(
                            value: 'money',
                            title: 'Making Money',
                            subtitle:
                                'I want to help people, earn money and do flexible tasks',
                            icon: Icons.attach_money,
                            context: context,
                          ),

                          SizedBox(height: spacingHeight * 0.5),

                          // Option 3 - Both
                          _buildOptionTile(
                            value: 'both',
                            title: 'Both',
                            subtitle:
                                'I want to do everything: find help and earn money on FixinGuru',
                            icon: Icons.all_inclusive,
                            context: context,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: spacingHeight * 2),

                    // Submit button
                    Center(
                      child: SizedBox(
                        width: size.width * 0.5,
                        height: size.height * 0.07,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4AC959),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor:
                                const Color(0xFF4AC959).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskAlertsPage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: buttonFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Icon(
                                Icons.check_circle_outline,
                                size: buttonFontSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: spacingHeight),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build radio option tiles
  Widget _buildOptionTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required BuildContext context,
  }) {
    final isSelected = selectedOption == value;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final optionIconSize = size.width * 0.1 < 40 ? size.width * 0.1 : 40.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4AC959).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF4AC959) : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: optionIconSize,
              height: optionIconSize,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4AC959) : Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFF4AC959) : Colors.white,
                      fontSize: titleFontSize / textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: subtitleFontSize / textScaleFactor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: isSmallScreen ? 0.8 : 1.0,
              child: Radio(
                value: value,
                groupValue: selectedOption,
                onChanged: (val) {
                  setState(() {
                    selectedOption = val.toString();
                  });
                  HapticFeedback.selectionClick();
                },
                activeColor: const Color(0xFF4AC959),
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF4AC959);
                  }
                  return Colors.grey;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TaskAlertsPage placeholder (simplified but responsive)
class TaskAlertsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Task Alerts',
          style: TextStyle(fontSize: 20 / textScaleFactor),
        ),
      ),
      body: Center(
        child: Text(
          'Task Alerts Page',
          style: TextStyle(fontSize: 16 / textScaleFactor),
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

    // Curve at 35% of the screen height
    double curveHeight = size.height * 0.285;

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

// Green curve painter
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4AC959)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.01 > 5.0 ? 5.0 : size.width * 0.01
      ..strokeCap = StrokeCap.round;

    double curveHeight = size.height * 0.285;

    final path = Path();
    path.moveTo(0, curveHeight - size.height * 0.05);
    path.quadraticBezierTo(
      size.width * 0.1,
      curveHeight - size.height * 0.13,
      size.width,
      curveHeight,
    );

    // Add a glow effect to the curve
    final glowPaint = Paint()
      ..color = const Color(0xFF4AC959).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02 > 10.0 ? 10.0 : size.width * 0.02
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
