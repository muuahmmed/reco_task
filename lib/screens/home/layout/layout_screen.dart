import 'package:dynamic_height_list_view/dynamic_height_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_states.dart';

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
                        SizedBox(height: screenSize.height * 0.0005),
                        _buildSectionTitle('Services:', screenSize),
                        SizedBox(height: screenSize.height * 0.0005),
                        serviceBuilder(context, screenSize),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildAnimatedOfferBanner(screenSize),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildAnimatedBanners(screenSize, isPortrait),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildFoodMenu(context, screenSize),
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

  // Animated Banners
  Widget _buildAnimatedBanners(Size screenSize, bool isPortrait) {
    return Column(
      children: [
        SizedBox(
          height: isPortrait
              ? screenSize.height * 0.2
              : screenSize.height * 0.4,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: 6,
            itemBuilder: (context, index) => AnimatedBuilder(
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
                  horizontal: screenSize.width * 0.0002,
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
                    fit: BoxFit.fitWidth,
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

  Widget _buildFoodMenu(BuildContext context, Size screenSize) {
    final cubit = HomeShopCubit.get(context);

    final List<Map<String, dynamic>> foodItems = [
      {
        'id': '1',
        'name': 'Margherita Pizza',
        'price': 12.99,
        'image': 'assets/home/pizza.jpg',
        'description': 'Classic pizza with tomato sauce and mozzarella',
      },
      {
        'id': '2',
        'name': 'Cheese Burger',
        'price': 8.99,
        'image': 'assets/home/food.png',
        'description': 'Juicy beef patty with cheese and veggies',
      },
      {
        'id': '3',
        'name': 'Chicken Caesar Salad',
        'price': 7.50,
        'image': 'assets/home/chicken-caesar-salad.jpg',
        'description': 'Fresh greens with grilled chicken and Caesar dressing',
      },
      {
        'id': '4',
        'name': 'Pasta Carbonara',
        'price': 11.99,
        'image': 'assets/home/pasta.jpg',
        'description': 'Creamy pasta with bacon and parmesan',
      },
    ];

    return SizedBox(
      height: screenSize.height * 0.4,
      child: DynamicHeightListView(
        scrollDirection: ScrollDirection.horizontal,
        physics: const BouncingScrollPhysics(),
        items: List.generate(foodItems.length, (index) => index),
        itemBuilder: (context, index) {
          final item = foodItems[index];
          final isFavorite = cubit.isFavorite(item);

          return Container(
            width: screenSize.width * 0.45,
            margin: EdgeInsets.only(right: screenSize.width * 0.03),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: SizedBox(
                          height: screenSize.height * 0.18,
                          width: double.infinity,
                          child: Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.fastfood, size: 40),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Text Content Section
                      Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: screenSize.height * 0.005),

                            Text(
                              item['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: screenSize.height * 0.005),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${item['price'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF8900FE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    cubit.addToCart(item);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item['name']} added to cart',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      screenSize.width * 0.02,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8900FE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: screenSize.width * 0.05,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        cubit.toggleFavorite(item);
                        cubit.emit(
                          FavoritesUpdatedState(),
                        ); // Force immediate UI update
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
