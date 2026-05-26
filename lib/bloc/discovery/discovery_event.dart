abstract class DiscoveryEvent {}

class DiscoverySearchRequested extends DiscoveryEvent {
  final double lat;
  final double lng;
  final double radius;
  final double? minRating;

  DiscoverySearchRequested({
    required this.lat,
    required this.lng,
    this.radius = 10,
    this.minRating,
  });
}

class DiscoveryRefreshRequested extends DiscoveryEvent {
  final double lat;
  final double lng;
  final double radius;
  final double? minRating;

  DiscoveryRefreshRequested({
    required this.lat,
    required this.lng,
    this.radius = 10,
    this.minRating,
  });
}
