class ShopServiceModel {
  final String? id;
  final String? shopId;
  final List<String>? paperSizes;
  final List<String>? colorModes;
  final List<String>? sides;
  final List<String>? bindings;
  final DateTime? updatedAt;

  ShopServiceModel({
    this.id,
    this.shopId,
    this.paperSizes,
    this.colorModes,
    this.sides,
    this.bindings,
    this.updatedAt,
  });

  factory ShopServiceModel.fromJson(Map<String, dynamic> json) {
    return ShopServiceModel(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String?,
      paperSizes: json['paper_sizes'] != null
          ? List<String>.from(json['paper_sizes'])
          : null,
      colorModes: json['color_modes'] != null
          ? List<String>.from(json['color_modes'])
          : null,
      sides: json['sides'] != null ? List<String>.from(json['sides']) : null,
      bindings: json['bindings'] != null
          ? List<String>.from(json['bindings'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'paper_sizes': paperSizes,
      'color_modes': colorModes,
      'sides': sides,
      'bindings': bindings,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  List<String> get supportedPaperSizes => paperSizes ?? [];
  bool get hasColorPrint => colorModes != null && colorModes!.contains('color');
}
