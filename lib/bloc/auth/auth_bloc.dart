import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthRegisterPartnerRequested>(_onRegisterPartnerRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (response) => emit(AuthSuccess(user: response.user, token: response.token)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      phone: event.phone,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (response) => emit(AuthSuccess(user: response.user, token: response.token)),
    );
  }

  Future<void> _onRegisterPartnerRequested(
    AuthRegisterPartnerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.registerPartner(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      phone: event.phone,
      shopName: event.shopName,
      shopAddress: event.shopAddress,
      shopPhone: event.shopPhone,
      openTime: event.openTime,
      closeTime: event.closeTime,
      operatingDays: event.operatingDays,
      shopPhoto: event.shopPhoto,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (response) => emit(AuthSuccess(user: response.user, token: response.token)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.logout();
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (_) => emit(AuthLoggedOut()),
    );
  }
}
