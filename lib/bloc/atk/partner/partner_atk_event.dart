import 'package:dio/dio.dart';

abstract class PartnerAtkEvent {}

class PartnerAtkLoadRequested extends PartnerAtkEvent {}

class PartnerAtkCreateRequested extends PartnerAtkEvent {
  final String name;
  final String? description;
  final int price;
  final int stock;
  final bool isAvailable;
  final MultipartFile? photo;

  PartnerAtkCreateRequested({
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.isAvailable,
    this.photo,
  });
}

class PartnerAtkUpdateRequested extends PartnerAtkEvent {
  final String id;
  final String? name;
  final String? description;
  final int? price;
  final int? stock;
  final bool? isAvailable;
  final MultipartFile? photo;

  PartnerAtkUpdateRequested({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.isAvailable,
    this.photo,
  });
}

class PartnerAtkDeleteRequested extends PartnerAtkEvent {
  final String id;

  PartnerAtkDeleteRequested(this.id);
}
