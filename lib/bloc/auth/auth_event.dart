abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phone;

  AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
  });
}

class AuthRegisterPartnerRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phone;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String openTime;
  final String closeTime;
  final List<String> operatingDays;
  final dynamic shopPhoto;

  AuthRegisterPartnerRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    required this.openTime,
    required this.closeTime,
    required this.operatingDays,
    this.shopPhoto,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateProfileAndShopRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String? shopName;
  final String? shopPhone;
  final String? shopDescription;
  final String? avatarPath;

  AuthUpdateProfileAndShopRequested({
    required this.name,
    required this.email,
    required this.phone,
    this.shopName,
    this.shopPhone,
    this.shopDescription,
    this.avatarPath,
  });
}

class AuthUpdateAvatarRequested extends AuthEvent {
  final dynamic avatar;

  AuthUpdateAvatarRequested({required this.avatar});
}

class AuthUpdateAddressRequested extends AuthEvent {
  final String address;

  AuthUpdateAddressRequested({required this.address});
}

class AuthRefreshUserRequested extends AuthEvent {}
