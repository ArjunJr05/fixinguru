import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCarouselIndex = 0;
  int _currentNavIndex = 2;

  // Changed to CarouselSliderController to match the expected type
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Carousel data
  final List<String> _carouselImages = [
    'assets/images/cart1.png',
    'assets/images/cart2.png',
    'assets/images/cart3.png',
  ];

  final List<Map<String, dynamic>> _serviceCategories = [
    {'name': 'Cooking', 'icon': Icons.restaurant},
    {'name': 'Pet care', 'icon': Icons.pets},
    {'name': 'Gardening', 'icon': Icons.yard},
    {'name': 'Transport', 'icon': Icons.local_shipping},
    {'name': 'Carpenter', 'icon': Icons.handyman},
    {'name': 'Shopping', 'icon': Icons.shopping_cart},
    {'name': 'Delivery', 'icon': Icons.delivery_dining},
    {'name': 'Package & Lifting', 'icon': Icons.card_giftcard},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Electrician', 'icon': Icons.electric_bolt},
    {'name': 'Painting', 'icon': Icons.format_paint},
    {'name': 'Repairs', 'icon': Icons.build},
    {'name': 'Ironing', 'icon': Icons.iron},
    {'name': 'Tutoring', 'icon': Icons.school},
    {'name': 'Design', 'icon': Icons.design_services},
    {'name': 'Plumbing', 'icon': Icons.plumbing},
    {'name': 'Photographer', 'icon': Icons.camera_alt},
    {'name': 'Events', 'icon': Icons.celebration},
    {'name': 'Translation', 'icon': Icons.translate},
    {'name': 'Custom', 'icon': Icons.tune},
  ];

  @override
  void initState() {
    super.initState();
    // Preload images in initState to avoid lag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (String image in _carouselImages) {
        precacheImage(AssetImage(image), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Responsive calculations
    final isSmallScreen = size.width < 360;

    // Adaptive sizing
    final baseFontSize = size.width / 28;
    final labelFontSize = max(min(baseFontSize * 0.9, 16.0), 12.0);
    final hintFontSize = max(min(baseFontSize * 0.8, 14.0), 11.0);

    // Responsive spacing
    final horizontalPadding = max(size.width * 0.05, 12.0);
    final verticalPadding = max(size.height * 0.015, 8.0);
    final spacingHeight = max(size.height * 0.02, 8.0);
    final carouselHeight = max(min(size.height * 0.22, 180.0), 120.0);
    final categoryIconSize = max(min(size.width * 0.08, 32.0), 20.0);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        children: [
          // Background with dual colors
          SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Section (Static)
                SizedBox(height: spacingHeight),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: carouselHeight,
                      viewportFraction: 0.92,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                    ),
                    carouselController: _carouselController,
                    items: _carouselImages.map((imagePath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding / 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF4AC959).withOpacity(0.7),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4AC959).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: spacingHeight * 1.5),

                // "Our Services" header (Static)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4AC959),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Our Services',
                        style: TextStyle(
                          fontSize: labelFontSize * 1.2 / textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: spacingHeight),

                // Scrollable "Our Services" Section
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 icons per row
                          childAspectRatio: isSmallScreen ? 0.7 : 0.75,
                          crossAxisSpacing: horizontalPadding / 4,
                          mainAxisSpacing: verticalPadding * 0.3,
                        ),
                        itemCount: _serviceCategories.length,
                        itemBuilder: (context, index) {
                          return _buildServiceItem(
                            context: context,
                            name: _serviceCategories[index]['name'],
                            icon: _serviceCategories[index]['icon'],
                            index: index,
                            iconSize: categoryIconSize * 0.85,
                            textSize: hintFontSize / textScaleFactor,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build service item with hover effect
  Widget _buildServiceItem({
    required BuildContext context,
    required String name,
    required IconData icon,
    required int index,
    required double iconSize,
    required double textSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4AC959).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Handle service tap
              },
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[850]!.withOpacity(0.5),
                      Colors.black,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4AC959),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Background painter for dual colors
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for dark grey area (above the line)
    final greyPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    // Paint for black area (below the line)
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Responsive curve height - works better on various screen sizes
    double curveHeight = size.height * 0.20;

    // Path for the upper grey section
    final greyPath = Path();
    greyPath.moveTo(0, 0);
    greyPath.lineTo(size.width, 0);
    greyPath.lineTo(size.width, curveHeight);

    // Create the curve that separates grey and black
    greyPath.quadraticBezierTo(
      size.width * 0.75,
      curveHeight + size.height * 0.05,
      0,
      curveHeight - size.height * 0.01,
    );

    greyPath.close();

    // Path for the lower black section
    final blackPath = Path();
    blackPath.moveTo(0, curveHeight - size.height * 0.01);
    blackPath.quadraticBezierTo(
      size.width * 0.75,
      curveHeight + size.height * 0.05,
      size.width,
      curveHeight,
    );
    blackPath.lineTo(size.width, size.height);
    blackPath.lineTo(0, size.height);
    blackPath.close();

    // Add a subtle gradient overlay for depth
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.4),
        ],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw both sections
    canvas.drawPath(greyPath, greyPaint);
    canvas.drawPath(blackPath, blackPaint);

    // Draw gradient overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );

    // Add subtle green accent line along the curve
    final accentPaint = Paint()
      ..color = const Color(0xFF4AC959).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final accentPath = Path();
    accentPath.moveTo(0, curveHeight - size.height * 0.01);
    accentPath.quadraticBezierTo(
      size.width * 0.75,
      curveHeight + size.height * 0.05,
      size.width,
      curveHeight,
    );

    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
