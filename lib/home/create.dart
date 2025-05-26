import 'package:fixinguru/home/recipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // For text-to-speech
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // For speech-to-text
import 'package:http/http.dart' as http; // For API calls
import 'dart:convert'; // For JSON parsing

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

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

  // Add speech-to-text instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Add text-to-speech instance
  final FlutterTts _flutterTts = FlutterTts();

  // API URL of your deployed Flask app
  final String _apiUrl =
      'https://budget-estimation.onrender.com/api/estimate'; // Replace with your Render URL
  bool _isLoading = false;
  String? _estimationResult;

  // Store the estimated budget value for validation
  double? _estimatedBudgetValue;

  // Flag to enable/disable budget field
  bool _isBudgetFieldEnabled = false;

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
  void initState() {
    super.initState();
    // Initialize speech-to-text
    _initSpeech();
    // Initialize text-to-speech
    _initTts();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        print('Speech error: $errorNotification');
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  // Initialize text-to-speech
  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Start listening for speech input
  void _startListening() async {
    if (_speech.isAvailable) {
      if (!_isListening) {
        setState(() {
          _isListening = true;
        });
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _descriptionController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      print('Speech recognition not available');
    }
  }

  // Stop listening for speech input
  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  // Speak text using text-to-speech
  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  // Get AI budget estimation from the server
  Future<void> _getBudgetEstimation() async {
    // Remove the validation check that requires budget to be entered first
    // Just verify other required fields are filled
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _estimationResult = null;
        _estimatedBudgetValue = null; // Reset estimated budget value
        _isBudgetFieldEnabled = false; // Disable budget field while loading
        _budgetController.text = ''; // Clear previous budget
      });

      try {
        // Prepare request data
        Map<String, dynamic> data = {
          'task_title': _titleController.text,
          'category': selectedCategory == 'Other' &&
                  _otherCategoryController.text.isNotEmpty
              ? _otherCategoryController.text
              : selectedCategory,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'date':
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          'time': _selectedTime.format(context),
        };

        // Make API call
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          setState(() {
            _estimationResult = result['estimate'];
            _isLoading = false;
          });

          // Auto-fill budget field with the estimated amount
          if (_estimationResult != null) {
            // Modified regex to capture budget with optional commas
            final RegExp regExp =
                RegExp(r'ESTIMATED BUDGET: ₹([\d,]+(\.\d+)?)');
            final match = regExp.firstMatch(_estimationResult!);
            if (match != null && match.groupCount >= 1) {
              // Extract budget string and remove commas before parsing
              final String budgetString = match.group(1)!;
              final String budgetWithoutCommas =
                  budgetString.replaceAll(',', '');

              // Parse the clean string to double
              _estimatedBudgetValue = double.tryParse(budgetWithoutCommas);

              // Set the budget controller text with the clean number (no commas)
              if (_estimatedBudgetValue != null) {
                _budgetController.text = _estimatedBudgetValue!.toString();

                // Enable budget field after estimation
                setState(() {
                  _isBudgetFieldEnabled = true;
                });
              }
            }

            // Speak the estimation result
            _speakText(_estimationResult!);
          }
        } else {
          setState(() {
            _estimationResult = 'Error: Could not get estimation';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _estimationResult = 'Error: $e';
          _isLoading = false;
        });
      }
    } else {
      // Show validation error if required fields are missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the required fields first'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _otherCategoryController.dispose();
    _flutterTts.stop();
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
        title: const Text(
          'Create New Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                              duration: const Duration(milliseconds: 200),
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
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor.withOpacity(0.2)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      category['emoji'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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

                    // Task Description with voice input
                    _buildSectionTitle('Description'),
                    Stack(
                      children: [
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
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              if (_isListening) {
                                _stopListening();
                              } else {
                                _startListening();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? primaryColor
                                    : primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color:
                                    _isListening ? Colors.white : primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
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

                    // Get AI Estimation Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getBudgetEstimation,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 20),
                        label: Text(
                          _isLoading
                              ? 'Estimating...'
                              : 'Get AI Budget Estimate',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: fieldSpacing),

                    // AI Estimation Result
                    if (_estimationResult != null) ...[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: fieldSpacing),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: primaryColor, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Budget Estimation',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.volume_up,
                                    color: primaryColor.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _speakText(_estimationResult!),
                                ),
                              ],
                            ),
                            Divider(color: primaryColor.withOpacity(0.2)),
                            Text(
                              _estimationResult!,
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Budget with validation against estimated budget
                    _buildSectionTitle('Budget'),
                    _buildTextFormField(
                        controller: _budgetController,
                        hintText: 'Your budget',
                        prefixIcon: Icons.attach_money,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        isEnabled: _isBudgetFieldEnabled,
                        validator: (value) {
                          if (_isBudgetFieldEnabled &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter your budget';
                          }

                          if (value != null && value.isNotEmpty) {
                            final double? enteredValue = double.tryParse(value);
                            if (enteredValue == null) {
                              return 'Please enter a valid amount';
                            }

                            // Check if the entered value is less than the estimated budget
                            if (_estimatedBudgetValue != null &&
                                enteredValue < _estimatedBudgetValue!) {
                              return 'Budget cannot be less than the estimated amount (₹${_estimatedBudgetValue!.toStringAsFixed(2)})';
                            }
                          }

                          return null;
                        }),

                    // Show a note about minimum budget when estimation is available
                    if (_estimatedBudgetValue != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          _isBudgetFieldEnabled
                              ? 'Note: Your budget must be ₹${_estimatedBudgetValue!.toStringAsFixed(2)} or higher'
                              : 'Get AI estimation first to enable budget entry',
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.8),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    if (!_isBudgetFieldEnabled && _estimatedBudgetValue == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          'Get AI estimation first to enable budget entry',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Extra space at the bottom to ensure scrollability
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),

              // Fixed Post Task button at the bottom
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                      offset: const Offset(0, -4),
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
                          // Get the category name
                          String categoryName = selectedCategory;
                          if (selectedCategory == 'Other' &&
                              _otherCategoryController.text.isNotEmpty) {
                            categoryName = _otherCategoryController.text;
                          }

                          // First navigate to receipt page
                          if (_isBudgetFieldEnabled &&
                              _estimatedBudgetValue != null) {
                            // Create task data to pass to receipt page
                            final taskData = {
                              'title': _titleController.text,
                              'category': categoryName,
                              'description': _descriptionController.text,
                              'location': _locationController.text,
                              'date':
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              'time': _selectedTime.format(context),
                              'estimatedBudget': _estimatedBudgetValue,
                              'finalBudget':
                                  double.tryParse(_budgetController.text) ??
                                      _estimatedBudgetValue,
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskReceiptPage(taskData: taskData),
                              ),
                            );
                          } else {
                            // Show error if budget estimation hasn't been done
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please get AI budget estimation first'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
                      child: const Row(
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
    bool isEnabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isEnabled ? cardColor : cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        enabled: isEnabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: secondaryTextColor),
          filled: false,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: isEnabled
                      ? primaryColor.withOpacity(0.7)
                      : secondaryTextColor,
                  size: 20)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: secondaryTextColor.withOpacity(0.3), width: 1),
          ),
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
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  color: primaryColor.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(color: textColor),
              ),
              const Spacer(),
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
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.access_time,
                  color: primaryColor.withOpacity(0.7), size: 20),
              const SizedBox(width: 10),
              Text(
                _selectedTime.format(context),
                style: TextStyle(color: textColor),
              ),
              const Spacer(),
              Icon(Icons.arrow_drop_down, color: secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get icon for selected category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Moving':
        return Icons.local_shipping;
      case 'Assembly':
        return Icons.build;
      case 'Delivery':
        return Icons.local_shipping;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Plumbing':
        return Icons.plumbing;
      case 'Gardening':
        return Icons.yard;
      default:
        return Icons.miscellaneous_services;
    }
  }

  // Helper function to get color for selected category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cleaning':
        return Colors.blue;
      case 'Moving':
        return Colors.amber;
      case 'Assembly':
        return Colors.purple;
      case 'Delivery':
        return Colors.orange;
      case 'Electrical':
        return Colors.yellow;
      case 'Plumbing':
        return Colors.cyan;
      case 'Gardening':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Receipt Preview Page
