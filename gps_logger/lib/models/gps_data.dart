import 'package:intl/intl.dart';

class GPSPoint {
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;

  GPSPoint({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'timestamp': DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(timestamp),
      'unix_timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory GPSPoint.fromJson(Map<String, dynamic> json) {
    return GPSPoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      speed: json['speed'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['unix_timestamp'] as int,
      ),
    );
  }
}

class GPSSession {
  final String sessionId;
  final DateTime startTime;
  DateTime? endTime;
  final List<GPSPoint> points;

  GPSSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    List<GPSPoint>? points,
  }) : points = points ?? [];

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'start_time': DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(startTime),
      'end_time': endTime != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime!)
          : null,
      'points_count': points.length,
      'points': points.map((p) => p.toJson()).toList(),
    };
  }

  factory GPSSession.fromJson(Map<String, dynamic> json) {
    print(json['end_time']);
    return GPSSession(
      sessionId: json['session_id'] as String,
      startTime:
          DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).tryParse(json['start_time']) ??
          DateTime.now(),
      endTime: null,

      // endTime:
      //     DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(json['end_time'])
      points: (json['points'] as List)
          .map((p) => GPSPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
