import '../../../services/entities/user_entity.dart';

abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {}

class RegisterSuccessState extends RegisterStates {
  final UserEntity userEntity;
  RegisterSuccessState({required this.userEntity});
}

class RegisterErrorState extends RegisterStates {
  final String error;
  RegisterErrorState(this.error);
}