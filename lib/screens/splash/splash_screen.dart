import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../cache/cache_helper.dart';
import '../home/main_home/main_home_screen.dart';
import '../login/login_screen.dart';
import '../onboarding/onboarding.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash duration

    final currentUser = FirebaseAuth.instance.currentUser;
    final onBoarding = CacheHelper.getData(key: 'onBoarding') ?? false;

    Widget nextScreen;

    if (currentUser != null && onBoarding) {
      nextScreen = const MainHomeScreen();
    } else if (onBoarding) {
      nextScreen = const LoginScreen();
    } else {
      nextScreen = const OnBoardingScreen();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Right-positioned ellipse (flipped horizontally)
          Positioned(
            left: size.width * 0.1, // 5% from left
            top: size.height * 0.23, // 25% from top
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(pi), // Horizontal flip
                child: Image.asset(
                  'assets/splash_screen/Ellipse 153.png',
                  width: 330,
                  height: 335,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Centered main logo with animations
          Positioned(
            left: size.width * 0.05, // 5% from left
            top: size.height * 0.25, // 25% from top
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/splash_screen/nawel.png',
                    width: 335,
                    height: 335,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
