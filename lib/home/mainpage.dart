import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 2;
  late AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Widget> _pages;
  bool _isCheckingLoginState = true;
  String? _userPhoneNumber;
  String _userName =
      'User'; // Default name, will be updated from preferences or Firestore

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

    // Initialize Firebase and then check login state
    Firebase.initializeApp().then((_) {
      _checkLoginState();
    });
  }

  // Check if user is logged in
  Future<void> _checkLoginState() async {
    try {
      bool isLoggedIn = await LoginStateManager.isLoggedIn();

      if (!isLoggedIn) {
        // User is not logged in, redirect to login page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      // User is logged in, get their phone number and initialize the app
      String? phoneNumber = await LoginStateManager.getSavedPhoneNumber();

      if (mounted) {
        setState(() {
          _userPhoneNumber = phoneNumber;
          _isCheckingLoginState = false;
        });

        // Initialize pages after confirming login state
        _initializePages();

        // Optionally load user data from Firestore
        _loadUserData();
      }
    } catch (e) {
      print('Error checking login state: $e');
      // On error, redirect to login page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  // Initialize pages after login verification
  void _initializePages() {
    _pages = [
      const Tasker(),
      BrowsePage(onTaskSelected: (task) {
        // Navigate to task details when a task is selected
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsPage(task: task),
          ),
        );
      }),
      const HomeScreen(),
      NotificationsPage(),
      const ProfilePage(),
    ];
  }

  // Load user data from SharedPreferences or Firestore
  // Add these variables at the top of your _MainPageState class
  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String? _profilePhotoUrl;

// Update the _loadUserData method
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phoneNumber = await LoginStateManager.getSavedPhoneNumber();

      if (phoneNumber != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(phoneNumber)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            _firstName = userData['firstName'] ?? '';
            _lastName = userData['lastName'] ?? '';
            _phoneNumber = phoneNumber;
            _profilePhotoUrl = userData['profile_photo_url'];

            // Update the user name for display
            _userName = '$_firstName $_lastName'.trim();

            // Save the name to preferences for future use
            prefs.setString('userName', _userName);
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Use default values on error
      setState(() {
        _firstName = 'User';
        _lastName = '';
        _userName = 'User';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking login state
    if (_isCheckingLoginState) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4AC959)),
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final iconSize = max(min(size.width * 0.06, 24.0), 16.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      extendBody: true,

      // App Bar
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
                MaterialPageRoute(builder: (context) => const PaymentPage()),
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
                MaterialPageRoute(builder: (context) => const ChatPage()),
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
                      // Handle navigation based on the item
                      _handleDrawerNavigation(_drawerItems[index]['title']);
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

  // Handle drawer navigation
  void _handleDrawerNavigation(String title) {
    switch (title) {
      case 'Home':
        setState(() {
          _currentNavIndex = 2; // Home tab
        });
        break;
      case 'My Profile':
        setState(() {
          _currentNavIndex = 4; // Profile tab
        });
        break;
      case 'Payments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentPage()),
        );
        break;
      // Add more cases as needed
      default:
        // Handle other menu items
        break;
    }
  }

  // Drawer Header with dynamic user data
  Widget _buildDrawerHeader() {
    // Get the first letter for the avatar
    String avatarText = _firstName.isNotEmpty
        ? _firstName[0].toUpperCase()
        : _lastName.isNotEmpty
            ? _lastName[0].toUpperCase()
            : '?';

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
              // Profile avatar with first letter
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4AC959).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4AC959),
                    width: 2,
                  ),
                ),
                child: Center(
                  child:
                      _profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _profilePhotoUrl!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to letter avatar if image fails to load
                                  return Text(
                                    avatarText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              avatarText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_firstName $_lastName'.trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _phoneNumber.isNotEmpty
                          ? "+91-" + _phoneNumber
                          : 'Phone not available',
                      style: const TextStyle(
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    // Store the context in a variable before showing the dialog
    final currentContext = context;

    showDialog(
      context: currentContext,
      builder: (context) => LogoutConfirmationDialog(
        onConfirmLogout: () {
          Navigator.of(context).pop(); // Close the dialog
          _performLogout(currentContext); // Use the stored context
        },
      ),
    );
  }

  // Logout Button
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          // Use the scaffold key to get the context
          if (_scaffoldKey.currentContext != null) {
            _showLogoutConfirmationDialog(_scaffoldKey.currentContext!);
          }
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

  // Perform logout and navigate to the login screen
  void _performLogout(BuildContext context) async {
    try {
      // Get the context before any async operations
      final navigator = Navigator.of(context);

      // Clear login state using the LoginStateManager
      await LoginStateManager.clearLoginState();

      // Use the stored navigator reference
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      // If there's an error, still try to navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
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
                color: const Color(0xFF4AC959),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: size * 0.5,
              child: Image.asset(
                'assets/images/logo.png',
                width: size * 1.5,
                height: size * 1.5,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if logo doesn't exist
                  return Icon(
                    Icons.home,
                    color: Colors.white,
                    size: size * 0.5,
                  );
                },
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

// Login State Manager (add this if it's not already in your login file)
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
    await prefs.remove('userName'); // Also clear saved user name
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
