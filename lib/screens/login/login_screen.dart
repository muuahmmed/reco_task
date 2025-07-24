import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reco_test/screens/home/main_home/main_home_screen.dart';
import 'package:reco_test/screens/login/cubit/login_cubit.dart';
import 'package:reco_test/screens/login/cubit/login_states.dart';
import '../../components/componets.dart';
import '../../services/auth/auth_repo.dart';
import '../onboarding/onboarding.dart';
import '../sign_up/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _buttonScaleAnimation;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo animations
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Form animations
    _formSlideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuad),
      ),
    );

    // Button animation
    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final cubit = ShopLoginCubit.get(context);
      cubit.userLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        rememberMe: true,
      );
    }
  }


  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    final primaryColor = theme.primaryColor;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return BlocProvider(

      create: (context) => ShopLoginCubit(getIt<AuthRepo>()),
      child: BlocConsumer<ShopLoginCubit, ShopLoginStates>(
        listener: (context, state) {
          if (state is ShopLoginSuccessState) {
            navigateAndFinish(context, const MainHomeScreen());
            showToast(text: 'Login Successful', state: ToastStates.SUCCESS);
          } else if (state is ShopLoginErrorState) {
            showToast(text: state.error, state: ToastStates.ERROR);
          } else if (state is ShopForgotPasswordSuccessState) {
            showToast(
              text: 'Password reset sent to ${state.email}',
              state: ToastStates.SUCCESS,
            );
            Navigator.pop(context);
          } else if (state is ShopForgotPasswordErrorState) {
            showToast(text: state.error, state: ToastStates.ERROR);
          }
        },
        builder: (BuildContext context, ShopLoginStates state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo with combined animations
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: SizedBox(
                                height:
                                MediaQuery.of(context).size.height * 0.35,
                                child: Image.asset(
                                  'assets/splash_screen/nawel.png',
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Form with slide up animation
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _formSlideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                children: [
                                  // Email field with animation
                                  ScaleTransition(
                                    scale: _buttonScaleAnimation,
                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: primaryColor,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(
                                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Password field with animation
                                  ScaleTransition(
                                    scale: _buttonScaleAnimation,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: primaryColor,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                              !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Forgot Password?',
                                                ),
                                                content: const Text(
                                                  'Enter your email to reset your password.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      final email =
                                                      _emailController.text
                                                          .trim();
                                                      if (email.isEmpty) {
                                                        showToast(
                                                          text:
                                                          'Please enter your email',
                                                          state:
                                                          ToastStates.ERROR,
                                                        );
                                                        return;
                                                      }
                                                      ShopLoginCubit.get(context).sendPasswordResetEmail(email);
                                                    },
                                                    child: const Text('Send'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Login Button with enhanced animation
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return ScaleTransition(
                                        scale: _buttonScaleAnimation,
                                        child: SizedBox(
                                          width: buttonWidth,
                                          height: 50,
                                          child:
                                          state is ShopLoginLoadingState
                                              ? const Center(
                                            child:
                                            CircularProgressIndicator(),
                                          )
                                              :
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              primaryColor,
                                              foregroundColor:
                                              onPrimaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                  10,
                                                ),
                                              ),
                                              elevation: 4,
                                              shadowColor: primaryColor,
                                            ),
                                            onPressed:
                                                (){
                                              _submitForm(
                                                context,
                                              );
                                            },
                                            child: const Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 30),

                                  // Register button with animation
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                              _navigateToRegister(context),
                                          child: Text(
                                            'Create an account',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}