// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fixinguru/home/create.dart';
import 'package:flutter/material.dart';

class Tasker extends StatefulWidget {
  const Tasker({Key? key}) : super(key: key);

  @override
  State<Tasker> createState() => _TaskerState();
}

class _TaskerState extends State<Tasker> {
  bool isClient = false;
  bool isOffersExpanded = true;
  bool isActiveTasksExpanded = true;
  bool isCompletedExpanded = true;
  bool isPostedExpanded = true;

  List<TaskItem> clientTasks = [
    TaskItem(
      name: "Carry Boxes Upstairs",
      icon: Icons.people,
      color: Colors.blue,
      date: "2 days ago",
      status: "Open",
    ),
    TaskItem(
      name: "Clean my Old House",
      icon: Icons.person,
      color: Colors.orange,
      date: "1 day ago",
      status: "Open",
    ),
    TaskItem(
      name: "Assemble new Furniture",
      icon: Icons.face,
      color: Colors.purple,
      date: "3 days ago",
      status: "Open",
    ),
    TaskItem(
      name: "Clean my Old House",
      icon: Icons.person,
      color: Colors.orange,
      date: "5 days ago",
      status: "In Progress",
    ),
    TaskItem(
      name: "Carry Boxes Upstairs",
      icon: Icons.people,
      color: Colors.blue,
      date: "1 week ago",
      status: "Open",
    ),
    TaskItem(
      name: "Assemble new Furniture",
      icon: Icons.face,
      color: Colors.purple,
      date: "2 weeks ago",
      status: "Open",
    ),
  ];

