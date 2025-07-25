import 'package:dynamic_height_list_view/dynamic_height_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen>
    with SingleTickerProviderStateMixin {
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  );
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Auto-scroll banners
    _autoScrollBanners();
  }

  void _autoScrollBanners() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_bannerController.hasClients) {
        final nextPage = (_bannerController.page!.round() + 1) % 6;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _autoScrollBanners();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Animated Header
                  _buildAnimatedHeader(context),

                  Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenSize.height * 0.01),
                        _buildSectionTitle('Services:', screenSize),
                        SizedBox(height: screenSize.height * 0.01),
                        serviceBuilder(context, screenSize),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildAnimatedOfferBanner(screenSize),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildSectionTitle('Shortcuts:', screenSize),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildAnimatedShortcuts(screenSize),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildAnimatedBanners(screenSize, isPortrait),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildSectionTitle(
                          'Popular Restaurants nearby',
                          screenSize,
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildAnimatedRestaurants(screenSize),
                        SizedBox(height: screenSize.height * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section Title Builder
  Widget _buildSectionTitle(String text, Size screenSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: screenSize.width * 0.06,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // Animated Header
  Widget _buildAnimatedHeader(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: screenSize.height * 0.25,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8900FE), Color(0xFFFFDE59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Deliver to',
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              'AL Satwa, 81A Street',
              style: TextStyle(
                fontSize: screenSize.width * 0.04,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Row(
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: screenSize.width * 0.07,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Text('Hi !'),
                ),
                const Spacer(),
                AnimatedRotation(
                  duration: const Duration(seconds: 2),
                  turns: 1,
                  child: CircleAvatar(
                    radius: screenSize.width * 0.07,
                    backgroundImage: const AssetImage(
                      'assets/splash_screen/nawel.png',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Services Builder
  Widget serviceBuilder(BuildContext context, Size screenSize) {
    final items = [
      {'image': 'assets/home/food.png', 'badge': 'Up to 50%', 'text': 'Food'},
      {
        'image': 'assets/home/health.png',
        'badge': '20 mins',
        'text': 'Health & wellness',
      },
      {
        'image': 'assets/home/groceries.png',
        'badge': '15 mins',
        'text': 'Groceries',
      },
    ];

    return DynamicHeightListView(
      items: List.generate(items.length, (index) => index),

      scrollDirection: ScrollDirection.horizontal,

      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenSize.width * 0.25,
              height: screenSize.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  item['image']!,
                  width: screenSize.width * 0.25,
                  height: screenSize.width * 0.18,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: screenSize.height * 0.001),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.03,
                vertical: screenSize.height * 0.005,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8900FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['badge']!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: screenSize.height * 0.003),

            Text(
              item['text']!,
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  // Animated Offer Banner
  Widget _buildAnimatedOfferBanner(Size screenSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated vault with icon
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.01),
            child: SizedBox(
              width: screenSize.width * 0.15,
              height: screenSize.width * 0.15,
              child: Stack(
                children: [
                  // Vault with bounce animation
                  AnimatedRotation(
                    duration: const Duration(seconds: 2),
                    turns: 0.05,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/home/Security Vault.png',
                        width: screenSize.width * 0.15,
                        height: screenSize.width * 0.15,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Icon with pulse animation
                  Positioned(
                    bottom: screenSize.width * 0.01,
                    right: screenSize.width * 0.01,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      width: screenSize.width * 0.06,
                      height: screenSize.width * 0.06,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(screenSize.width * 0.005),
                      child: Image.asset(
                        'assets/home/nawel 5.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  child: const Text(
                    'Got a code !',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1,
                  child: Text(
                    'Add your code and save on your order',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.035,
                      color: Colors.grey.shade600,
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

  // Animated Shortcuts
  Widget _buildAnimatedShortcuts(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.12,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: 5,
        itemBuilder:
            (context, index) => AnimatedContainer(
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.elasticOut,
          width: screenSize.width * 0.18,
          height: screenSize.width * 0.18,
          margin: EdgeInsets.all(screenSize.width * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Shortcut ${index + 1}',
              style: TextStyle(
                fontSize: screenSize.width * 0.04,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Animated Banners
  Widget _buildAnimatedBanners(Size screenSize, bool isPortrait) {
    return Column(
      children: [
        SizedBox(
          height:
          isPortrait ? screenSize.height * 0.25 : screenSize.height * 0.4,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: 6,
            itemBuilder:
                (context, index) => AnimatedBuilder(
              animation: _bannerController,
              builder: (context, child) {
                double value = 1.0;
                if (_bannerController.position.haveDimensions) {
                  value = _bannerController.page! - index;
                  value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                }
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: screenSize.width * 0.9,
                margin: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/home/banner.png',
                    fit: BoxFit.cover,
                    width: screenSize.width * 0.9,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        SmoothPageIndicator(
          controller: _bannerController,
          count: 6,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            type: WormType.thin,
            dotColor: Colors.grey,
            activeDotColor: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  // Animated Restaurants
  Widget _buildAnimatedRestaurants(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.12,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: screenSize.width * 0.03),
        itemBuilder:
            (context, index) => AnimatedContainer(
          duration: Duration(milliseconds: 500 + (index * 150)),
          curve: Curves.easeInOutBack,
          width: screenSize.width * 0.25,
          margin: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.01,
            horizontal: screenSize.width * 0.04,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/home/banner.png',
              width: screenSize.width * 0.2,
              height: screenSize.width * 0.2,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}