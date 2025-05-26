// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:fixinguru/home/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskCategory {
  final int id;
  final String name;
  final IconData icon;
  bool enabled;

  TaskCategory(
      {required this.id,
      required this.name,
      required this.icon,
      this.enabled = true});
}

class TaskAlertsPage extends StatefulWidget {
  const TaskAlertsPage({super.key});

  @override
  _TaskAlertsPageState createState() => _TaskAlertsPageState();
}

class _TaskAlertsPageState extends State<TaskAlertsPage>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of notification categories with icons
  List<TaskCategory> categories = [
    TaskCategory(
        id: 1, name: 'Cleaning', icon: Icons.cleaning_services, enabled: true),
    TaskCategory(
        id: 2, name: 'Handy Person', icon: Icons.handyman, enabled: true),
    TaskCategory(id: 3, name: 'Assembly', icon: Icons.build, enabled: true),
    TaskCategory(
        id: 4, name: 'Delivery', icon: Icons.local_shipping, enabled: true),
    TaskCategory(id: 5, name: 'Moving', icon: Icons.poll, enabled: true),
    TaskCategory(
        id: 6,
        name: 'Electrical',
        icon: Icons.electrical_services,
        enabled: true),
    TaskCategory(id: 7, name: 'Plumbing', icon: Icons.plumbing, enabled: true),
    TaskCategory(id: 8, name: 'Gardening', icon: Icons.yard, enabled: true),
  ];

  bool get allCategoriesEnabled =>
      categories.every((category) => category.enabled);

  // Check if any category is enabled
  bool get anyCategoryEnabled => categories.any((category) => category.enabled);

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleCategory(int id) {
    setState(() {
      final categoryIndex =
          categories.indexWhere((category) => category.id == id);
      if (categoryIndex != -1) {
        categories[categoryIndex].enabled = !categories[categoryIndex].enabled;
      }
    });
  }

  void toggleAllCategories() {
    final newValue = !allCategoriesEnabled;
    setState(() {
      for (var category in categories) {
        category.enabled = newValue;
      }
    });
  }

  void saveSettings() {
    // Only proceed if at least one category is enabled
    if (!anyCategoryEnabled) return;

    // Animate saving
    _animationController.reset();
    _animationController.forward();

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Settings saved successfully!',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Navigate to MainPage after a short delay
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
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

                    // Bell icon and title
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
                            Icons.notifications_active,
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
                                'Edit your task alerts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize / 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'All alerts are on by default',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: subtitleFontSize / 2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: spacingHeight * 3),

                    // Categories container
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
                          // All Categories toggle
                          SwitchListTile(
                            title: Text(
                              'All Categories',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 / textScaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Toggle all task categories at once',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12 / textScaleFactor,
                              ),
                            ),
                            value: allCategoriesEnabled,
                            onChanged: (value) => toggleAllCategories(),
                            activeColor: const Color(0xFF4AC959),
                            inactiveTrackColor: Colors.grey[800],
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey[800],
                          ),

                          // List of categories
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: size.height * 0.45,
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: categories.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[800],
                                indent: 60,
                                endIndent: 20,
                              ),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return SwitchListTile(
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4AC959)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          category.icon,
                                          color: category.enabled
                                              ? const Color(0xFF4AC959)
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14 / textScaleFactor,
                                          fontWeight: category.enabled
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: category.enabled,
                                  onChanged: (value) =>
                                      toggleCategory(category.id),
                                  activeColor: const Color(0xFF4AC959),
                                  inactiveTrackColor: Colors.grey[800],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: spacingHeight * 0.8),

                    // Save button
                    Center(
                      child: SizedBox(
                        width: size.width * 0.7,
                        height: size.height * 0.07,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4AC959),
                            foregroundColor: Colors.white,
                            elevation: anyCategoryEnabled ? 5 : 0,
                            shadowColor: anyCategoryEnabled
                                ? const Color(0xFF4AC959).withOpacity(0.5)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: anyCategoryEnabled ? saveSettings : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save Preferences',
                                style: TextStyle(
                                  fontSize: buttonFontSize / textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Icon(
                                Icons.save_alt,
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
    double curveHeight = size.height * 0.24;

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

    double curveHeight = size.height * 0.24;

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
