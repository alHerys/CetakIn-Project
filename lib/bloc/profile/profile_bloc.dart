import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
    on<ProfileUpdateProfileAndShopRequested>(_onUpdateProfileAndShopRequested);
    on<ProfileUpdateAvatarRequested>(_onUpdateAvatarRequested);
    on<ProfileUpdateShopPhotoRequested>(_onUpdateShopPhotoRequested);
    on<ProfileUpdateAddressRequested>(_onUpdateAddressRequested);
    on<ProfileUpdateShopServicesRequested>(_onUpdateShopServicesRequested);
    on<ProfileUpdateShopPricingRequested>(_onUpdateShopPricingRequested);
    on<ProfileUpdateShopHoursRequested>(_onUpdateShopHoursRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final user = event.user as UserModel;
    final token = event.token;

    // If partner, fetch shop data
    if (user.role == 'partner') {
      final shopResult = await _profileRepository.getMyShop();
      shopResult.fold(
        (_) => emit(ProfileLoaded(user: user, token: token)),
        (shop) => emit(ProfileLoaded(user: user.copyWith(shop: shop), token: token)),
      );
    } else {
      emit(ProfileLoaded(user: user, token: token));
    }
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final meResult = await _profileRepository.getMe();
    await meResult.fold(
      (failure) async => null,
      (user) async {
        if (user.role == 'partner') {
          final shopResult = await _profileRepository.getMyShop();
          shopResult.fold(
            (_) => emit(ProfileLoaded(user: user, token: currentState.token)),
            (shop) => emit(ProfileLoaded(user: user.copyWith(shop: shop), token: currentState.token)),
          );
        } else {
          emit(ProfileLoaded(user: user, token: currentState.token));
        }
      },
    );
  }

  Future<void> _onUpdateProfileAndShopRequested(
    ProfileUpdateProfileAndShopRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    final profileResult = await _profileRepository.updateProfile(
      name: event.name,
      email: event.email,
      phone: event.phone,
    );

    await profileResult.fold(
      (failure) async {
        emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
      },
      (_) async {
        if (event.avatarPath != null) {
          try {
            final multipartFile = await MultipartFile.fromFile(event.avatarPath!);
            final avatarResult = await _profileRepository.updateAvatar(multipartFile);
            if (avatarResult.isLeft()) {
               final failure = avatarResult.fold((l) => l, (r) => '');
               emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
               return;
            }
          } catch (e) {
            emit(ProfileUpdateFailure(error: e.toString(), user: currentState.user, token: currentState.token));
            return;
          }
        }

        if (currentState.user.role == 'partner') {
          final shopResult = await _profileRepository.updateShop(
            shopName: event.shopName,
            shopPhone: event.shopPhone,
            shopDescription: event.shopDescription,
          );
          await shopResult.fold(
            (failure) async {
              emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
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
    ProfileUpdateAvatarRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    final result = await _profileRepository.updateAvatar(event.avatar);
    result.fold(
      (failure) => emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token)),
      (user) => emit(ProfileUpdateSuccess(message: 'Avatar updated successfully', user: user, token: currentState.token)),
    );
  }

  Future<void> _onUpdateShopPhotoRequested(
    ProfileUpdateShopPhotoRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    final result = await _profileRepository.updateShop(shopPhoto: event.shopPhoto);
    await result.fold(
      (failure) async {
        emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
      },
      (_) async {
        await _fetchMeAndEmitSuccess(emit, currentState.token, 'Shop photo updated successfully');
      },
    );
  }

  Future<void> _onUpdateAddressRequested(
    ProfileUpdateAddressRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    if (currentState.user.role == 'partner') {
      final shopResult = await _profileRepository.updateShop(
        shopAddress: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      await shopResult.fold(
        (failure) async {
          emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
        },
        (_) async => await _fetchMeAndEmitSuccess(emit, currentState.token, 'Address updated successfully'),
      );
    } else {
      // Mock for non-partner address update
      emit(ProfileUpdateSuccess(message: 'Address updated successfully', user: currentState.user, token: currentState.token));
    }
  }

  Future<void> _onUpdateShopServicesRequested(
    ProfileUpdateShopServicesRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    final result = await _profileRepository.updateShopServices(
      paperSizes: event.paperSizes,
      colorModes: event.colorModes,
      sides: event.sides,
      bindings: event.bindings,
    );

    await result.fold(
      (failure) async {
        emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
      },
      (_) async {
        await _fetchMeAndEmitSuccess(emit, currentState.token, 'Shop services updated successfully');
      },
    );
  }

  Future<void> _onUpdateShopPricingRequested(
    ProfileUpdateShopPricingRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    final result = await _profileRepository.updateShopPricing(
      blackAndWhitePerPage: event.blackAndWhitePerPage,
      fullColorPerPage: event.fullColorPerPage,
      doubleSideSurcharge: event.doubleSideSurcharge,
      bindingPrices: event.bindingPrices,
    );

    await result.fold(
      (failure) async {
        emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
      },
      (_) async {
        await _fetchMeAndEmitSuccess(emit, currentState.token, 'Shop pricing updated successfully');
      },
    );
  }

  Future<void> _fetchMeAndEmitSuccess(Emitter<ProfileState> emit, String token, String message) async {
    final meResult = await _profileRepository.getMe();
    await meResult.fold(
      (failure) async => emit(ProfileUpdateFailure(error: failure, user: (state as ProfileLoaded).user, token: token)),
      (user) async {
        if (user.role == 'partner') {
          final shopResult = await _profileRepository.getMyShop();
          shopResult.fold(
            (_) => emit(ProfileUpdateSuccess(message: message, user: user, token: token)),
            (shop) => emit(ProfileUpdateSuccess(message: message, user: user.copyWith(shop: shop), token: token)),
          );
        } else {
          emit(ProfileUpdateSuccess(message: message, user: user, token: token));
        }
      },
    );
  }

  Future<void> _onUpdateShopHoursRequested(
    ProfileUpdateShopHoursRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdateLoading(user: currentState.user, token: currentState.token));

    final result = await _profileRepository.updateShop(
      openTime: event.openTime,
      closeTime: event.closeTime,
      operatingDays: event.operatingDays,
    );

    await result.fold(
      (failure) async {
        emit(ProfileUpdateFailure(error: failure, user: currentState.user, token: currentState.token));
      },
      (_) async {
        await _fetchMeAndEmitSuccess(emit, currentState.token, 'Shop hours updated successfully');
      },
    );
  }
}
