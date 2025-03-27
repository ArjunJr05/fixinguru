import 'dart:math';

import 'package:fixinguru/browse/broswer.dart';
import 'package:fixinguru/browse/broswer2.dart';
import 'package:fixinguru/browse/payment.dart';
import 'package:fixinguru/front/logout.dart';
import 'package:fixinguru/home/homepage.dart';
import 'package:fixinguru/home/notification.dart';
import 'package:fixinguru/home/profile.dart';
import 'package:fixinguru/home/search.dart';
import 'package:fixinguru/home/tasker.dart';
import 'package:fixinguru/login/loginpage.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 2;
  late AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Widget> _pages;

  // Sample task data for demonstration
  final Map<String, dynamic> sampleTask = {
    "title": "Furniture Assembly",
    "icon": "🪑",
    "time": "2-3 hours",
    "category": "Home Repair",
    "description": "Tomorrow, 2 PM | Subang Jaya",
  };

  // List of titles for the app bar
  final List<String> _titles = [
    'Tasks',
    'Browse Tasks',
    'Home',
    'Notifications',
    'Profile',
  ];

  // List of drawer menu items
  final List<Map<String, dynamic>> _drawerItems = [
    {'icon': Icons.home_outlined, 'title': 'Home'},
    {'icon': Icons.person_outline, 'title': 'My Profile'},
    {'icon': Icons.history, 'title': 'Task History'},
    {'icon': Icons.star_outline, 'title': 'Reviews'},
    {'icon': Icons.payment_outlined, 'title': 'Payments'},
    {'icon': Icons.settings_outlined, 'title': 'Settings'},
    {'icon': Icons.help_outline, 'title': 'Help & Support'},
    {'icon': Icons.info_outline, 'title': 'About Us'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize _pages here with access to context
    _pages = [
      Tasker(),
      BrowsePage(onTaskSelected: (task) {
        // Navigate to task details when a task is selected
        Navigator.push(
          context, // Now we can safely access context here
          MaterialPageRoute(
            builder: (context) => TaskDetailsPage(task: task),
          ),
        );
      }),
      HomeScreen(),
      NotificationsPage(),
      ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = max(min(size.width * 0.06, 24.0), 16.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      extendBody: true,

      // App Bar
      // In the _MainPageState class, update the build method's AppBar actions
      appBar: AppBar(
        backgroundColor: const Color(0xFF4AC959),
        title: Text(
          _titles[_currentNavIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.payment,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
          )
        ],
        elevation: 0,
      ),

      // Drawer
      drawer: _buildDrawer(context),

      // Body - show the current page
      body: _pages[_currentNavIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.article_outlined,
                  index: 0,
                  size: iconSize,
                ),
                _buildNavItem(
                  icon: Icons.search,
                  index: 1,
                  size: iconSize,
                ),
                _buildCentralNavItem(size: max(iconSize * 1.8, 50.0)),
                _buildNavItem(
                  icon: Icons.notifications_none,
                  index: 3,
                  size: iconSize,
                ),
                _buildNavItem(
                  icon: Icons.chat_rounded,
                  index: 4,
                  size: iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // App Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(),

            // Drawer Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _drawerItems.length,
                itemBuilder: (context, index) {
                  return _buildDrawerItem(
                    icon: _drawerItems[index]['icon'],
                    title: _drawerItems[index]['title'],
                    onTap: () {
                      Navigator.pop(context);
                      // Handle navigation
                    },
                  );
                },
              ),
            ),

            // Logout Button
            _buildLogoutButton(),

            // App Version
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Drawer Header
  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF4AC959),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  // Ensures the image fits inside the circular shape
                  child: Image.asset(
                    'assets/images/ganesh2.jpg',
                    width:
                        56, // Slightly smaller than the container to fit inside
                    height: 56,
                    fit: BoxFit
                        .cover, // Ensures the image covers the area properly
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arjun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'arjun@example.com',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4AC959).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4AC959).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFF4AC959),
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '4.8/5.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(120 reviews)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  // Logout Button
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          // Show the logout confirmation dialog
          _showLogoutConfirmationDialog(context);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.red.shade900,
              width: 1,
            ),
          ),
          backgroundColor: Colors.red.shade900.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red.shade300,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show the logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmationDialog(
        onConfirmLogout: () {
          // Perform logout logic here
          Navigator.of(context).pop(); // Close the dialog
          _performLogout(context); // Call the logout function
        },
      ),
    );
  }

  // Perform logout and navigate to the login screen
  void _performLogout(BuildContext context) {
    // Clear user session or perform any logout logic here
    // For example, you can use a state management solution (e.g., Provider, Riverpod) to clear the user's session.

    // Navigate to the login screen or home screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Replace with your login screen
      (Route<dynamic> route) => false, // Remove all routes from the stack
    );
  }

  // Build navigation item
  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required double size,
  }) {
    final isSelected = index == _currentNavIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _updateNavIndex(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFF4AC959).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF4AC959) : Colors.white,
            size: size,
          ),
        ),
      ),
    );
  }

  // Build central navigation button
  Widget _buildCentralNavItem({required double size}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4AC959).withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _updateNavIndex(2),
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CD964),
                  Color(0xFF4AC959),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF4AC959),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor:
                  Colors.black, // Black background inside the CircleAvatar
              radius:
                  size * 0.5, // Adjust the radius to fit inside the container
              child: Image.asset(
                'assets/images/logo.png', // Path to your image asset
                width: size * 1.5, // Set the width
                height: size * 1.5, // Set the height
                fit: BoxFit.contain, // Adjust the image fit
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Update the navigation index
  void _updateNavIndex(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
    });
  }
}
