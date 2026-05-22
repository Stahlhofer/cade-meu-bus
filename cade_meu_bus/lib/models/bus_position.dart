class BusPosition {
  final String timestamp;
  final String timeUnix;
  final double latitude;
  final double longitude;
  final double speed;

  BusPosition({
    required this.timestamp,
    required this.timeUnix,
    required this.latitude,
    required this.longitude,
    required this.speed,
  });

  factory BusPosition.fromJson(Map<String, dynamic> json) {
    return BusPosition(
      timestamp: json['timestamp'],
      timeUnix: json['time_unix'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      speed: double.parse(json['vel']),
    );
  }
}
