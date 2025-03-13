// ignore_for_file: prefer_const_constructors

import 'package:fixinguru/front/logout.dart';
import 'package:fixinguru/login/loginpage.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Stats for the profile page
  final Map<String, int> taskerStats = {
    'Completed': 12,
    'Rating': 4, // Out of 5
    'Earnings': 850, // In dollars
  };

  final Map<String, int> clientStats = {
    'Posted': 6,
    'Completed': 3,
    'Bookmarked': 4,
  };

  // Profile information
  final String userName = "Alex Johnson";
  final String userBio =
      "Professional handyman with 5+ years of experience. Specializing in furniture assembly, home repairs, and moving assistance.";
  final String userLocation = "San Francisco, CA";
  final String memberSince = "May 2023";

  // Skills list
  final List<String> skills = [
    "Furniture Assembly",
    "Moving",
    "Home Repairs",
    "Painting",
    "Cleaning",
    "Gardening",
  ];

  // Reviews list for the profile
  final List<ReviewItem> reviews = [
    ReviewItem(
      name: "Sarah M.",
      date: "2 weeks ago",
      rating: 5,
      comment:
          "Alex was extremely professional and assembled my IKEA furniture quickly. Would hire again!",
      taskName: "Furniture Assembly",
    ),
    ReviewItem(
      name: "Michael T.",
      date: "1 month ago",
      rating: 4,
      comment:
          "Great job helping me move. Was on time and very careful with my belongings.",
      taskName: "Moving Assistance",
    ),
    ReviewItem(
      name: "Jennifer L.",
      date: "2 months ago",
      rating: 5,
      comment:
          "Fixed my leaky faucet and even gave me tips on preventing future issues. Very knowledgeable!",
      taskName: "Home Repairs",
    ),
  ];

  // Color scheme matching the existing app
  final primaryColor = const Color(0xFF4CD964);
  final backgroundColor = Colors.black;
  final cardColor = Color(0xFF121212);
  final textColor = Colors.white;
  final secondaryTextColor = Colors.grey;

  bool isEditingMode = false;
  bool isTaskerView = true;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make the UI responsive
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
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 1));
                },
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: [
                    SizedBox(height: screenHeight * 0.02),

                    // Profile header with avatar, name, edit button
                    _buildProfileHeader(context),

                    SizedBox(height: screenHeight * 0.025),

                    // Bio section
                    _buildBioSection(context),

                    SizedBox(height: screenHeight * 0.025),

                    // Stats overview
                    _buildStatsOverview(context),

                    SizedBox(height: screenHeight * 0.025),

                    // Skills section (only for tasker view)
                    if (isTaskerView) _buildSkillsSection(context),

                    if (isTaskerView) SizedBox(height: screenHeight * 0.025),

                    // Reviews section (only for tasker view)
                    if (isTaskerView) _buildReviewsSection(context),

                    // Task history (only for client view)
                    if (!isTaskerView) _buildTaskHistorySection(context),

                    SizedBox(height: screenHeight * 0.025),

                    // Account settings section
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

  // Profile header with avatar, name, and edit button
  Widget _buildProfileHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Hero(
          tag: 'profile-avatar',
          child: Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.2),
              border: Border.all(color: primaryColor, width: 2),
              image: DecorationImage(
                image: AssetImage('assets/images/ganesh2.jpg'),
                fit: BoxFit.cover,
                // Use a placeholder here, in a real app you would use user's image
                onError: (exception, stackTrace) {
                  // Fallback for when the image is not available
                },
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
              isEditingMode
                  ? TextField(
                      style: TextStyle(
                        color: textColor,
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        hintText: "Your Name",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      controller: TextEditingController(text: userName),
                    )
                  : Text(
                      userName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: isSmallScreen ? 12 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: secondaryTextColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    userLocation,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: secondaryTextColor,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Member since $memberSince",
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
        // Edit button
        IconButton(
          onPressed: () {
            setState(() {
              isEditingMode = !isEditingMode;
            });
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

  // Bio section
  Widget _buildBioSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
                  controller: TextEditingController(text: userBio),
                )
              : Text(
                  userBio,
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
        ],
      ),
    );
  }

  // Stats overview section
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
          'Tasks Completed',
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

  // Skills section (for tasker view)
  Widget _buildSkillsSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
                    // Add skill functionality
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        onTap: () {
                          // Remove skill functionality
                        },
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

  // Reviews section (for tasker view)
  Widget _buildReviewsSection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
          ...reviews
              .map((review) => _buildReviewItem(review, context))
              .toList(),
        ],
      ),
    );
  }

  // Review item
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

  // Task history section (for client view)
  Widget _buildTaskHistorySection(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // Sample task history
    final List<TaskItem> taskHistory = [
      TaskItem(
        name: "Furniture Assembly",
        icon: Icons.chair,
        color: Colors.blue,
        date: "2 weeks ago",
        status: "Completed",
      ),
      TaskItem(
        name: "House Cleaning",
        icon: Icons.cleaning_services,
        color: Colors.orange,
        date: "1 month ago",
        status: "Completed",
      ),
      TaskItem(
        name: "Garden Maintenance",
        icon: Icons.grass,
        color: Colors.green,
        date: "2 months ago",
        status: "Completed",
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
          ...taskHistory
              .map((task) => _buildTaskHistoryItem(task, context))
              .toList(),
        ],
      ),
    );
  }

  // Task history item
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
            child: Icon(task.icon, color: task.color),
            radius: isSmallScreen ? 18 : 20,
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

  // Account settings section
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
        boxShadow: [
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
                    // Handle navigation for each item
                    if (item['title'] == 'Log Out') {
                      // Show the logout confirmation dialog
                      _showLogoutConfirmationDialog(context);
                    } else {
                      // Navigate to other settings pages
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => SomePage()));
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
          }).toList(),
        ],
      ),
    );
  }

  // Stats card from the existing app (reused)
  // Stats card from the existing app (reused)
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
          boxShadow: [
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

void _performLogout(BuildContext context) {
  // Clear user session or perform any logout logic here
  // Example: Clear user data, reset state, etc.

  // Navigate to the login screen or home screen
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (context) => LoginScreen()), // Replace with your login screen
    (Route<dynamic> route) => false, // Remove all routes from the stack
  );
}
