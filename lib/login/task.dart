// ignore_for_file: prefer_const_constructors

import 'dart:ui';

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

    // Here you would typically send this data to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
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
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Image with dark overlay - sized to fit any screen
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bell icon with shadow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 35,
                            child: Icon(
                              Icons.notifications_active,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 18),

                        // Title and description
                        Text(
                          'Edit your task alerts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: screenSize.width * 0.7,
                          child: Text(
                            'All alerts are on by default',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade300,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: screenSize.width * 0.9,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // All Categories toggle with improved styling
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    child: SwitchListTile(
                                      title: Row(
                                        children: [
                                          Icon(Icons.category,
                                              color: Colors.green),
                                          SizedBox(width: 12),
                                          Text(
                                            'All Categories',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Toggle all task categories at once',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12,
                                        ),
                                      ),
                                      value: allCategoriesEnabled,
                                      onChanged: (value) =>
                                          toggleAllCategories(),
                                      activeColor: Colors.green,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade800,
                                    thickness: 1,
                                  ),

                                  // Scrollable list of categories with improved styling
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: screenSize.height * 0.4,
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      itemCount: categories.length,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        height: 1,
                                        color: Colors.grey.shade800
                                            .withOpacity(0.5),
                                        indent: 60,
                                        endIndent: 20,
                                      ),
                                      itemBuilder: (context, index) {
                                        final category = categories[index];
                                        return Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 2),
                                          child: SwitchListTile(
                                            title: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    category.icon,
                                                    color: category.enabled
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  category.name,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: category.enabled
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: category.enabled,
                                            onChanged: (value) =>
                                                toggleCategory(category.id),
                                            activeColor: Colors.green,
                                            inactiveTrackColor:
                                                Colors.grey.shade800,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Save button with animation and gradient
                        Container(
                          width: screenSize.width * 0.9,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: anyCategoryEnabled
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                      spreadRadius: -5,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ElevatedButton(
                            onPressed: anyCategoryEnabled ? saveSettings : null,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.transparent,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                              disabledBackgroundColor:
                                  Colors.grey.shade800.withOpacity(0.3),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: anyCategoryEnabled
                                    ? LinearGradient(
                                        colors: [
                                          Colors.green.shade600,
                                          Colors.green.shade400,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: anyCategoryEnabled
                                    ? null
                                    : Colors.grey.shade800.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_alt,
                                        color: anyCategoryEnabled
                                            ? Colors.white
                                            : Colors.grey),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Preferences',
                                      style: TextStyle(
                                        color: anyCategoryEnabled
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
