import '../../data/models/auth/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final String token;

  ProfileLoaded({required this.user, required this.token});
}

class ProfileUpdateLoading extends ProfileLoaded {
  ProfileUpdateLoading({required super.user, required super.token});
}

class ProfileUpdateSuccess extends ProfileLoaded {
  final String message;
  ProfileUpdateSuccess({required this.message, required super.user, required super.token});
}

class ProfileUpdateFailure extends ProfileLoaded {
  final String error;
  ProfileUpdateFailure({required this.error, required super.user, required super.token});
}
