import 'package:dio/dio.dart';
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
    on<AuthUpdateProfileAndShopRequested>(_onUpdateProfileAndShopRequested);
    on<AuthUpdateAvatarRequested>(_onUpdateAvatarRequested);
    on<AuthUpdateAddressRequested>(_onUpdateAddressRequested);
    on<AuthRefreshUserRequested>(_onRefreshUserRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.login(event.email, event.password);
    await result.fold(
      (failure) async => emit(AuthFailure(failure)),
      (response) async {
        // Fetch full user data (with shop) after login
        final meResult = await _authRepository.getMe();
        meResult.fold(
          (_) => emit(AuthSuccess(user: response.user, token: response.token)),
          (user) => emit(AuthSuccess(user: user, token: response.token)),
        );
      },
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

  Future<void> _onUpdateProfileAndShopRequested(
    AuthUpdateProfileAndShopRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccess) return;

    emit(AuthUpdateLoading(user: currentState.user, token: currentState.token));

    final profileResult = await _authRepository.updateProfile(
      name: event.name,
      email: event.email,
      phone: event.phone,
    );

    await profileResult.fold(
      (failure) async {
        emit(AuthUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
      },
      (_) async {
        if (event.avatarPath != null) {
          try {
            final multipartFile = await MultipartFile.fromFile(event.avatarPath!);
            final avatarResult = await _authRepository.updateAvatar(multipartFile);
            if (avatarResult.isLeft()) {
               final failure = avatarResult.fold((l) => l, (r) => '');
               emit(AuthUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
               return; 
            }
          } catch (e) {
            emit(AuthUpdateFailure(error: e.toString(), user: currentState.user, token: currentState.token));
            return;
          }
        }

        if (currentState.user.role == 'partner') {
          final shopResult = await _authRepository.updateShop(
            shopName: event.shopName,
            shopPhone: event.shopPhone,
            shopDescription: event.shopDescription,
          );
          await shopResult.fold(
            (failure) async {
              emit(AuthUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
            },
            (_) async => await _fetchMeAndEmitSuccess(emit, currentState.token, 'Profile updated successfully'),
          );
        } else {
          await _fetchMeAndEmitSuccess(emit, currentState.token, 'Profile updated successfully');
        }
      },
    );
  }

  Future<void> _onUpdateAvatarRequested(
    AuthUpdateAvatarRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccess) return;

    emit(AuthUpdateLoading(user: currentState.user, token: currentState.token));

    final result = await _authRepository.updateAvatar(event.avatar);
    result.fold(
      (failure) => emit(AuthUpdateFailure(error: failure, user: currentState.user, token: currentState.token)),
      (user) => emit(AuthUpdateSuccess(message: 'Avatar updated successfully', user: user, token: currentState.token)),
    );
  }

  Future<void> _onUpdateAddressRequested(
    AuthUpdateAddressRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccess) return;

    emit(AuthUpdateLoading(user: currentState.user, token: currentState.token));

    if (currentState.user.role == 'partner') {
      final shopResult = await _authRepository.updateShop(shopAddress: event.address);
      await shopResult.fold(
        (failure) async {
          emit(AuthUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
        },
        (_) async => await _fetchMeAndEmitSuccess(emit, currentState.token, 'Address updated successfully'),
      );
    } else {
      // Mock for non-partner address update
      emit(AuthUpdateSuccess(message: 'Address updated successfully', user: currentState.user, token: currentState.token));
    }
  }

  Future<void> _onRefreshUserRequested(
    AuthRefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccess) return;

    final meResult = await _authRepository.getMe();
    meResult.fold(
      (failure) => null, // Just ignore or handle failure
      (user) => emit(AuthSuccess(user: user, token: currentState.token)),
    );
  }

  Future<void> _fetchMeAndEmitSuccess(Emitter<AuthState> emit, String token, String message) async {
    final meResult = await _authRepository.getMe();
    meResult.fold(
      (failure) => emit(AuthUpdateFailure(error: failure, user: (state as AuthSuccess).user, token: token)),
      (user) => emit(AuthUpdateSuccess(message: message, user: user, token: token)),
    );
  }
}
