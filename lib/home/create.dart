// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Categories with emoji icons
  List<Map<String, dynamic>> categories = [
    {'name': 'Cleaning', 'emoji': '🧹'},
    {'name': 'Moving', 'emoji': '📦'},
    {'name': 'Assembly', 'emoji': '🔧'},
    {'name': 'Delivery', 'emoji': '🚚'},
    {'name': 'Electrical', 'emoji': '⚡'},
    {'name': 'Plumbing', 'emoji': '🚿'},
    {'name': 'Gardening', 'emoji': '🌱'},
    {'name': 'Other', 'emoji': '🔍'},
  ];
  String selectedCategory = 'Cleaning';

  // Use consistent colors as theme variables
  final primaryColor = const Color(0xFF4CD964);
  final backgroundColor = const Color(0xFF121212);
  final cardColor = const Color(0xFF1E1E1E);
  final textColor = Colors.white;
  final secondaryTextColor = Colors.grey;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.black,
              surface: cardColor,
              onSurface: textColor,
            ),
            dialogBackgroundColor: backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.black,
              surface: cardColor,
              onSurface: textColor,
            ),
            dialogBackgroundColor: backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make the UI responsive
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Adaptive spacing based on screen size
    final double fieldSpacing = screenHeight * 0.01;
    final double sectionSpacing = screenHeight * 0.015;
    final double categoryItemWidth =
        screenWidth < 360 ? screenWidth * 0.23 : screenWidth * 0.25;

    // Determine if we need to adjust for smaller screens
    final bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Create New Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Add a subtle gradient to the app bar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Main content area with scrolling
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  children: [
                    // Task Title
                    _buildSectionTitle('Task Title'),
                    _buildTextFormField(
                      controller: _titleController,
                      hintText: 'e.g. Help me move my furniture',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: sectionSpacing),

                    // Task Category
                    _buildSectionTitle('Category'),
                    Container(
                      height: isSmallScreen
                          ? screenHeight * 0.11
                          : screenHeight * 0.13,
                      margin: EdgeInsets.symmetric(vertical: fieldSpacing),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final bool isSelected =
                              selectedCategory == category['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category['name'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: categoryItemWidth,
                              margin:
                                  EdgeInsets.only(right: screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withOpacity(0.15)
                                    : cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor.withOpacity(0.2)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      category['emoji'],
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? primaryColor
                                          : secondaryTextColor,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: fieldSpacing),

                    // Other Category Input - Only show when "Other" is selected
                    if (selectedCategory == 'Other') ...[
                      _buildSectionTitle('Specify Category'),
                      _buildTextFormField(
                        controller: _otherCategoryController,
                        hintText: 'Enter custom category',
                        prefixIcon: Icons.category,
                        validator: (value) {
                          if (selectedCategory == 'Other' &&
                              (value == null || value.isEmpty)) {
                            return 'Please specify the category';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: sectionSpacing),
                    ],

                    // Task Description
                    _buildSectionTitle('Description'),
                    _buildTextFormField(
                      controller: _descriptionController,
                      hintText: 'Describe your task in detail...',
                      maxLines: isSmallScreen ? 3 : 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: sectionSpacing),

                    // Location
                    _buildSectionTitle('Location'),
                    _buildTextFormField(
                      controller: _locationController,
                      hintText: 'Enter location',
                      prefixIcon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: sectionSpacing),

                    // Date and Time in a row
                    Row(
                      children: [
                        // Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Date'),
                              _buildDateField(),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        // Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Time'),
                              _buildTimeField(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionSpacing),

                    // Budget
                    _buildSectionTitle('Budget'),
                    _buildTextFormField(
                      controller: _budgetController,
                      hintText: 'Your budget',
                      prefixIcon: Icons.attach_money,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your budget';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    // Extra space at the bottom to ensure scrollability
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),

              // Fixed Post Task button at the bottom
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12 + bottomPadding,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, -4),
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process data and return to previous screen
                          String categoryName = selectedCategory;
                          if (selectedCategory == 'Other' &&
                              _otherCategoryController.text.isNotEmpty) {
                            categoryName = _otherCategoryController.text;
                          }

                          TaskItem newTask = TaskItem(
                            name: _titleController.text,
                            icon: _getCategoryIcon(selectedCategory),
                            color: _getCategoryColor(selectedCategory),
                            date: "Just now",
                            status: "Open",
                            category: categoryName,
                          );
                          Navigator.pop(context, newTask);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Post Task',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: secondaryTextColor),
          filled: false,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: primaryColor.withOpacity(0.7), size: 20)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: 11),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  color: primaryColor.withOpacity(0.7), size: 20),
              SizedBox(width: 12),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(color: textColor),
              ),
              Spacer(),
              Icon(Icons.arrow_drop_down, color: secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.access_time,
                  color: primaryColor.withOpacity(0.7), size: 20),
              SizedBox(width: 12),
              Text(
                _selectedTime.format(context),
                style: TextStyle(color: textColor),
              ),
              Spacer(),
              Icon(Icons.arrow_drop_down, color: secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Moving':
        return Icons.local_shipping;
      case 'Assembly':
        return Icons.build;
      case 'Delivery':
        return Icons.delivery_dining;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Plumbing':
        return Icons.plumbing;
      case 'Gardening':
        return Icons.yard;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.home_repair_service;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cleaning':
        return Colors.blue;
      case 'Moving':
        return Colors.orange;
      case 'Assembly':
        return Colors.purple;
      case 'Delivery':
        return Colors.amber;
      case 'Electrical':
        return Colors.yellow;
      case 'Plumbing':
        return Colors.cyan;
      case 'Gardening':
        return Colors.green;
      case 'Other':
        return Colors.grey;
      default:
        return primaryColor;
    }
  }
}

// Task Item class for creating new tasks
class TaskItem {
  final String name;
  final IconData icon;
  final Color color;
  final String date;
  final String status;
  final String category;

  TaskItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.date,
    required this.status,
    required this.category,
  });
}
