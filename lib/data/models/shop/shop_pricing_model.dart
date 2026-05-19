class ShopPricingModel {
  final String? id;
  final String? shopId;
  final int? blackAndWhitePerPage;
  final int? fullColorPerPage;
  final int? doubleSideSurcharge;
  final Map<String, dynamic>? bindingPrices;
  final DateTime? updatedAt;

  ShopPricingModel({
    this.id,
    this.shopId,
    this.blackAndWhitePerPage,
    this.fullColorPerPage,
    this.doubleSideSurcharge,
    this.bindingPrices,
    this.updatedAt,
  });

  factory ShopPricingModel.fromJson(Map<String, dynamic> json) {
    return ShopPricingModel(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String?,
      blackAndWhitePerPage: json['black_and_white_per_page'] as int?,
      fullColorPerPage: json['full_color_per_page'] as int?,
      doubleSideSurcharge: json['double_side_surcharge'] as int?,
      bindingPrices: json['binding_prices'] as Map<String, dynamic>?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'black_and_white_per_page': blackAndWhitePerPage,
      'full_color_per_page': fullColorPerPage,
      'double_side_surcharge': doubleSideSurcharge,
      'binding_prices': bindingPrices,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