  final primaryColor = const Color(0xFF4CD964);
  final backgroundColor = Colors.black;
  final cardColor = Color(0xFF121212);
  final textColor = Colors.white;
  final secondaryTextColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make the UI responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with toggle switch
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isClient = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isClient ? primaryColor : backgroundColor,
                        foregroundColor: !isClient ? Colors.black : textColor,
                        elevation: !isClient ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(20),
                            right: Radius.zero,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        side: BorderSide(
                          color:
                              !isClient ? primaryColor : Colors.grey.shade700,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'As a Tasker',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isClient = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isClient ? primaryColor : backgroundColor,
                        foregroundColor: isClient ? Colors.black : textColor,
                        elevation: isClient ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.zero,
                            right: Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        side: BorderSide(
                          color: isClient ? primaryColor : Colors.grey.shade700,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'As a Client',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content based on selected mode
            Expanded(
              child: isClient
                  ? _buildClientView(context)
                  : _buildTaskerView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = screenWidth * 0.05;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.02),

          // Welcome message
          Text(
            'My Tasks',
            style: TextStyle(
              color: textColor,
              fontSize: isSmallScreen ? 22 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          Text(
            'Manage your task requests',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),

          SizedBox(height: screenHeight * 0.025),

          // Stats overview with responsive spacing
          Row(
            children: [
              _buildStatCard(
                'Posted',
                clientTasks.length.toString(),
                Icons.post_add,
                primaryColor.withOpacity(0.2),
                primaryColor,
                context,
              ),
              SizedBox(width: screenWidth * 0.03),
              _buildStatCard(
                'Booked',
                '2',
                Icons.calendar_today,
                Colors.blue.withOpacity(0.2),
                Colors.blue,
                context,
              ),
              SizedBox(width: screenWidth * 0.03),
              _buildStatCard(
                'Completed',
                '3',
                Icons.check_circle,
                Colors.purple.withOpacity(0.2),
                Colors.purple,
                context,
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // Scrollable task sections
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: cardColor,
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1));
              },
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  _buildExpandableSection(
                    title: 'Posted Ads',
                    isExpanded: isPostedExpanded,
                    onTap: () {
                      setState(() {
                        isPostedExpanded = !isPostedExpanded;
                      });
                    },
                    content: isPostedExpanded ? _buildTasksList(context) : null,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  _buildExpandableSection(
                    title: 'Booked',
                    isExpanded: false,
                    onTap: () {},
                    content: null,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Completed section
                  _buildExpandableSection(
                    title: 'Completed',
                    isExpanded: false,
                    onTap: () {},
                    content: null,
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Create new task button for small screens or when scrolling
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.08),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => CreateTaskPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text(
                              'Create New Task',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the list of tasks for Posted Ads section
  Widget _buildTasksList(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Column(
      children: [
        ...clientTasks
            .map((task) => _buildEnhancedTaskItem(task, context))
            .toList(),
        if (clientTasks.isEmpty)
          _buildEmptyState(
            icon: Icons.post_add,
            message: 'No posted tasks yet',
            context: context,
          ),
      ],
    );
  }

  // Empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required BuildContext context,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(screenHeight * 0.03),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated Tasker view with improved UI and responsive design
  Widget _buildTaskerView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.02;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the tasker view
            Padding(
              padding: EdgeInsets.only(bottom: verticalPadding),
              child: Text(
                'My Dashboard',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Offer/Questions section (expandable)
            _buildTaskerExpandableSection(
              title: 'Offer/Questions',
              isExpanded: isOffersExpanded,
              onTap: () {
                setState(() {
                  isOffersExpanded = !isOffersExpanded;
                });
              },
              content: isOffersExpanded
                  ? _buildEmptyMessageContent(
                      'Soon you will discuss your active tasks here 🗨️',
                      Icons.chat_bubble_outline,
                      context,
                    )
                  : null,
            ),

            SizedBox(height: verticalPadding),

            // Active Tasks section (expandable)
            _buildTaskerExpandableSection(
              title: 'Active Tasks',
              isExpanded: isActiveTasksExpanded,
              onTap: () {
                setState(() {
                  isActiveTasksExpanded = !isActiveTasksExpanded;
                });
              },
              content: isActiveTasksExpanded
                  ? _buildEmptyMessageContent(
                      'Your active tasks will appear here',
                      Icons.assignment,
                      context,
                    )
                  : null,
            ),

            SizedBox(height: verticalPadding),

            // Completed section (expandable)
            _buildTaskerExpandableSection(
              title: 'Completed',
              isExpanded: isCompletedExpanded,
              onTap: () {
                setState(() {
                  isCompletedExpanded = !isCompletedExpanded;
                });
              },
              content: isCompletedExpanded
                  ? _buildEmptyMessageContent(
                      'Your completed tasks will appear here',
                      Icons.task_alt,
                      context,
                    )
                  : null,
            ),

            // Extra padding at the bottom for better scrolling
            SizedBox(height: verticalPadding * 2),
          ],
        ),
      ),
    );
  }

  // Helper method to build empty content with message and icon
  Widget _buildEmptyMessageContent(
      String message, IconData icon, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.18,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.grey[500],
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the tasker expandable sections with improved styling
  Widget _buildTaskerExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget? content,
  }) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSectionIcon(title),
                        color: primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content (if expanded)
          if (content != null) content,
        ],
      ),
    );
  }

  // Helper method to determine icon based on section title
  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Offer/Questions':
        return Icons.question_answer;
      case 'Active Tasks':
        return Icons.engineering;
      case 'Completed':
        return Icons.check_circle;
      case 'Posted Ads':
        return Icons.post_add;
      case 'Booked':
        return Icons.calendar_today;
      default:
        return Icons.list;
    }
  }

  // Helper method to build expandable sections for client view with improved styling
  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget? content,
  }) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSectionIcon(title),
                        color: primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          title == 'Posted Ads'
                              ? '${clientTasks.length}'
                              : title == 'Booked'
                                  ? '2'
                                  : '3',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content (if expanded)
          if (content != null) content,
        ],
      ),
    );
  }

  // Enhanced task item with improved visual styling
  Widget _buildEnhancedTaskItem(TaskItem task, BuildContext context) {
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
      margin: EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 12,
        ),
        leading: Hero(
          tag: 'task-${task.name}-icon',
          child: CircleAvatar(
            backgroundColor: task.color.withOpacity(0.2),
            child: Icon(task.icon, color: task.color),
            radius: isSmallScreen ? 20 : 24,
          ),
        ),
        title: Text(
          task.name,
          style: TextStyle(
            color: textColor,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              SizedBox(width: 4),
              Text(
                'Posted ${task.date}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isSmallScreen ? 10 : 10,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12,
            vertical: 6,
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
        onTap: () {
          // Navigate to task details
        },
      ),
    );
  }

  // Stats card for overview section with responsive design
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
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: isSmallScreen ? 16 : 20,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              count,
              style: TextStyle(
                color: textColor,
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
