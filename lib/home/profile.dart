import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixinguru/front/logout.dart';
import 'package:fixinguru/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data variables
  String? _phoneNumber;
  String _firstName = '';
  String _lastName = '';
  String _location = '';
  String _about = '';
  String _createdDay = '';
  List<String> _skills = [];

  // Stats
  final Map<String, int> taskerStats = {
    'Completed': 0,
    'Rating': 0,
    'Earnings': 0,
  };

  final Map<String, int> clientStats = {
    'Posted': 0,
    'Completed': 0,
    'Bookmarked': 0,
  };

  // Color scheme
  final primaryColor = const Color(0xFF4CD964);
  final backgroundColor = Colors.black;
  final cardColor = Color(0xFF121212);
  final textColor = Colors.white;
  final secondaryTextColor = Colors.grey;

  bool isEditingMode = false;
  bool isTaskerView = true;
  bool _isLoading = true;

  // Controllers for editable fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _newSkillController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _newSkillController.dispose();
    _emailController.dispose(); // Add this line
    super.dispose();
  }

  // Add this variable with your other user data variables
  String _email = '';

// Update the _loadUserData method to fetch email
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get phone number from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _phoneNumber = prefs.getString('phoneNumber');

      if (_phoneNumber != null) {
        // Fetch user document
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_phoneNumber).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Set user data including email
          setState(() {
            _firstName = userData['first_name'] ?? '';
            _lastName = userData['last_name'] ?? '';
            _location = userData['location'] ?? '';
            _about = userData['about'] ?? '';
            _createdDay = userData['created_day'] ?? '';
            _email = userData['email'] ?? '';

            // Initialize controllers
            _firstNameController.text = _firstName;
            _lastNameController.text = _lastName;
            _locationController.text = _location;
            _aboutController.text = _about;
            _emailController.text = _email; // Add this line
          });

          // Fetch skills document
          DocumentSnapshot skillsDoc =
              await _firestore.collection('skill').doc(_phoneNumber).get();

          List<String> skillsList = [];
          if (skillsDoc.exists) {
            Map<String, dynamic> skillsData =
                skillsDoc.data() as Map<String, dynamic>;

            // Extract all string values that aren't metadata fields
            skillsData.forEach((key, value) {
              if (value is String &&
                  key != 'about' &&
                  key != 'created_day' &&
                  key != 'email' &&
                  key != 'first_name' &&
                  key != 'last_name' &&
                  key != 'location' &&
                  key != 'password') {
                skillsList.add(value);
              }
            });
          }

          setState(() {
            _skills = skillsList;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    if (_phoneNumber == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user document
      await _firestore.collection('users').doc(_phoneNumber).update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'location': _locationController.text,
        'about': _aboutController.text,
        'email': _emailController.text, // Add this line to update email
      });

      // Create a map for skills where each skill is a separate field
      Map<String, dynamic> skillsMap = {};
      for (int i = 0; i < _skills.length; i++) {
        skillsMap['skill_${i + 1}'] = _skills[i];
      }

      // Update the skills document
      await _firestore.collection('skill').doc(_phoneNumber).set({
        ...skillsMap,
        'about': _aboutController.text,
        'created_day': _createdDay,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'location': _locationController.text,
      }, SetOptions(merge: true));

      // Refresh data
      await _loadUserData();

      setState(() {
        isEditingMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profile updated successfully!',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          duration: Duration(seconds: 3),
          elevation: 6,
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addSkill() {
    if (_newSkillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_newSkillController.text.trim());
        _newSkillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  Widget _buildProfileHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Get first letter of first name for avatar
    String avatarText =
        _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with first letter
        Hero(
          tag: 'profile-avatar',
          child: Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.2),
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: Center(
              child: Text(
                avatarText,
                style: TextStyle(
                  fontSize: isSmallScreen ? 40 : 50,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        // Name and member since info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name section
              isEditingMode
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          style: TextStyle(
                            color: textColor,
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            hintText: "First Name",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: _firstNameController,
                        ),
                        SizedBox(height: 4),
                        TextField(
                          style: TextStyle(
                            color: textColor,
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            hintText: "Last Name",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: _lastNameController,
                        ),
                      ],
                    )
                  : Text(
                      '$_firstName $_lastName',
                      style: TextStyle(
                        color: textColor,
                        fontSize: isSmallScreen ? 12 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

              SizedBox(height: 4),
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: secondaryTextColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  isEditingMode
                      ? Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: textColor,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              hintText: "Location",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: _locationController,
                          ),
                        )
                      : Text(
                          _location,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                ],
              ),
              SizedBox(height: 4),
              // Phone Number
              if (_phoneNumber != null && _phoneNumber!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: secondaryTextColor,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "+91-" + _phoneNumber!,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 4),
              // Email
              // Email
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: secondaryTextColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  isEditingMode
                      ? Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: textColor,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: TextEditingController(
                                text: _email), // Add this controller
                          ),
                        )
                      : Text(
                          _email.isNotEmpty
                              ? _email
                              : "No email provided", // Use the _email variable
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                ],
              ),
              SizedBox(height: 4),
              // Member since
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: secondaryTextColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Member since $_createdDay",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Edit/Save button
        IconButton(
          onPressed: () {
            if (isEditingMode) {
              _saveProfileChanges();
            } else {
              setState(() {
                isEditingMode = true;
              });
            }
          },
          icon: Icon(
            isEditingMode ? Icons.check : Icons.edit,
            color: primaryColor,
          ),
          tooltip: isEditingMode ? "Save Profile" : "Edit Profile",
        ),
      ],
    );
  }

  Widget _buildBioSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About Me",
            style: TextStyle(
              color: primaryColor,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          isEditingMode
              ? TextField(
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  maxLines: 4,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    hintText: "Tell others about yourself...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  controller: _aboutController,
                )
              : _about.isEmpty
                  ? Text(
                      "No about added yet",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: isSmallScreen ? 13 : 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Text(
                      _about,
                      style: TextStyle(
                        color: textColor,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Skills",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isEditingMode)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: cardColor,
                        title: Text(
                          "Add Skill",
                          style: TextStyle(color: primaryColor),
                        ),
                        content: TextField(
                          controller: _newSkillController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: "Enter new skill",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            onPressed: () {
                              _addSkill();
                              Navigator.pop(context);
                            },
                            child: Text("Add",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: primaryColor,
                    size: 16,
                  ),
                  label: Text(
                    "Add",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          _skills.isEmpty && !isEditingMode
              ? Text(
                  "No skills added yet",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.asMap().entries.map((entry) {
                    int index = entry.key;
                    String skill = entry.value;
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            skill,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isEditingMode) ...[
                            SizedBox(width: 4),
                            InkWell(
                              onTap: () => _removeSkill(index),
                              child: Icon(
                                Icons.close,
                                color: primaryColor,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // Other existing methods (_buildStatsOverview, _buildReviewsSection, etc.) remain the same
  // Just replace the hardcoded values with your variables

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: cardColor,
                onRefresh: _loadUserData,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    _buildProfileHeader(context),
                    SizedBox(height: screenHeight * 0.025),
                    _buildBioSection(context),
                    SizedBox(height: screenHeight * 0.025),
                    _buildStatsOverview(context),
                    SizedBox(height: screenHeight * 0.025),
                    if (isTaskerView) _buildSkillsSection(context),
                    if (isTaskerView) SizedBox(height: screenHeight * 0.025),
                    if (isTaskerView) _buildReviewsSection(context),
                    if (!isTaskerView) _buildTaskHistorySection(context),
                    SizedBox(height: screenHeight * 0.025),
                    _buildAccountSettingsSection(context),
                    SizedBox(height: screenHeight * 0.08),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The rest of your existing widget methods (_buildStatsOverview, _buildReviewsSection, etc.)
  // should remain the same, just make sure to replace any hardcoded values with your variables
  // For brevity, I'm not including them all here, but they should be in your original code

  Widget _buildStatsOverview(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Use the appropriate stats based on the current view
    final stats = isTaskerView ? taskerStats : clientStats;

    // Generate stat cards
    List<Widget> statCards = [];

    if (isTaskerView) {
      statCards = [
        _buildStatCard(
          'Resolved',
          stats['Completed'].toString(),
          Icons.check_circle,
          Colors.purple.withOpacity(0.2),
          Colors.purple,
          context,
        ),
        SizedBox(width: screenWidth * 0.03),
        _buildStatCard(
          'Rating',
          '${stats['Rating']}/5',
          Icons.star,
          Colors.orange.withOpacity(0.2),
          Colors.orange,
          context,
        ),
        SizedBox(width: screenWidth * 0.03),
        _buildStatCard(
          'Earnings',
          '\$${stats['Earnings']}',
          Icons.attach_money,
          primaryColor.withOpacity(0.2),
          primaryColor,
          context,
        ),
      ];
    } else {
      statCards = [
        _buildStatCard(
          'Posted',
          stats['Posted'].toString(),
          Icons.post_add,
          primaryColor.withOpacity(0.2),
          primaryColor,
          context,
        ),
        SizedBox(width: screenWidth * 0.03),
        _buildStatCard(
          'Completed',
          stats['Completed'].toString(),
          Icons.task_alt,
          Colors.purple.withOpacity(0.2),
          Colors.purple,
          context,
        ),
        SizedBox(width: screenWidth * 0.03),
        _buildStatCard(
          'Bookmarked',
          stats['Bookmarked'].toString(),
          Icons.bookmark,
          Colors.blue.withOpacity(0.2),
          Colors.blue,
          context,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: statCards,
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // Sample reviews - in a real app, you'd fetch these from Firestore
    final List<ReviewItem> reviews = [
      ReviewItem(
        name: "Sarah M.",
        date: "2 weeks ago",
        rating: 5,
        comment: "Great work!",
        taskName: "Furniture Assembly",
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reviews",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${reviews.length}",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...reviews.map((review) => _buildReviewItem(review, context)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewItem review, BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                review.date,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              // Task name
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review.taskName,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Rating stars
              ...List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: isSmallScreen ? 14 : 16,
                );
              }),
            ],
          ),
          SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              color: textColor,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHistorySection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // Sample task history - in a real app, fetch from Firestore
    final List<TaskItem> taskHistory = [
      TaskItem(
        name: "Furniture Assembly",
        icon: Icons.chair,
        color: Colors.blue,
        date: "2 weeks ago",
        status: "Completed",
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Task History",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${taskHistory.length}",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...taskHistory.map((task) => _buildTaskHistoryItem(task, context)),
        ],
      ),
    );
  }

  Widget _buildTaskHistoryItem(TaskItem task, BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    Color statusColor;
    switch (task.status.toLowerCase()) {
      case 'open':
        statusColor = primaryColor;
        break;
      case 'in progress':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = primaryColor;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: task.color.withOpacity(0.2),
            radius: isSmallScreen ? 18 : 20,
            child: Icon(task.icon, color: task.color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Posted ${task.date}",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              task.status,
              style: TextStyle(
                color: statusColor,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    List<Map<String, dynamic>> settingsItems = [
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage your alerts',
        'color': Colors.orange,
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'subtitle': 'Add or edit payment options',
        'color': Colors.green,
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Privacy & Security',
        'subtitle': 'Manage your account security',
        'color': Colors.blue,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get assistance',
        'color': Colors.purple,
      },
      {
        'icon': Icons.logout,
        'title': 'Log Out',
        'subtitle': 'Sign out of your account',
        'color': Colors.red,
      },
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Settings",
            style: TextStyle(
              color: primaryColor,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          ...settingsItems.map((item) {
            return Column(
              children: [
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: isSmallScreen ? 18 : 20,
                    ),
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      color: textColor,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle'],
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: secondaryTextColor,
                    size: isSmallScreen ? 14 : 16,
                  ),
                  onTap: () {
                    if (item['title'] == 'Log Out') {
                      _showLogoutConfirmationDialog(context);
                    }
                  },
                ),
                if (settingsItems.indexOf(item) < settingsItems.length - 1)
                  Divider(
                    color: Colors.grey.shade800,
                    height: 1,
                    indent: 56,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color bgColor,
    Color iconColor,
    BuildContext context,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                color: textColor,
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmationDialog(
        onConfirmLogout: () {
          Navigator.of(context).pop();
          _performLogout(context);
        },
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    // Clear user session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('phoneNumber');
    await prefs.setBool('isLoggedIn', false);

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}

class ReviewItem {
  final String name;
  final String date;
  final int rating;
  final String comment;
  final String taskName;

  ReviewItem({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
    required this.taskName,
  });
}

class TaskItem {
  final String name;
  final IconData icon;
  final Color color;
  final String date;
  final String status;

  TaskItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.date,
    required this.status,
  });
}
