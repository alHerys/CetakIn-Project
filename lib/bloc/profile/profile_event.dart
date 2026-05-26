abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {
  final dynamic user;
  final String token;

  ProfileLoadRequested({required this.user, required this.token});
}

class ProfileRefreshRequested extends ProfileEvent {}

class ProfileUpdateProfileAndShopRequested extends ProfileEvent {
  final String name;
  final String email;
  final String phone;
  final String? shopName;
  final String? shopPhone;
  final String? shopDescription;
  final String? avatarPath;

  ProfileUpdateProfileAndShopRequested({
    required this.name,
    required this.email,
    required this.phone,
    this.shopName,
    this.shopPhone,
    this.shopDescription,
    this.avatarPath,
  });
}

class ProfileUpdateAvatarRequested extends ProfileEvent {
  final dynamic avatar;

  ProfileUpdateAvatarRequested({required this.avatar});
}

class ProfileUpdateShopPhotoRequested extends ProfileEvent {
  final dynamic shopPhoto;

  ProfileUpdateShopPhotoRequested({required this.shopPhoto});
}

class ProfileUpdateAddressRequested extends ProfileEvent {
  final String address;
  final double? latitude;
  final double? longitude;

  ProfileUpdateAddressRequested({
    required this.address,
    this.latitude,
    this.longitude,
  });
}

class ProfileUpdateShopServicesRequested extends ProfileEvent {
  final List<String> paperSizes;
  final List<String> colorModes;
  final List<String> sides;
  final List<String> bindings;

  ProfileUpdateShopServicesRequested({
    required this.paperSizes,
    required this.colorModes,
    required this.sides,
    required this.bindings,
  });
}

class ProfileUpdateShopPricingRequested extends ProfileEvent {
  final int blackAndWhitePerPage;
  final int fullColorPerPage;
  final int doubleSideSurcharge;
  final Map<String, int> bindingPrices;

  ProfileUpdateShopPricingRequested({
    required this.blackAndWhitePerPage,
    required this.fullColorPerPage,
    required this.doubleSideSurcharge,
    required this.bindingPrices,
  });
}

class ProfileUpdateShopHoursRequested extends ProfileEvent {
  final String openTime;
  final String closeTime;
  final List<String> operatingDays;

  ProfileUpdateShopHoursRequested({
    required this.openTime,
    required this.closeTime,
    required this.operatingDays,
  });
}
