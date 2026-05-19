import '../../data/models/auth/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  final String token;

  AuthSuccess({required this.user, required this.token});
}

class AuthUpdateLoading extends AuthSuccess {
  AuthUpdateLoading({required super.user, required super.token});
}

class AuthUpdateSuccess extends AuthSuccess {
  final String message;
  AuthUpdateSuccess({required this.message, required super.user, required super.token});
}

class AuthUpdateFailure extends AuthSuccess {
  final String error;
  AuthUpdateFailure({required this.error, required super.user, required super.token});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

class AuthLoggedOut extends AuthState {}
