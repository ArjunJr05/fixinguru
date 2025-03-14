import 'dart:math';

import 'package:fixinguru/browse/broswer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Main color scheme for the app
class AppColors {
  static const Color primary = Color(0xFF00C853);
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color divider = Color(0xFF2C2C2C);
}

class BrowsePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTaskSelected;

  const BrowsePage({Key? key, required this.onTaskSelected}) : super(key: key);

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage>
    with SingleTickerProviderStateMixin {
  String selectedCategory = "All";
  late AnimationController _shakeController;
  final Map<String, GlobalKey> _buttonKeys =
      {}; // Changed to _buttonKeys for buttons only
  String?
      _currentlyShakingTaskId; // Track which task button is currently shaking

  // Add animation controller for shake effect
  @override
  void initState() {
    super.initState();
    filteredTasks = List.from(allTasks);
    _searchController.addListener(_onSearchChanged);

    // Initialize the shake animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize button keys for all tasks
    for (var task in allTasks) {
      _buttonKeys[task["id"]] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Sample task data
  // In _BrowsePageState class, modify the allTasks list
  final List<Map<String, dynamic>> allTasks = [
    {
      "id": "task1",
      "title": "Furniture Assembly",
      "icon": "🛏️",
      "time": "2-3 hours",
      "description": "Tomorrow, 2 PM | Subang Jaya",
      "amount": "RS 150",
      "category": "Home Repair",
    },
    {
      "id": "task2",
      "title": "House Cleaning",
      "icon": "🧹",
      "time": "4-5 hours",
      "description": "This Weekend | Petaling Jaya",
      "amount": "RS 200",
      "category": "Cleaning",
    },
    {
      "id": "task3",
      "title": "Moving Assistance",
      "icon": "📦",
      "time": "Full Day",
      "description": "Next Monday | Cheras",
      "amount": "RS 350",
      "category": "Transport & Removals",
    },
    {
      "id": "task4",
      "title": "Bathroom Repair",
      "icon": "🚿",
      "time": "2-3 hours",
      "description": "Flexible | Ampang",
      "amount": "RS 180",
      "category": "Plumbing",
    },
    {
      "id": "task5",
      "title": "Room Painting",
      "icon": "🎨",
      "time": "1-2 days",
      "description": "Next Week | Bangsar",
      "amount": "RS 400",
      "category": "Painting",
    },
    {
      "id": "task6",
      "title": "Office Relocation",
      "icon": "🏢",
      "time": "Full Weekend",
      "description": "March 20-21 | KLCC",
      "amount": "RS 800",
      "category": "Transport & Removals",
    },
    {
      "id": "task7",
      "title": "Kitchen Renovation",
      "icon": "🍳",
      "time": "1-2 weeks",
      "description": "Starting April | Mont Kiara",
      "amount": "RS 1,500",
      "category": "Home Repair",
    },
    {
      "id": "task8",
      "title": "Garden Maintenance",
      "icon": "🌱",
      "time": "3-4 hours",
      "description": "Every Weekend | Damansara",
      "amount": "RS 120",
      "category": "Gardening",
    },
  ];

  List<Map<String, dynamic>> filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Pre-defined categories list for better performance
  final List<Map<String, String>> categories = [
    {"name": "All", "emoji": "🔍"},
    {"name": "Cleaning", "emoji": "🧹"},
    {"name": "Transport & Removals", "emoji": "🚚"},
    {"name": "Home Repair", "emoji": "🔧"},
    {"name": "Plumbing", "emoji": "🚿"},
    {"name": "Painting", "emoji": "🎨"},
    {"name": "Gardening", "emoji": "🌱"},
  ];

  void _onSearchChanged() {
    _filterTasks();
  }

  void _filterTasks() {
    String searchTerm = _searchController.text.toLowerCase();

    setState(() {
      if (searchTerm.isEmpty && selectedCategory == "All") {
        filteredTasks = List.from(allTasks);
      } else {
        filteredTasks = allTasks.where((task) {
          // Check if task matches search term
          bool matchesSearch = searchTerm.isEmpty ||
              task["title"].toLowerCase().contains(searchTerm) ||
              task["description"].toLowerCase().contains(searchTerm);

          // Check if task matches selected category
          bool matchesCategory =
              selectedCategory == "All" || task["category"] == selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      _filterTasks();
    });
  }

  // Method to navigate to task detail page
  void _navigateToTaskDetail(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(task: task),
      ),
    );
  }

  // Modified method to create shake effect on the button only
  void _shakeButton(String taskId) {
    if (_buttonKeys.containsKey(taskId) &&
        _buttonKeys[taskId]!.currentContext != null) {
      // Provide haptic feedback to indicate the tap was received
      HapticFeedback.mediumImpact();

      // Set currently shaking task
      setState(() {
        _currentlyShakingTaskId = taskId;
      });

      // Reset the controller and start the animation
      _shakeController.reset();
      _shakeController.forward().then((_) {
        // Clear the currently shaking task when animation completes
        setState(() {
          _currentlyShakingTaskId = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get device dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16.0 : 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  // Replace the text with search and filter icons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: AppColors.textSecondary,
                          size: isSmallScreen ? 20 : 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _filterTasks();
                            }
                          });
                        },
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.textSecondary,
                          size: isSmallScreen ? 20 : 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          _showFilterBottomSheet(context, isSmallScreen);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search field
            if (_isSearching)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 20.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon:
                        Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    _filterTasks();
                  },
                ),
              ),

            SizedBox(
              height: isSmallScreen ? 90 : 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.0 : 16.0,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(categories[index]["name"]!,
                      categories[index]["emoji"]!, isSmallScreen);
                },
              ),
            ),

            // Available tasks section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16.0 : 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Available Tasks",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      "${filteredTasks.length} Tasks",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task list
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState(isSmallScreen)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16.0 : 20.0,
                        vertical: 8.0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _buildTaskCard(task, isSmallScreen);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: isSmallScreen ? 60 : 70,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            "No tasks found",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, String emoji, bool isSmallScreen) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => _filterByCategory(category),
      child: Container(
        width: isSmallScreen ? 70 : 80,
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 6 : 8,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isSmallScreen ? 22 : 24),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              category.length > 10
                  ? "${category.substring(0, 8)}..."
                  : category,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Updated task card to shake only the view details button
  Widget _buildTaskCard(Map<String, dynamic> task, bool isSmallScreen) {
    // Create a shake animation for the button
    final Animation<double> offsetAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Check if this specific task button is the one that should be shaking
    final bool shouldShakeThisButton = _currentlyShakingTaskId == task["id"];

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          // Activate shake effect when the card is tapped
          _shakeButton(task["id"]);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isSmallScreen ? 50 : 56,
                    height: isSmallScreen ? 50 : 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        task["icon"],
                        style: TextStyle(fontSize: isSmallScreen ? 22 : 24),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                task["title"],
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isSmallScreen ? 15 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            // Task amount
                            Text(
                              task["amount"],
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 3 : 4),
                        Text(
                          task["description"],
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Wrap(
                          spacing: isSmallScreen ? 6 : 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                task["time"],
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                task["category"] ?? "General",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // View Detail Button with shake animation
              AnimatedBuilder(
                animation: offsetAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: shouldShakeThisButton
                        ? Offset(
                            sin(_shakeController.value * 10 * 3.14159) * 10, 0)
                        : Offset.zero,
                    child: child!,
                  );
                },
                child: SizedBox(
                  key: _buttonKeys[task["id"]],
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToTaskDetail(task),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                    ),
                    child: Text(
                      "View Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, bool isSmallScreen) {
    // Using a separate variable for state inside the modal
    String tempSelectedCategory = selectedCategory;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filter Tasks",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Categories",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories.map((category) {
                    final isSelected = tempSelectedCategory == category["name"];

                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          tempSelectedCategory = category["name"]!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          category["name"]!,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = tempSelectedCategory;
                      _filterTasks();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Apply Filters",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
