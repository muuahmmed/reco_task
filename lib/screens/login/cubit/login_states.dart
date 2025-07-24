
import '../../../services/entities/user_entity.dart';

abstract class ShopLoginStates {
  const ShopLoginStates();
}

class ShopLoginInitialState extends ShopLoginStates {
  const ShopLoginInitialState();
}

class ShopLoginLoadingState extends ShopLoginStates {
  const ShopLoginLoadingState();
}

class ShopLoginSuccessState extends ShopLoginStates {
  final UserEntity user;
  final bool isGoogleSignIn;
  final bool rememberMe;

  const ShopLoginSuccessState({
    required this.user,
    this.isGoogleSignIn = false,
    this.rememberMe = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShopLoginSuccessState &&
              runtimeType == other.runtimeType &&
              user == other.user &&
              isGoogleSignIn == other.isGoogleSignIn &&
              rememberMe == other.rememberMe;

  @override
  int get hashCode =>
      user.hashCode ^ isGoogleSignIn.hashCode ^ rememberMe.hashCode;
}

class ShopLoginErrorState extends ShopLoginStates {
  final String error;
  final StackTrace? stackTrace;

  const ShopLoginErrorState(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShopLoginErrorState &&
              runtimeType == other.runtimeType &&
              error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class ShopForgotPasswordLoadingState extends ShopLoginStates {
  const ShopForgotPasswordLoadingState();
}

class ShopForgotPasswordSuccessState extends ShopLoginStates {
  final String email;

  const ShopForgotPasswordSuccessState(this.email);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShopForgotPasswordSuccessState &&
              runtimeType == other.runtimeType &&
              email == other.email;

  @override
  int get hashCode => email.hashCode;
}

class ShopForgotPasswordErrorState extends ShopLoginStates {
  final String error;
  final StackTrace? stackTrace;

  const ShopForgotPasswordErrorState(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShopForgotPasswordErrorState &&
              runtimeType == other.runtimeType &&
              error == other.error;

  @override
  int get hashCode => error.hashCode;
}