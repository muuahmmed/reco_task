import 'package:flutter/material.dart';
import '../../cache/cache_helper.dart';
import '../../services/auth/auth_repo.dart';
import '../../services/firebase/firebase_service.dart';
import '../../services/firebase/firestore_service.dart';
import '../login/login_screen.dart';
import 'package:get_it/get_it.dart' show GetIt;

class BoardingModel {
  final String image;
  final String title;
  final String body;
  final String logo;
  BoardingModel({
    required this.image,
    required this.title,
    required this.body,
    required this.logo,
  });
}

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController boardController = PageController();
  bool isLast = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<BoardingModel> boarding = [
    BoardingModel(
      title: 'All-in-One Delivery',
      body:
          'Order groceries, medicines, and meals delivered straight to your door',
      image: 'assets/onboarding_screens/image.png',
      logo: 'assets/onboarding_screens/bg.png',
    ),
    BoardingModel(
      title: 'User-to-User Delivery',
      body: 'Send or receive items from other users quickly and easily',
      image: 'assets/onboarding_screens/image.png',
      logo: 'assets/onboarding_screens/bg.png',
    ),
    BoardingModel(
      title: 'Sales & Discounts',
      body: 'Discover exclusive sales and deals every day',
      image: 'assets/onboarding_screens/image.png',
      logo: 'assets/onboarding_screens/bg.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  void submit() {
    CacheHelper.saveData(key: 'onBoarding', value: true).then((value) {
      if (value) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    boardController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: boardController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              _animationController.reset();
              _animationController.forward();
              setState(() {
                isLast = index == boarding.length - 1;
              });
            },
            itemCount: boarding.length,
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: buildBoardingItem(boarding[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBoardingItem(BoardingModel model) => Stack(
    children: [
      // Background image with fade transition
      FadeTransition(
        opacity: _fadeAnimation,
        child: Image.asset(
          model.image,
          height: MediaQuery.of(context).size.height * 0.5,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),

      // Bottom logo with slide up animation
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutQuad,
                ),
              ),
          child: Image.asset(
            model.logo,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with slide up animation
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOutQuad,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          model.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Body text with slide up animation
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOutQuad,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          model.body,
                          style: const TextStyle(
                            color: Color(0xFF677294),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  // Get Started button with scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9004fc),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Next button with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextButton(
                      onPressed: () {
                        if (isLast) {
                          submit();
                        } else {
                          boardController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: const Text(
                        'next',
                        style: TextStyle(
                          color: Color(0xFF9004fc),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

final getIt = GetIt.instance;

void setup() {
  // Register FirebaseAuthService
  getIt.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  // Register DatabaseService
  getIt.registerLazySingleton<DatabaseService>(() => FirestoreService());

  // Register AuthRepo implementation
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      firebaseAuthService: getIt<FirebaseAuthService>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );
}
