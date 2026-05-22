class BusPosition {
  final String timestamp;

  final int timeUnix;

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

      timeUnix: int.parse(json['time_unix'].toString()),

      latitude: double.parse(json['lat'].toString()),

      longitude: double.parse(json['lon'].toString()),

      speed: double.parse(json['vel'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'time_unix': timeUnix.toString(),
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'vel': speed.toString(),
    };
  }
}
