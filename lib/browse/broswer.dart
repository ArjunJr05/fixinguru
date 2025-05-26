import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  bool isStarred = false;
  bool isApplicationSubmitted = false;

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;

    if (isApplicationSubmitted) {
      return _buildApplicationSubmittedScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isStarred ? Icons.star : Icons.star_border,
              color: isStarred ? Colors.amber : Colors.grey.shade400,
            ),
            onPressed: () {
              setState(() {
                isStarred = !isStarred;
                // Show a subtle feedback
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isStarred
                        ? "Added to favorites"
                        : "Removed from favorites"),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.grey.shade400),
            onPressed: _shareViaWhatsApp,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Color(0xFF121212),
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Icon and Title Section with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                widget.task["icon"] ?? "📋",
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task["title"] ?? "Task Title",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        constraints.maxWidth > 360 ? 20 : 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildChip(
                                      widget.task["time"] ?? "No time",
                                      Colors.green.withOpacity(0.2),
                                      Colors.green,
                                      Icons.access_time_filled_rounded,
                                    ),
                                    _buildChip(
                                      widget.task["category"] ??
                                          "Uncategorized",
                                      Colors.grey.shade800.withOpacity(0.5),
                                      Colors.white,
                                      Icons.category_rounded,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Cards Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            "Location",
                            _extractLocation(widget.task["description"] ?? ""),
                            Icons.location_on_rounded,
                            Colors.blue.withOpacity(0.2),
                            constraints,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            "When",
                            _extractTime(widget.task["description"] ?? ""),
                            Icons.access_time_rounded,
                            Colors.amber.withOpacity(0.2),
                            constraints,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description Section
                    _buildSectionTitle("Task Description"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.shade800, width: 0.5),
                      ),
                      child: Text(
                        "I need ${widget.task["title"]?.toLowerCase() ?? "assistance"}. ${_generateDetailedDescription(widget.task)}",
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: constraints.maxWidth > 360 ? 16 : 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Skills Required Section
                    _buildSectionTitle("Skills Required"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.shade800, width: 0.5),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _generateSkillsRequired(widget.task).map((skill) {
                          return _buildSkillChip(skill);
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Budget Section
                    _buildSectionTitle("Budget"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A1A1A),
                            Color(0xFF222222),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Amount",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "RM ${_generateBudget(widget.task)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      constraints.maxWidth > 360 ? 20 : 18,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.sync_alt,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Negotiable",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.grey.shade800, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                isApplicationSubmitted = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: Colors.green.withOpacity(0.3),
            ),
            child: const Text(
              "Apply Now",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
      String label, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF222222), Color(0xFF2D2D2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
          const SizedBox(width: 6),
          Text(
            skill,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon,
      Color iconBgColor, BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: constraints.maxWidth > 360 ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationSubmittedScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation container
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 70,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Application Submitted!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800, width: 0.5),
                  ),
                  child: Text(
                    "Your application for '${widget.task["title"] ?? "this task"}' has been successfully submitted. The task poster will review your application and contact you soon.",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 8,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Back to Browse",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Share via WhatsApp
  void _shareViaWhatsApp() async {
    final String text =
        "Check out this task: ${widget.task["title"] ?? "Task"} - ${_extractLocation(widget.task["description"] ?? "")}";

    try {
      await Share.share(text, subject: "Task Share");
      HapticFeedback.lightImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Could not share the task"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Helper methods to extract and generate data (unchanged)
  String _extractLocation(String description) {
    final parts = description.split('|');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return "Location not specified";
  }

  String _extractTime(String description) {
    final parts = description.split('|');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return "Time not specified";
  }

  String _generateDetailedDescription(Map<String, dynamic> task) {
    String category = task["category"] ?? "";

    switch (category) {
      case "Transport & Removals":
        return "I'm planning to relocate and need assistance with moving my belongings. I have furniture, several boxes of personal items, and some appliances. I need someone with a truck or van who can help with loading, transportation, and unloading at the new location.";
      case "Cleaning":
        return "I need a thorough cleaning of my house before guests arrive. This includes vacuuming, mopping, bathroom cleaning, kitchen cleaning, and dusting. The house is approximately 1,500 sq ft with 3 bedrooms and 2 bathrooms.";
      case "Plumbing":
        return "I have a leaking faucet and a slow drain in my bathroom. The leak has been ongoing for a few days and seems to be getting worse. I need an experienced plumber who can diagnose and fix these issues efficiently.";
      case "Painting":
        return "My apartment walls need repainting as they're showing signs of wear and tear. It's a 2-bedroom apartment with an open living/dining area. I'd prefer neutral colors and would like to discuss options with an experienced painter.";
      case "Home Repair":
        return "My air conditioner isn't cooling properly and makes a strange noise when running. It's a split unit installed about 3 years ago. I need someone to diagnose the issue, perform necessary maintenance, and ensure it's running efficiently.";
      default:
        return "I need assistance with this task and am looking for experienced professionals who can help me complete it efficiently.";
    }
  }

  List<String> _generateSkillsRequired(Map<String, dynamic> task) {
    String category = task["category"] ?? "";

    switch (category) {
      case "Transport & Removals":
        return [
          "Driving License",
          "Van/Truck",
          "Heavy Lifting",
          "Organization"
        ];
      case "Cleaning":
        return [
          "Deep Cleaning",
          "Appliance Cleaning",
          "Bathroom Cleaning",
          "Organization"
        ];
      case "Plumbing":
        return [
          "Pipe Repair",
          "Drain Cleaning",
          "Fixture Installation",
          "Leak Detection"
        ];
      case "Painting":
        return [
          "Wall Preparation",
          "Color Matching",
          "Precision Painting",
          "Clean Finish"
        ];
      case "Home Repair":
        return [
          "AC Repair",
          "Electrical Knowledge",
          "Troubleshooting",
          "Maintenance"
        ];
      default:
        return ["Reliability", "Communication", "Problem Solving"];
    }
  }

  String _generateBudget(Map<String, dynamic> task) {
    String category = task["category"] ?? "";

    switch (category) {
      case "Transport & Removals":
        return "350 - 500";
      case "Cleaning":
        return "150 - 250";
      case "Plumbing":
        return "200 - 300";
      case "Painting":
        return "500 - 800";
      case "Home Repair":
        return "250 - 400";
      default:
        return "200 - 350";
    }
  }
}
