import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../components/componets.dart';
import '../../services/auth/auth_repo.dart';
import '../login/login_screen.dart';
import '../onboarding/onboarding.dart';
import 'cubit/sign_up_cubit.dart';
import 'cubit/sign_up_states.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _formScaleAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Logo animations
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
          ),
        );

    // Form animations
    _formScaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuad),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        showToast(text: 'Passwords do not match', state: ToastStates.ERROR);
        return;
      }

      final cubit = RegisterCubit.get(context);
      cubit.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
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
      create: (BuildContext context) => RegisterCubit(getIt<AuthRepo>()),

      child: BlocConsumer(
        listener: (context, state) {
          if (state is RegisterSuccessState) {
            showToast(
              text: 'Registration successful',
              state: ToastStates.SUCCESS,
            );
            _navigateToLogin(context);
          } else if (state is RegisterErrorState) {
            showToast(text: state.error, state: ToastStates.ERROR);
          }
        },
        builder: (BuildContext context, Object? state) {
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
                          position: _logoSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
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

                    // Form with animations
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _formScaleAnimation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    // Name Field
                                    _buildAnimatedFormField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 20),

                                    // Email Field
                                    _buildAnimatedFormField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
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
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 20),

                                    // Password Field
                                    _buildAnimatedPasswordField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      obscureText: _obscurePassword,
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 20),

                                    // Confirm Password Field
                                    _buildAnimatedPasswordField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirm Password',
                                      obscureText: _obscureConfirmPassword,
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        return null;
                                      },
                                      textInputAction: TextInputAction.done,
                                    ),
                                    const SizedBox(height: 30),

                                    // Register Button with enhanced animation
                                    AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return ScaleTransition(
                                          scale: _buttonScaleAnimation,
                                          child: SizedBox(
                                            width: buttonWidth,
                                            height: 50,
                                            child: state is RegisterLoadingState
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : ElevatedButton(
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
                                                    onPressed: () {
                                                      _submitForm(context);
                                                    },
                                                    child: const Text(
                                                      'REGISTER',
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

                                    // Login Prompt with animation
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                _navigateToLogin(context),
                                            child: Text(
                                              'Already have an account?',
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

  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
      ),
    );
  }

  Widget _buildAnimatedPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onPressed,
    required String? Function(String?) validator,
    TextInputAction? textInputAction,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: primaryColor,
            ),
            onPressed: onPressed,
          ),
        ),
        validator: validator,
        textInputAction: textInputAction,
      ),
    );
  }
}
