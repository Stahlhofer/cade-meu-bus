// import 'dart:async';
// import 'dart:convert';

// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';

// import '../models/bus_data.dart';
// import '../models/bus_position.dart';

// import 'gps_service.dart';
// import 'mqtt_service.dart';
// import 'storage_service.dart';

// class SessionService {
//   final GpsService gpsService = GpsService();

//   final StorageService storageService = StorageService();

//   MqttService mqttService = MqttService();

//   Timer? timer;

//   final String busCode;

//   final String busName;

//   final String city;

//   SessionService({
//     required this.busCode,
//     required this.busName,
//     required this.city,
//   });

//   final StreamController<BusData> _positionController =
//       StreamController.broadcast();

//   Stream<BusData> get positions => _positionController.stream;

//   Future<void> start() async {
//     try {
//       await mqttService.connect();
//     } catch (e) {
//       print("FAILED START $e");
//     }

//     timer = Timer.periodic(const Duration(seconds: 10), (_) async {
//       await captureAndSend();
//     });

//     await captureAndSend();
//   }

//   Future<void> captureAndSend() async {
//     try {
//       Position position = await gpsService.getCurrentPosition();

//       final now = DateTime.now();

//       final busData = BusData(
//         busCode: busCode,

//         nome: busName,

//         city: city,

//         mqttTopic: 'cade-meu-bus/$city/$busCode',

//         position: BusPosition(
//           timestamp: DateFormat('HH:mm dd-MM-yyyy').format(now),

//           timeUnix: now.millisecondsSinceEpoch,

//           latitude: position.latitude,

//           longitude: position.longitude,

//           speed: position.speed * 3.6,
//         ),
//       );

//       _positionController.add(busData);

//       await storageService.savePosition(busData);

//       mqttService.publishJson(
//         topic: 'cade-meu-bus/$city/$busCode',
//         json: jsonEncode(busData.toJson()),
//       );

//       print("SESSION SERVICE: ${mqttService.connectionState}");
//     } catch (e) {
//       print('SESSION ERROR: $e');
//     }
//   }

//   void stop() {
//     timer?.cancel();
//   }
// }import 'dart:async';
import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../models/bus_config.dart';
import '../models/bus_data.dart';
import '../models/bus_position.dart';

import 'config_storage_service.dart';
import 'gps_service.dart';
import 'mqtt_service.dart';
import 'storage_service.dart';

class SessionService {
  final GpsService gpsService = GpsService();

  final StorageService storageService = StorageService();

  final ConfigStorageService configStorageService =
      ConfigStorageService();

  final MqttService mqttService = MqttService();

  Timer? timer;

  BusConfig? config;

  final StreamController<BusData> _positionController =
      StreamController.broadcast();

  Stream<BusData> get positions => _positionController.stream;

  Future<void> start() async {
    /// CARREGA CONFIGURAÇÃO
    config = await configStorageService.loadConfig();

    if (config == null || config!.topic.isEmpty) {
      throw Exception('TOPIC NOT CONFIGURED');
    }

    await mqttService.connect();

    timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await captureAndSend();
    });

    await captureAndSend();
  }

  String get fullTopic => 'cade-meu-bus/${config!.topic}';

  String get busCode {
    final parts = config!.topic.split('/');

    return parts.isNotEmpty ? parts.last : 'unknown';
  }

  String get city {
    final parts = config!.topic.split('/');

    return parts.isNotEmpty ? parts.first : 'unknown';
  }

  Future<void> captureAndSend() async {
    try {
      Position position = await gpsService.getCurrentPosition();

      final now = DateTime.now();

      final busData = BusData(
        busCode: busCode,

        nome: config!.nome,

        city: city,

        mqttTopic: fullTopic,

        position: BusPosition(
          timestamp: DateFormat('HH:mm dd-MM-yyyy').format(now),

          timeUnix: now.millisecondsSinceEpoch,

          latitude: position.latitude,

          longitude: position.longitude,

          speed: position.speed * 3.6,
        ),
      );

      /// STREAM LOCAL
      _positionController.add(busData);

      /// STORAGE
      await storageService.savePosition(busData);

      /// MQTT
      mqttService.publishJson(
        topic: fullTopic,

        json: jsonEncode(busData.toJson()),
      );

      print('PUBLISHED TO: $fullTopic');
    } catch (e) {
      print('SESSION ERROR: $e');
    }
  }

  void stop() {
    timer?.cancel();
  }
}
